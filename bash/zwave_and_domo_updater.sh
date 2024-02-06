#! /bin/sh
#This script can be used to update OpenZwave & Domoticz automatically.
#It will ask for a password when executed by a non-root user, 
#to overcome this call the script like: 'echo YOURPASSWORDHERE | sh domoticzupdate.sh' (without quotes) which is not a very secure method ofcourse (because the terminal will save your password) 
#The script will first stop monit (to prevent automatic restart of Domoticz), then stop Domoticz, do a git pull, compile, start Domoticz again, start monit again

sudo -S /etc/init.d/monit stop \
&& sudo -S /etc/init.d/domoticz.sh stop \
&& cd /home/domoticz/open-zwave \
&& git pull \
&& make clean \
&& make \
&& cd /home/domoticz/domoticz/ \
&& git pull \
&& make \
&& sudo -S /etc/init.d/domoticz.sh start \
&& sudo -S /etc/init.d/monit start