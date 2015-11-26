#!/usr/bin/env bash

# Enabling region51/compton copr repository for compton

sudo dnf -y copr enable region51/compton

# Packages

sudo dnf -y install \
    network-manager-applet \
    pnmixer \
    compton \
    feh \
    ImageMagick \
    i3lock \
    scrot \
    fontawesome-fonts \
    google-droid-sans-fonts \
    google-droid-serif-fonts \
    google-droid-sans-mono-fonts \
    xbacklight \
    pavucontrol
