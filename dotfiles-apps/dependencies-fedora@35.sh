#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

if ask "Install required dependencies?" N; then

	sudo dnf -y update

	# Installing rpmfusion-free/nonfree repositories

	sudo dnf -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${release}.noarch.rpm
	sudo dnf -y install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${release}.noarch.rpm

	# Registering google-chrome & google-talkplugin repositories

	if [ "$release" -le 30 ]; then

		sudo tee /etc/yum.repos.d/google-chrome.repo <<- 'EOF'
			[google-chrome]
			name=google-chrome
			baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch
			enabled=1
			gpgcheck=1
			gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
		EOF

	else

		sudo dnf config-manager --set-enabled google-chrome

	fi

	sudo tee /etc/yum.repos.d/google-talkplugin.repo <<- 'EOF'
		[google-talkplugin]
		name=google-talkplugin
		baseurl=http://dl.google.com/linux/talkplugin/rpm/stable/$basearch
		enabled=1
		gpgcheck=1
		gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
	EOF

	# Keybase repository

	sudo tee /etc/yum.repos.d/keybase.repo <<- 'EOF'
		[keybase]
		name=keybase
		baseurl=http://prerelease.keybase.io/rpm/x86_64
		enabled=1
		gpgcheck=1
		gpgkey=https://keybase.io/docs/server_security/code_signing_key.asc
	EOF

	# Opera repository

	# use `snap` to install opera. Keep repository, but disable it for now.

	sudo tee /etc/yum.repos.d/opera.repo <<- 'EOF'
		[opera]
		name=Opera packages
		type=rpm-md
		baseurl=https://rpm.opera.com/rpm
		enabled=0
		gpgcheck=1
		gpgkey=https://rpm.opera.com/rpmrepo.key
	EOF

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
		google-talkplugin

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
		hplip-gui \
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
		python3-devel

	# Other

	sudo snap install \
		chromium-ffmpeg \
		opera \
		seahorse \
		pinentry-gtk \
		pinentry-gnome3 \
		keybase \
		brave \
		intellij-idea-community \
		remarkable-desktop

	flatpak -y install \
		com.vscodium.codium

	# Cleanup

	sudo dnf clean packages

fi
