#!/usr/bin/env bash

# Sanity checks
command -v git > /dev/null 2>&1 || { echo "'git' command not found. Aborting!" && exit 1; }
command -v python3 > /dev/null 2>&1 || { echo "'python3' command not found. Aborting!" && exit 1; }

# make sure that required environment variables are set during installation
: "${ULAUNCHER_EXTENSIONS:=${HOME}/.local/share/ulauncher/extensions}"
: "${HOME_STORAGE:=${HOME}/.home}"
: "${APP_STORAGE:=${HOME_STORAGE}/opt}"

# download source code and install extensions via symlinks
mkdir -pv "${APP_STORAGE}"
mkdir -pv "${ULAUNCHER_EXTENSIONS}"

declare -a __extension_map=(
	'ulauncher ulauncher-emoji.git'
	'yannishuber pass-ulauncher.git'
	'caraterra pass-for-ulauncher.git'
	'caraterra pass-otp-for-ulauncher.git'
	'mikebarkmin ulauncher-obsidian.git'
)
for row in "${__extension_map[@]}"; do
	read -ar entry <<< "${row}"
	git clone "https://github.com/${entry[0]}/${entry[1]}" "${APP_STORAGE}/${entry[1]}"
	ln -s "${APP_STORAGE}/${entry[1]}" "${ULAUNCHER_EXTENSIONS}/com.github.${entry[0]}.${entry[1]//.git/}"
done
