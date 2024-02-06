#!/bin/bash
#This script will toggle a switch in Domoticz, which will turn off and on a 433Mhz mains plug.
#This is done when the internet ('FirstIP' & 'SecondIP' cannot be reached for more than 3 times)
#For more information see the corresponding blogpost: http://thinkpad.tweakblogs.net/blog/12056/modem-automatisch-powercyclen-bij-internetproblemen

FirstIP="8.8.8.8" #Google DNS
SecondIP="208.67.222.222" #OpenDNS Public DNS
IDX="300" #IDX of the outlet that controls power to your modem
DomoIP="127.0.0.1"
DomoPort="80"

COUNTER=0
while [ $COUNTER -lt 3 ] ## Try 3 times before resetting the modem. Modify as needed.
do
if ping -c 1 -w 5 $FirstIP &> /dev/null ## Determine if second IP-address is reachable.
	then
	echo "First IP responds, do nothing"
	exit 1
elif ping -c 1 -w 5 $SecondIP &> /dev/null ## Determine if second IP-address server is reachable.
	then
	echo "Second IP responds, do nothing"
	exit 1
else
	let COUNTER=COUNTER+1
fi
done
#Turn modem off
wget -O /dev/null - -q -t 1 'http://'$DomoIP':'$DomoPort'/json.htm?type=command&param=switchlight&idx='$IDX'&switchcmd=Off&level=0'     
echo "Turn modem off (sending command twice to Domoticz, just to be sure)"
sleep 2
wget -O /dev/null - -q -t 1 'http://'$DomoIP':'$DomoPort'/json.htm?type=command&param=switchlight&idx='$IDX'&switchcmd=Off&level=0' 
echo "Now waiting 10 seconds"
sleep 10 ## Delay of 10, increase as needed.

#Turn modem back on again
wget -O /dev/null - -q -t 1 'http://'$DomoIP':'$DomoPort'/json.htm?type=command&param=switchlight&idx='$IDX'&switchcmd=On&level=0'
echo "Turn modem back on again (sending command twice to Domoticz, just to be sure)"
sleep 2
wget -O /dev/null - -q -t 1 'http://'$DomoIP':'$DomoPort'/json.htm?type=command&param=switchlight&idx='$IDX'&switchcmd=On&level=0'