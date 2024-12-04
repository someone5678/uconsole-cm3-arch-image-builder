#!/bin/bash
# This script setup systemctl

source ./envs.sh

_MP=${WORKING_DIR%/}/${IMAGE_MOUNT_POINT%/}/@
_MP_ABS=$(readlink -f "${_MP}")  # further ensure absolute path

configure_systemctl() {
    chroot "$_MP_ABS" sh -c "systemctl enable NetworkManager"
    chroot "$_MP_ABS" sh -c "systemctl enable sddm"
    chroot "$_MP_ABS" sh -c "systemctl enable bluetooth"
}

configure_systemctl
