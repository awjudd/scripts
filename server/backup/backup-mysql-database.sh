#!/bin/bash

# Define all of the variables that will be used to connect to the database
USERNAME=root
PASSWORD=
DATABASE=

# Define all of the files to stage the data to
TMP_DIR=/tmp/database

# Full links to the commands
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"

# Check if the user provided a config file
if [ -n "$1" -a -e "$1" ]; then
    source "$1"
fi

# Check if the user provided a staging path
if [ -d "$2" ]; then
    TMP_DIR="$2"
fi

# Make sure the temporary directory exists
mkdir --parents "$TMP_DIR"

# Decide which command to run, either to dump a specific database, or all fo them
if [ -z $DATABASE ]; then
    # No database selected, so dump all of the databases
    echo 'test'
else
    # At least 1 database was selected, so dump it
    for DB in $DATABASE
    do
        $MYSQLDUMP --force --opt --user=$USERNAME --password=$PASSWORD --databases $DB > "$TMP_DIR/$DB.sql"
    done
fi
