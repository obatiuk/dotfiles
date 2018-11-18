#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

# Enabling copr repositories

sudo dnf -y copr enable gregw/i3desktop

# Packages

sudo dnf -y --best --allowerasing install \
    i3-gaps \
    xfconf \
    gnome-keyring \
    seahorse \
    i3status \
    i3lock \
    network-manager-applet \
    terminology \
    pnmixer \
    compton \
    feh \
    ImageMagick \
    scrot \
    fontawesome-fonts \
    xautolock \
    pavucontrol \
    xorg-x11-xinit-session \
    xfce4-notifyd \
    xfce4-power-manager \
    xfce4-screenshooter \
    xfce-polkit \
    xfce4-settings \
    thunar \
    thunar-archive-plugin \
    thunar-volman \
    xarchiver \
    blueman \
    bluez-hid2hci \
    quicksynergy \
    baobab \
    gnome-shell-extension-user-theme \
    system-config-printer \
    gvfs-smb \
    firewall-config \
    gimp \
    eog \
    evince \
    xdg-utils \
    file-roller \
    redshift \
    redshift-gtk \
    dropbox \
    gedit

# MS fonts

sudo dnf -y install http://sourceforge.net/projects/mscorefonts2/files/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Cleanup

sudo dnf clean packages
