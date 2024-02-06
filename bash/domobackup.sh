#!/bin/bash
#This script can be used to make a backup of the Domoticz database, the 'scripts' folder and the 'www' folder
#It compresses the 'scripts' and 'www' folder into a .tar.gz file
#The database, .tar.gz files are uploaded to a FTP-server and the backups older than 31 days will get deleted
DOMO_IP="192.168.1.55"  # Domoticz IP 
DOMO_PORT="8080"        # Domoticz port 

### END OF USER CONFIGURABLE PARAMETERS
TIMESTAMP=`/bin/date +%Y%m%d%H%M%S`
BACKUPFOLDER="/home/domoticz/backup"
BACKUPFILE="domoticzbackup_$TIMESTAMP.db" # backups will be named "domoticz_YYYYMMDDHHMMSS.db.gz"
BACKUPFILEGZ="$BACKUPFILE".gz
cd $BACKUPFOLDER
mkdir -p database
mkdir -p scripts
mkdir -p www

#Create backup and make tar archives
/usr/bin/curl -s http://$DOMO_IP:$DOMO_PORT/backupdatabase.php > /home/domoticz/backup/database/$BACKUPFILE
tar -zcvf $BACKUPFOLDER/scripts/domoticz_scripts_$TIMESTAMP.tar.gz /home/domoticz/domoticz/scripts/
tar -zcvf $BACKUPFOLDER/www/domoticz_wwwfolder_$TIMESTAMP.tar.gz /home/domoticz/domoticz/www/

#Upload backup to NAS over FTP
curl -T $BACKUPFOLDER/database/$BACKUPFILE ftp://192.168.1.55/domoticzVM/database/ --user FTPUSER:FTPPASSWORD
curl -T $BACKUPFOLDER/scripts/domoticz_scripts_$TIMESTAMP.tar.gz ftp://192.168.1.55/domoticzVM/scripts/ --user FTPUSER:FTPPASSWORD
curl -T $BACKUPFOLDER/www/domoticz_wwwfolder_$TIMESTAMP.tar.gz ftp://192.168.1.55/domoticzVM/www/ --user FTPUSER:FTPPASSWORD

#Delete backups older than 31 days
/usr/bin/find $BACKUPFOLDER/database/ -name '*.db' -mtime +31 -delete
/usr/bin/find $BACKUPFOLDER/scripts/ -name '*.tar.gz' -mtime +31 -delete
/usr/bin/find $BACKUPFOLDER/www/ -name '*.tar.gz' -mtime +31 -delete

