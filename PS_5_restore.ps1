
Clear-Host
Write-Host "Usage: <Adapter: jlink or stlink>"
$adapter = Read-Host
$Loc = $PSScriptRoot
$Interface_cfg = "$Loc\openocd\interface_" + $adapter + ".cfg"
$backup = "$Loc\backups\internal_flash_backup.bin"
if(!(Test-Path "$Loc\logs\")){
  New-Item -Path $PSScriptRoot -Name "logs" -ItemType "directory"
}

if(!(Test-Path "$Loc\backups\internal_flash_backup.bin")){
    Write-Host "No backup of internal flash found in \backups\internal_flash_backup.bin"
    break
}

if(!(Test-Path "$Loc\backups\flash_backup.bin")){
    Write-Host "No backup of SPI flash found in \backups\flash_backup.bin"
    break
}

Write-Host "Ok, restoring original firmware! (We will not lock the device, so you won't have to repeat this procedure!)"

Write-Host "Restoring internal flash..."

Invoke-Expression "openocd -f $Interface_cfg -c 'init;' -c 'halt;' -c 'program $backup 0x08000000 verify;' -c 'exit;'" *>&1  | Out-File "$Loc\logs\5_openocd.log" -Encoding ascii -Append
if(-not $LASTEXITCODE -eq 0){
    Write-Host "Restoring internal flash failed. Check debug connection and try again."
    break
}


Write-Host "Restoring SPI flash..."
$scriptPath ="$Loc\scripts\flashloader.ps1"
Invoke-Expression "$scriptPath $adapter flash_backup.bin"
if(-not $LASTEXITCODE -eq 0){
    Write-Host "Restoring SPI flash failed. Check debug connection and try again."
    break
}

Write-Host "Success, your device should be running the original firmware again!"
Write-Host "(You should power-cycle the device now)"
Pause