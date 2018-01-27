#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

# Enabling copr repository for compton

sudo dnf -y copr enable yaroslav/i3desktop
sudo dnf -y copr enable mosquito/atom

# Packages

sudo dnf -y --best --allowerasing install \
    gnome-keyring \
    seahorse \
    i3-gaps \
    i3status \
    i3lock \
    rofi \
    network-manager-applet \
    terminology \
    pnmixer \
    compton \
    feh \
    ImageMagick \
    scrot \
    fontawesome-fonts \
    google-droid-sans-fonts \
    google-droid-serif-fonts \
    google-droid-sans-mono-fonts \
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
    quicksynergy \
    baobab \
    gnome-shell-extension-user-theme \
    system-config-printer \
    gvfs-smb \
    firewall-config \
    gimp \
    eog \
    evince \
    xdg-utils \
    file-roller \
    atom \
    redshift \
    redshift-gtk

# Cleanup

sudo dnf clean packages
