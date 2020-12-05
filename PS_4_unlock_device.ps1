Clear-Host

$Loc = $PSScriptRoot
$rdp0_config = "$Loc\openocd\rdp0.cfg"
$Interface_cfg = "$Loc\openocd\interface_" + $1 + ".cfg"
Write-Host "Usage: <Adapter: jlink or stlink>"
$1 = Read-Host
if(!(Test-Path "$Loc\logs\")){
  New-Item -Path $PSScriptRoot -Name "logs" -ItemType "directory"
}

Write-Host "Unlocking your device will erase its internal flash. Even though your backup"
$key = Read-Host "is validated, this still can go wrong. Are you sure? (Y/y)"
if(!($key -match "y")){
    Write-Host "Aborted."
    break
}

$ShaBackup = "efa04c387ad7b40549e15799b471a6e1cd234c76"
Write-Host "Validating internal flash backup before proceeding..."
if(!(Test-Path "$Loc\backups\internal_flash_backup.bin")){
    Write-Host "Backup not found. Aborting."
    break
}
if(!($shaBackup -eq (Get-FileHash -Path "$Loc\backups\internal_flash_backup.bin" -algorithm SHA1)) | out-null){
    Write-Host "Backup is not valid. Aborting."
    break
}

Write-Host "Unlocking device... (Takes up to 30 seconds.)"    
Invoke-Expression "openocd -f $Interface_cfg -c 'init;' -c 'halt;' -f $rdp0_config" *>&1 | Out-File "$Loc\logs\4_openocd.log" -Encoding ascii -Append
if(-not $LASTEXITCODE -eq 0){
    Write-Host "Unlocking device failed."
    break
}

Write-Host "Congratulations, your device has been unlocked."
Write-Host "Please power-cycle it for the changes to take full effect."
Pause