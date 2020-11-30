#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: backup_flash.sh <Adapter: jlink or stlink>"
    exit 1
fi

if test -f backups/flash_backup.bin; then
    echo "Already have a backup in backups/flash_backup.bin, refusing to overwrite."
    exit 1
fi

ADAPTER=$1

echo "Make sure your Game & Watch is turned on and in the time screen. Press return when ready!"
read -n 1

mkdir -p backups
mkdir -p logs

echo "Attempting to dump flash using adapter $1."
echo "Running OpenOCD... (This will take roughly 30 seconds, your Game and Watch screen will blink in between.)"
if ! openocd -f openocd/flash_"$1".cfg >>logs/2_openocd.log 2>&1; then
    echo "Failed to dump SPI flash from device. Verify debug connection and try again."
    exit 1
fi

echo "Validating ITCM dump..."
if ! shasum --check shasums/itcm_backup.bin.sha1 >/dev/null 2>&1; then
    echo "Failed to correctly dump ITCM. Restart Game & Watch and try again."
    exit 1
fi


echo "Extracting checksummed part..."
if ! dd if=backups/flash_backup.bin of=backups/flash_backup_checksummed.bin count=1040384 bs=1 >/dev/null 2>&1; then
    echo "Failed to access flash_backup.bin"
    echo "Verify openocd works correctly"
    exit 1
fi

echo "Validating checksum..."
if ! shasum --check shasums/flash_backup_checksummed.bin.sha1 >/dev/null 2>&1; then
    echo "Failed to verify checksum. Try again."
    exit 1
fi

rm backups/flash_backup_checksummed.bin

echo "Looks good! Successfully backed up the (encrypted) SPI flash to flash_backup.bin!"
