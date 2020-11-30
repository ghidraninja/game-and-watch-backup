#!/bin/bash

echo "Running sanity checks..."
if ! openocd -v >/dev/null 2>&1; then
    echo "OpenOCD does not seem to be working. Please validate that you have it installed correctly!"
    exit 1
fi

if ! /usr/bin/env python3 -V >/dev/null 2>&1; then
    echo "Could not run python3. Please validate that you have it installed correctly!"
    exit 1
fi

if ! arm-none-eabi-objdump -v >/dev/null 2>&1; then
    echo "Could not find arm-none-eabi-objdump. Please validate that it's installed and in PATH."
    exit 1
fi

if ! bc -v >/dev/null 2>&1; then
    echo "Could not find bc. Please validate that it's installed and in PATH."
    exit 1
fi

echo "Looks good!"
