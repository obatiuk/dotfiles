#!/usr/bin/env bash

[ -n "$(echo $@ | grep "\-debug")" ] && set -x

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

    # Target folders

    [ -d ${target_dir}/.Xresources.d ] || mkdir -vp ${target_dir}/.Xresources.d
    [ -d ${target_dir}/.bashrc.d ] || mkdir -vp ${target_dir}/.bashrc.d

    # Profile

    ln -svfn ${dotfiles_dir}/.face.icon ${target_dir}/.face.icon

    # GTK

    ln -svfn ${dotfiles_dir}/.gtkrc-2.0 ${target_dir}/.gtkrc-2.0
    ln -svfn ${dotfiles_dir}/.gtkrc-2.0-kde4 ${target_dir}/.gtkrc-2.0-kde4

    # X settings

    ln -svfn ${dotfiles_dir}/.Xresources.d/.Xresources-fonts ${target_dir}/.Xresources.d/.Xresources-fonts

    # Bash profiles


    ln -svfn ${dotfiles_dir}/.bashrc.d/.bashrc-base ${target_dir}/.bashrc.d/.bashrc-base
    ln -svfn ${dotfiles_dir}/.bashrc.d/.bashrc-git ${target_dir}/.bashrc.d/.bashrc-git

    # Check all required resources

    checkAllResources

fi
