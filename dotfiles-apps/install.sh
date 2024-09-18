#!/usr/bin/env bash

# shellcheck disable=SC2154
# shellcheck disable=SC2143
# shellcheck disable=SC2016

[ -n "$(echo "$@" | grep "\-debug")" ] && set -x

#
# Variables
#

dotfiles_dir=$(dirname "$(readlink -f "$0")")

#
# Imports
#

. "${dotfiles_dir}/../functions"

#
# Setup
#

if ask "Do you want to apply 'apps' configuration?" N; then

	bash "./dependencies-${distro}@${release}.sh"


	#
	# Configuration files
	#

	stow --dir=packages --target=${HOME} -vv --stow --no-folding dotfiles-apps

	#
	# Settings
	#

	# git

	git config --global diff.tool meld
	git config --global difftool.prompt false
	git config --global difftool.meld.cmd 'meld "$LOCAL" "$REMOTE"'

	git config --global merge.tool meld
	git config --global mergetool.meld.cmd 'meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED"'

	echo "'apps' configuration was successfully applied"
else
	echo "'apps' configuration was not applied"
fi
