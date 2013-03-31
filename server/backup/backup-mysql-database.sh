#!/bin/bash

# Define all of the variables that will be used to connect to the database
USERNAME=root
PASSWORD=
DATABASE=

# Define all of the files to stage the data to
TMP_DIR=/tmp/database

# Define the helper script to handle the processing of the file
BACKUP_SCRIPT=./backup-to-server.sh

# Full links to the commands
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"
SH=/bin/sh

# Check if the user provided a config file
if [ -n "$1" -a -e "$1" ]; then
    source "$1"
fi

# Make sure the temporary directory exists
mkdir --parents "$TMP_DIR"

# Decide which command to run, either to dump a specific database, or all fo them
if [ -z "$DATABASE" ]; then
    # No database selected, so dump all of the databases
    DATABASE=`$MYSQL --user=$USERNAME --password=$PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`    
fi

# At least 1 database was selected, so dump it
for DB in $DATABASE
do
    $MYSQLDUMP --force --opt --user=$USERNAME --password=$PASSWORD --databases $DB | gzip > "$TMP_DIR/$DB.sql.gz"
done

if [ -n "$BACKUP_SCRIPT" -a "$BACKUP_SCRIPT" ]; then 
    . "$BACKUP_SCRIPT" "$1"
fi

# Remove the zipped contents of the folder
rm -rf "$TMP_DIR/"*
