#!/usr/bin/env bash

DOTFILES_DIR=$(pwd)/dotfiles
TARGET_DIR=${HOME}

# Target folders

[ -d ${TARGET_DIR}/.config ] || mkdir -p ${TARGET_DIR}/.config


# Profile

ln -sfn ${DOTFILES_DIR}/.face.icon ${TARGET_DIR}/.face.icon

# i3 Configuration

ln -sfn ${DOTFILES_DIR}/.config/i3status.conf ${TARGET_DIR}/.config/i3status.conf
ln -sfn ${DOTFILES_DIR}/.i3 ${TARGET_DIR}/.i3

# Wallpaper

ln -sfn ${DOTFILES_DIR}/.config/wallpaper ${TARGET_DIR}/.config/wallpaper

# GTK

ln -sfn ${DOTFILES_DIR}/.gtkrc-2.0 ${TARGET_DIR}/.gtkrc-2.0
ln -sfn ${DOTFILES_DIR}/.gtkrc-2.0-kde4 ${TARGET_DIR}/.gtkrc-2.0-kde4

# Compton

ln -sfn ${DOTFILES_DIR}/.config/compton.conf ${TARGET_DIR}/.config/compton.conf