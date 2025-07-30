#proxmox #ad
#### Example with EFI

- Print the current partition table

```
fdisk -l /dev/vda | grep ^/dev
```

> GPT PMBR size mismatch (67108863 != 335544319) will be corrected by w(rite).
> 
> /dev/vda1      34     2047     2014 1007K BIOS boot
> 
> /dev/vda2    2048   262143   260096  127M EFI System
> 
> /dev/vda3  262144 67108830 66846687 31.9G Linux LVM


- Resize the partition 3 (LVM PV) to occupy the whole remaining space of the hard drive)

```
parted /dev/vda
```

(parted) print
Warning: Not all of the space available to /dev/vda appears to be used, you can
fix the GPT to use all of the space (an extra 268435456 blocks) or continue
with the current setting? 
Fix/Ignore? F 

(parted) resizepart 3 100%
(parted) quit

#### Example without EFI

Another example without EFI using parted:

parted /dev/vda

(parted) print

Number  Start   End     Size    Type      File system  Flags
1       1049kB  538MB   537MB   primary   fat32        boot
2       539MB   21.5GB  20.9GB  extended
3       539MB   21.5GB  20.9GB  logical                lvm

Yoy will want to resize the 2nd partition first (extended):

(parted) resizepart 2 100%
(parted) resizepart 3 100%

- Check the new partition table

(parted) print

Number  Start   End     Size    Type      File system  Flags
1       1049kB  538MB   537MB   primary   fat32        boot
2       539MB   26.8GB  26.3GB  extended
3       539MB   26.8GB  26.3GB  logical                lvm

(parted) quit

## 3. Enlarge the filesystem(s) in the partitions on the virtual disk

If you did not resize the filesystem in step 2

### Online for Linux guests with LVM

Enlarge the physical volume to occupy the whole available space in the partition:

pvresize /dev/vda3

List logical volumes:

lvdisplay

 --- Logical volume ---
 LV Path                /dev/{volume group name}/root
 LV Name                root
 VG Name                {volume group name}
 LV UUID                DXSq3l-Rufb-...
 LV Write Access        read/write
 LV Creation host, time ...
 LV Status              available
 # open                 1
 LV Size                <19.50 GiB
 Current LE             4991
 Segments               1
 Allocation             inherit
 Read ahead sectors     auto
 - currently set to     256
 Block device           253:0

  
Enlarge the logical volume and the filesystem (the file system can be mounted, works with ext4 and xfs). Replace "{volume group name}" with your specific volume group name:

#This command will increase the partition up by 20GB
lvresize --size +20G --resizefs /dev/{volume group name}/root 

#Use all the remaining space on the volume group
lvresize --extents +100%FREE --resizefs /dev/{volume group name}/root

### Online for Linux guests without LVM

Enlarge the filesystem (in this case root is on vda1)

resize2fs /dev/vda1