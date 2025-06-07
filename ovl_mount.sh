#!/bin/bash

# ovl_mount.sh
# This script is used to manage overlay mounts for layered patches.
# Useful for preserving game files as immutable layers while allowing r/w configuration.
# usage: ./ovl_mount.sh [mount|umount|help]

LAYERS=ovlfs/layers
RW_LAYER=ovlfs/rw_layer
OVL_WORK=ovlfs/work
OVL_MERGED=ovlfs/mount
# This script union-mounts everything in the current directory into a read-write layer in $RW_LAYER

mkdir -p $OVL_MERGED $RW_LAYER $OVL_WORK

function list_layers() {
    # list directories in $LAYERS
    ls -d $LAYERS/*| xargs -I{} realpath {} | sort
}

# This should accept a list of layers and mount them in $OVL_MERGED, the first argument being the bottom layer
# overlay bottom, layer1, layer2
# overlay $(list_layers)
function overlay() {
    # sort in reverse order and join with colons for lowerdir
    local layers=$(echo "$@" | tr ' ' '\n' | sort -r | paste -sd:)
    local rw_layer=$(realpath "$RW_LAYER")
    local final=$(realpath "$OVL_MERGED")
    local work=$(realpath "$OVL_WORK")

    sudo mount -v -t overlay overlay -o \
        lowerdir="$layers",upperdir="$rw_layer",workdir="$work" "$final"
}

function ovl_unmount() {
    sudo umount -v "$OVL_MERGED"
}


if [ "$1" = "umount" ]
then
    ovl_unmount
    exit 0
elif [ "$1" = "mount" ]
then
    overlay $(list_layers)
    exit 0
elif [ "$1" = "help" ]
then
    echo "Usage: $0 [mount|umount|help]"
    exit 0
else
    echo "Unknown command: $1"
    echo "Usage: $0 [mount|umount|help]"
    exit 1
fi