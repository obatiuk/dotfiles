#!/usr/bin/env bash

#
# Variables
#


DOTFILES_DIR=$(pwd)/dotfiles
TARGET_DIR=${HOME}
DISTRO=$(lsb_release -si)

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

ask "Install required dependencies? (Distro: ${DISTRO})?" Y && bash ./dependencies-${DISTRO}.sh

# Target folders

[ -d ${TARGET_DIR}/.config ] || mkdir -p ${TARGET_DIR}/.config

# Profile

ln -sfn ${DOTFILES_DIR}/.face.icon ${TARGET_DIR}/.face.icon

# i3 Configuration

ln -sfn ${DOTFILES_DIR}/.i3 ${TARGET_DIR}/.i3
ln -sfn ${DOTFILES_DIR}/.config/i3status.conf ${TARGET_DIR}/.config/i3status.conf

# Wallpaper

ln -sfn ${DOTFILES_DIR}/.config/wallpaper ${TARGET_DIR}/.config/wallpaper

# GTK

ln -sfn ${DOTFILES_DIR}/.gtkrc-2.0 ${TARGET_DIR}/.gtkrc-2.0
ln -sfn ${DOTFILES_DIR}/.gtkrc-2.0-kde4 ${TARGET_DIR}/.gtkrc-2.0-kde4

# Compton

ln -sfn ${DOTFILES_DIR}/.config/compton.conf ${TARGET_DIR}/.config/compton.conf