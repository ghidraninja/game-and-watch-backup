#!/bin/bash

source config.sh $@

echo "Installing on internal flash..."
if ! ${OPENOCD} -f openocd/interface_"${ADAPTER}".cfg \
    -c "init;" \
    -c "halt;" \
    -c "program prebuilt/gw_retrogo_nes.elf;" \
    -c "program prebuilt/gw_retrogo_nes_extflash.bin 0x90000000"
    -c "exit;" >>logs/5_openocd.log 2>&1; then
    echo "Installing on flash failed."
    exit 1
fi


echo "Success!"
