#!/bin/bash
# This script install custom packages(include kernel and firmware packages)
# to the rootfs. The packages are located in `pkgs`

source ./envs.sh
check_var_non_empty WORKING_DIR IMAGE_MOUNT_POINT

_MP=${WORKING_DIR%/}/${IMAGE_MOUNT_POINT%/}/@
_PACSTRAP_EXTRA_PARAMS=()

if [ -n "$PACSTRAP_PACMAN_CONFIG_FILE" ]; then
    _PACSTRAP_EXTRA_PARAMS+="-C"
    _PACSTRAP_EXTRA_PARAMS+="$PACSTRAP_PACMAN_CONFIG_FILE"
fi

# Oops, this can be done directly by pacstrap
pacstrap -G -M "${_PACSTRAP_EXTRA_PARAMS[@]}" -U "${_MP}" "${CUSTOM_PACKAGES[@]}"
