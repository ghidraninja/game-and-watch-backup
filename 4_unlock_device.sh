#!/bin/bash

source config.sh $@

echo "Unlocking your device will erase its internal flash. Even though your backup"
echo "is validated, this still can go wrong. Are you sure? (y/N)"
read -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted."
    exit 1
fi

echo "Validating internal flash backup before proceeding..."
if ! shasum --check shasums/internal_flash_backup_${TARGET}.bin.sha1 >/dev/null 2>&1; then
    echo "Backup is not valid. Aborting."
    exit 1
fi

echo "Unlocking device... (Takes up to 30 seconds.)"    
if ! ${OPENOCD} -f "openocd/interface_${ADAPTER}.cfg" \
    -c "init;" \
    -c "halt;" \
    -f openocd/rdp0.cfg >>logs/4_openocd.log 2>&1; then
    echo "Unlocking device failed."
    exit 1
fi

echo "Congratulations, your device has been unlocked. Just a few more steps!"
echo "- The Game & Watch will not yet be functional"
echo "- Disconnect power from the device for the changes to take full effect"
echo "- Power it again"
echo "- Run the 5_restore.sh script to restore the SPI and Internal Flash."
