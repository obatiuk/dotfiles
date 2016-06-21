#!/usr/bin/env bash

. ../functions

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

sudo dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$release.noarch.rpm
sudo dnf install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$release.noarch.rpm

# Packages

sudo dnf install \
    google-chrome-stable \
    google-talkplugin \
    firefox \
    google-droid-sans-fonts \
    google-droid-serif-fonts \
    google-droid-sans-mono-fonts \
    git \
    filelight \
    unrar \
    fedora-icon-theme \
    adwaita-cursor-theme \
    oxygen-gtk2 \
    mc \
    htop \
    cabextract \
    unrar

# Cleanup

sudo dnf clean packages