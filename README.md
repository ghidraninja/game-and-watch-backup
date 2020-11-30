# Game and Watch Backup and Restore tools

This repository contains pre-built tools for backing up & restoring the original Game and Watch firmware.

What you'll need:
- A Game & Watch in original state
- An ARM debug probe (Tested with J-Link and ST-Link compatible devices)
- Connections to the [debug port](https://twitter.com/ghidraninja/status/1326860677353512960) - testclips or soldered wires work well!
- A computer with Ubuntu 20.04 or compatible.


## Warnings & disclaimer

The tools in this repository will modify both the internal and the external flash of the Game and Watch.
While we tested the scripts to our best ability, we can not guarantee that there won't be failures that will leave your
Game & Watch damaged. Use these tools at your own risk. If you feel like you don't understand what you're doing it might be best to let someone with more experience help (and teach) you!


## Connecting the debugger

When connecting the debugger ensrue that at least SWDIO, SWDCLK and GND are connected. Do *not* under any circumstances connect 3.3V to the VDD connection. If your debug probe (for example ST-Link clones) does not have a VTREF connector, just leave VDD unconnected. Connecting 3.3V to VDD will likely destroy your SPI flash.


### Ubuntu setup

Install the required tools:

```
sudo apt-get install gcc-arm-none-eabi binutils-arm-none-eabi openocd python3
```

### Mac Setup

Using homebrew:
```
brew install openocd
brew tap ArmMbed/homebrew-formulae
brew install arm-none-eabi-gcc
```

## Usage

The scripts are split into 5 parts:

- 1_sanity_check.sh - Performs sanity check and makes sure all required tools are available
- 2_backup_flash.sh - Backs up the contents of the SPI flash. Does not modify device contents.
- 3_backup_internal_flash.sh - Backs up the internal flash. To do this the contents of the SPI flash are modified. Your device will stop working until it's restored in step 5.
- 4_unlock_device.sh - This will disable the active read protection. This will erase the internal flash of the STM32.
- 5_restore.sh - This will restore the original firmware.

Just run these scripts *from the checked out directory* one after each other. All scripts are safe to be re-run in case of error.

Ensure that you keep your backup in a safe place so you can always recover. Don't ask us for flash dumps & co, we will not share them.

## What if something goes wrong

As long as your electrical connections are right and you didn't short/overvolt anything, chances are high that it's rescuable:

If a script fails and the device does not work after power-cycling, repeat the script. If it fails again, try to hold the power button of the device while executing the script.

#### Something goes wrong during Step 1 & 2

Your device was not modified by the scripts, so it should just continue to work after a power cycle.

#### Something goes wrong during Step 3

Step 3 will change the internal flash of the device. If this step fails it will leave your device in a bricked state. To recover from it run:

```
./scripts/flashloader.sh <stlink or jlink> ./backups/flash_backup.bin
```

If the script can't connect to the device, press & hold down power on the device while running flashloader & try to FULLY powercycle the target between attempts.

#### Something goes wrong during Step 4

Step 4 will cause a mass erase, and leave your device empty. To restore it, run script 5.

#### Something goes wrong during Step 5

Step 5 should succeed, if it doesn't: Try to run the script while holding down the power button of the Game & Watch. Try power-cycling the target in between attempts.

## Sources for binaries

The binaries in firmware/ are based on:

- [flashloader](https://github.com/ghidraninja/game-and-watch-flashloader)
- [flashdumper](https://github.com/ghidraninja/game-and-watch-flashdumper)
