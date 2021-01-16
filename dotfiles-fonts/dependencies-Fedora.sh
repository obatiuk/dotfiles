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

# Fonts

sudo dnf -y install \
    google-droid-sans-fonts \
    google-droid-serif-fonts \
    google-droid-sans-mono-fonts \
    adobe-source-code-pro-fonts \
    dejavu-fonts-common \
    dejavu-sans-fonts \
    dejavu-sans-mono-fonts \
    dejavu-serif-fonts \
    liberation-fonts-common \
    liberation-mono-fonts \
    liberation-narrow-fonts \
    liberation-sans-fonts \
    liberation-serif-fonts

# MS fonts

sudo dnf -y install http://sourceforge.net/projects/mscorefonts2/files/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Cleanup

sudo dnf clean packages
