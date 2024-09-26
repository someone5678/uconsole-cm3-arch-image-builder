#!/bin/bash
# This script write config.txt and cmdline.txt for RPi
# will overwrite original values

source ./envs.sh
check_var_non_empty WORKING_DIR IMAGE_MOUNT_POINT

_MP=${WORKING_DIR%/}/${IMAGE_MOUNT_POINT%/}

cat << EOF > "${_MP}/boot/config.txt"
[all]
ignore_lcd=1
disable_fw_kms_setup=1
disable_audio_dither
pwm_sample_bits=20

# setup headphone detect pin
gpio=10=ip,np

# boot custom kernel
kernel=vmlinuz-linux-uconsole-rpi64
arm_64bit=1
initramfs initramfs-linux-uconsole-rpi64.img followkernel

dtoverlay=dwc2,dr_mode=host
dtoverlay=audremap,pins_12_13
dtparam=audio=on

[pi3]
dtoverlay=vc4-kms-v3d
dtoverlay=uconsole

[cm4]
arm_boost=1
max_framebuffers=2
dtoverlay=vc4-kms-v3d-pi4
dtoverlay=uconsole,cm4,hwi2c

[cm4s]
arm_boost=1
max_framebuffers=2
dtoverlay=vc4-kms-v3d-pi4
dtoverlay=uconsole,hwi2c

[all]
# whatever you need
EOF

cat << EOF > "${_MP}/boot/cmdline.txt"
root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait loglevel=3 cpufreq.default_governor=schedutil
EOF
