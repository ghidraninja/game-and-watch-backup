#!/bin/bash

source config.sh $@

if [[ $TARGET == "mario" ]] && \
    test -f backups/flash_backup.bin && test -f backups/internal_flash_backup.bin && \
    ! test -f backups/flash_backup_$TARGET.bin && ! test -f backups/internal_flash_backup_$TARGET.bin \
    ; then
    echo "Discovered mario backups with old names. Renaming files to the new format."
    mv backups/flash_backup.bin backups/flash_backup_$TARGET.bin
    mv backups/internal_flash_backup.bin backups/internal_flash_backup_$TARGET.bin
fi

if ! test -f backups/internal_flash_backup_$TARGET.bin; then
    echo "No backup of internal flash found in backups/internal_flash_backup_$TARGET.bin"
    exit 1
fi

if ! test -f backups/flash_backup_$TARGET.bin; then
    echo "No backup of SPI flash found in backups/flash_backup_$TARGET.bin"
    exit 1
fi

echo "Ok, restoring original firmware! (We will not lock the device, so you won't have to repeat this procedure!)"

echo "Restoring SPI flash..."
if ! ${OPENOCD} -f "openocd/target_${TARGET}.cfg" -f "openocd/interface_${ADAPTER}.cfg" \
    -c "init;" \
    -c "halt;" \
    -c "program backups/flash_backup_${TARGET}.bin 0x90000000 verify;" \
    -c "exit;" >>logs/5_openocd.log 2>&1; then
    echo "Restoring SPI flash failed. Check debug connection and try again."
    exit 1
fi


echo "Restoring internal flash..."
if ! ${OPENOCD} -f "openocd/target_${TARGET}.cfg" -f "openocd/interface_${ADAPTER}.cfg" \
    -c "init;" \
    -c "halt;" \
    -c "program backups/internal_flash_backup_${TARGET}.bin 0x08000000 verify;" \
    -c "exit;" >>logs/5_openocd.log 2>&1; then
    echo "Restoring internal flash failed. Check debug connection and try again."
    exit 1
fi

echo "Success, your device should be running the original firmware again!"
echo "(You should power-cycle the device now)"
