#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

sudo dnf -y update

# Installing rpmfusion-free/nonfree repositories

sudo dnf -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${release}.noarch.rpm
sudo dnf -y install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${release}.noarch.rpm

# Keybase repository

sudo bash -c 'cat << EOF > /etc/yum.repos.d/keybase.repo
[keybase]
name=keybase
baseurl=http://prerelease.keybase.io/rpm/x86_64
enabled=1
gpgcheck=1
gpgkey=https://keybase.io/docs/server_security/code_signing_key.asc
EOF
'

# Base system packages

sudo dnf -y install \
    NetworkManager-wifi \
    NetworkManager-openvpn \
    crda \
    redhat-lsb-core \
    nano \
    iwl*-firmware \
    gparted \
    ecryptfs-utils \
    stow \
    gnupg \
    gnupg2 \
    snapd \
    usbutils \
    pciutils \
    git \
    git-extras \
    htop \
    mc \
    keybase \
    pwgen \
    samba-client

# Additional packages

sudo dnf -y install \
    unrar \
    lynx \
    crudini \
    sysstat \
    p7zip \
    nmap \
    cabextract

# Cleanup

sudo dnf -y clean packages