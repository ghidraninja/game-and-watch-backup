#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ELF=firmware/flash_programmer.elf
ADDRESS=0
SIZE=$((1024 * 1024))
MAGIC="0xdeadbeef"
ERASE=1
IMAGE=$2
objdump=${OBJDUMP:-arm-none-eabi-objdump}

function get_symbol {
	name=$1
	objdump_cmd="${objdump} -t ${ELF}"
	size=$(${objdump_cmd} | grep " $name" | cut -d " " -f1 | tr 'a-f' 'A-F')
	printf "ibase=16\n${size}\n" | bc
}

VAR_program_size=$(printf '0x%08x\n' $(get_symbol "program_size"))
VAR_program_address=$(printf '0x%08x\n' $(get_symbol "program_address"))
VAR_program_magic=$(printf '0x%08x\n' $(get_symbol "program_magic"))
VAR_program_done=$(printf '0x%08x\n' $(get_symbol "program_done"))
VAR_program_erase=$(printf '0x%08x\n' $(get_symbol "program_erase"))


if ! openocd -f openocd/interface_"$1".cfg \
    -c "init;" \
    -c "echo \"Resetting device\";" \
    -c "reset halt;" \
    -c "echo \"Programming ELF\";" \
    -c "load_image ${ELF};" \
    -c "reset halt;" \
    -c "sleep 100;" \
    -c "echo \"Loading image into RAM\";" \
    -c "load_image ${IMAGE} 0x24000000;" \
    -c "mww ${VAR_program_size} ${SIZE}" \
    -c "mww ${VAR_program_address} ${ADDRESS}" \
    -c "mww ${VAR_program_magic} ${MAGIC}" \
    -c "mww ${VAR_program_erase} ${ERASE}" \
    -c "reg sp [mrw 0x20000000];" \
    -c "reg pc [mrw 0x20000004];" \
    -c "echo \"Starting flash process\";" \
    -c "resume; exit;" >>logs/flashloader.log 2>&1; then
    echo "Loading failed."
    exit 1
fi


echo "Loaded flashloader, flashing SPI, please wait."

echo "\t(If this takes more than 2 minutes something went wrong.)"
echo "\t(If the screen blinks rapidly, something went wrong.)"
echo "\t(If the screen blinks slowly, everything worked but the script didn't detect it)"
while true; do
    DONE_MAGIC=$(openocd -f  openocd/interface_${1}.cfg -c "init; mdw ${VAR_program_done}" -c "exit;" 2>&1 | grep ${VAR_program_done} | cut -d" " -f2)
    if [[ "$DONE_MAGIC" == "cafef00d" ]]; then
        echo "Done!"
        break;
    fi
    sleep 1
done