#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

if ask "Install required dependencies?" N; then

sudo dnf -y groupinstall "i3 desktop"

# Packages

sudo dnf -y --best --allowerasing install \
    i3-gaps \
    xfconf \
    gnome-keyring \
    seahorse \
    i3status \
    i3lock \
    network-manager-applet \
    pnmixer \
    compton \
    feh \
    scrot \
    xautolock \
    pavucontrol \
    xorg-x11-xinit-session \
    xfce4-notifyd \
    xfce4-power-manager \
    xfce4-screenshooter \
    xfce-polkit \
    xfce4-settings \
    thunar \
    thunar-archive-plugin \
    thunar-volman \
    xarchiver \
    blueman \
    bluez-hid2hci \
    gnome-shell-extension-user-theme \
    system-config-printer \
    gvfs-smb \
    firewall-config \
    eog \
    evince \
    xdg-utils \
    file-roller \
    redshift \
    redshift-gtk \
    gedit \
    terminilogy \
    micro \
    bat

# Cleanup

sudo dnf clean packages

fi