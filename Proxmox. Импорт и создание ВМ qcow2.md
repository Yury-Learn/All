## Step 1: Create a Directory to Store QCOW2 Images

First, we need to create a directory to store the QCOW2 images. I am going to create a directory called **"`qcow`"** under the Proxmox default storage directory.

$ sudo mkdir /var/lib/vz/template/qcow

Please note that you can save the images on any location of your choice.

## Step 2: Copy the QCOW2 Images to Proxmox Storage Directory

Download and copy the QCOW2 image to the directory that you created earlier. For the purpose of this guide, I will be using FreeBSD 12.3 QCOW2 image file.

$ sudo cp Software/FreeBSD\ 12\ Qcow2/FreeBSD-12.3-RELEASE-amd64.qcow2 /var/lib/vz/template/qcow/

You can verify if the image is really copied or not.

$ ls -l -h /var/lib/vz/template/qcow/

**Sample Output:**

total 3.2G
-rw-r--r-- 1 root root 3.2G Jun 13 16:17 FreeBSD-12.3-RELEASE-amd64.qcow2

[![Copy QCOW2 Image To Proxmox Storage](https://ostechnix.com/wp-content/uploads/2022/06/Copy-QCOW2-Image-To-Proxmox-Storage.png "Copy QCOW2 Image To Proxmox Storage")](https://ostechnix.com/wp-content/uploads/2022/06/Copy-QCOW2-Image-To-Proxmox-Storage.png)

Copy QCOW2 Image To Proxmox Storage

## Step 3: Create a VM Without OS

Log in to the Proxmox Web UI dashboard by navigating to **https://ip-address:8006** URL.

Right click on your Proxmox node and click "Create VM" option from the context menu.

[![Create New VM In Proxmox](https://ostechnix.com/wp-content/uploads/2022/06/Create-New-VM-In-Proxmox.png "Create New VM In Proxmox")](https://ostechnix.com/wp-content/uploads/2022/06/Create-New-VM-In-Proxmox.png)

Create New VM In Proxmox

Enter the name of the VM. Also make a note of the VM ID (i.e. **107** in my case). The ID will be auto-created based on the existing number of available VMs. We are going to need the VM ID when we attach the QCOW2 image to the VM. Click OK to continue.

[![Enter VM Details](https://ostechnix.com/wp-content/uploads/2022/06/Enter-VM-Details.png.webp "Enter VM Details")](https://ostechnix.com/wp-content/uploads/2022/06/Enter-VM-Details.png)

Enter VM Details

Next choose **"Do not use any media"** option. Because we already have a pre-installed OS in the QCOW2 image, right? Yes! Also choose the guest type and version. There is no entry for Unix guest OS in Proxmox, so I simply selected "Other". If you use import a Linux Qcow2 image, choose guest type as "Linux" and Kernel as "6.x-2.6 Kernel".

[![Choose 'Do Not Use Any Media' Option](https://ostechnix.com/wp-content/uploads/2022/06/Choose-Do-Not-Use-Any-Media-Option-1.png.webp "Choose 'Do Not Use Any Media' Option")](https://ostechnix.com/wp-content/uploads/2022/06/Choose-Do-Not-Use-Any-Media-Option-1.png)

Choose 'Do Not Use Any Media' Option

Choose the graphics card, firmware and SCSI controller settings for your VM. usually, the default values are sufficient. I will go with default values.

[![Enter System Details For VM](https://ostechnix.com/wp-content/uploads/2022/06/Enter-System-Details-For-VM.png "Enter System Details For VM")](https://ostechnix.com/wp-content/uploads/2022/06/Enter-System-Details-For-VM.png)

Enter System Details For VM

Enter the size for the virtual machine's disk. Here, I will keep the default size i.e. 32 GB. Also make sure you've chosen the disk format as **"QEMU image format"** as shown in the following screenshot.

[![Enter Disk Size For VM](https://ostechnix.com/wp-content/uploads/2022/06/Enter-Disk-Size-For-VM.png "Enter Disk Size For VM")](https://ostechnix.com/wp-content/uploads/2022/06/Enter-Disk-Size-For-VM.png)

Enter Disk Size For VM

Enter the CPU details such as number of sockets and cores.

[![Enter CPU Details](https://ostechnix.com/wp-content/uploads/2022/06/Enter-CPU-Details.png.webp "Enter CPU Details")](https://ostechnix.com/wp-content/uploads/2022/06/Enter-CPU-Details.png)

Enter CPU Details

Enter the RAM size for your VM. here, I have given 2 GB.

[![Enter Memory Details](https://ostechnix.com/wp-content/uploads/2022/06/Enter-Memory-Details.png.webp "Enter Memory Details")](https://ostechnix.com/wp-content/uploads/2022/06/Enter-Memory-Details.png)

Enter Memory Details

Enter network details. Mostly the default settings will work just fine. If you wish to change the network settings (E.g. enable or disable firewall), do it as you wish.

[![Enter Network Details](https://ostechnix.com/wp-content/uploads/2022/06/Enter-Network-Details.png "Enter Network Details")](https://ostechnix.com/wp-content/uploads/2022/06/Enter-Network-Details.png)

Enter Network Details

You will see the summary of the VM's settings. Review them and if you're OK with it, click Finish to create the VM. Or click "Back" button and change the settings as you wish.

[![Confirm VM Creation](https://ostechnix.com/wp-content/uploads/2022/06/Confirm-VM-Creation.png "Confirm VM Creation")](https://ostechnix.com/wp-content/uploads/2022/06/Confirm-VM-Creation.png)

Confirm VM Creation

We just created a VM without OS. It is time to attach the QCOW2 image to the VM.

## Step 4: Import QCOW2 Image into Proxmox Server

Before importing the QCOW2 into your Proxmox server, make sure you've the following details in hand.

1. Virtual machine's ID,
2. Proxmox storage name,
3. Location of the Proxmox QCOW2 image file.

If you don't have them or don't know where to find them, just open your Proxmox web UI dashboard. On the left pane, you will see the virtual machine's IDs and the storage name.

[![Virtual Machine IDs And Storage Name In Proxmox](https://ostechnix.com/wp-content/uploads/2022/06/Virtual-Machine-IDs-And-Storage-Name-In-Proxmox.png "Virtual Machine IDs And Storage Name In Proxmox")](https://ostechnix.com/wp-content/uploads/2022/06/Virtual-Machine-IDs-And-Storage-Name-In-Proxmox.png)

Virtual Machine IDs And Storage Name In Proxmox

Here, my FreeBSD 12 VM id is **"107"** and Proxmox storage name is **"local"**. And the directory path where I saved the QCOW2 image is **`/var/lib/vz/template/qcow/`** (Please refer Step 2.).

Change into the `/var/lib/vz/template/qcow/` directory:

$ cd /var/lib/vz/template/qcow/

Now, import the QCOW2 image into the Proxmox server using command:

$ sudo qm importdisk 107 FreeBSD-12.3-RELEASE-amd64.qcow2 local

Replace the VM id (107) and storage name (local) with your own.

**Sample Output:**

importing disk 'FreeBSD-12.3-RELEASE-amd64.qcow2' to VM 107 ...
Formatting '/var/lib/vz/images/107/vm-107-disk-1.raw', fmt=raw size=5369626624 preallocation=off
transferred 0.0 B of 5.0 GiB (0.00%)
transferred 52.7 MiB of 5.0 GiB (1.03%)
[...]
transferred 5.0 GiB of 5.0 GiB (100.00%)
transferred 5.0 GiB of 5.0 GiB (100.00%)
**Successfully imported disk** as 'unused0:local:107/vm-107-disk-1.raw'

[![Import QCOW2 Into Proxmox](https://ostechnix.com/wp-content/uploads/2022/06/Import-QCOW2-Into-Proxmox.png "Import QCOW2 Into Proxmox")](https://ostechnix.com/wp-content/uploads/2022/06/Import-QCOW2-Into-Proxmox.png)

Import QCOW2 Into Proxmox

We imported the virtual disk to Proxmox. Now go back to the Proxmox web UI dashboard and attach the virtual disk to the VM.

## Step 5: Attach QCOW2 Virtual Disk to VM

Click on the Virtual machine that you created in step 3. In my case, it is FreeBSD 12 VM. Select **"Hardware"** tab. On the right hand side, you will the newly imported QCOW2 disk as **unused disk**. Select the unused disk and then click **"Edit"** button.

[![Edit Unused Disk](https://ostechnix.com/wp-content/uploads/2022/06/Edit-Unused-Disk.png "Edit Unused Disk")](https://ostechnix.com/wp-content/uploads/2022/06/Edit-Unused-Disk.png)

Edit Unused Disk

Choose the bus type as **"VirtIO Block"** to get best disk I/O performance and hit **"Add"** button.

[![Change Bus Type To VirtIO Block](https://ostechnix.com/wp-content/uploads/2022/06/Change-Bus-Type-To-VirtIO-Block.png.webp "Change Bus Type To VirtIO Block")](https://ostechnix.com/wp-content/uploads/2022/06/Change-Bus-Type-To-VirtIO-Block.png)

Change Bus Type To VirtIO Block

You will now see a newly disk with VirtIO as bus type has been attached to the VM.

[![Attach New Disk To Proxmox VM](https://ostechnix.com/wp-content/uploads/2022/06/Attach-New-Disk-To-Proxmox-VM.png "Attach New Disk To Proxmox VM")](https://ostechnix.com/wp-content/uploads/2022/06/Attach-New-Disk-To-Proxmox-VM.png)

Attach New Disk To Proxmox VM

Great! We successfully attached a new disk to the Proxmox VM.

## Step 6: Change the Boot Order

To make the VM to boot from the newly added disk, we must change the boot order.

Select **Virtual machine -> Options -> Boot Order**.

[![Select Boot Order](https://ostechnix.com/wp-content/uploads/2022/06/Select-Boot-Order.png "Select Boot Order")](https://ostechnix.com/wp-content/uploads/2022/06/Select-Boot-Order.png)

Select Boot Order

In order to boot from the new disk, it must be on top in the boot order window. Select the newly added VirtIO disk and drag it to the top. Make sure you checked the tick box to enable the disk. Click "OK" to save.

[![Change Disk Boot Order In Proxmox](https://ostechnix.com/wp-content/uploads/2022/06/Change-Disk-Boot-Order-In-Proxmox.png.webp "Change Disk Boot Order In Proxmox")](https://ostechnix.com/wp-content/uploads/2022/06/Change-Disk-Boot-Order-In-Proxmox.png)

Change Disk Boot Order In Proxmox

Now start the virtual machine. It should boot from the new disk.

[![FreeBSD Virtual Machine Running In Proxmox](https://ostechnix.com/wp-content/uploads/2022/06/FreeBSD-Virtual-Machine-Running-In-Proxmox.png "FreeBSD Virtual Machine Running In Proxmox")](https://ostechnix.com/wp-content/uploads/2022/06/FreeBSD-Virtual-Machine-Running-In-Proxmox.png)

FreeBSD Virtual Machine Running In Proxmox

That's it. Start using the newly created virtual machine.