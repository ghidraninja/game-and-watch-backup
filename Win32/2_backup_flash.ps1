Clear-Host
Write-Host "Type your Adapter: jlink, stlink"
$adapter = Read-Host
 
$path = $PSScriptRoot + "\backups"
if (!(Test-Path -Path $path)) {
  New-Item -Path $PSScriptRoot -Name "backups" -ItemType "directory"
}
#Write-Host "Script file is in:" $path

openocd-0.10.0-15/bin/openocd.exe -s $PSScriptRoot"\openocd" -f flash_"$adapter".cfg 
Pause