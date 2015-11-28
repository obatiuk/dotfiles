#!/usr/bin/env bash

. ../functions

#
# Variables
#

dotfiles_dir=$(pwd)

#
# Setup
#

ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

# Profile

ln -sfn ${dotfiles_dir}/.face.icon ${target_dir}/.face.icon

# GTK

ln -sfn ${dotfiles_dir}/.gtkrc-2.0 ${target_dir}/.gtkrc-2.0
ln -sfn ${dotfiles_dir}/.gtkrc-2.0-kde4 ${target_dir}/.gtkrc-2.0-kde4
