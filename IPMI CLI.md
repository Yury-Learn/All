#ipmi #cli


### What is IPMI?

IPMI is standard which allows remote server management, primarily developed by Intel. IPMI cards, known as Baseboard Management Cards (BMCs) are primitive computers in their own right and are operational all the time, so long as the server has a power source. The server itself does not need to be powered on, or the operating system operational for the BMC to work, it just needs a power source to be connected to the server.

The primary benefits of IPMI are:

- View server chassis and motherboard sensor output remotely, such as chassis status and intrusion detection.
    
- Ability to remotely power on, power off, reboot the server and flash the identification light.
    
- Ability to set up a console on a serial port and have the BMC redirect that console over a network port, which in cooperation with BIOS level console redirection, gives you the ability to view the BIOS, bootloader, bootup and shutdown procedures and console output should the machine hang or lock up, just as you would if you were interacting with the machine locally. This is called Serial Over Lan (SOL) and is available in IPMI v2.0 as a standard and using non-standard proprietary methods in v1.5.
    

Essentially, IPMI will save you purchasing a separate remote power control unit and SOL will save you purchasing an IP KVM, both of which would be quite expensive for the same functionality the IPMI provides.

Some downside of IPMI:

- In general systems fitted with IPMI are substantially more expensive than those without
    
- The IPMI controller does use power, about 4-6W
    
- The IPMI is another security risk vector
    

### IPMI Revisions

There are currently 3 IPMI revisions (with details taken from [http://www.ecst.csuchico.edu/~dranch/LINUX/IPMI/ipmi-on-linux.html](http://www.ecst.csuchico.edu/~dranch/LINUX/IPMI/ipmi-on-linux.html "http://www.ecst.csuchico.edu/~dranch/LINUX/IPMI/ipmi-on-linux.html")):

- IPMI v1.0 - Autonomous access, logging and control. IPMI messaging command sets, sensor data records and event messages. Access through system interfaces like memory mapped IO, I2C bus etc.
    
- IPMI v1.5 - Ability to send IPMI messages to BMC over LAN, LAN alerting. No SOL as part of the standard's specification but some vendor specific SOL implementations.
    
- IPMI v2.0 - Serial Over LAN enabling console redirection, access control, enhanced authentication, packet encryption using RCMP+, SMbus interface.
    

IPMI version 2.0 is desirable as it allows you to use SOL to get a remote console on the server as though it were local in cases where the operating system locks up and SSH or (heaven forbid) telnet access are not available due to the operating system being inoperable. v2.0 also allows you to encrypt the contents of the IPMI packets sent to remote systems and so protects the BMC passwords and your commands on the network. IPMI v1.5 still allows to you to power the system on and off and view sensor output, but does not support packet encryption (and therefore sends your BMC password over the network in plain text) and does not support SOL in any standardised way. Both 2.0 and 1.5 are in common usage and are both still sold on new servers.

### Usage:

- `ipmitool -h`
    
- Chassis power commands:
    
    - List current power status: `ipmitool -I lanplus -H 192.168.1.42 -U baumkp -a chassis power status`
        
    - List available chassis commands:`sudo ipmitool -I open chassis`
        
    - List chassis policy options `ipmitool -I lanplus -H 192.168.1.42 -U baumkp chassis policy`
        
    - Lists current chassis policy state: `ipmitool -I lanplus -H 192.168.1.42 -U baumkp chassis policy list`
        
    - List all current chassis info: `ipmitool -I lanplus -H 192.168.1.42 -U baumkp chassis status`
        
    - List available power commands`ipmitool -I lanplus -H 192.168.1.42 -U baumkp chassis power`
        
    - Turn power on | off | reset | soft: `ipmitool -I lanplus -H 192.168.1.40 -U baumkp chassis power on`
        
    - Turn power on | off | reset | soft: `ipmitool -I lanplus -H 192.168.1.40 -U baumkp chassis power soft`
        
    - chassis power options [off, reset, cycle] will all hard stop the main computer, which in many cases may not be preferred. Soft option should initiate an OS shutdown, (if supported).
        
- Retrieving ILOM IP address with ipmitool: `sudo ipmitool lan print`
    
- Retrieving Sensor Data: `sudo ipmitool sdr` or to include alarm thresholds: `sudo ipmitool sensor`
    
- Get Hardware Information: `sudo ipmitool fru print`
    
- Retrieve the System Event Log (SEL): `sudo ipmitool sel`
    
- Retrieve BMC info:  `ipmitool -I lanplus -H 192.168.1.42 -U baumkp -a bmc info`
    
- List Authorised Users: `sudo ipmitool user list`
    
- List active ILOM Sessions: `ipmitool session info all` Not much use for me….
    
- Reset the ILOM: ipmitool mc reset warm or ipmitool mc reset cold
    

Options:

- -I : Selects IPMI interface to use; options seem to be: lan for IPMI 1.5 and lanplus for IPMI 2.0.
    
- -H : remote server address IP or hostname; to specify the IPMI BMC connect and use
    
- -U : remote user name to use to connect to IPMI BMC for command
    
- -a : prompt for remote server password (for CLI, not batch files)
    
- -f </path/password_file> : specify use of file for remote server password (need for batch files and to prevent constant prompting for password). This is more secure than actually placing the password on the command line. The file literally just has the password in it.
    

## IPMI BASH Scripts

### IPMI Start Script

This script is used to start-up a remote BMC computer via ipmitool.

The script performs some basic error checking a reporting, of the ipmitool functions used. Once the ipmi start command has been issued the main computer is checked using the ping command to determine if it is actually up. The script exits with a 0 upon successful ping attempt or other error codes as noted in the code upon failure.

edit code: `sudo vim Myscripts/ipmi_start_05_40.sh`

to run script stand alone to start the remote computer: `bash Myscripts/ipmi_start_05_40.sh ; echo $?`

(the `echo $?` will return the error code, as per typical Unix, a 0 return indicates success.)

#!/bin/bash
 
BMC_IP="192.168.1.40"
User_Name="baumkp"
PW_file_location="/etc/ipmitool"
LAN_IP="192.168.1.5"
 
#Check if on
status_on="Chassis Power is on"
status_off="Chassis Power is off"
power_status=$(ipmitool -I lanplus -H $BMC_IP -U $User_Name -f $PW_file_location power status 2>/dev/null)
if [ ${?} -ne 0 ]
  then exit 11
  #error 11 means that the impitool power status return an error
  #ipmitool communication to remote machine did not function for any possible reason
fi
 
if [ "$power_status" == "$status_off" ]
  then
    ipmitool -I lanplus -H $BMC_IP -U $User_Name -f $PW_file_location power on &>/dev/null 2>/dev/null
    if [ $? -ne 0 ]
      then exit 12
      #error 12 means that the ipmi tool power on command returned an error code
    fi
    sleep 10
fi
 
for ((c=1; C<15; c++))
do
  ping -c1 -W1 -q $LAN_IP &>/dev/null
  if [ $? -eq 0 ]
    then
      exit 0
      # Successful communication to machine to be started!
    else
      sleep 10
  fi
done
exit 13
#exit code 13 means that the ping attempts were unsuccessful

### IPMI Stop Script

This script is used to Soft Stop a remote BMC computer via ipmitool. This negates the need to place command directly on the computer in question.

The script performs some basic error checking and reporting, of the ipmitool functions used. Once the ipmi soft stop command has been issued the main computer is check using the ipmi power status command command to determine if it is actually down. The script exits with a 0 upon on successful attempt to verify actual power down or other error codes as noted in the code upon failure.

edit code: `sudo vim ~/Myscripts/ipmi_stop_05_40.sh`

to run script stand alone to soft stop the remote computer: `bash ~/Myscripts/ipmi_stop_05_40.sh ; echo $?`

(the `echo $?` will return the error code, as per typical Unix, a 0 return indicates success.)

#!/bin/bash
 
BMC_IP="192.168.1.40"
User_Name="baumkp"
PW_file_location="/etc/ipmitool"
LAN_IP="192.168.1.5"
 
#Check if on
status_on="Chassis Power is on"
status_off="Chassis Power is off"
power_status=$(ipmitool -I lanplus -H $BMC_IP -U $User_Name -f $PW_file_location power status 2>/dev/null)
if [ ${?} -ne 0 ]
  then exit 11
  #error 11 means that the impitool power status return an error
  #ipmitool communication to remote machine did not function for any possible reason
fi
 
if [ "$power_status" == "$status_on" ]
  then
    ipmitool -I lanplus -H $BMC_IP -U $User_Name -f $PW_file_location power soft &>/dev/null 2>/dev/null
    if [ $? -ne 0 ]
      then exit 12
      #error 12 means that the ipmi tool power on command returned an error code
    fi
    sleep 40
fi
 
for ((c=1; C<8; c++))
do
  power_status=$(ipmitool -I lanplus -H $BMC_IP -U $User_Name -f $PW_file_location power status 2>/dev/null)
  if [ ${?} -ne 0 ]
    then exit 11
    #error 11 means that the impitool power status return an error
    #ipmitool communication to remote machine did not function for any possible reason
  fi
 
  if [ "$power_status" == "$status_off" ]
    then
    exit 0
    # The machine is verified as shutdown
  fi
  sleep 30
  #wait another 30 seconds and check again 
done
 
exit 13
#exit code 13 means that the machine did not shutdown in the check time period

### Test Script

#!/bin/bash
 
#Check if on
status_on="Chassis Power is on"
status_off="Chassis Power is off"
power_status=$(ipmitool -I lanplus -H 192.168.1.41 -U baumkp -f /etc/ipmitool power status &>/dev/null) ; echo $?
rc=$?
 
if ["$?" -ne "0"] then echo "Error" fi
 
 
#If off, turn on 
ipmitool -I lanplus -H 192.168.1.40 -U baumkp -f /etc/ipmitool power on
 
#Wait until running status returned
ipmitool -I lanplus -H 192.168.1.40 -U baumkp -f /etc/ipmitool power status
 
#Wait until OS is running
ping -c1 -W1 -q 192.168.1.10 &>/dev/null ; echo $?

### IPMI List

- 040 005 kptreeserver
    
- 041 010 kpts
    
- 042 001 Router
    

### Glossary

List of IPMI terms. Taken wholesale from [http://www.ecst.csuchico.edu/~dranch/LINUX/IPMI/ipmi-on-linux.html](http://www.ecst.csuchico.edu/~dranch/LINUX/IPMI/ipmi-on-linux.html "http://www.ecst.csuchico.edu/~dranch/LINUX/IPMI/ipmi-on-linux.html")

- BMC : Baseboard Management Controllers. IPMI compliant micro controllers that handle system event management. These are usually available as cPCI cards.
    
- GPCagent : A SuperMicro proprietary “Graceful Power” control agent. This agent provides graceful power control features for both Linux and windows platform. GPC means the OS will shutdown gracefully before a power shutdown. It is available from the SuperMicro website. It run as a daemon (smagent) on a Linux based managed system. It requires openIPMI kernel modules to be installed on the managed system to interact with the IPMI device.
    
- i2c : A low speed (>=400khz) system management interface supported on most embedded systems. It is similar to the SMBus.
    
- ipmicli : A SuperMicro proprietary command line interface for Linux, similar in function to IPMIView, available from the SuperMicro website.
    
- IPMItool : An opensource tool for accessing the IPMI device through either local or remote access. Its a command line tool that can used to perform various commands for reading and writing to the IPMI device. It is equivalent to the ipmicli proprietary tool except for console redirection which is not available on this tool.
    
- IPMIView : A SuperMicro proprietary java applet available from SuperMicro website. Runs on both windows (tested on windows2k) and Linux (fc3) platforms. This runs on the remote system and can be used to interact with the IPMI interface on the managed system. This software provides sensor monitoring, secure login, LAN/IP configuration, chassis power control and console redirection terminal. It also provides a graceful power shutdown/restart option that requires a daemon running on the managed system.
    
- ipnmac : A SuperMicro proprietary command line tool for Linux to set the IP and mac address for the ipmi interface. This tool can be used to set the address locally on the managed system.
    
- Managed system : system which is to be managed using IPMI. The IPMI card is installed on this machine. IPMI v2.0 supports both local and remote access to the BMC. Local access is provided through a system interface like kCS (IO port). Remote access is provided through the onboard LAN interface (on IPMI supported motherboards).
    
- OpenIPMI : An opensource IPMI project that maintains linux drivers for the IPMI device. These drivers run on the managed system and provide a local interface to the IPMI card. They also support a primitive command line utility, equivalent to the ipmicli. The utility is meant more as a sample than a working tool.
    
- Remote system : System from which the IPMI enabled server is managed. This is usually over the network.
    
- SMbus : System Management bus. A low speed (<100khz) system management interface supported on most PC and server motherboards. It is similar to the I2C bus. The BMC uses the SMbus to communicate with motherboard sensors and Ethernet interface.
    
- SuperoDoctor : A SuperMicro proprietary IPMI tool. Verision II is a command line tool for local access on the managed system to IPMI interface. Version III is a GUI based tool for local access but works only on windows platform. This requires the openIPMI kernel modules to be installed on the managed machine.