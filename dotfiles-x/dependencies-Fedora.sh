#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

sudo dnf -y update

# Registering google-chrome & google-talkplugin repositories

sudo bash -c 'cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/\$basearch
enabled=1
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
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF
'

# Opera repository

sudo bash -c 'cat << EOF > /etc/yum.repos.d/opera.repo
[opera]
name=Opera packages
type=rpm-md
baseurl=https://rpm.opera.com/rpm
enabled=1
gpgcheck=1
gpgkey=https://rpm.opera.com/rpmrepo.key

EOF
'

# Installing rpmfusion-free/nonfree repositories

sudo dnf -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${release}.noarch.rpm
sudo dnf -y install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${release}.noarch.rpm

# Base packages

sudo dnf -y install @base-x

sudo dnf -y install \
    gnome-shell \
    fedora-icon-theme \
    adwaita-cursor-theme \
    gtk2 \
    gtk3 \
    gtk-murrine-engine \
    gdm \
    screenfetch \
    gparted \
    meld \
    diffuse \
    jad \
    pulseaudio-utils \
    gvfs-mtp \
    NetworkManager-openvpn-gnome \
    gnome-calculator

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

# Browsers

sudo dnf -y install \
    google-chrome-stable \
    google-talkplugin \
    opera-stable

# Office

sudo dnf -y install \
    libreoffice-core \
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-filters

# Codecs

sudo dnf -y --setopt=strict=0 install gstreamer{1,}-{ffmpeg,libav,plugins-{good,ugly,bad{,-free,-nonfree}}} 

# HP printer support

sudo dnf -y install \
    cups \
    hplip \
    hplip-gui
    gcc-c++ \
    dbus \
    gcc \
    libusb \
    libtool \
    libjpeg \
    xsane \
    rpm-build \
    dbus-devel \
    libjpeg-devel \
    cups-devel \
    libusb-devel \
    sane-backends-devel \
    net-snmp-devel \
    openssl-devel \
    python3-PyQt4 \
    python3-devel \
    python2-notify

# Avahi

sudo dnf -y install \
    avahi \
    avahi-tools

# Cleanup

sudo dnf -y clean packages