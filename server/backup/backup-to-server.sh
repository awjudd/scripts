#!/bin/bash

# SSH Settings
SSH_USERNAME=
SSH_REMOTE_DIRECTORY="./sync/"
SSH_PORT=22
SSH_SERVERS=

# Hooks for pre and post processing on the server
SSH_PRE_HOOK=
SSH_POST_HOOK=

# Commands required
SSH=/usr/bin/ssh
SCP=/usr/bin/scp
FILTER="*.gz"

# Check if a value was provided for the temporary directory
if [ -z "$TMP_DIR" ]; then
    TMP_DIR=/tmp/
fi

# Check if the user provided a config file
if [ -n "$1" -a -e "$1" ]; then
    source "$1"
fi

# Drop all of the files in the path which match our filter into the drop folder
for SERVER in $SSH_SERVERS
do
    # Check if there was a pre-execution hook
    if [ -n "$SSH_PRE_HOOK" ]; then
        echo "Executing pre-execution hook on: $SERVER"
        $SSH -p$SSH_PORT $SSH_USERNAME@$SERVER "$SSH_PRE_HOOK"
    fi

    echo "Copying files to: $SERVER"
    $SCP -P$SSH_PORT "$TMP_DIR/"$FILTER $SSH_USERNAME@$SERVER:$SSH_REMOTE_DIRECTORY

    # Check if there was a pre-execution hook
    if [ -n "$SSH_POST_HOOK" ]; then
        echo "Executing post-execution hook on: $SERVER"
        $SSH -p$SSH_PORT $SSH_USERNAME@$SERVER "$SSH_POST_HOOK"
    fi
done
