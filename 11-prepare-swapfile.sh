#!/bin/bash
# This script write swapfile on demand

source ./envs.sh
check_var_non_empty WORKING_DIR IMAGE_MOUNT_POINT

if ! test 0 -lt "$SWAP_SIZE"
then
    echo "Find no valid SWAP_SIZE, skipping swapfile creation"
    exit 0
fi

_MP=${WORKING_DIR%/}/${IMAGE_MOUNT_POINT%/}
_SWAPFILE=@swap/swapfile

echo "Creating ${_SWAPFILE}, size ${SWAP_SIZE} MiB"
CWD=${pwd}
cd ${_MP}
btrfs subvolume create @swap
btrfs filesystem mkswapfile --size ${SWAP_SIZE}m --uuid clear ${_SWAPFILE}
cd $CWD
