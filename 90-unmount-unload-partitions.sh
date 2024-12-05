#!/bin/bash
# This script unmount the partitions and free the loop device

source ./envs.sh
check_var_non_empty IMAGE_FILE

# gather loop device information
_DEV_INFO=$(losetup -j "${IMAGE_FILE}" | awk -F: '{ print $1 }' )

for _DEVICE in $_DEV_INFO
do
    echo "Releasing ${_DEVICE}"

    # unmount partitions, order matters
    for part in 1 2
    do
        umount -l "${_DEVICE}p$part"
    done

    # free loop device
    losetup -d "${_DEVICE}"
done
