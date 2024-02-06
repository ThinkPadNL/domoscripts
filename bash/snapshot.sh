#!/bin/sh
#This script grabs a snapshot from a IP-cam that uses a RTSP-stream
#It will send a pushnotification and will send you the snapshot by mail
today=`/bin/date '+%d-%m-%Y__%H-%M-%S'`;  #Used to generate filename
datesubject=`/bin/date '+%d-%m-%Y om %T'`;  #Used to generate filename
IP="192.168.1.20"                         # IP address Camera


#Ping IP-address of camera to see if it's online, otherwise we don't have to grab a snapshot
if ping -c 1 $IP > /dev/null ; then  

#Grab snapshot from RTSP-stream

/usr/bin/avconv -rtsp_transport tcp -i 'rtsp://'$IP'/user=admin&password=&channel=1&stream=0.sdp' -f image2 -vframes 1 -pix_fmt yuvj420p /home/domoticz/deurbelsnapshots/$today.jpeg

#Send pushnotification with URL to snapshot
sh /home/domoticz/domoticz/scripts/bash/deurbel/pushover.sh -u YOURUSERKEYHERE -a YOURAPPLICATIONKEYHERE -q "Deurbel" -m "Er is aangebeld op de galerij. Zie bijlage in mail voor foto."
echo "Er is op" $datesubject "aangebeld, zie de bijlage voor de foto." | mail -s "Deurbelfoto" -r "YOUR NAME<yourmailaddress@here.com>" -aFrom:yourmailaddress@here.com -A /home/domoticz/deurbelsnapshots/$today.jpeg yourmailaddress@here.com

#Delete previous taken snapshots older than 7 days
find /home/domoticz/deurbelsnapshots/ -name '*.jpeg' -mtime +7 -delete
else
   sh /home/domoticz/domoticz/scripts/bash/deurbel/pushover.sh -u YOURUSERKEYHERE -a YOURAPPLICATIONKEYHERE -q "Deurbel" -m "Net aangebeld, plaatje niet beschikbaar omdat cam offline is"
fi

