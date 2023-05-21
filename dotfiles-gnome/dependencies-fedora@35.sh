#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

if ask "Install required dependencies?" N; then

	sudo dnf -y update

	sudo dnf install @gnome-desktop

	# Packages

	sudo dnf -y --best --allowerasing install \
		gdm \
		gnome-shell \
		gnome-shell-extension-dash-to-dock \
		gnome-shell-extension-appindicator \
		fedora-icon-theme \
		adwaita-icon-theme \
		adwaita-cursor-theme \
		arc-theme \
		gtk2 \
		gtk3 \
		gtk-murrine-engine \
		fedora-workstation-repositories \
		pinentry-gtk \
		pinentry-gnome3 \
		jetbrains-mono-fonts-all \
		screenfetch \
		gvfs-mtp \
		NetworkManager-openvpn-gnome \
		gnome-calculator \
		gnome-terminal \
		ddcutil \
		ulauncher

	# Cleanup

	sudo dnf clean packages

fi
