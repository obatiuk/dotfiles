#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

sudo dnf -y update

# Installing rpmfusion-free/nonfree repositories

sudo dnf -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${release}.noarch.rpm
sudo dnf -y install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${release}.noarch.rpm

# Registering google-chrome & google-talkplugin repositories

if [ "$release" -le 30 ]; then

sudo bash -c 'cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF
'

else

    sudo dnf config-manager --set-enabled google-chrome

fi

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

# Packages

sudo dnf -y --best --allowerasing install \
    ImageMagick \
    fontawesome-fonts \
    baobab \
    gimp \
    dropbox \
    gparted \
    meld \
    diffuse \
    jad

# Browsers

sudo dnf -y install \
    fedora-workstation-repositories \
    google-chrome-stable \
    google-talkplugin \
    opera-stable \
    chromium-libs-media-freeworld \
    chromium-freeworld

# Office

sudo dnf -y install \
    libreoffice-core \
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-filters

# Codecs

sudo dnf -y --setopt=strict=0 install \
    ffmpeg \
    gstreamer{1,}-{ffmpeg,libav,vaapi,plugins-{good,ugly,bad{,-free,-nonfree,-freeworld,-extras}}}

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
    snap

sudo snap install chromium-ffmpeg

# Cleanup

sudo dnf clean packages
