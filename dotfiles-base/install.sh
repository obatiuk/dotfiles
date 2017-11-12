#!/usr/bin/env bash

[ -n "$(echo $@ | grep "\-debug")" ] && set -x

#
# Variables
#

dotfiles_dir=$(readlink -f "$0")

#
# Imports
#

. ${dotfiles_dir}/../functions

#
# Setup
#

if ask "Do you want to install base configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    #
    # Home folder
    #

    # Target home folders

    [ -d ${home_dir}/.config/gtk-3.0 ] || mkdir -vp ${home_dir}/.config/gtk-3.0
    [ -d ${home_dir}/.themes ] || mkdir -vp ${home_dir}/.themes

    # Profile

    ln -svfn ${dotfiles_dir}/.face.icon ${home_dir}/.face.icon

    # Theme

    ln -svfn ${dotfiles_dir}/.themes/Arc-X ${home_dir}/.themes/Arc-X

    # GTK

    ln -svfn ${dotfiles_dir}/.gtkrc-2.0 ${home_dir}/.gtkrc-2.0
    ln -svfn ${dotfiles_dir}/.gtkrc-2.0 ${home_dir}/.gtkrc-2.0-kde4
    ln -svfn ${dotfiles_dir}/.config/gtk-3.0/settings.ini ${home_dir}/.config/gtk-3.0/settings.ini

    #
    # Config folder
    #

    # Target config folders

    [ -d ${config_dir}/.Xresources.d ] || mkdir -vp ${config_dir}/.Xresources.d
    [ -d ${config_dir}/.bashrc.d ] || mkdir -vp ${config_dir}/.bashrc.d

    # X settings

    ln -svfn ${dotfiles_dir}/.home/.Xresources.d/.Xresources-fonts ${config_dir}/.Xresources.d/.Xresources-fonts

    # Bash profiles

    ln -svfn ${dotfiles_dir}/.home/.bashrc.d/.bashrc-base ${config_dir}/.bashrc.d/.bashrc-base
    ln -svfn ${dotfiles_dir}/.home/.bashrc.d/.bashrc-git ${config_dir}/.bashrc.d/.bashrc-git

    #
    # Settings
    #

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
