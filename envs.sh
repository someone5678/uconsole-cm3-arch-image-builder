#!/bin/bash

# These are general configs

# working directory
WORKING_DIR="workspace/image-build"

# image file name
IMAGE_NAME="test-image.img"

# full image size, in MiB
IMAGE_SIZE=16384

# boot partition size, in MiB
BOOT_SIZE=1024

# swapfile size, in MiB. swapfile is used so the partition can be flexible
# swapfile location is hardcoded in corresponding script
SWAP_SIZE=4096

# RootFS tar ball, ommit to use pacstrap
# or read from environment
# can be online resource
# currently only support for pacstrap and http source are implemented
#ROOTFS_ARCHIVE=http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz

# Pacstrap bootstrapping settings
PACSTRAP_PACMAN_CONFIG_FILE=resources/arch-stage0-pacman.conf
# For China mainland users
#PACSTRAP_PACMAN_CONFIG_FILE=resources/arch-stage0-cn-pacman.conf

# first privileged user's name and password
if [ -f "../cred.sh" ]; then
	source ../cred.sh
else
	NEW_USER_NAME=ucon
	NEW_USER_PASSWORD=ucon
fi

# mountpoint
IMAGE_MOUNT_POINT=mp

# pacstrap extra packages
# These are packages present in official archlinuxarm repository
PACSTRAP_EXTRA_PACKAGES=(
	# Default
	# base
	# archlinuxarm-keyring
	# raspberrypi-bootloader
	# linux-firmware
	# wireless-regdb
	# networkmanager
	# vi
	# nano
	# sudo

	## Base system
	iptables-nft
	base
	base-devel
	archlinuxarm-keyring
	raspberrypi-bootloader
	raspberrypi-utils
	cryptsetup
	device-mapper
	linux-firmware
	firmware-raspberrypi
	sudo
	diffutils
	# dracut # cause kernelpanic
	inetutils
	less
	logrotate
	lsb-release
	man-db
	man-pages
	mdadm
	nano
	nano-syntax-highlighting
	perl
	s-nail
	sysfsutils
	systemd-sysvcompat
	texinfo
	which
	vi

	## Filesystem
	btrfs-progs
	dosfstools
	e2fsprogs
	exfatprogs
	f2fs-tools
	jfsutils
	lvm2
	mtools
	nfs-utils
	nilfs-utils
	ntfs-3g
	reiserfsprogs
	xfsprogs

	## Boot
	efibootmgr
	efitools

	# HARDWARE

	## X system
	mesa
	mesa-utils
	xf86-input-libinput
	xf86-video-amdgpu
	xorg-server
	xorg-xdpyinfo
	xorg-xinit
	xorg-xinput
	xorg-xkill
	xorg-xrandr

	## Network hardware
	b43-fwcutter

	## General hardware
	lsscsi
	sg3_utils
	smartmontools
	usbutils

	## Audio hardware
	alsa-firmware
	alsa-plugins
	alsa-utils
	gst-libav
	gst-plugin-pipewire
	gst-plugins-bad
	gst-plugins-ugly
	libdvdcss
	pavucontrol
	pipewire-alsa
	pipewire-jack
	pipewire-pulse
	rtkit
	sof-firmware
	wireplumber

	# SOFTWARE

	## General system
	bash-completion
	dmidecode
	dialog
	dmraid
	duf
	fakeroot
	freetype2
	git
	glances
	python-packaging
	gpm
	gptfdisk
	haveged
	hwdetect
	inxi
	libgsf
	libopenraw
	plocate
	ntp
	pacman-contrib
	pkgfile
	poppler-glib
	power-profiles-daemon
	rebuild-detector
	rsync
	tldr
	unrar
	unzip
	wget
	xdg-user-dirs
	xdg-utils
	xz

	# ## Network
	bind
	dnsmasq
	ethtool
	iwd
	modemmanager
	nbd
	ndisc6
	net-tools
	netctl
	networkmanager
	networkmanager-openconnect
	networkmanager-openvpn
	nss-mdns
	openconnect
	openvpn
	ppp
	pptpclient
	rp-pppoe
	usb_modeswitch
	vpnc
	whois
	wireless-regdb
	#wireless_tools
	wpa_supplicant
	xl2tpd
	vulkan-broadcom

	## Bluetooth
	bluez
	bluez-utils

	## Firewall
	ufw
	python-pyqt5
	python-capng

	## Live iso tools
	clonezilla
	efitools
	fsarchiver
	gpart
	gparted
	grsync
	partitionmanager
	hdparm

	## Fonts
	cantarell-fonts
	noto-fonts
	noto-fonts-emoji
	noto-fonts-cjk
	noto-fonts-extra
	ttf-bitstream-vera
	ttf-dejavu
	ttf-liberation
	ttf-opensans

	# DESKTOP

	## Desktop environment
	ark
	bluedevil
	breeze-gtk
	dolphin
	dolphin-plugins
	ffmpegthumbs
	fwupd
	gwenview
	haruna
	kate
	kcalc
	discover
	flatpak
	kde-cli-tools
	kde-gtk-config
	kdeconnect
	kdegraphics-thumbnailers
	kdenetwork-filesharing
	kdeplasma-addons
	kgamma
	kimageformats
	kinfocenter
	kio-admin
	kio-extras
	kio-fuse
	konsole
	kscreen
	kwallet-pam
	kwayland-integration
	libappindicator-gtk3
	maliit-keyboard
	okular
	plasma-browser-integration
	plasma-desktop
	plasma-disks
	plasma-firewall
	plasma-nm
	plasma-pa
	plasma-systemmonitor
	plasma-workspace
	powerdevil
	print-manager
	sddm-kcm
	spectacle
	xdg-desktop-portal-kde
	xsettingsd
	xwaylandvideobridge

	## Browser
	firefox

	## System
	meld

	# VM SUPPORT
	
	## Qemu
	qemu-guest-agent
	
	## Spice
	spice-vdagent
)

# These are custom packages, located in pkgs
CUSTOM_PACKAGES=(
	# Wireless firmware, packaged
	"pkgs/ap6256-firmware-0.1.20231120-1-any.pkg.tar.zst"
	# linux kernel
	"pkgs/linux-uconsole-rpi64-6.6.51+g0fb3c83a9fa3-1-aarch64.pkg.tar.zst"
)

######## don't change code below this line unless you understand the outcome ########
#####################################################################################

# check necessary variables
check_var_non_empty() {
	for v in "$@"
	do
		if [ -z "${!v}" ]
		then
			echo "Variable $v should not be empty! Export it or set it in envs.sh. Aborting."
			exit 1
		fi
	done
}

check_var_non_empty \
	WORKING_DIR IMAGE_NAME BOOT_SIZE

# prepare workspace folder
mkdir -p ${WORKING_DIR}

# concate to get image path
IMAGE_FILE=${WORKING_DIR%/}/${IMAGE_NAME}

# pad a little before first partition, MiB
PART_PAD_SIZE=${PART_PAD_SIZE:-16}

# limit minimum boot partition size to 300MiB
if ! test 300 -lt $BOOT_SIZE
then
	BOOT_SIZE=300
fi

# commands for parted
# using MBR to avoid tweaking hybrid MBR
PARTITION_COMMANDS=(
	"mklabel msdos"
	"mkpart primary fat32 ${PART_PAD_SIZE}MiB $((PART_PAD_SIZE+BOOT_SIZE))MiB"
	"set 1 boot on"
	"mkpart primary btrfs $((PART_PAD_SIZE+BOOT_SIZE))MiB 100%"
)
