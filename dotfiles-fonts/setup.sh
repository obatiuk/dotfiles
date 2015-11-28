#!/usr/bin/env bash

. ../functions

#
# Variables
#

dotfiles_dir=$(pwd)

#
# Setup
#

if ask "Do you want to install font configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    # Adding configuration to the current profile

    ln -sfn ${dotfiles_dir}/.bash_profile-fonts ${target_dir}/.bash_profile-fonts

fi

