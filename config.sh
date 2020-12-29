#!/bin/bash

OPENOCD=${OPENOCD:-$(which openocd)}

if [[ -z ${OPENOCD} ]]; then
  echo "Cannot find 'openocd' in the PATH. You can set the environment variable 'OPENOCD' to manually specify the location"
  exit 2
fi

OPENOCD_VERSION=$(${OPENOCD} -v 2> >(cut -f 4 -d" " ) |head -1)
ADAPTER=$1

mkdir -p logs backups

if [[ $# -ne 1 ]] && [[ ! "$0" =~ .*"config.sh" ]]; then
    echo "Usage: $0 <Adapter: jlink or stlink or rpi>"
    exit 1
fi
