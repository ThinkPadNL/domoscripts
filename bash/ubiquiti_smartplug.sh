#!/bin/bash   
#This script is used to extract the measured values from a Ubiquiti mPower smartplug and send these values to virtual devices in Domoticz

#PLUGNAME=MPBureau #Not needed it looks, works fine without
PLUGIP=192.168.1.22
PLUGUSER=ubnt     #default "ubnt"
PLUGPASSWORD=ubnt   #default "ubnt"
SESSIONID=01234567890123456789012345678901 #Random ID as you can see

DOMOTICZSERVER=127.0.0.1
DOMOTICZPORT=80

#Create virtual sensors in Domoticz and enter their IDX's here. For the sensor types, see Domoticz JSON wiki
IDX_POWER=247     
IDX_VOLT=246      
IDX_CURRENT=      
IDX_PF= 
IDX_THISMONTH=254       


if ping -c 1 $PLUGIP > /dev/null ; then  # if host is online then:
  
  #Login to webinterface of plug
  curl --silent -X POST -d "username=$PLUGUSER&password=$PLUGPASSWORD" -b "AIROS_SESSIONID=$SESSIONID" $PLUGIP/login.cgi

  #Turn outlet no1 on
  #curl --silent -X PUT -d output=1 -b "AIROS_SESSIONID="$SESSIONID 192.168.4.22/sensors/1 > /dev/null

  #Wait for 2 seconds to let plug measure the load
  #sleep 2
  
  #Retrieve all data from JSON-output
  SENSOR=$(curl --silent -b "AIROS_SESSIONID=$SESSIONID" $PLUGIP/sensors) 


  #Grab power (Watt) from retrieved values and leave 1 decimal, stripoff rest (change printf %.1f if you want more/less decimals)
  #MPPOWER=$(echo $SENSOR | cut -d "," -f3 | cut -d ":" -f2 | awk '{printf("%.1f\n", $1)}')
  MPPOWER=$(echo $SENSOR | cut -d "," -f6 | cut -d ":" -f2 | awk '{printf("%.1f\n", $1)}')
  #Send data to Domoticz sensor without displaying any curl output on commandline
  curl --silent $DOMOTICZSERVER:$DOMOTICZPORT'/json.htm?type=command&param=udevice&idx='$IDX_POWER'&svalue='$MPPOWER > /dev/null 
  #Display powerconsumption (Watt) on commandline
  #echo $MPPOWER 'Watt'


  #Grab current (Ampère) from retrieved values and leave 1 decimal, stripoff rest (change printf %.3f if you want more/less decimals)
  MPCURRENT=$(echo $SENSOR | cut -d "," -f5 | cut -d ":" -f2 | awk '{printf("%.1f\n", $1)}')
  #Send data to Domoticz sensor without displaying any curl output on commandline
  #curl --silent $DOMOTICZSERVER:$DOMOTICZPORT'/json.htm?type=command&param=udevice&idx='$IDX_CURRENT'&svalue='$MPCURRENT > /dev/null 
  #Display current (Ampère) on commandline
  #echo $MPCURRENT 'A'


  #Grab voltage (Volts) from retrieved values and leave 3 decimals, stripoff rest (change printf %.3f if you want more/less decimals)
  MPVOLTAGE=$(echo $SENSOR | cut -d "," -f9 | cut -d ":" -f2 | awk '{printf("%.3f\n", $1)}')
  curl --silent $DOMOTICZSERVER:$DOMOTICZPORT'/json.htm?type=command&param=udevice&idx='$IDX_VOLT'&svalue='$MPVOLTAGE > /dev/null 
  #Display mains voltage (Volt) on commandline
  #echo $MPVOLTAGE 'Volt'

  #Grab voltage (Volts) from retrieved values and leave 3 decimals, stripoff rest (change printf %.3f if you want more/less decimals)
  MPTHISMONTH=$(echo $SENSOR | cut -d "," -f13 | cut -d ":" -f2 | awk '{printf("%.0f\n", $1)}')
  curl --silent $DOMOTICZSERVER:$DOMOTICZPORT'/json.htm?type=command&param=udevice&idx='$IDX_THISMONTH'&nvalue=0&svalue='$MPTHISMONTH > /dev/null 
  #Display mains voltage (Volt) on commandline
  echo $MPTHISMONTH
  RESULT=`echo "scale=4; ($MPTHISMONTH * 0.3125) / 1000" | bc`
  echo $RESULT


  #Grab powerfactor (cos phi) from retrieved values and leave 2 decimals, stripoff rest (change printf %.2f if you want more/less decimals)
  MPPOFA=$(echo $SENSOR | cut -d "," -f7 | cut -d ":" -f2 | awk '{printf("%.2f\n", $1)}')
  #Send data to Domoticz sensor without displaying any curl output on commandline
  #curl --silent $DOMOTICZSERVER:$DOMOTICZPORT'/json.htm?type=command&param=udevice&idx='$IDX_PF'&svalue='$MPPOFA > /dev/null 
  #Display mains voltage (Volt) on commandline
  #echo $MPPOFA 'cos phi'

  #Display info message
  #echo "Sensors in Domoticz should be updated with new values, have a look at them"
  
  #Turn outlet no1 off
  #curl --silent -X PUT -d output=0 -b "AIROS_SESSIONID="$SESSIONID 192.168.4.22/sensors/1 > /dev/null

  #Logout from plug
  curl -b "AIROS_SESSIONID=$SESSIONID" $PLUGIP/logout.cgi


else #Plug not responding to ping, display error message
  echo "Plug not responding to ping, is it connected to your WLAN?"
fi


