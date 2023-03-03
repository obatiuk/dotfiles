#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

if ask "Install required dependencies?" N; then

sudo dnf -y update

sudo dnf install @gnome-desktop

# Packages

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

sudo dnf -y --best --allowerasing install \
    fedora-workstation-repositories \
    arc-theme \
    adwaita-icon-theme \
    adwaita-cursor-theme \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-appindicator \
    pinentry-gtk \
    pinentry-gnome3

# Cleanup

sudo dnf clean packages

fi