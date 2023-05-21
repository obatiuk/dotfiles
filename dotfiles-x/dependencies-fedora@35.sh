#!/usr/bin/env bash

dotfiles_dir=$(dirname $(readlink -f $0))

. ${dotfiles_dir}/../functions

if ask "Install required dependencies?" N; then

	sudo dnf -y update

	# Base packages

	sudo dnf -y install @base-x

	# Avahi

	sudo dnf -y install \
		avahi \
		avahi-tools

	# Cleanup

	sudo dnf -y clean packages

fi
