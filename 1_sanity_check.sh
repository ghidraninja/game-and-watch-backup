#!/bin/bash

source config.sh placeHolder

echo "Running sanity checks..."
if ! ${OPENOCD} -v >/dev/null 2>&1; then
    echo "OpenOCD does not seem to be working. Please validate that you have it installed correctly!"
    exit 1
fi

if [[ "${OPENOCD_VERSION}" == "0.10.0" ]]; then
  echo "You seem to be using a vanilla version of openocd."
  echo "In case you see the following error: "
  echo "  openocd/interface_stlink.cfg:1: Error: Can't find interface/stlink.cfg"
  echo "Update your openocd version."
fi

if ! /usr/bin/env python3 -V >/dev/null 2>&1; then
    echo "Could not run python3. Please validate that you have it installed correctly!"
    exit 1
fi

if ! arm-none-eabi-objdump -v >/dev/null 2>&1; then
    echo "Could not find arm-none-eabi-objdump. Please validate that it's installed and in PATH."
    exit 1
fi

echo "Looks good!"
