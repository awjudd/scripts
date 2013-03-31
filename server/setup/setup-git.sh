#!/bin/bash

# Check if the script is being run as root
if [$USER!='root']; then
    echo -n 'This script must be run as root.'
    exit
fi

# Install SVN from the repositories
apt-get install git -y

