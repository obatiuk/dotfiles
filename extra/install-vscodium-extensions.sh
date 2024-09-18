#!/usr/bin/env bash

# shellcheck disable=SC2143

# Sanity checks
command -v flatpak > /dev/null 2>&1 || { echo "'flatpak' not found. Aborting!" && exit 1; }
[ -n "$(flatpak list | grep com.vscodium.codium)" ] || { echo "'vscodium' is not installed. Aborting!" && exit 1; }

declare -a __extensions=(
	'EditorConfig.EditorConfig'
	'jianbingfang.dupchecker'
	'mechatroner.rainbow-csv'
	'bierner.markdown-mermaid'
	'bpruitt-goddard.mermaid-markdown-syntax-highlighting'
	'eamodio.gitlens'
	'ecmel.vscode-html-css'
	'EditorConfig.EditorConfig'
	'humao.rest-client'
	'jebbs.plantuml'
	'moshfeu.compare-folders'
	'ms-azuretools.vscode-docker'
	'ph-hawkins.arc-plus'
	'PKief.material-icon-theme'
	'redhat.java'
	'redhat.vscode-xml'
	'redhat.vscode-yaml'
	'streetsidesoftware.code-spell-checker'
	'timonwong.shellcheck'
	'usernamehw.errorlens'
	'vscjava.vscode-maven'
	'yzhang.markdown-all-in-one')
for extension in "${__extensions[@]}"; do
	flatpak run com.vscodium.codium --force --install-extension "${extension}"
done
