Clear-Host
Write-Host "Running sanity checks..."

if (!(openocd -v) | out-null) {
    Write-Host "OpenOCD does not seem to be working. Please validate that you have it installed correctly!"
    exit 1
}

if (!(python -V) | out-null){
    Write-Host "Could not run python3. Please validate that you have it installed correctly!"
    exit 1
}

if (!(arm-none-eabi-objdump -v) | out-null){
    Write-Host "Could not find arm-none-eabi-objdump. Please validate that it's installed and in PATH."
    exit 1
}

Write-Host "Looks good!"