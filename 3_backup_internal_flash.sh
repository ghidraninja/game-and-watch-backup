#!/bin/bash

set -e

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <Adapter: jlink or stlink>"
    exit 1
fi

ADAPTER=$1
mkdir -p logs

if test -f backups/internal_flash_backup.bin; then
    echo "Already have a backup in backups/internal_flash_backup.bin, refusing to overwrite."
    exit 1
fi

echo "This step will overwrite the contents of the SPI flash chip that we backed up in step 2."
echo "It will be restored in step 5. Continue? (Y/y)"
read -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted."
    exit 1
fi

echo "Generating encrypted flash image from backed up data..."
if ! python3 python/tcm_encrypt.py backups/flash_backup.bin backups/itcm_backup.bin payload/payload.bin new_flash_image.bin; then
    echo "Failed to build encrypted flash image."
    exit 1
fi


echo "Running flashloader..."

if ! ./scripts/flashloader.sh $ADAPTER new_flash_image.bin; then
    echo "Flashloader failed, check debug connection and try again."
    exit 1
fi

echo "Flash successfully flashed. Now do the following procedure:"
echo "- Disconnect power from the device"
echo "- Power it again"
echo "- Press and hold the power button"
echo "- Press return (while still holding the power button)!"


read -n 1

echo "Dumping internal flash..."    
if ! openocd -f openocd/interface_"$1".cfg \
    -c "init;" \
    -c "halt;" \
    -c "dump_image backups/internal_flash_backup.bin 0x24000000 131072" \
    -c "exit;" >>logs/3_openocd.log 2>&1; then
    echo "Dumping internal flash failed."
    exit 1
fi

echo "Verifying internal flash backup..."
if ! shasum --check shasums/internal_flash_backup.bin.sha1 >/dev/null 2>&1; then
    echo "The backup of the internal flash failed. Please try again."
    exit 1
fi

rm new_flash_image.bin

echo "Device backed up successfully"