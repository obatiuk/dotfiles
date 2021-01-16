#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

sudo dnf -y update

sudo dnf install @gnome-desktop
sudo dnf install dnf-plugin-tracer

# Packages

sudo dnf -y --best --allowerasing install \
    fedora-workstation-repositories \
    arc-theme \
    adwaita-icon-theme \
    adwaita-cursor-theme \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-horizontal-workspaces \
    pulseaudio-utils

# Cleanup

sudo dnf clean packages