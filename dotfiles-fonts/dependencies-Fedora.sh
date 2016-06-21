#!/usr/bin/env bash

. ../functions

# Installing external repository for infinality packages

sudo dnf config-manager --add-repo=http://download.opensuse.org/repositories/home:/fastrizwaan/Fedora_${release}/home:fastrizwaan.repo

# Packages

sudo dnf -y install \
   freetype-infinality-ultimate \
   cabextract

sudo dnf -y install http://sourceforge.net/projects/mscorefonts2/files/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Cleanup

sudo dnf clean packages
