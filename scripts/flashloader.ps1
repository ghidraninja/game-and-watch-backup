Clear-Host
Write-Host "Running flashloader..."
$1=$args[0]
$2=$args[1]
$Interface_cfg = "$Loc\openocd\interface_" + $1 + ".cfg"
$Loc = Split-Path -Path $PSScriptRoot -Parent
$ELF='firmware\\flash_programmer.elf'
$ADDRESS=0
$SIZE=((1024 * 1024))
$MAGIC="0xdeadbeef"
$ERASE=1
$IMAGE=$2
#objdump=${OBJDUMP:-arm-none-eabi-objdump}

function get_symbol {
    param($name)
	$objdump_cmd= objdump -t $ELF
    $size = $objdump_cmd | Select-String "$name" 
    $size = "$size".Split(" ")[0]
    return "0x" + '{0:X8}' -f $size.ToUpper()
}

$VAR_program_size = get_symbol("program_size")
$VAR_program_address = get_symbol("program_address")
$VAR_program_magic = get_symbol("program_magic")
$VAR_program_done = get_symbol("program_done")
$VAR_program_erase = get_symbol("program_erase")


$FlashLog = "$Loc\logs\flashloader.log"
(Invoke-Expression "openocd -f $Interface_cfg -c 'init;' -c 'load_image $ELF;' -c 'reset halt' -c 'sleep 100' -c 'load_image $IMAGE 0x24000000' -c 'mww $VAR_program_size $SIZE' -c 'mww $VAR_program_address $ADDRESS' -c 'mww $VAR_program_magic $MAGIC' -c 'mww $VAR_program_erase $ERASE' -c 'reg sp [mrw 0x20000000];' -c 'reg pc [mrw 0x20000004];' -c 'resume;' -c 'exit;'") *>&1 | Out-File $FlashLog -Encoding ascii -Append
if(-not $LASTEXITCODE -eq 0){
    # *>&1 | Out-File "$Loc\logs\flashloader.log" -Encoding ascii -Append)){
    Write-Host "Loading failed."
    break
}


Write-Host "Loaded flashloader, flashing SPI, please wait."

Write-Host "    (If this takes more than 2 minutes something went wrong.)"
Write-Host "    (If the screen blinks rapidly, something went wrong.)"
Write-Host "    (If the screen blinks slowly, everything worked but the script didn't detect it)"
$DONE_MAGIC = $null
 while(1){
    openocd -f $Interface_cfg -c "init; mdw $VAR_program_done" -c "exit;" *>&1 | Select-String $VAR_program_done | Tee-Object -Variable DONE_MAGIC 
    $DONE_MAGIC = "$DONE_MAGIC".split(": ")
    if($DONE_MAGIC -match "cafef00d"){
        Write-Host "Done!"
        exit;
    }
    sleep 1
} 
