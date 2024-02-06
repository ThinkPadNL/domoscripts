#!/bin/bash
#This script is used to dump the contents of the specified MySQL-database and upload them to a FTP-server
#It also will delete older backups from the backup folder (not from the FTP-server, you have to do that yourself)
# Database credentials
user="USERNAME"
password="PASSWORD"
host="localhost"
db_name="DBNAME"

# Other options
backup_path="/home/dbdumps/_mysql"
date=$(date +"%d-%b-%Y")

# Set default file permissions
umask 177

# Dump database into SQL file
mysqldump --user=$user --password=$password --host=$host $db_name > $backup_path/$db_name-$date.sql

# Delete files older than 31 days
find $backup_path -name '*.sql' -mtime +31 -delete
curl -T $backup_path/$db_name-$date.sql ftp://192.168.1.55/tomcatVM/db_backup/ --user FTPUSER:FTPPASSWORD
