Clear-Host
Write-Host "Running sanity checks..."

Invoke-Expression 'openocd -v'  *>&1 | Out-Null
if(-not $LASTEXITCODE -eq 0){
    Write-Host "OpenOCD does not seem to be working. Please validate that you have it installed correctly!"
    break
}

Invoke-Expression 'python -v'  *>&1 | Out-Null
if(-not $LASTEXITCODE -eq 0){
    Write-Host "Could not run python3. Please validate that you have it installed correctly!"
    break
}

Invoke-Expression 'arm-none-eabi-objdump -v'  *>&1 | Out-Null
if(-not $LASTEXITCODE -eq 0){
    Write-Host "Could not find arm-none-eabi-objdump. Please validate that it's installed and in PATH."
    break
}

Write-Host "Looks good!"