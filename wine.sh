#!/bin/bash

# Simple wrapper for wine

PACKAGE_DIR="$(dirname "$(readlink -f "$0")")/ovlfs/mount/App"
export WINEPREFIX="$(dirname "$(readlink -f "$0")")/wineprefix"
WINE_CMD="wine"
exec $WINE_CMD $@