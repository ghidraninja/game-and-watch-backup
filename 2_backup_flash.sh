#!/bin/bash

source config.sh $@

if test -f backups/flash_backup_$TARGET.bin; then
    echo "Already have a backup in backups/flash_backup_$TARGET.bin, refusing to overwrite."
    exit 1
fi

echo "Make sure your Game & Watch is turned on and in the time screen. Press return when ready!"
read -n 1

echo "Attempting to dump flash using adapter ${ADAPTER}."
echo "Running OpenOCD... (This can take up to a few minutes.)"
if ! ${OPENOCD} \
    -f "openocd/target_${TARGET}.cfg" \
    -f "openocd/interface_${ADAPTER}.cfg" \
    -f "openocd/flash.cfg" >> logs/2_openocd.log 2>&1; then
    echo "Failed to dump SPI flash from device. Verify debug connection and try again."
    exit 1
fi

echo "Validating ITCM dump..."
if ! shasum --check shasums/itcm_backup_${TARGET}.bin.sha1 >/dev/null 2>&1; then
    echo "Failed to correctly dump ITCM. Restart Game & Watch and try again."
    exit 1
fi


echo "Extracting checksummed part..."
echo dd if=backups/flash_backup_${TARGET}.bin of=backups/flash_backup_checksummed_${TARGET}.bin bs=16 skip=${SPIFLASH_SKIP_16} count=${SPIFLASH_COUNT_16}

if ! dd if=backups/flash_backup_${TARGET}.bin of=backups/flash_backup_checksummed_${TARGET}.bin bs=16 skip=${SPIFLASH_SKIP_16} count=${SPIFLASH_COUNT_16} >/dev/null 2>&1; then
    echo "Failed to access flash_backup_${TARGET}.bin"
    echo "Verify openocd works correctly"
    exit 1
fi

echo "Validating checksum..."
if ! shasum --check shasums/flash_backup_checksummed_${TARGET}.bin.sha1 >/dev/null 2>&1; then
    echo "Failed to verify checksum of the external flash. Try again."
    exit 1
fi

rm -f backups/flash_backup_checksummed_${TARGET}.bin

echo "Looks good! Successfully backed up the (encrypted) SPI flash to backups/flash_backup_${TARGET}.bin!"
