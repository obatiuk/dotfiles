#!/usr/bin/env bash

# Sanity checks
command -v git > /dev/null 2>&1 || { echo "'git' command not found. Aborting!" && exit 1; }
command -v python3 > /dev/null 2>&1 || { echo "'python3' command not found. Aborting!" && exit 1; }
command -v pass > /dev/null 2>&1 || { echo "'pass' command not found. Aborting!" && exit 1; }

# make sure that required environment variables are set during installation
: "${PASSWORD_STORE_ENABLE_EXTENSIONS:=true}"
: "${PASSWORD_STORE_DIR:=${HOME}/.password-store}"
: "${PASSWORD_STORE_EXTENSIONS_DIR:=${PASSWORD_STORE_DIR}/.extensions}"
: "${HOME_STORAGE:=${HOME}/.home}"
: "${APP_STORAGE:=${HOME_STORAGE}/opt}"
: "${BASH_COMPLETION_USER_DIR:=${XDG_DATA_HOME:-${HOME}/.local/share}/bash-completion}/completions"

mkdir -pv "${APP_STORAGE}"
mkdir -pv "${PASSWORD_STORE_EXTENSIONS_DIR}"
mkdir -pv "${BASH_COMPLETION_USER_DIR}"

declare -a __extension_map=(
	'pass-symlink.git /src/ symlink.bash'
	'pass-age.git / age.bash'
	'pass-file.git / file.bash'
	'pass-ln.git / ln.bash'
)
for row in "${__extension_map[@]}"; do
	read -ar entry <<< "${row}"
	git clone "https://github.com/obatiuk/${entry[0]}" "${APP_STORAGE}/${entry[0]}"
	ln -s "${APP_STORAGE}/${entry[0]}${entry[1]}${entry[2]}" "${PASSWORD_STORE_EXTENSIONS_DIR}/${entry[2]}"
done

declare -a __completion_map=(
	'pass-ln.git / pass-ln.bash.completion pass-ln'
)
for row in "${__completion_map[@]}"; do
	read -ar entry <<< "${row}"
	git clone "https://github.com/obatiuk/${entry[0]}" "${APP_STORAGE}/${entry[0]}"
	ln -s "${APP_STORAGE}/${entry[0]}${entry[1]}${entry[2]}" "${BASH_COMPLETION_USER_DIR}/${entry[3]}"
done

# make sure `pass-age` extension works correctly
pass git config log.showsignature false

# pass audit installer
cd "${APP_STORAGE}" &&
	git clone "https://github.com/obatiuk/pass-audit.git" "pass-audit.git" \
		&& cd "pass-audit.git" && sudo python3 setup.py install

# other extensions that require installation
declare -a __extensions=(
	'pass-update.git'
	'pass-tessen.git'
	'pass-extension-meta.git'
	'pass-gen.git')
for extension in "${__extensions[@]}"; do
	cd "${APP_STORAGE}" && git clone "https://github.com/obatiuk/${extension}" "${extension}" \
		&& cd "${extension}" && sudo make install
done
