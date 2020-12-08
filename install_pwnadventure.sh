#!/bin/bash

source config.sh $1

echo "Installing on internal flash..."
if ! ${OPENOCD} -f openocd/interface_"${ADAPTER}".cfg \
    -c "init;" \
    -c "halt;" \
    -c "program prebuilt/gw_retrogo_nes.elf;" \
    -c "exit;" >>logs/5_openocd.log 2>&1; then
    echo "Installing on flash failed."
    exit 1
fi


echo "Installing data on SPI flash..."

# If you adjust this line to point to a different binary, make sure to use the .elf, not the .bin file!
# I.e.: ./scripts/flashloader.sh $ADAPTER ../game-and-watch-retro-go/build/gw_retrogo_nes_extflash.elf
if ! ./scripts/flashloader.sh $ADAPTER prebuilt/gw_retrogo_nes_extflash.bin; then
    echo "Installing on SPI flash failed. Check debug connection and try again."
    exit 1
fi

echo "Success!"
