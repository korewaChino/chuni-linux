#!/bin/bash -x
# Rewrite of segatools hook script
# WINE_CMD="$(which wine)"
WINE_CMD="umu-wrapper --profile chuni run --"
PACKAGE_DIR="$(dirname "$(readlink -f "$0")")/ovlfs/mount/App"
export WINEPREFIX="$(dirname "$(readlink -f "$0")")/wineprefix"

UMU=1

pushd "$PACKAGE_DIR/bin"

function amdaemon() {
    $WINE_CMD inject_x64 -d -k chusanhook_x64.dll amdaemon.exe -c config_common.json config_server.json config_client.json config_cvt.json config_sp.json config_hook.json
}

function chusanApp() {
    $WINE_CMD inject_x86 -d -k chusanhook_x86.dll chusanApp.exe
}

if [ "$UMU" -ne 1 ]; then
    amdaemon &
    AM_DAEMON_PID=$!
    chusanApp

    # Kill amdaemon.exe if still running
    $WINE_CMD taskkill /f /im amdaemon.exe > /dev/null 2>&1 || true
else
    # Just run the batch script
    $WINE_CMD start.bat
fi




echo
echo "Game processes have terminated"
read -p "Press Enter to exit..."