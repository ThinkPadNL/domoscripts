#!/bin/sh
truncate -s 0 /home/domoticz/ramdrive/domoticz.log


#Ramdrive can be created by putting:
#tmpfs  /home/domoticz/ramdrive tmpfs  defaults,noatime,nodiratime,size=50000000  0  0
#In /etc/fstab
#Don't forget to make the directory first (mkdir /home/domoticz/ramdrive)

