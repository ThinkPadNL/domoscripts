#!/bin/bash
# Database credentials
user="root"
password=""
host="localhost"
db_name="DBNAME"

# Other options
backup_path="/home/dbdumps/_mysql"
date=$(date +"%d-%b-%Y")

# Set default file permissions
umask 177

# Dump database into SQL file
mysqldump --user=$user --password=$password --host=$host $db_name > $backup_path/$db_name-$date.sql

# Delete files older than 2 days
find $backup_path -name '*.sql' -mtime +2 -delete
curl -T $backup_path/$db_name-$date.sql ftp://192.168.4.4/db_backup/ --user USERNAME_HERE:PASSWORD_HERE