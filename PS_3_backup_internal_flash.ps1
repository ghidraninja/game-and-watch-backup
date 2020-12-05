Clear-Host

$Loc = $PSScriptRoot
Write-Host "Usage: <Adapter: jlink or stlink>"

$adapter = Read-Host
$Interface_adapter = "$Loc\openocd\interface_$adapter.cfg"
if(!(Test-Path "$Loc\logs\")){
    New-Item -Path $PSScriptRoot -Name "logs" -ItemType "directory"
  }

if( Test-Path "$Loc\backups\"){
    if( Test-Path "$Loc\backups\internal_flash_backup.bin"){
        Write-Host "Already have a backup in \backups\internal_flash_backup.bin, refusing to overwrite."
        break
    }
}

Write-Host "This step will overwrite the contents of the SPI flash chip that we backed up in step 2."
Write-Host "It will be restored in step 5. Continue? (Y/y)"
$2 = Read-Host 
if(!($2 -match 'y')){
    Write-Host "Aborted."
    break
}

Write-Host "Generating encrypted flash image from backed up data..."
Invoke-Expression "python '$Loc\python\tcm_encrypt.py' '$Loc\backups\flash_backup.bin' '$Loc\backups\itcm_backup.bin' '$Loc\payload\payload.bin' '$Loc\new_flash_image.bin'" *>&1 | Out-Null
if(-not $LASTEXITCODE -eq 0){
    Write-Host "Failed to build encrypted flash image."
    break
}

$scriptPath ="$Loc\scripts\flashloader.ps1"
Invoke-Expression "$scriptPath $adapter new_flash_image.bin" *>&1 
if(-not $LASTEXITCODE -eq 0){
    Write-Host "Flashloader failed, check debug connection and try again."
    break
}

Clear-Host
Write-Host "Flash successfully flashed. Now do the following procedure:"
Write-Host "- Disconnect power from the device"
Write-Host "- Power it again"
Write-Host "- Press and hold the power button"
Write-Host "- Press return (while still holding the power button)!"

Pause

Write-Host "Dumping internal flash..."    
Invoke-Expression "openocd -f $Interface_adapter -c 'init;' -c 'halt;' -c 'dump_image internal_flash_backup.bin 0x24000000 131072' -c 'break;'" *>&1 | Out-Null
<# if(-not $LASTEXITCODE -eq 0){
    Write-Host "Dumping internal flash failed."
    break
} #>

Move-Item $Loc\internal_flash_backup.bin $Loc\backups
$ShaBackup = 'efa04c387ad7b40549e15799b471a6e1cd234c76'
Write-Host "Verifying internal flash backup..."
if(!($ShaBackup = (Get-FileHash -Path "$Loc\backups\internal_flash_backup.bin" -algorithm SHA1))){
    Write-Host "The backup of the internal flash failed. Please try again."
    break
}

Remove-Item new_flash_image.bin

Write-Host "Device backed up successfully"
Pause