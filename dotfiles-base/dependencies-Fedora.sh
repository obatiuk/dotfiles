#!/usr/bin/env bash

. ../functions

sudo dnf -y update

# Registering google-chrome & google-talkplugin repositories

sudo bash -c 'cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/\$basearch
enabled=1
skip_if_unavailable = 1
keepcache = 0
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF
'

sudo bash -c 'cat << EOF > /etc/yum.repos.d/google-talkplugin.repo
[google-talkplugin]
name=google-talkplugin
baseurl=http://dl.google.com/linux/talkplugin/rpm/stable/\$basearch
enabled=1
gpgcheck=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF
'

# Installing rpmfusion-free/nonfree repositories

sudo dnf -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${release}.noarch.rpm
sudo dnf -y install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${release}.noarch.rpm

# Packages

sudo dnf -y install \
    google-chrome-stable \
    google-talkplugin \
    firefox \
    google-droid-sans-fonts \
    google-droid-serif-fonts \
    google-droid-sans-mono-fonts \
    git \
    git-extras \
    unrar \
    fedora-icon-theme \
    adwaita-cursor-theme \
    gnome-keyring \
    seahorse \
    gtk2 \
    gtk3 \
    gtk-murrine-engine \
    mc \
    lynx \
    gdm \
    htop \
    crudini \
    screenfetch \
    gparted \
    meld \
    diffuse \
    ecryptfs-utils \
    adobe-source-code-pro-fonts \
    sysstat \
    gnome-keyring \
    p7zip \
    jad \
    nmap

sudo dnf -y --setopt=strict=0 install gstreamer{1,}-{ffmpeg,libav,plugins-{good,ugly,bad{,-free,-nonfree}}} 

# Cleanup

sudo dnf -y clean packages