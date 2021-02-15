#!/bin/bash

source config.sh $1

if ! test -f backups/internal_flash_backup.bin; then
    echo "No backup of internal flash found in backups/internal_flash_backup.bin"
    exit 1
fi

if ! test -f backups/flash_backup.bin; then
    echo "No backup of SPI flash found in backups/flash_backup.bin"
    exit 1
fi

echo "Ok, restoring original firmware! (We will not lock the device, so you won't have to repeat this procedure!)"


echo "Restoring internal flash..."
if ! ${OPENOCD} -f openocd/interface_"${ADAPTER}".cfg \
    -c "init;" \
    -c "halt;" \
    -c "program backups/internal_flash_backup.bin 0x08000000 verify;" \
    -c "exit;" >>logs/5_openocd.log 2>&1; then
    echo "Restoring internal flash failed. Check debug connection and try again."
    exit 1
fi


echo "Restoring SPI flash..."
if ! ./scripts/flashloader.sh $ADAPTER backups/flash_backup.bin; then
    echo "Restoring SPI flash failed. Check debug connection and try again."
    exit 1
fi

echo "Restart device. Continue? (y/N)"
read -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Success, your device should be running the original firmware again!"
    echo "(You should power-cycle the device now)"
    exit 1
fi

echo "Restarting device..."
if ! ${OPENOCD} -f openocd/interface_"${ADAPTER}".cfg \
    -c "init;" \
    -c "reset run;" \
    -c "exit;" >>logs/5_openocd-2.log 2>&1; then
    echo "Reseting failed. Check debug connection and try again."
    exit 1
fi

echo "Success, your device should be running the original firmware again!"
