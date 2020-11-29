#!/bin/bash


if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <Adapter: jlink or stlink>"
    exit 1
fi

ADAPTER=$1


echo "Unlocking your device will erase its internal flash. Even though your backup"
echo "is validated, this still can go wrong. Are you sure? (Y/y)"
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
if ! openocd -f openocd/interface_"$1".cfg \
    -c "init;" \
    -c "halt;" \
    -f openocd/rdp0.cfg; then
    echo "Unlocking device failed."
    exit 1
fi

echo "Congratulations, your device has been unlocked. Please power-cycle it for the changes to take full effect."
