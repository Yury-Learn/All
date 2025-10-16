#powershell 

# Тело скрипта

```powershell
<# 
Скрипт настраивает:
 - MesloLGM Nerd Font
 - Windows Terminal (шрифт для всех профилей)
 - VS Code (терминал: PowerShell + Meslo + улучшенный рендер глифов)
 - Профили PowerShell (UTF-8 + одна инициализация oh-my-posh с выбранной темой)

Параметры:
 -Theme <имя>         : имя темы oh-my-posh без/с .omp.json (по умолчанию powerlevel10k_rainbow)
 -Interactive         : интерактивный выбор темы из $env:POSH_THEMES_PATH
 -SkipFont            : пропустить установку шрифта Meslo Nerd Font
 -SkipWT              : пропустить настройку Windows Terminal
 -SkipVSCode          : пропустить настройку VS Code терминала

Примеры:
 .\setup-omp.ps1                              # всё по умолчанию (powerlevel10k_rainbow)
 .\setup-omp.ps1 -Theme paradox               # с темой paradox
 .\setup-omp.ps1 -Interactive                 # выбрать тему из списка
#>

param(
  [string]$Theme = "powerlevel10k_rainbow",
  [switch]$Interactive,
  [switch]$SkipFont,
  [switch]$SkipWT,
  [switch]$SkipVSCode
)

function Write-Step($msg){ Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Stop-Err($msg){ throw "[ERROR] $msg" }

# --- 0. Проверки окружения -----------------------------------------------------
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) { Stop-Err "Требуется PowerShell 7 (pwsh)." }
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) { Stop-Err "Не найден oh-my-posh. Установите: winget install JanDeDobbeleer.OhMyPosh" }

# --- 1. Выбор темы --------------------------------------------------------------
$themesPath = $env:POSH_THEMES_PATH
if (-not $themesPath -or -not (Test-Path $themesPath)) { Stop-Err "Не найдена папка тем: `$env:POSH_THEMES_PATH" }

# нормализуем имя
if ($Theme -notmatch '\.omp\.json$') { $Theme = "$Theme.omp.json" }

if ($Interactive) {
  Write-Step "Интерактивный выбор темы"
  $all = Get-ChildItem -Path $themesPath -Filter *.omp.json | Sort-Object Name
  if(-not $all){ Stop-Err "Темы не найдены в $themesPath" }
  $i = 1
  $all | ForEach-Object { "{0,2}) {1}" -f $i++, $_.Name } | Write-Host
  $sel = Read-Host "Введите номер темы (по умолчанию 1)"
  if([string]::IsNullOrWhiteSpace($sel)){ $sel = 1 }
  if($sel -as [int] -lt 1 -or $sel -as [int] -gt $all.Count){ Stop-Err "Неверный номер." }
  $Theme = $all[([int]$sel-1)].Name
}

$ThemeFile = Join-Path $themesPath $Theme
if (-not (Test-Path $ThemeFile)) { Stop-Err "Файл темы не найден: $ThemeFile" }
Write-Host "Выбрана тема: $Theme" -ForegroundColor Green

# --- 2. Установка шрифта -------------------------------------------------------
if (-not $SkipFont) {
  Write-Step "Установка шрифта MesloLGM Nerd Font (через oh-my-posh)"
  try {
    oh-my-posh font install Meslo | Out-Null
  } catch {
    Write-Warning "Не смогли установить через oh-my-posh: $_"
  }
}

# точное имя семейства (как видит Windows)
Add-Type -AssemblyName System.Drawing
$fonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
$FontName = ($fonts | Where-Object { $_ -match '^MesloLGM Nerd Font$' })[0]
if (-not $FontName) { $FontName = "MesloLGM Nerd Font" }  # большинство сборок так называют семейство

# --- 3. Windows Terminal: шрифт всем профилям ----------------------------------
if (-not $SkipWT) {
  Write-Step "Настройка Windows Terminal → font.face = '$FontName'"
  $wtStore  = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
  $wtWinget = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
  $wt = if (Test-Path $wtStore){$wtStore} elseif (Test-Path $wtWinget){$wtWinget} else {$null}
  if (-not $wt) { Write-Warning "settings.json WT не найден — пропускаю."; }
  else {
    $json = Get-Content $wt -Raw | ConvertFrom-Json
    if (-not $json.PSObject.Properties.Match('profiles').Count) { $json | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{}) }
    if (-not $json.profiles.PSObject.Properties.Match('defaults').Count){ $json.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{}) }
    if (-not $json.profiles.defaults.PSObject.Properties.Match('font').Count){ $json.profiles.defaults | Add-Member -NotePropertyName font -NotePropertyValue ([pscustomobject]@{}) }
    $json.profiles.defaults.font.face = $FontName
    if ($json.profiles.PSObject.Properties.Match('list').Count) {
      foreach($p in $json.profiles.list){
        if (-not $p.PSObject.Properties.Match('font').Count){ $p | Add-Member -NotePropertyName font -NotePropertyValue ([pscustomobject]@{}) }
        $p.font.face = $FontName
      }
    }
    $json | ConvertTo-Json -Depth 100 | Set-Content $wt -Encoding utf8
    Write-Host "Windows Terminal настроен: $wt" -ForegroundColor Green
  }
}

# --- 4. VS Code: профиль терминала + шрифт -------------------------------------
if (-not $SkipVSCode) {
  Write-Step "Настройка VS Code терминала (PowerShell + шрифт '$FontName')"
  $codeStable   = Join-Path $env:APPDATA "Code\User\settings.json"
  $codeInsiders = Join-Path $env:APPDATA "Code - Insiders\User\settings.json"
  $codeFiles = @($codeStable, $codeInsiders) | Where-Object { Test-Path $_ }
  $PwshPath = (Get-Command pwsh).Source
  foreach($path in $codeFiles){
    $cfg = if((Get-Content $path -ErrorAction SilentlyContinue).Length){ Get-Content $path -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
    if(-not $cfg.PSObject.Properties.Match('terminal.integrated.profiles.windows').Count){
      $cfg | Add-Member -Name "terminal.integrated.profiles.windows" -MemberType NoteProperty -Value ([pscustomobject]@{}) -Force
    }
    $cfg."terminal.integrated.profiles.windows".PowerShell = [pscustomobject]@{
      path = $PwshPath; args = @(); icon = "terminal-powershell"
    }
    $cfg | Add-Member -Name "terminal.integrated.defaultProfile.windows" -MemberType NoteProperty -Value "PowerShell" -Force
    $cfg | Add-Member -Name "terminal.integrated.fontFamily"            -MemberType NoteProperty -Value $FontName -Force
    $cfg | Add-Member -Name "terminal.integrated.customGlyphs"          -MemberType NoteProperty -Value $true    -Force
    $cfg | ConvertTo-Json -Depth 100 | Set-Content $path -Encoding utf8
    Write-Host "VS Code settings обновлён: $path" -ForegroundColor Green
  }
}

# --- 5. Профили PowerShell: чистка и единый init -------------------------------
Write-Step "Чистка всех профилей PowerShell от дубликатов oh-my-posh init"
$profiles = [ordered]@{
  CurrentUserAllHosts     = $PROFILE.CurrentUserAllHosts
  CurrentUserCurrentHost  = $PROFILE.CurrentUserCurrentHost
  AllUsersAllHosts        = $PROFILE.AllUsersAllHosts
  AllUsersCurrentHost     = $PROFILE.AllUsersCurrentHost
}
$rx = '(?ms)^\s*oh-my-posh\s+init.*Invoke-Expression.*\r?\n'
foreach($k in $profiles.Keys){
  $p = $profiles[$k]
  if(Test-Path $p){
    $txt = Get-Content $p -Raw
    $new = [regex]::Replace($txt, $rx, '')
    if($new -ne $txt){ Set-Content $p -Value $new -Encoding utf8 }
  }
}

Write-Step "Добавление UTF-8 блока и единственного init в CurrentUserCurrentHost"
$text = if (Test-Path $PROFILE) { Get-Content $PROFILE -Raw } else { '' }
if ($text -notmatch 'UTF-8 console defaults') {
$utf8 = @'
# --- UTF-8 console defaults ---
$enc = [System.Text.UTF8Encoding]::new()
[Console]::InputEncoding  = $enc
[Console]::OutputEncoding = $enc
$OutputEncoding           = $enc
chcp 65001 > $null
# --- end UTF-8 defaults ---
'@
  $text = $utf8 + "`r`n" + $text
}
$init = 'oh-my-posh init pwsh --config "' + $ThemeFile + '" | Invoke-Expression'
$text = ($text -replace $rx,'').TrimEnd() + "`r`n" + $init + "`r`n"
Set-Content $PROFILE -Value $text -Encoding utf8

# --- 6. Применяем и показываем итог -------------------------------------------
Write-Step "Применение профиля"
. $PROFILE

Write-Step "Итоговый init-рядок"
(Get-Content $PROFILE -Raw) -split "`r?`n" | Select-String -SimpleMatch 'oh-my-posh init'

Write-Host "`nГотово. Откройте новую вкладку в Windows Terminal и, при необходимости, 'Reload Window' в VS Code." -ForegroundColor Green

```

# Запуск

- 1) Разрешить локальные скрипты (один раз для текущего пользователя)
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

- 2) Запуск по умолчанию (тема powerlevel10k_rainbow)
```powershell
.\setup-omp.ps1
```

- 3) Выбрать тему интерактивно
```powershell
.\setup-omp.ps1 -Interactive
```

- 4) Явно указать тему
```powershell
.\setup-omp.ps1 -Theme paradox
```
### Пояснение ключей/параметров

- `-Theme` — имя темы в `$env:POSH_THEMES_PATH` (можно без `.omp.json`).
    
- `-Interactive` — выведет нумерованный список тем и спросит номер.
    
- `-SkipFont` / `-SkipWT` / `-SkipVSCode` — пропустят соответствующие шаги, если всё уже настроено.