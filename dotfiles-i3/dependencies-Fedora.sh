#!/usr/bin/env bash

. ../functions

# Enabling region51/compton copr repository for compton

sudo dnf -y copr enable region51/compton

# Packages

sudo dnf -y install \
    i3 \
    i3status \
    i3lock \
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
    xfce4-notifyd \
    xfce4-power-manager