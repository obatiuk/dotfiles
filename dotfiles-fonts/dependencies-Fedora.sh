#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

# *** Fedora <25

if [ "$release" -le 25 ]; then

    # Installing external repository for infinality packages

    sudo dnf config-manager --add-repo=http://download.opensuse.org/repositories/home:/fastrizwaan/Fedora_${release}/home:fastrizwaan.repo

    # Packages

    sudo dnf -y install \
	fontconfig-infinality-ultimate \
	freetype-infinality-ultimate \


# *** Fedora 28+

elif [ "$release" -ge 29 ]; then

    # Better fonts repository

    sudo dnf copr enable dawid/better_fonts

    sudo dnf -y install \
	fontconfig-enhanced-defaults \
	fontconfig-font-replacements

fi

# Cleanup

sudo dnf clean packages
