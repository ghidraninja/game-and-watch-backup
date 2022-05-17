#!/bin/bash

set -e

source config.sh $@

if test -f backups/internal_flash_backup_${TARGET}.bin; then
    echo "Already have a backup in backups/internal_flash_backup_${TARGET}.bin, refusing to overwrite."
    exit 1
fi

if ! dd if=backups/flash_backup_${TARGET}.bin of=backups/flash_backup_checksummed_${TARGET}.bin bs=16 skip=${SPIFLASH_SKIP_16} count=${SPIFLASH_COUNT_16} >/dev/null 2>&1; then
    echo "Failed to access flash_backup_${TARGET}.bin"
    echo "Please run ./2_backup_flash.sh again"
    exit 1
fi

if ! shasum --check shasums/flash_backup_checksummed_${TARGET}.bin.sha1 >/dev/null 2>&1; then
    echo "*** External flash backup does not verify correctly ***"
    echo "Please run ./2_backup_flash.sh again"
    rm backups/flash_backup_checksummed.bin
    exit 1
fi

echo "Validating ITCM dump..."
if ! shasum --check shasums/itcm_backup_${TARGET}.bin.sha1 >/dev/null 2>&1; then
    echo "*** ITCM dump does not verify correctly ***"
    echo "Please run ./2_backup_flash.sh again"
    exit 1
fi

rm -f backups/flash_backup_checksummed_${TARGET}.bin

echo "This step will overwrite the contents of the SPI flash chip that we backed up in step 2."
echo "It will be restored in step 5. Continue? (y/N)"
read -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborted."
    exit 1
fi

echo "Generating encrypted flash image from backed up data..."
if ! python3 python/tcm_encrypt.py \
    backups/flash_backup_${TARGET}.bin \
    ${FLASH_OFFSET} \
    backups/itcm_backup_${TARGET}.bin \
    payload/payload.bin \
    new_flash_image.bin; then
    echo "Failed to build encrypted flash image."
    exit 1
fi

echo "Programming payload to SPI flash..."
if ! ${OPENOCD} -f "openocd/target_${TARGET}.cfg" -f "openocd/interface_${ADAPTER}.cfg" \
    -c "init;" \
    -c "halt;" \
    -c "program new_flash_image.bin 0x90000000 verify;" \
    -c "exit;" >>logs/3_openocd.log 2>&1; then
    echo "Writing payload to SPI flash failed. Check debug connection and try again."
    exit 1
fi

echo "Flash successfully programmed. Now do the following procedure:"
echo "- Disconnect power from the device"
echo "- Power it again"
echo "- Press the power button on the device"
echo "- The LCD should show a blue screen"
echo "- If it's not blue, you can try pressing the Time button on the device"
echo "- Press return"


read -n 1

echo "Dumping internal flash..."    
if ! ${OPENOCD} -f "openocd/interface_${ADAPTER}.cfg" \
    -c "init;" \
    -c "halt;" \
    -c "dump_image backups/internal_flash_backup_${TARGET}.bin 0x24000000 131072" \
    -c "exit;" >>logs/3_openocd.log 2>&1; then
    echo "Dumping internal flash failed."
    exit 1
fi

echo "Verifying internal flash backup..."
if ! shasum --check shasums/internal_flash_backup_${TARGET}.bin.sha1 >/dev/null 2>&1; then
    echo "The backup of the internal flash failed. Please try again."
    exit 1
fi

rm -f new_flash_image.bin

echo "Device backed up successfully"
