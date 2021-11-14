#!/bin/bash

source config.sh $@

if ! test -f backups/flash_backup_$TARGET.bin; then
    echo "No backup of SPI flash found in backups/flash_backup_$TARGET.bin"
    exit 1
fi

echo "Restoring SPI flash..."
if ! ${OPENOCD} -f "openocd/target_${TARGET}.cfg" -f "openocd/interface_${ADAPTER}.cfg" \
    -c "init;" \
    -c "reset halt;" \
    -c "program backups/flash_backup_${TARGET}.bin 0x90000000 verify;" \
    -c "exit;" >>logs/5_openocd.log 2>&1; then
    echo "Restoring SPI flash failed. Check debug connection and try again."
    exit 1
fi

echo "Success, your device should be running the original firmware again!"
echo "(You should power-cycle the device now)"
