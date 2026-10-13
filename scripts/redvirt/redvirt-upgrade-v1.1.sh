#!/usr/bin/env bash
# RED VIRT 7.3 -> 7.3.3: staged, single-host update with manual Engine transitions.
# v1.1 - 2026-10-13
# Manual ONLY: Engine Maintenance; reboot after PASS; Engine Activate.
set -Eeuo pipefail
export LC_ALL=C
umask 077

STAGE="${1:-}"
BASE='/root/redvirt-upgrade'
REPO='virtualization-7.3-host-updates'
LOGDIR="$BASE/logs"
CERT_WARN_DAYS=30
CERT_STOP_DAYS=7

[[ $EUID -eq 0 ]] || { echo 'STOP: run as root'; exit 1; }
mkdir -p "$LOGDIR"
LOG="$LOGDIR/${STAGE:-unknown}-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

say()  { printf '\n=== %s ===\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
stop() { printf 'STOP: %s\n' "$*" >&2; exit 1; }
trap 'printf "ERROR at line %s (stage %s): %s\n" "$LINENO" "$STAGE" "$BASH_COMMAND" >&2' ERR

DNF_OPTS=(
  --disablerepo='*'
  --enablerepo="$REPO"
  --setopt="${REPO}.skip_if_unavailable=0"
  --setopt="${REPO}.gpgcheck=1"
  --setopt='keepcache=1'
  --setopt='installonly_limit=0'
  --exclude='*libvirt*'
  --exclude='*libguestfs*'
  --exclude='*qemu*'
  --exclude='*grub2*'
  --exclude='*shim*'
  --exclude='redvirt-release'
  --exclude='*capstone*'
  --exclude='*virtiofsd*'
)

require_binary() {
  local b
  for b in "$@"; do command -v "$b" >/dev/null 2>&1 || stop "Required command missing: $b"; done
}

check_os() {
  say 'OS edition'
  [[ -r /etc/os-release ]] || stop '/etc/os-release not found'
  # shellcheck disable=SC1091
  . /etc/os-release
  printf 'OS=%s VERSION_ID=%s EDITION=%s\n' "${NAME:-?}" "${VERSION_ID:-?}" "${EDITION:-?}"
  [[ "${VERSION_ID:-}" == '7.3' ]] || stop 'This script is only for RED OS 7.3'
  [[ "${EDITION:-}" == 'Certified' ]] || stop 'Edition is not Certified: verify vendor-specific excludes before proceeding'
}

check_services() {
  local svc
  for svc in vdsmd sanlock multipathd iscsid NetworkManager; do
    systemctl is-active --quiet "$svc" || stop "Required service is not active: $svc"
  done
  echo 'Required base services: active'
}

check_no_vms() {
  say 'No running VMs'
  local vms
  vms=$(timeout 45 vdsm-client Host getVMList) || stop 'Could not query VDSM VM list'
  [[ "$(printf '%s' "$vms" | tr -d '[:space:]')" == '[]' ]] || stop "VDSM lists VM(s): $vms"
  if ps -eo comm= | grep -Eq '^qemu(-kvm|-system.*)?$'; then
    stop 'QEMU process is still running'
  fi
  echo 'VDSM [] and no QEMU processes'
}

check_no_partial_lvm() {
  local attrs
  attrs=$(vgs --noheadings -o vg_attr) || stop 'Cannot read VG attributes'
  if grep -q 'p' <<< "$attrs"; then stop 'Partial VG detected'; fi
  attrs=$(lvs -a --noheadings -o lv_attr) || stop 'Cannot read LV attributes'
  if grep -q 'p' <<< "$attrs"; then stop 'Partial LV detected'; fi
}

ipv4_state() {
  ip -o -4 addr show scope global | awk '{print $2, $4}' | sort -u
}

path_counts() {
  # Multipath -ll supports both "WWID dm-N" and "alias (WWID) dm-N" forms.
  awk '
    $2 ~ /^dm-[0-9]+$/ { key=$1; if (!(key in count)) count[key]=0; next }
    $3 ~ /^dm-[0-9]+$/ { key=$2; gsub(/[()]/,"",key); if (!(key in count)) count[key]=0; next }
    /active ready running/ { if (key != "") count[key]++ }
    END { for (k in count) print k, count[k] }
  ' | sort
}

snapshot() {
  local stage="$1" dir="$BASE/$stage"
  mkdir -p "$dir"
  date --iso-8601=seconds > "$dir/time.txt"
  hostname -f > "$dir/hostname.txt"
  uname -r > "$dir/kernel.txt"
  rpm -qa | sort > "$dir/packages.txt"
  ipv4_state > "$dir/ipv4.txt"
  ip -br address > "$dir/network.txt"
  ip -4 route > "$dir/routes.txt"
  lsblk -o NAME,KNAME,TYPE,SIZE,FSTYPE,MOUNTPOINT > "$dir/lsblk.txt"
  systemctl --failed --no-pager > "$dir/failed-services.txt" || true
  pvs -o pv_name,pv_uuid,vg_name,pv_attr > "$dir/pvs.txt" 2>&1 || true
  vgs -o vg_name,pv_count,lv_count,vg_attr > "$dir/vgs.txt" 2>&1 || true
  lvs -a -o vg_name,lv_name,lv_attr > "$dir/lvs.txt" 2>&1 || true
  multipath -ll > "$dir/multipath.txt" 2>&1 || true
  path_counts < "$dir/multipath.txt" > "$dir/path-counts.txt"
  iscsiadm -m session > "$dir/iscsi.txt" 2>&1 || true
  echo "Snapshot: $dir"
}

cert_check() {
  say 'Host certificates (expiry and validity)'
  require_binary openssl date find
  [[ -d /etc/pki/vdsm ]] || stop '/etc/pki/vdsm directory not found'
  local path subject issuer start end start_ts now count=0
  now=$(date +%s)
  while IFS= read -r path; do
    if ! openssl x509 -in "$path" -noout -enddate >/dev/null 2>&1; then continue; fi
    ((count+=1))
    subject=$(openssl x509 -in "$path" -noout -subject)
    issuer=$(openssl x509 -in "$path" -noout -issuer)
    start=$(openssl x509 -in "$path" -noout -startdate | cut -d= -f2-)
    end=$(openssl x509 -in "$path" -noout -enddate | cut -d= -f2-)
    start_ts=$(date -d "$start" +%s) || stop "Invalid cert date: $path"
    echo "CERT: $path"
    echo "  $subject"
    echo "  $issuer"
    echo "  notBefore=$start | notAfter=$end"
    (( start_ts <= now )) || stop "Certificate is not yet valid: $path"
    openssl x509 -in "$path" -noout -checkend 0 >/dev/null || stop "Certificate expired: $path"
    if ! openssl x509 -in "$path" -noout -checkend $((CERT_STOP_DAYS*86400)) >/dev/null; then
      stop "Certificate expires within $CERT_STOP_DAYS days: $path"
    fi
    if ! openssl x509 -in "$path" -noout -checkend $((CERT_WARN_DAYS*86400)) >/dev/null; then
      warn "Certificate expires within $CERT_WARN_DAYS days: $path"
    fi
  done < <(find /etc/pki/vdsm \( -type f -o -type l \) -name '*.pem' | sort)
  (( count >= 1 )) || stop 'Could not find valid certificate PEM files under /etc/pki/vdsm'
  [[ -f /etc/pki/vdsm/certs/vdsmcert.pem ]] || stop 'VDSM host certificate not found'
  [[ -s /etc/pki/vdsm/certs/cacert.pem ]] || stop 'VDSM CA certificate not found'
  openssl verify -CAfile /etc/pki/vdsm/certs/cacert.pem \
    /etc/pki/vdsm/certs/vdsmcert.pem || stop 'VDSM certificate fails validation against the host CA'
  echo 'VDSM certificate chain: verified against host CA'
  echo "Certificate files checked: $count"
  echo 'NOTE: no certificate renewal or PKI enrollment is performed.'
}

check_repo_config() {
  say 'DNF repository config and GPG'
  local files repo_file baseurl gpgcheck gpgkey keypath
  mapfile -t files < <(grep -Rl -F "[$REPO]" /etc/yum.repos.d --include='*.repo' || true)
  (( ${#files[@]} == 1 )) || stop "Expected exactly 1 repo config file for $REPO; found ${#files[@]}"
  repo_file="${files[0]}"
  echo "Repo config: $repo_file"
  # Obtain values only from the corresponding INI section.
  baseurl=$(awk -v section="[$REPO]" '
    /^\[/ { inside=($0==section) }
    inside && /^[[:space:]]*baseurl[[:space:]]*=/ { sub(/^[^=]*=/,""); gsub(/^[[:space:]]+|[[:space:]]+$/,""); print; exit }
  ' "$repo_file")
  gpgcheck=$(awk -v section="[$REPO]" '
    /^\[/ { inside=($0==section) }
    inside && /^[[:space:]]*gpgcheck[[:space:]]*=/ { sub(/^[^=]*=/,""); gsub(/[[:space:]]/,""); print; exit }
  ' "$repo_file")
  gpgkey=$(awk -v section="[$REPO]" '
    /^\[/ { inside=($0==section) }
    inside && /^[[:space:]]*gpgkey[[:space:]]*=/ { sub(/^[^=]*=/,""); gsub(/[[:space:]]/,""); print; exit }
  ' "$repo_file")
  echo "baseurl=$baseurl | gpgcheck=$gpgcheck | gpgkey=$gpgkey"
  [[ "$baseurl" == http://repo.red-soft.ru/virtualization/7.3/host-updates/* || \
     "$baseurl" == https://repo.red-soft.ru/virtualization/7.3/host-updates/* ]] || \
     stop "Repository URL not on approved primary host-updates endpoint: $baseurl"
  [[ "$gpgcheck" == 1 ]] || stop 'Repository must have gpgcheck=1'
  [[ "$gpgkey" == file:///* ]] || stop 'Expected local file:// GPG key (inspect repo configuration)'
  keypath=${gpgkey#file://}
  [[ -s "$keypath" ]] || stop "GPG key does not exist: $keypath"
  rpm -q --whatprovides "$keypath" || stop 'Local repository GPG key is not owned by an installed RPM'
  [[ "$baseurl" == https://* ]] || warn 'Primary repo is HTTP (RPM GPG signature verification remains enabled; repo metadata is not TLS-protected)'
}

repo_reachable() {
  say 'Primary repository availability'
  check_repo_config
  local attempt
  for attempt in 1 2 3; do
    echo "Refresh metadata: attempt $attempt/3"
    if timeout --kill-after=15s 180s dnf "${DNF_OPTS[@]}" makecache --refresh; then
      echo 'REPO CHECK PASSED'
      return 0
    fi
    warn "Repository not available on attempt $attempt"
    (( attempt == 3 )) || sleep 10
  done
  stop 'Repository unavailable after 3 attempts. Do not modify DNS/network automatically.'
}

boot_controller_modules() {
  # Trace block-device ancestry of / and /boot to physical disks and their
  # PCI / SCSI controller driver modules. Detect from running kernel sysfs.
  local src disk p mod
  local -a disks=()
  for mount in / /boot; do
    src=$(findmnt -no SOURCE "$mount" 2>/dev/null || true)
    [[ -n "$src" ]] || stop "Cannot find device for $mount"
    while read -r disk typ; do
      [[ "$typ" == disk ]] && disks+=("$disk")
    done < <(lsblk -s -r -n -o KNAME,TYPE "$src")
  done
  (( ${#disks[@]} > 0 )) || stop 'Cannot determine root/boot physical disks'
  for disk in "${disks[@]}"; do
    p=$(readlink -f "/sys/class/block/$disk/device") || stop "No sysfs device for $disk"
    while [[ "$p" != '/' && "$p" != '/sys' ]]; do
      if [[ -L "$p/driver/module" ]]; then
        mod=$(basename "$(readlink -f "$p/driver/module")")
        case "$mod" in
          megaraid_sas|mpt3sas|mpi3mr|hpsa|smartpqi|aacraid|ahci|nvme|virtio_blk|virtio_scsi|qla2xxx|lpfc)
            echo "$mod"
            ;;
        esac
      fi
      p=$(dirname "$p")
    done
  done | sort -u
}

check_new_boot() {
  say 'New boot kernel, GRUB and initramfs'
  local old new img listing mod conf filename existing_root new_root free_mb
  old=$(cat "$BASE/old-kernel.txt")
  new=$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-lt | sort -V | tail -1)
  [[ -n "$new" && "$new" != "$old" ]] || stop "No new kernel installed; old=$old new=$new"
  rpm -q "kernel-lt-$old" >/dev/null || stop "Original running kernel removed: $old"
  img="/boot/initramfs-$new.img"
  [[ -s "$img" && -s "/boot/vmlinuz-$new" && -s "/boot/config-$new" ]] || stop 'Missing new kernel/config/initramfs file'
  listing="$BASE/new-initramfs-contents.txt"
  lsinitrd "$img" > "$listing" || stop "Cannot inspect initramfs: $img"
  lsinitrd -m "$img" > "$BASE/new-initramfs-dracut-modules.txt" || stop 'Cannot inspect dracut modules'
  if [[ "$(findmnt -no SOURCE /)" == /dev/mapper/* ]]; then
    grep -Eq 'usr/sbin/lvm$' "$listing" || stop 'initramfs has no lvm'
    grep -Eq 'usr/sbin/dmsetup$' "$listing" || stop 'initramfs has no dmsetup'
  fi
  [[ "$(grubby --default-kernel)" == "/boot/vmlinuz-$new" ]] || stop 'New kernel is not default in GRUB'
  existing_root=$(grubby --info="/boot/vmlinuz-$old" | sed -n '/^root=/ {s/^root=//;p;q;}')
  new_root=$(grubby --info="/boot/vmlinuz-$new" | sed -n '/^root=/ {s/^root=//;p;q;}')
  [[ -n "$existing_root" && "$existing_root" == "$new_root" ]] || stop "GRUB root mismatch: old=$existing_root new=$new_root"
  [[ -s "$BASE/boot-controller-modules.txt" ]] || stop 'Baseline boot controller inventory missing'
  conf="/boot/config-$new"
  while read -r mod; do
    [[ -n "$mod" ]] || continue
    echo "Boot controller: $mod"
    filename=$(modinfo -k "$new" -F filename "$mod" 2>/dev/null || true)
    if [[ "$filename" == '(builtin)' ]]; then
      echo "  $mod is built in to new kernel"
    elif grep -Eq "/${mod}\.ko(\.[a-zA-Z0-9]+)?$" "$listing"; then
      echo "  $mod found IN new initramfs"
    else
      # Some distros do not expose builtin files through modinfo.
      local config_name
      config_name="CONFIG_$(tr '[:lower:]' '[:upper:]' <<< "$mod")"
      if grep -Fxq "${config_name}=y" "$conf"; then
        echo "  $mod built in according to config"
      else
        stop "Boot controller $mod is absent from new initramfs (module file: $filename)"
      fi
    fi
  done < "$BASE/boot-controller-modules.txt"
  free_mb=$(df -Pm /boot | awk 'NR==2 {print $4}')
  (( free_mb >= 100 )) || stop 'Less than 100 MiB free on /boot'
  printf '%s\n' "$new" > "$BASE/target-kernel.txt"
  grubby --info="/boot/vmlinuz-$new"
  echo "BOOT CHECK PASSED: $new"
}

compare_ipv4() {
  local new="$BASE/current-ipv4.txt"
  ipv4_state > "$new"
  if ! comm -23 "$BASE/baseline/ipv4.txt" "$new" > "$BASE/missing-ipv4.txt"; then
    stop 'Could not compare IPv4 addresses'
  fi
  if [[ -s "$BASE/missing-ipv4.txt" ]]; then
    cat "$BASE/missing-ipv4.txt"
    stop 'One or more baseline IPv4 addresses are missing'
  fi
  echo 'All baseline IPv4 addresses present'
}

compare_storage_baseline() {
  say 'PV completeness and multipath redundancy'
  local current="$BASE/current-pv-uuids.txt"
  pvs --noheadings -o pv_uuid | awk 'NF {print $1}' | sort -u > "$current" || stop 'pvs failed'
  comm -23 "$BASE/expected-pv-uuids.txt" "$current" > "$BASE/missing-pvs.txt"
  if [[ -s "$BASE/missing-pvs.txt" ]]; then
    cat "$BASE/missing-pvs.txt"
    stop 'PV(s) from baseline are missing'
  fi
  check_no_partial_lvm
  multipath -ll > "$BASE/current-multipath.txt" || stop 'multipath query failed'
  path_counts < "$BASE/current-multipath.txt" > "$BASE/current-path-counts.txt"
  # No active/ready/running paths may be lost compared to the baseline.
  awk '
    NR==FNR { expected[$1]=$2; next }
    { current[$1]=$2 }
    END {
      for (w in expected) {
        if (!(w in current) || current[w] < expected[w]) {
          printf "PATH LOSS: %s baseline=%d now=%d\n",w,expected[w],current[w]+0
          bad=1
        }
      }
      exit bad
    }
  ' "$BASE/baseline/path-counts.txt" "$BASE/current-path-counts.txt" || stop 'Multipath redundancy less than baseline'
  local old_sessions current_sessions
  old_sessions=$(wc -l < "$BASE/baseline/iscsi.txt")
  current_sessions=$(iscsiadm -m session | wc -l) || stop 'iscsi session query failed'
  (( current_sessions >= old_sessions )) || stop "Only $current_sessions iSCSI sessions; baseline had $old_sessions"
  echo "PV and path counts OK. iSCSI sessions: $current_sessions (baseline: $old_sessions)"
}

stage_baseline() {
  [[ ! -f "$BASE/expected-pv-uuids.txt" ]] || stop 'Baseline already exists. Preserve it; do not overwrite.'
  check_os
  check_services
  check_no_partial_lvm
  cert_check
  repo_reachable
  snapshot baseline
  [[ -s "$BASE/baseline/path-counts.txt" ]] || stop 'No multipath maps detected'
  local pv_tmp="$BASE/expected-pv-uuids.txt.pending"
  local modules_tmp="$BASE/boot-controller-modules.txt.pending"
  pvs --noheadings -o pv_uuid | awk 'NF {print $1}' | sort -u > "$pv_tmp"
  [[ -s "$pv_tmp" ]] || stop 'No PVs found'
  boot_controller_modules > "$modules_tmp"
  [[ -s "$modules_tmp" ]] || stop 'Could not identify boot RAID/HBA/NVMe controller. Inspect manually.'
  mv "$modules_tmp" "$BASE/boot-controller-modules.txt"
  mv "$pv_tmp" "$BASE/expected-pv-uuids.txt"
  echo "Host: $(hostname -f), PVs: $(wc -l < "$BASE/expected-pv-uuids.txt")"
  echo "Boot controller module(s): $(tr '\n' ' ' < "$BASE/boot-controller-modules.txt")"
  echo 'BASELINE PASS. MANUAL NEXT: Engine -> Maintenance.'
}

stage_upgrade() {
  [[ "${2:-}" == '--maintenance-confirmed' ]] || stop 'Usage: upgrade --maintenance-confirmed'
  [[ -n "${TMUX:-}" ]] || stop 'Start tmux before upgrade'
  [[ -t 0 ]] || stop 'Interactive terminal required for production approval'
  [[ -s "$BASE/expected-pv-uuids.txt" ]] || stop 'Run baseline BEFORE Engine Maintenance'
  [[ ! -e "$BASE/upgrade-completed" ]] || stop 'Upgrade already completed on this host'
  [[ "$(cat "$BASE/baseline/hostname.txt")" == "$(hostname -f)" ]] || stop 'Baseline from different host'
  [[ "$(cat "$BASE/baseline/kernel.txt")" == "$(uname -r)" ]] || stop 'Kernel changed since baseline'
  check_os
  check_services
  check_no_vms
  cert_check
  snapshot pre-upgrade
  if grep -q 'p' < <(vgs --noheadings -o vg_attr); then
    warn 'Partial SAN VG during Maintenance: compare against baseline; not activating any LV'
  fi
  local free_mb answer rc
  free_mb=$(df -Pm /boot | awk 'NR==2 {print $4}')
  (( free_mb >= 250 )) || stop 'Less than 250 MiB free on /boot'
  repo_reachable
  say 'Pre-download update list'
  if dnf "${DNF_OPTS[@]}" check-update; then rc=0; else rc=$?; fi
  case "$rc" in
    0) echo 'No updates available (with Certified excludes). No installation performed.'; return 0 ;;
    100) echo 'Updates available' ;;
    *) stop "DNF check-update failed: exit=$rc" ;;
  esac
  say 'Download RPMs, NO installation'
  dnf "${DNF_OPTS[@]}" upgrade --downloadonly -y || stop 'RPM download failed'
  say 'Offline transaction plan'
  local plan="$BASE/offline-transaction-plan.txt"
  if dnf --cacheonly "${DNF_OPTS[@]}" upgrade --assumeno > "$plan" 2>&1; then rc=0; else rc=$?; fi
  cat "$plan"
  if (( rc != 1 )) || ! grep -Eq '^Operation aborted\.' "$plan"; then
    stop "Unexpected transaction-plan result: rc=$rc"
  fi
  grep -Fq 'Dependencies resolved.' "$plan" || stop 'No successful dependency resolution in plan'
  grep -Fq 'Transaction Summary' "$plan" || stop 'No DNF transaction summary in plan' 
  if grep -Ei '(^Error:|^Problem [0-9]+:|conflicting requests|nothing provides|GPG check FAILED|Skipping packages)' "$plan"; then
    stop 'Dependency or transaction issue detected'
  fi
  if grep -Eq '^Removing:|^Remove +[0-9]+ Packages' "$plan"; then
    stop 'Plan contains package REMOVAL. Review manually before using this script.'
  fi
  echo 'Plan accepted: no obvious dependency errors/removal; inspect the displayed package list.'
  echo "HOST: $(hostname -f)"
  echo 'Manual Engine state must be MAINTENANCE (or documented InstallFailed with no VMs).'
  printf 'Type exact hostname to AUTHORIZE INSTALL: '
  read -r answer
  [[ "$answer" == "$(hostname -f)" ]] || stop 'Hostname confirmation does not match'
  printf '%s\n' "$(uname -r)" > "$BASE/old-kernel.txt"
  say 'Installing cached RPM packages, NO automatic reboot'
  dnf --cacheonly "${DNF_OPTS[@]}" upgrade -y || stop 'DNF installation failed; do not reboot'
  say 'Post-install integrity'
  dnf history list > "$BASE/dnf-history-after.txt"
  sed -n '1,12p' "$BASE/dnf-history-after.txt"
  rpm -q vdsm openvswitch ovirt-openvswitch-ovn || stop 'Core virtualization RPM missing'
  check_new_boot
  cert_check
  snapshot post-install
  date --iso-8601=seconds > "$BASE/upgrade-completed"
  echo 'UPGRADE / BOOT FILES PASS. MANUAL NEXT: REBOOT via IPMI / console.'
}

stage_postboot() {
  [[ -s "$BASE/upgrade-completed" ]] || stop 'No completed upgrade marker'
  local target
  target=$(cat "$BASE/target-kernel.txt")
  [[ "$(uname -r)" == "$target" ]] || stop "Wrong kernel: $(uname -r), expected $target"
  check_services
  compare_ipv4
  cert_check
  snapshot postboot
  echo '=== Storage immediately after boot (may be partial BEFORE Engine Activate) ==='
  vgs -o vg_name,pv_count,vg_attr || true
  iscsiadm -m session || true
  echo 'POSTBOOT PASS for kernel/services/network/certs.'
  warn 'SAN paths may appear only after manual Engine -> Activate; do not force LVM/iSCSI changes here.'
  date --iso-8601=seconds > "$BASE/postboot-completed"
  echo 'MANUAL NEXT: Engine -> Activate. Then run final.'
}

stage_final() {
  [[ -s "$BASE/expected-pv-uuids.txt" ]] || stop 'No baseline PV list'
  check_os
  check_services
  compare_ipv4
  cert_check
  snapshot final
  compare_storage_baseline
  for svc in libvirtd ovirt-ha-agent ovirt-ha-broker; do
    systemctl is-active --quiet "$svc" || stop "Required final service is not active: $svc"
  done
  timeout 60 hosted-engine --vm-status > "$BASE/final/hosted-engine-status.txt" || stop 'Hosted Engine HA status unavailable'
  [[ -s "$BASE/final/hosted-engine-status.txt" ]] || stop 'Empty Hosted Engine HA output'
  awk -v target="$(hostname -f)" '
    /--== Host / {
      active = (index($0,"Host " target " (id:") > 0)
      if (active) seen=1
      next
    }
    active && /Status up-to-date/ && /True/ { current=1 }
    END { exit !(seen && current) }
  ' "$BASE/final/hosted-engine-status.txt" || stop 'Local Hosted Engine HA metadata is stale or host not listed'
  grep -Eq 'Engine status.*"vm": "up".*"health": "good"' \
    "$BASE/final/hosted-engine-status.txt" || stop 'No healthy running Hosted Engine VM was reported'
  echo 'Hosted Engine HA: local host up-to-date, manager VM healthy'
  if [[ -s "$BASE/upgrade-completed" ]]; then
    local target
    target=$(cat "$BASE/target-kernel.txt")
    [[ "$(uname -r)" == "$target" ]] || stop 'Final: wrong booted kernel'
    [[ -s "$BASE/postboot-completed" ]] || stop 'Run postboot before final for this upgrade'
    echo "FINAL PASS: UPGRADE VERIFIED ($(hostname -f), $target)"
    date --iso-8601=seconds > "$BASE/final-validation-passed"
  else
    echo 'FINAL PASS: BASELINE TEST ONLY (no recorded upgrade on this host).'
  fi
  echo 'NOTE: Engine must independently show host Up and storage domains Active.'
}

case "$STAGE" in
  baseline)  stage_baseline ;;
  upgrade)   stage_upgrade "${2:-}" ;;
  postboot)  stage_postboot ;;
  final)     stage_final ;;
  certs)     cert_check ;;
  repo)      repo_reachable ;;
  *)
    cat <<'EOF'
Usage: bash redvirt-upgrade-v1.1.sh <stage>
  baseline                         BEFORE Engine Maintenance (host Up)
  upgrade --maintenance-confirmed  AFTER manual Engine Maintenance; run in tmux
  postboot                         AFTER manual reboot, BEFORE Engine Activate
  final                            AFTER manual Engine Activate
  certs                            read-only host certificate inspection
  repo                             primary repo reachability and GPG check
No automatic reboot, host activation, SAN changes or service restarts.
EOF
    exit 2
    ;;
esac