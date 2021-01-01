#!/bin/bash

source config.sh $1

echo "Unlocking your device will erase its internal flash. Even though your backup"
echo "is validated, this still can go wrong. Are you sure? (y/N)"
read -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted."
    exit 1
fi

echo "Validating internal flash backup before proceeding..."
if ! shasum --check shasums/internal_flash_backup.bin.sha1 >/dev/null 2>&1; then
    echo "Backup is not valid. Aborting."
    exit 1
fi

echo "Unlocking device... (Takes up to 30 seconds.)"    
if ! ${OPENOCD} -f openocd/interface_"${ADAPTER}".cfg \
    -c "init;" \
    -c "halt;" \
    -f openocd/rdp0.cfg >>logs/4_openocd.log 2>&1; then
    echo "Unlocking device failed."
    exit 1
fi

echo "Congratulations, your device has been unlocked."
echo "Please power-cycle it for the changes to take full effect."
