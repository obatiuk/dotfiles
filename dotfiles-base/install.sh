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

    [ -d ${target_dir}/.config/gtk-3.0 ] || mkdir -vp ${target_dir}/.config/gtk-3.0
    [ -d ${target_dir}/.Xresources.d ] || mkdir -vp ${target_dir}/.Xresources.d
    [ -d ${target_dir}/.bashrc.d ] || mkdir -vp ${target_dir}/.bashrc.d
    [ -d ${target_dir}/.themes ] || mkdir -vp ${target_dir}/.themes

    # Profile

    ln -svfn ${dotfiles_dir}/.face.icon ${target_dir}/.face.icon

    # Theme

    ln -svfn ${dotfiles_dir}/.themes/Arc-X ${target_dir}/.themes/Arc-X

    # GTK

    ln -svfn ${dotfiles_dir}/.gtkrc-2.0 ${target_dir}/.gtkrc-2.0
    ln -svfn ${dotfiles_dir}/.gtkrc-2.0 ${target_dir}/.gtkrc-2.0-kde4
    ln -svfn ${dotfiles_dir}/.config/gtk-3.0/settings.ini ${target_dir}/.config/gtk-3.0/settings.ini

    # X settings

    ln -svfn ${dotfiles_dir}/.Xresources.d/.Xresources-fonts ${target_dir}/.Xresources.d/.Xresources-fonts

    # Bash profiles


    ln -svfn ${dotfiles_dir}/.bashrc.d/.bashrc-base ${target_dir}/.bashrc.d/.bashrc-base
    ln -svfn ${dotfiles_dir}/.bashrc.d/.bashrc-git ${target_dir}/.bashrc.d/.bashrc-git

    # Git config

    git config --global credential.helper gnome-keyring

    # Check all required resources

    checkAllResources

    if ask "Enable GDM?"; then
	sudo systemctl enable gdm
    fi
    
    if ask "Generate default global .gitconfig?"; then
	git config --global color.ui auto
	git config --global core.autocrlf input
	git config --global push.default simple
	git config --global credential.helper gnome-keyring
    fi
fi
