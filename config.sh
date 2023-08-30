#!/bin/bash

OPENOCD=${OPENOCD:-$(which openocd)}

if [[ -z ${OPENOCD} ]]; then
  echo "Cannot find 'openocd' in the PATH. You can set the environment variable 'OPENOCD' to manually specify the location"
  exit 2
fi

helptext() {
  echo "Usage: $0 <Adapter: jlink or stlink or rpi or pico> <mario or zelda>"
}

OPENOCD_VERSION=$(${OPENOCD} -v 2> >(cut -f 4 -d" " ) |head -1)
ADAPTER=$1
TARGET=$2

if [[ $TARGET == "mario" ]]; then
  SPIFLASH_SKIP_16=0
  SPIFLASH_COUNT_16=$(( 0xfe000 / 16 ))
  FLASH_OFFSET=0
elif [[ $TARGET == "zelda" ]]; then
  # 0x0000_0000 - 0x0000_008f volatile area
  # 0x0000_1000 - 0x0000_108f volatile area
  # 0x0000_2000 - 0x0000_2b1f volatile area
  # 0x0000_4000 - 0x0000_4b1f volatile area
  # 0x0000_6000 - 0x0000_6b1f volatile area
  # 0x0000_8000 - 0x0000_8b1f volatile area
  # 0x0002_0000 - 0x0032_549f ROM area
  # 0x003e_0000 - 0x0040_0000 volatile area

  SPIFLASH_SKIP_16=$(( 0x20000 / 16 ))
  SPIFLASH_COUNT_16=$(( (0x3254a0 - 0x20000) / 16 ))
  FLASH_OFFSET=$(( 0x30c3a8 ))
else
  helptext
  exit 1
fi

if [[ $# -ne 2 ]] && [[ ! "$0" =~ .*"config.sh" ]]; then
  helptext
  exit 1
fi

mkdir -p logs backups
