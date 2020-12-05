Clear-Host
Set-Location = $PSScriptRoot
$path = $PSScriptRoot + "\backups"

Write-Host "Instructions:"
Write-Host "- Type in your Adapter"
Write-Host "- Press and hold the power button"
Write-Host "- Press return (while still holding the power button)!"
Write-Host " "
Write-Host "Type your Adapter: jlink, stlink"
$adapter = Read-Host
 
if (!(Test-Path -Path $path)) {
  New-Item -Path $PSScriptRoot -Name "backups" -ItemType "directory"
}

openocd -s $PSScriptRoot"\openocd" -f flash_"$adapter".cfg 

Write-Host "Validating ITCM dump..."

$ShaITCM = "ca71a54c0a22cca5c6ee129faee9f99f3a346ca0"
$pathITCM = $PSScriptRoot + "\backups\itcm_backup.bin"
if (!(($pathShaITCM) = (Get-FileHash -Path $pathITCM -algorithm SHA1))){
  Write-Host "Failed to correctly dump ITCM. Restart Game & Watch and try again."
  break
}

$in = $PSScriptRoot + "\backups\flash_backup.bin"
$out = $PSScriptRoot + "\flash_backup_checksummed.bin"
Write-Host "Extracting checksummed part..."
dd if=$in of=$out count=1040384 bs=1

Write-Host "Validating checksum..."
$ShaBackup = "eea70bb171afece163fb4b293c5364ddb90637ae"
$pathfullBackup = $PSScriptRoot + "\backups\flash_backup_checksummed.bin"
if(!(($pathShaBackup) = (Get-FileHash -Path $pathfullBackup -algorithm SHA1))){
  Write-Host "Failed to verify checksum. Try again."
  break
}

Remove-Item -Path $out

Write-Host "Looks good! Successfully backed up the (encrypted) SPI flash to flash_backup.bin!"

Pause