#!/usr/bin/env bash

. ../functions

# Enabling copr repository for compton

sudo dnf -y copr enable yaroslav/i3desktop

# Packages

sudo dnf -y --best --allowerasing install \
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
    quicksynergy \
    baobab \
    gnome-shell-extension-user-theme \
    system-config-printer \
    gvfs-smb \
    firewall-config \
    gimp \
    eog \
    evince \
    xdg-utils

# Cleanup

sudo dnf clean packages
