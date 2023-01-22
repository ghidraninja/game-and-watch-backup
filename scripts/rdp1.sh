#!/bin/bash

source config.sh $@

echo "This will lock your device! Are you sure? (y/N)"
read -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted."
    exit 1
fi

echo "Validating internal flash backup before proceeding..."
if ! shasum --check shasums/internal_flash_backup_$TARGET.bin.sha1 >/dev/null 2>&1; then
    echo "Backup is not valid. Aborting."
    exit 1
fi

echo "Locking device... (Takes up to 30 seconds.)"
if ! ${OPENOCD} -f "openocd/interface_${ADAPTER}.cfg" \
    -c "init;" \
    -c "halt;" \
    -f openocd/rdp1.cfg >>logs/rdp1_openocd.log 2>&1; then
    echo "Locking device failed."
    exit 1
fi

echo "Device is locked."
