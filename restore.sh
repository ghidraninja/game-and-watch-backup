#!/bin/bash


if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <Adapter: jlink or stlink>"
    exit 1
fi


if ! test -f backups/internal_flash_backup.bin; then
    echo "No backup of internal flash found in backups/internal_flash_backup.bin"
    exit 1
fi

if ! test -f backups/flash_backup.bin; then
    echo "No backup of SPI flash found in backups/flash_backup.bin"
    exit 1
fi

ADAPTER=$1

echo "Ok, restoring original firmware!"

echo "Restoring SPI flash..."
if ! ./scripts/flashloader.sh $ADAPTER backups/flash_backup.bin; then
    echo "Restoring SPI flash failed. Check debug connection and try again."
    exit 1
fi

echo "Restoring internal flash..."
if ! openocd -f openocd/interface_"$1".cfg \
    -c "init;" \
    -c "halt;" \
    -c "program backups/internal_flash_backup.bin 0x08000000 verify;" \
    -c "exit;" >/dev/null 2>&1; then
    echo "Restoring internal flash failed. Check debug connection and try again."
    exit 1
fi

echo "Success, your device should be running the original firmware again!"