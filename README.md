# Game and Watch Backup and Restore tools

This repository contains pre-built tools for backing up & restoring the original Game and Watch firmware.

What you'll need:
- A Game & Watch in original state
- An ARM debug probe (Tested with J-Link and ST-Link compatible devices) or a Raspberry Pi
- Connections to the [debug port](https://twitter.com/ghidraninja/status/1326860677353512960) - testclips or soldered wires work well!
- A computer with Ubuntu 20.04 or compatible.

Also see this video for a rough overview over how the scripts work: https://www.youtube.com/watch?v=-MzmoEFs0bQ

## Warnings & disclaimer

The tools in this repository will modify both the internal and the external flash of the Game and Watch.
While we tested the scripts to our best ability, we can not guarantee that there won't be failures that will leave your
Game & Watch damaged. Use these tools at your own risk. If you feel like you don't understand what you're doing it might be best to let someone with more experience help (and teach) you!
Feel free to join our [discord channel](https://discord.gg/rE2nHVAKvn) and ask any support questions in *#game-and-watch-support*.

## Read this first

This manual is for developers, and not yet suitable for end-users. The goal is to enable other developers to be able to contribute to Game & Watch development, and hopefully eventually get to a point where we can release end-user instructions :)

Please note that we recommend either a (full-size, not mini) J-Link/J-Link Edu, or an offical ST-Link. ST-Link clones have caused a lot of issues, please avoid them. Also please disconnect the battery before you continue.

## Connecting the debugger

When connecting the debugger ensure that at least SWDIO, SWDCLK and GND are connected. Do *not* under any circumstances connect 3.3V to the VDD connection. If your debug probe (for example ST-Link clones) does not have a VTREF connector, just leave VDD unconnected. Connecting 3.3V to VDD will likely destroy your SPI flash.

### Supported Debuggers

Please either use an official ST-Link (not one of the small USB stick clones) or a full-size J-Link. Others might work, a lot of them do not work with the 1.9V logic levels used on the Game and Watch.

Programmers we had a lot of trouble with: J-Link EDU Mini (does not work), cheap ST-Link clones.

### Raspberry Pi host

You can use a Raspberry Pi to back up your Game and Watch. In this case you should use a Raspbian install and follow the steps in the Ubuntu setup section but on Raspberry Pi. You need to use 3 wires: GPIO25 for SWCLK,GPIO24 for SWDIO and GND for GND (in BCM pinout notation) or you can hardcode your own gpios in openocd/rpi.cfg. A quick pinout reference on RPi can be seen by opening a terminal and running `pinout`.

### Ubuntu setup

Install the required tools:

```
sudo apt-get install binutils-arm-none-eabi python3 libhidapi-hidraw0 libftdi1 libftdi1-2
```

Note: The version of openocd included in Ubuntu 20.04 (0.10.0) does not include functionality that is needed by these scripts. A build from the unreleased master branch is needed. Please install a newer version either by building it yourself, or by installing a prebuilt package, e.g. from [this nightly build](https://github.com/kbeckmann/ubuntu-openocd-git-builder), using [xPack](https://xpack.github.io/openocd/) or similar.

### Alternative openocd location

If you used the aforementioned nightly openocd build, it will reside in the /opt directory.

To use that specific version you can either export the variable OPENOCD or prefix your commands with the variable declaration:

```
export OPENOCD="/opt/openocd-git/bin/openocd"
./1_sanity_check.sh
./2_....
```
OR
```
OPENOCD="/opt/openocd-git/bin/openocd" ; ./1_sanity_check.sh
OPENOCD="/opt/openocd-git/bin/openocd" ; ./2_....
```

Finally, you could just hardwire some variables in 'config.sh'

### Mac Setup

Using homebrew:
```
brew install --HEAD openocd
brew tap ArmMbed/homebrew-formulae
brew install arm-none-eabi-gcc
```

## Usage

Before starting, make sure to unplug the battery as it can interfere with the process. Power the device using the USB-C connector.

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

Also, as a first step, try to lower your adapter speed. When using stlink, you do this by adding `adapter speed 100` as the last line in `openocd/interface_stlink.cfg`.

#### Something goes wrong during Step 1 & 2

Your device was not modified by the scripts, so it should just continue to work after a power cycle.

#### Something goes wrong during Step 3

Step 3 will change the internal flash of the device. If this step fails it will leave your device in a bricked state. To recover from it run:

```
./scripts/flashloader.sh <stlink or jlink or rpi> ./backups/flash_backup.bin
```

If the script can't connect to the device, press & hold down power on the device while running flashloader & try to FULLY powercycle the target between attempts.

#### Something goes wrong during Step 4

Step 4 will cause a mass erase, and leave your device empty. To restore it, run script 5.

#### Something goes wrong during Step 5

Step 5 should succeed, if it doesn't: Try to run the script while holding down the power button of the Game & Watch. Try power-cycling the target in between attempts.

### Getting help and contributing

Feel free to join our [discord channel](https://discord.gg/rE2nHVAKvn) and ask any support questions in *#game-and-watch-support*.

Other channels:

- *#game-and-watch-hacking* A channel for general talk about homebrew on the Game & Watch! Please, no ROMs, no flash dumps, etc, but any code related question or other hacking ideas very welcome.
- *#replacement-pcb* In here we discuss the possibilities and development of replacement PCBs for the Game and Watch.
- [game-and-watch-hacking wiki](https://github.com/ghidraninja/game-and-watch-hacking/wiki) A reference wiki all things hacking the Game & Watch. Including internals.


## Sources for binaries

The binaries in firmware/ are based on:

- [flashloader](https://github.com/ghidraninja/game-and-watch-flashloader)
- [flashdumper](https://github.com/ghidraninja/game-and-watch-flashdumper)
