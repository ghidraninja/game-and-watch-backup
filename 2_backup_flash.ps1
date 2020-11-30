Clear-Host
Write-Host "Type your Adapter: jlink, stlink"
$adapter = Read-Host
 
$path = $PSScriptRoot + "\backups"
$pathSha = $PSScriptRoot + "\shasums"
if (!(Test-Path -Path $path)) {
  New-Item -Path $PSScriptRoot -Name "backups" -ItemType "directory"
}

openocd-0.10.0-15_win/bin/openocd.exe -s $PSScriptRoot"\openocd" -f flash_"$adapter".cfg 

Write-Host "Validating ITCM dump..."

if(($pathSha"\itcm_backup.bin.sha1") neq (Get-FileHash -Path $path\"itcm_backup.bin" algorithm -SHA1)){
  Write-Host "Failed to correctly dump ITCM. Restart Game & Watch and try again."
}

Write-Host "Extracting checksummed part..."
MinGW\msys\dd.exe if=backups/flash_backup.bin of=backups/flash_backup_checksummed.bin count=1040384

Write-Host "Validating checksum..."
if(($pathSha"\flash_backup_checksummed.bin.sha1") neq (Get-FileHash -Path $path\"flash_backup_checksummed.bin" algorithm -SHA1)){
  Write-Host "Failed to verify checksum. Try again."
}

Remove-Item -Path $path\"flash_backup_checksummed.bin"

Write-Host "Looks good! Successfully backed up the (encrypted) SPI flash to flash_backup.bin!"

Pause