#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

if ask "Install required dependencies?" N; then

	sudo dnf -y update

	# Installing rpmfusion-free/nonfree repositories

	sudo dnf -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${release}.noarch.rpm
	sudo dnf -y install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${release}.noarch.rpm

	# Base system packages

	sudo dnf -y install \
		NetworkManager-wifi \
		NetworkManager-openvpn \
		crda \
		redhat-lsb-core \
		nano \
		iwl*-firmware \
		ecryptfs-utils \
		stow \
		gnupg2 \
		pinentry-tty \
		snapd \
		usbutils \
		pciutils \
		git \
		git-extras \
		htop \
		mc \
		pwgen \
		samba-client \
		tree \
		rpmconf \
		rsync \
		restic \
		rclone \
		bat \
		fzf \
		fd-find \
		ydiff \
		power-profiles-daemon \
		pass \
		pass-otp \
		screen \
		tio

	# Additional packages

	sudo dnf -y install \
		unrar \
		lynx \
		crudini \
		sysstat \
		p7zip \
		nmap \
		cabextract \
		iotop \
		qrencode \
		acpi

	# dnf plugins

	sudo dnf -y install \
		dnf-plugin-diff \
		dnf-plugins-extras-tracer

	# Plymouth

	sudo dnf -y install \
		plymouth \
		plymouth-system-theme

	# Cleanup

	sudo dnf -y clean packages

fi
