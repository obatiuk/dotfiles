#!/usr/bin/env bash

[ -n "$(echo $@ | grep "\-debug")" ] && set -x

#
# Variables
#

dotfiles_dir=$(dirname $(readlink -f $0))

#
# Imports
#

. ${dotfiles_dir}/../functions

#
# Setup
#

if ask "Do you want to install 'apps' configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    #
    # Settings
    #

    echo "apps configuration files were successfully installed"
else
    echo "apps configuration files were not installed"
fi