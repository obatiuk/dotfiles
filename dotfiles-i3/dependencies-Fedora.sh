#!/usr/bin/env bash

. ../functions

# Enabling region51/compton copr repository for compton

sudo dnf -y copr enable region51/compton
sudo dnf -y copr enable yaroslav/rofi

# Packages

sudo dnf -y install \
    i3 \
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
    xbacklight \
    xautolock \
    pavucontrol \
    gnome-keyring \
    seahorse \
    xorg-x11-xinit-session \
    xfce4-notifyd \
    xfce4-power-manager \
    xfce4-screenshooter \
    xfce-polkit \
    xfce4-volumed \
    xfce4-settings \
    fedora-icon-theme \
    gtk-xfce-engine \
    oxygen-gtk2

# Cleanup

sudo dnf clean packages