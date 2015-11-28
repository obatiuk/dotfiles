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

# Packages

sudo dnf install \
    google-chrome-stable \
    google-talkplugin \
    firefox
