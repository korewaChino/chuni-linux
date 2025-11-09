# CHUNITHM on Proton

> [!NOTE]
> For new and returning users
>
> If you're looking for the old legacy guide with the prototype [Stratum](https://github.com/FyraLabs/stratum) script, that one can be found [here](./legacy/README.md).
> For less literate users who just want a mutable layer of the game running on Wine, this is the guide for you!

Despite being a Windows-exclusive, proprietary arcade-only game, CHUNITHM can still be run on Linux using Wine-based compatibility layers like Proton. This guide will walk you through the process of getting CHUNITHM to run on Linux.


## Requirements

- Wine 10 or later
- Winetricks

## Setup

You'll need to prepare your game dumps (stolen from your local arcade cabinet or obtained elsewhere, i don't care) and set them up according to [here](https://two-torial.xyz/games/sega/chunithm/x-verse/setup/).

For simplicity since I know most people reading this guide is too tech illiterate to handle console commands, we'll be using Lutris to manage our Wine prefixes and launch the game.

### Installing Lutris

Install Lutris using your distribution's package manager or by following the instructions on the [Lutris website](https://lutris.net/downloads/).

### Using the Lutris install script

The provided Lutris install script will set up the Wine prefix for you, but you will need to point to the game directories yourself.

This Lutris script also automatically downloads the latest release of segatools and prompts you to point to the unencrypted game binaries.

1. Download the Lutris install script from [here](./lutris/chunithm.yml).
2. Open Lutris and click on the "+" button to add a new game.
3. Select "Import from YAML file" and choose the downloaded `chunithm.yml` file.
4. In the configuration window, set the "Game installation directory" to the path where your CHUNITHM game files are located.
5. Click "Save" to create the new game entry. Lutris will now set up the Wine prefix and install segatools for you.'
6. After the installation is complete, configure the game settings as needed

As this script makes no assumptions about your game dump structure, you will have to manually edit `segatools.ini` to include relative paths to your
update files (Option) and metadata ROMs (ICF) based on where you placed them in your game dump.

### Setting up the Wine prefix (manual method)

1. Add a new game on Lutris by clicking the "+" button and selecting "Add locally installed game".
2. Set the runner type to "Wine".
3. In the "Runner options" tab, set the "Audio Driver" option to "ALSA", this is required for proper audio output.
4. In the "Game options" tab, set the "Executable" field to point to your `start.bat` script inside your game dump directory.
5. In the "Wine prefix" field, set the path to where you want your Wine prefix to be created (e.g., `~/Games/chunithm`).
6. Click "Save" to create the new game entry.
7. Click on the game entry, then click on the dropdown arrow next to the Wine icon and select "Winetricks".
8. In the Winetricks window, install the following components:
  - `vcrun2012`
9. Close Winetricks and return to Lutris.
10. Install the rest of the dependencies manually by following the instructions in the [Setup](https://two-torial.xyz/games/sega/chunithm/x-verse/setup/) guide linked above.
