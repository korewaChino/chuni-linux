# CHUNITHM on Proton

This repository contains documentation and helper scripts for running CHUNITHM (or any modern PC-based arcade game) on Proton, a compatibility layer for running Windows games on Linux.

We'll be taking advantage of OverlayFS to create a virtual filesystem to keep the original game assets immutable, while providing a modifiable layer for configuration.

## Requirements

- A Linux distribution with support for OverlayFS (e.g., Ubuntu, Fedora, Arch Linux).
- [`umu-launcher`](https://github.com/Open-Wine-Components/umu-launcher)
- [`umu-wrapper`](https://github.com/korewaChino/umu-wrapper) by me!
- Filesystem dumps from your cabinet PC, obtained elsewhere.
- A basic-to-intermediate understanding of Linux command line and file system operations.
- Optional(?): A dongle DRM patch for your game (i.e segatools)
- DXVK, as CHUNITHM is still a DirectX 9 game, and Proton's DXVK implementation is required to run it properly.

## Setup

### Preparing and layering assets

To get started, prepare your game files and extract them into `ovlfs/layers` for each patch you want to apply, the directory structure should look like this:

```text
ovlfs/
├── layers/
│   ├── 2.25.00/
│   │   ├── App
│   │   ├── Option
│   ├── 2.26.00/
│   │   ├── App
│   ├── 2.27.00/ # ..and so on
│   │   ├── App
│   ├── 99-custom/ Insert your custom patches somewhere like this...
│   │   ├── App
│   │      ├──<your custom files...>
```

The `ovl_mount.sh` script should help you setup the layers and mount them correctly. Make sure to run it with the correct permissions.

> [!NOTE]
> Raw filesystem dumps are usually compressed and encrypted, you may need to find a way to decrypt and unpack the executable binaries before you can use them. This process will not be covered here. Once you have those binaries, you may place them in a layer above the actual game files (e.g. `70-binaries/`).

You may also want to create another layer for your custom patches, such as `90-patches/` where you can place your initial configuration files, custom assets, or any other modifications you want to apply to the game.

This documentation and helper scripts assumes you will be using segatools to patch the game, so you will have to extract the patches for your specific game. For CHUNITHM you will be extracting the nested `chusan.zip`, and then create a new directory in `ovlfs/layers/99-chusan/App/bin`, and place the contents of the resulting `chusan` directory there. The resulting directory structure should look like this:

```text
ovlfs/
├── layers/
│   ...
│   ├── 99-chusan/
│   │   ├── App
│   │   │   ├── bin
│   │   │   │   ├── config_hook.json
│   │   │   │   ├── inject_x64.exe
│   │   │   │   ├── inject_x86.exe
│   │   │   │   ├── segatools.ini
│   │   │   │   └── start.bat
```

### Mounting the OverlayFS

Once you're done with the layers, you can mount the OverlayFS using the provided `ovl_mount.sh` script. This script will create a virtual filesystem that combines all your layers into a single view.

```bash
./ovl_mount.sh mount
```

This will now create a mountpoint at `ovlfs/mount` where you can access the combined filesystem. The full directory tree should now be a single view, with all your layers applied in the order specified.

### Setting up Wine/Proton

To run CHUNITHM with Wine/Proton, you need to create a Wine prefix with DXVK and Visual C++ 2012 Redistributables installed, you can do this using `winetricks`

We'll also assume the wineprefix will be located in `wineprefix/` of this repository, also assumed
by all scripts in this repository.

> [!NOTE]
> If you would like to change the location of the wineprefix, modify the `WINEPREFIX` variable in `start.sh` and `ovl_mount.sh` scripts accordingly.

```bash
winetricks --force dxvk vcrun2012
```

Now, configure the prefix to add a custom drive pointing to the mounted OverlayFS:

```bash
winecfg
```

Open the `Drives` tab, and add a new drive with the path to your mounted OverlayFS, e.g., `ovlfs/mount`. You should set a drive letter to some unique letter such as `W:` or `X:` to avoid conflicts with existing drives. By default the production cabinets use `E:` for game files, and `Y:` for option files, so you may want to use `W:` for our purposes.

If you're using my `umu-wrapper`, you have to set up a Proton prefix in `~/.config/umu-wrapper.toml`:

```toml
[[template]]
name = "chuni"
prefix = "/home/cappy/Games/chuni-prefix"
proton = "/home/<USER>/.local/share/Steam/compatibilitytools.d/GE-Proton10-1"
store = "steam"

[[profile]]
name = "chuni"
template = "chuni"
game_id = "0"
exe = "explorer"
```

The above configuration will give you a template for running CHUNITHM with the `umu-wrapper`. Make sure to replace `<USER>` with your actual username and adjust the paths accordingly.

### Running the game

Once you finally installed the prerequisites and mounted the OverlayFS, you can start the game using the provided `start.sh` script. This script will take care of launching the game with the correct environment variables and settings.

Before running the game, enter the mounted OverlayFS directory:

```bash
cd ovlfs/mount
```

And then modify the `segatools.ini` configuration to point them to correct directories, for example:

```ini
[vfs]
; Insert the path to the game AMFS directory here (contains ICF1 and ICF2)
amfs=Y:/amfs
; Insert the path to the game Option directory here (contains Axxx directories)
option=Y:/Option
; Create an empty directory somewhere and insert the path here.
; This directory may be shared between multiple SEGA games.
; NOTE: This has nothing to do with Windows %APPDATA%.
; NOTE(PROTON): It's usuallly advised to set this as the root of your drive letter, as using subdirectories seems to cause ENOENT errors from amdaemon
appdata=Y:

; ... Insert your other game-specific settings here

```

Finally, run the game using the `start.sh` script:

```bash
./start.sh
```

This script will launch the game using Proton, with the necessary environment variables set up for the game to run correctly.

## Cleanup

To unmount the OverlayFS and clean up, you can use the `ovl_mount.sh` script again:

```bash
./ovl_mount.sh unmount
```

## Notes

- Wine-Staging may cause issues with DXVK installed through winetricks, so it's recommended to use Proton or a custom Wine build with DXVK support.
- Make sure to keep your layers organized and well-documented, as it can get confusing with multiple patches and configurations.
