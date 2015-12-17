#!/usr/bin/env bash

. ../functions

#
# Variables
#

dotfiles_dir=$(pwd)

#
# Setup
#

if ask "Do you want to install base configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    # Profile

    ln -svfn ${dotfiles_dir}/.face.icon ${target_dir}/.face.icon

    # GTK

    ln -svfn ${dotfiles_dir}/.gtkrc-2.0 ${target_dir}/.gtkrc-2.0
    ln -svfn ${dotfiles_dir}/.gtkrc-2.0-kde4 ${target_dir}/.gtkrc-2.0-kde4

fi
