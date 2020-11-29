#!/bin/bash


if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <Adapter: jlink or stlink>"
    exit 1
fi

ADAPTER=$1
mkdir -p logs


echo "Installing on internal flash..."
if ! openocd -f openocd/interface_"$1".cfg \
    -c "init;" \
    -c "halt;" \
    -c "program prebuilt/gw_retrogo_nes.elf;" \
    -c "exit;" >>logs/5_openocd.log 2>&1; then
    echo "Installing on flash failed."
    exit 1
fi


echo "Installing data on SPI flash..."
if ! ./scripts/flashloader.sh $ADAPTER prebuilt/gw_retrogo_nes_extflash.bin; then
    echo "Installing on SPI flash failed. Check debug connection and try again."
    exit 1
fi

echo "Success!"
