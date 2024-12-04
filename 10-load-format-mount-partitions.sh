#!/bin/bash
# This script setup loops, format partitions and mount them
# here losetup is used, kpartx can also be used

source ./envs.sh
check_var_non_empty IMAGE_FILE IMAGE_MOUNT_POINT

# stop at any error
set -e

# setup loop device
_DEVICE=$(losetup -f -P --show "${IMAGE_FILE}")

# format partitions
mkfs.vfat -I -n BOOT ${_DEVICE}p1
mkfs.btrfs -L ROOT ${_DEVICE}p2

# mount partitions: boot(p1), root(p2)
_MP=${WORKING_DIR%/}/${IMAGE_MOUNT_POINT%/}

mkdir -p ${_MP}
mount ${_DEVICE}p2 ${_MP}
CWD=$(pwd)
cd ${_MP}
btrfs subvolume create @
btrfs subvolume create @cache
btrfs subvolume create @log
btrfs subvolume create @home
cd $CWD
_MP=${WORKING_DIR%/}/${IMAGE_MOUNT_POINT%/}/@

mkdir -p ${_MP}/boot
mount ${_DEVICE}p1 ${_MP}/boot
