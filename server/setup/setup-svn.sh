#!/bin/bash

SVN_BASE_PATH='/var/svn'

# Check if the base path was provided
if [ -n "$1" ]; then
    SVN_BASE_PATH=$1
fi

# Write to disk where the SVN repository will be stored
echo $SVN_BASE_PATH > "~/.svn_base"

# Check if the script is being run as root
if [$USER!='root']; then
    echo -n 'This script must be run as root.'
    exit
fi

# Make the base SVN directory if needed
if[!-d "$SVN_BASE_PATH" ]; then
    mkdir -p "$SVN_BASE_PATH"
fi

# Install SVN from the repositories
apt-get install subversion libapache2-svn -y

# Add the subversion user group if needed
/bin/egrep -i "^subversion" /etc/group > /dev/null

if [ $? -ne 0 ]; then
    addgroup subversion
fi

# Add www-data to the group
usermod -G subversion www-data

# Change the owner of the subversion directory
chgrp -R subversion "$SVN_BASE_PATH"

# Allow members of the subversion group to write to it
chmod -R 775 "$SVN_BASE_PATH"
