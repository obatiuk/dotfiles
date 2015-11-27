#!/usr/bin/env bash

#
# Variables
#


dotfiles_dir=$(pwd)/dotfiles
target_dir=${HOME}
distro=$(lsb_release -si)

#
# Functions
#

ask() {
    # http://djm.me/ask
    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question - use /dev/tty in case stdin is redirected from somewhere else
        read -p "$1 [$prompt] " REPLY </dev/tty

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

#
# Setup
#

ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

# Target folders

[ -d ${target_dir}/.config ] || mkdir -p ${target_dir}/.config

# Profile

ln -sfn ${dotfiles_dir}/.face.icon ${target_dir}/.face.icon
ln -sfn ${dotfiles_dir}/.profile ${target_dir}/.profile

# i3 Configuration

ln -sfn ${dotfiles_dir}/.i3 ${target_dir}/.i3
ln -sfn ${dotfiles_dir}/.config/i3status.conf ${target_dir}/.config/i3status.conf

# Wallpaper

ln -sfn ${dotfiles_dir}/.config/wallpaper ${target_dir}/.config/wallpaper

# GTK

ln -sfn ${dotfiles_dir}/.gtkrc-2.0 ${target_dir}/.gtkrc-2.0
ln -sfn ${dotfiles_dir}/.gtkrc-2.0-kde4 ${target_dir}/.gtkrc-2.0-kde4

# Compton

ln -sfn ${dotfiles_dir}/.config/compton.conf ${target_dir}/.config/compton.conf

# Xfce4 power manager icon
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/show-tray-icon -s 1