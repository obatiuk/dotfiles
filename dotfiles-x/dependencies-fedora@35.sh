#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

if ask "Install required dependencies?" N; then

sudo dnf -y update

# Base packages

sudo dnf -y install @base-x

sudo dnf -y install \
    gnome-shell \
    fedora-icon-theme \
    adwaita-cursor-theme \
    gtk2 \
    gtk3 \
    gtk-murrine-engine \
    gdm \
    screenfetch \
    gvfs-mtp \
    NetworkManager-openvpn-gnome \
    gnome-calculator

# Avahi

sudo dnf -y install \
    avahi \
    avahi-tools

# Cleanup

sudo dnf -y clean packages

fi