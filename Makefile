#!/usr/bin/env make -f
.ONESHELL:
.DEFAULT_GOAL := help

SHELL = /bin/bash
# .SHELLFLAGS := -eu -o pipefail -c # Useful debug options
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

COLOR_GREEN := \033[0;32m
COLOR_RED := \033[0;31m
COLOR_BLUE := \033[0;34m
COLOR_YELLOW := \033[0;33m
END_COLOR := \033[0m

INFO := $(COLOR_GREEN)
WARN := $(COLOR_YELLOW)
ERR := $(COLOR_RED)

colon := :
$(colon) := :
space := $(subst ,, )
dash := -
slash := /

export XDG_CONFIG_HOME ?= $(HOME)/.config
export XDG_DATA_HOME ?= $(HOME)/.local/share
export XDG_CACHE_HOME ?= $(HOME)/.cache
export XDG_PICTURES_DIR ?= $(HOME)/Private/Pictures
export NVM_DIR ?= $(XDG_DATA_HOME)/nvm

top := $(shell pwd)
now := $(shell date +%Y-%m-%d_%H:%M:%S)
uid := $(shell id -u)
model := $(shell (if command -v hostnamectl > /dev/null 2>&1; \
	then hostnamectl | grep 'Hardware Model:' | sed 's/^.*: //'; \
	else sudo dmidecode -s system-product-name ; fi) | tr "[:upper:]" "[:lower:]")
OS_RELEASE_EOL=$(shell grep -o 'SUPPORT_END=.*' /etc/os-release | sed 's/SUPPORT_END=//' )

INCLUDE = ./include

NVM_PATH = $(NVM_DIR)
NVM_CMD = . $(NVM_PATH)/nvm.sh && nvm

MAKEFILE_NAME := $(abspath $(lastword $(MAKEFILE_LIST)))
DOTFILES := $(abspath $(dir $(MAKEFILE_NAME)))
DOTHOME := $(abspath $(HOME)/.home)
BASHRCD := $(abspath $(HOME)/.bashrc.d)
HOME_BIN := $(abspath $(DOTHOME)/bin)
HOME_OPT := $(abspath $(DOTHOME)/opt)
PASS_HOME := $(abspath $(HOME)/.password-store)
PASS_EXT := $(abspath $(PASS_HOME)/.extensions)

VIVALDI_CF_SRC := $(DOTFILES)/.config/vivaldi/CustomUIModifications
VIVALDI_CF_DEST := $(XDG_CONFIG_HOME)/vivaldi/CustomUIModifications
ULAUNCHER_EXT := $(XDG_DATA_HOME)/ulauncher/extensions
STREAMDECK_CF_SRC := $(DOTFILES)/.config/streamdeck-ui
STREAMDECK_CF_DEST := $(XDG_CONFIG_HOME)/streamdeck-ui

INSTALL =
PATCH =
UPDATE =
CLEAN =
SETUP =
CHECK =
BACKUP =

ARC_THEME_SOURCE ?= git

########################################################################################################################
#
# Includes
#

# Include model-specific patches
-include $(INCLUDE)/$(subst $(space),$(dash),$(model)).mk

########################################################################################################################
#
# Functions
#

# Remove all URI components except package name and arch if the package is an URL
# Force package installation if `-B` flag is present
define dnf
	$(foreach pkg, $(strip $(1)), \
		$(eval $@_PACKAGE = $(pkg)) \
		$(eval $@_SOURCE = $(pkg)) \
		$(if $(findstring $(slash),$($@_PACKAGE)), \
			$(eval $@_PACKAGE = $(subst .rpm,$(space),$(lastword $(subst $(slash),$(space),$(pkg)))))) \
		$(if $(findstring B,$(firstword -$(MAKEFLAGS))), \
			sudo dnf -y install $($@_SOURCE);, \
			rpm -q $($@_PACKAGE) >& /dev/null || sudo dnf -y install $($@_SOURCE);))
endef

define clone
	mkdir -pv $(HOME_OPT)
	if [ ! -d $(HOME_OPT)/$(1) ]; then git clone 'https://github.com/obatiuk/$(1)' $(HOME_OPT)/$(1); fi
	cd $(HOME_OPT)/$(1) && git pull
endef

define log
	echo -e "$(subst ",,$(1))$(subst ",,$(2))$(END_COLOR)"
endef

########################################################################################################################
#
# Packages
#

# All rpm packages that are not directly referenced
packages_rpm := rpm dnf redhat-lsb rpmconf pwgen systemd pam-u2f pamu2fcfg xdg-user-dirs audit golang akmods mokutil
packages_rpm += iwl*-firmware fwupd bluez bash bash-completion avahi avahi-tools samba-client tree brightnessctl
packages_rpm += hplip hplip-gui xsane ffmpeg feh nano htop btop fzf less xdg-utils httpie lynis cheat tldr
packages_rpm += ImageMagick baobab gimp gparted gnome-terminal seahorse cups duf ssh-audit coreutils openssl
packages_rpm += libreoffice-core libreoffice-writer libreoffice-calc libreoffice-filters minder firefox
packages_rpm += gnome-pomodoro gnome-clocks fd-find ydiff webp-pixbuf-loader usbguard
packages_rpm += fastfetch bc usbutils pciutils acpi policycoreutils-devel pass-otp pass-audit
packages_rpm += gnupg2 pinentry-gtk pinentry-tty pinentry-gnome3 gedit gedit-plugins gedit-plugin-editorconfig
packages_rpm += gvfs-mtp screen tio dialog catimg cifs-utils sharutils binutils
packages_rpm += restic rsync rclone micro wget xsensors lm_sensors curl jq
packages_rpm += unrar lynx crudini sysstat p7zip nmap cabextract iotop qrencode uuid
packages_rpm += git diffutils git-lfs git-extras git-credential-libsecret git-crypt bat mc gh perl-Image-ExifTool
packages_rpm += snapd calibre clamav clamav-freshclam
packages_rpm += fedora-workstation-repositories
packages_rpm += adwaita-icon-theme adwaita-cursor-theme dconf
packages_rpm += python3 python3-pip python3-devel python3-virtualenv

# DNF plugins
plugins_dnf := dnf-plugins-core dnf-plugin-diff python3-dnf-plugin-tracer dnf-plugin-system-upgrade
plugins_dnf += remove-retired-packages dracut-config-rescue clean-rpm-gpg-pubkey python3-dnf-plugin-show-leaves
plugins_dnf += python3-dnf-plugin-rpmconf

# All `snap` packages that are not directly referenced
packages_snap := chromium-ffmpeg brave intellij-idea-community

# All **user** `flatpak` packages that are not directly referenced
packages_flatpak := com.vscodium.codium org.gnupg.GPA org.gtk.Gtk3theme.Arc-Darker eu.betterbird.Betterbird

# Font packages
packages_fonts := google-droid-sans-fonts google-droid-serif-fonts google-droid-sans-mono-fonts
packages_fonts += google-roboto-fonts adobe-source-code-pro-fonts dejavu-sans-fonts dejavu-sans-mono-fonts
packages_fonts += dejavu-serif-fonts liberation-fonts-common liberation-mono-fonts liberation-narrow-fonts
packages_fonts += liberation-sans-fonts liberation-serif-fonts jetbrains-mono-fonts-all fontawesome4-fonts

# GNOME Shell extensions
packages_gshell := gnome-shell-extension-dash-to-dock gnome-shell-extension-appindicator
packages_gshell += gnome-shell-extension-frippery-move-clock gnome-shell-extension-gsconnect
packages_gshell += gnome-shell-extension-sound-output-device-chooser gnome-shell-extension-freon
packages_gshell += gnome-shell-extension-blur-my-shell gnome-shell-extension-user-theme
packages_gshell += gnome-shell-extension-no-overview

ext_gshell := https\://extensions.gnome.org/extension/1401/bluetooth-quick-connect
ext_gshell += https\://extensions.gnome.org/extension/3780/ddterm
ext_gshell += https\://extensions.gnome.org/extension/4451/logo-menu
ext_gshell += https\://extensions.gnome.org/extension/4470/media-controls
ext_gshell += https\://extensions.gnome.org/extension/1112/screenshot-tool
ext_gshell += https\://extensions.gnome.org/extension/277/impatience/

# VSCode extensions
ext_vscode := EditorConfig.EditorConfig jianbingfang.dupchecker mechatroner.rainbow-csv bierner.markdown-mermaid
ext_vscode += bpruitt-goddard.mermaid-markdown-syntax-highlighting eamodio.gitlens ecmel.vscode-html-css
ext_vscode += humao.rest-client jebbs.plantuml moshfeu.compare-folders ms-azuretools.vscode-docker ph-hawkins.arc-plus
ext_vscode += PKief.material-icon-theme redhat.java redhat.vscode-xml redhat.vscode-yaml
ext_vscode += streetsidesoftware.code-spell-checker timonwong.shellcheck usernamehw.errorlens vscjava.vscode-maven
ext_vscode += yzhang.markdown-all-in-one

# Ulauncher extensions
ext_ulauncher += ulauncher-emoji.git pass-ulauncher.git pass-for-ulauncher.git pass-otp-for-ulauncher.git
ext_ulauncher += ulauncher-obsidian.git ulauncher-numconverter.git ulauncher-list-keywords.git

# IntelliJ extensions
ext_intellij := ru.adelf.idea.dotenv lermitage.intellij.battery.status Docker name.kropp.intellij.makefile
ext_intellij += com.jetbrains.packagesearch.intellij-plugin com.jetbrains.plugins.ini4idea

# micro extensions
ext_micro += $(addprefix micro_,editorconfig fzf filemanager)

vivaldi_conf_files := $(shell find .config/vivaldi/CustomUIModifications -type f -name '*.*')
vivaldi_conf_dest_files := $(addprefix $(HOME)/, $(vivaldi_conf_files))

streamdeck_conf_files := $(shell find .config/streamdeck-ui -type f -name '*.*')
streamdeck_conf_dest_files := $(addprefix $(HOME)/, $(streamdeck_conf_files))

ext_pass_dest_files = $(addprefix $(PASS_EXT)/,symlink.bash age.bash ln.bash file.bash update.bash tessen.bash \
	meta.bash)

########################################################################################################################
#
# Package installation customizations and aliases
#

INSTALL += dnf-plugins
dnf-plugins: $(plugins_dnf)

INSTALL += dnf-settings
dnf-settings: | crudini
	@sudo crudini --ini-options=nospace --set /etc/dnf/dnf.conf main fastestmirror 1
	@sudo crudini --ini-options=nospace --set /etc/dnf/dnf.conf main max_parallel_downloads 10
	@sudo crudini --ini-options=nospace --set /etc/dnf/dnf.conf main deltarpm true
	@sudo crudini --ini-options=nospace --set /etc/dnf/dnf.conf main ip_resolve 4

INSTALL += ecryptfs-utils
ecryptfs-utils:
	@$(call dnf,$@)
	@sudo modprobe ecryptfs
	@sudo usermod -aG ecryptfs '$(USER)'

INSTALL += fonts-better
fonts-better: /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:gombosg\:better_fonts.repo
	@$(call dnf,fontconfig-enhanced-defaults fontconfig-font-replacements)

INSTALL += fonts_ms
fonts-ms:
	@$(call dnf,http://sourceforge.net/projects/mscorefonts2/files/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm)

INSTALL += fonts
fonts: $(packages_fonts) fonts-better fonts-ms

INSTALL += flatpak
flatpak: gnome-desktop
	@$(call dnf,$@)
	@flatpak remotes | grep 'flathub' > /dev/null || flatpak remote-add --if-not-exists \
		flathub https://flathub.org/repo/flathub.flatpakrepo
	@flatpak --user remotes | grep 'flathub' > /dev/null || flatpak --user remote-add --if-not-exists \
		flathub https://flathub.org/repo/flathub.flatpakrepo
	@flatpak install --system org.gtk.Gtk3theme.Arc-Darker

INSTALL += nvm
nvm: | git
	@mkdir -pv $(NVM_PATH)
	@PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

INSTALL += npm
npm: | nvm
	@. $(NVM_PATH)/nvm.sh && nvm install --lts

INSTALL +=git-split-diffs
git-split-diffs: npm
	@. $(NVM_PATH)/nvm.sh && npm install -g git-split-diffs

# Disable GNOME search engine
INSTALL += disable-gnome-tracker
disable-gnome-tracker: | gnome-desktop gnome-tracker-settings
	-@sudo systemctl --user mask \
		tracker-extract-3.service \
		tracker-miner-fs-3.service \
		tracker-miner-rss-3.service \
		tracker-writeback-3.service \
		tracker-xdg-portal-3.service \
		tracker-miner-fs-control-3.service
	-@tracker3 reset -s -r || true

INSTALL += docker
docker: /etc/yum.repos.d/docker-ce.repo | systemd
	@sudo dnf -y remove --exclude=container-selinux \
		docker \
		docker-client \
		docker-client-latest \
		docker-common \
		docker-latest \
		docker-latest-logrotate \
		docker-logrotate \
		docker-selinux \
		docker-engine-selinux \
		docker-engine
	@$(call dnf,docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
	@sudo groupadd --force docker
	@sudo usermod -aG docker '$(USER)'
	@sudo systemctl enable --now docker

INSTALL += ql700
ql700: | cups
	@$(call dnf,https://download.brother.com/welcome/dlfp002191/ql700pdrv-3.1.5-0.i386.rpm)
	# Fix QL-700 brother printer access when SELinux is enabled
	# Source:
	# - http://support.brother.com/g/s/id/linux/en/faq_prn.html?c=us_ot&lang=en&comple=on&redirect=on#f00115
	# - http://www.pclinuxos.com/forum/index.php?topic=138727.0
	@sudo restorecon -RFv /usr/lib/cups/filter/*
	@sudo setsebool -P cups_execmem 1
	@sudo setsebool mmap_low_allowed 1

INSTALL += codecs
codecs: | /etc/yum.repos.d/rpmfusion-free.repo /etc/yum.repos.d/rpmfusion-nonfree.repo /etc/yum.repos.d/fedora-cisco-openh264.repo
	@sudo dnf -y --setopt=strict=0 install \
		gstreamer{1,}-{ffmpeg,libav,vaapi,plugins-{good,ugly,bad{,-free,-nonfree,-freeworld,-extras}}}
	@sudo dnf -y install *openh264

INSTALL += gnome-desktop
gnome-desktop:
	@# Force group installation if -B flag is present
	@$(if $(findstring B,$(firstword -$(MAKEFLAGS))), \
		@sudo dnf -y group install $@, \
		@sudo dnf group list --installed --hidden | grep $@ > /dev/null || sudo dnf -y group install $@)

INSTALL += google-chrome
google-chrome: | gnome-desktop /etc/yum.repos.d/google-chrome.repo
	@$(call dnf,google-chrome-stable)

INSTALL += vivaldi-bin
vivaldi-bin: | gnome-desktop /etc/yum.repos.d/vivaldi-fedora.repo
	@$(call dnf,vivaldi-stable)

INSTALL += vivaldi
vivaldi: | vivaldi-bin $(vivaldi_conf_dest_files)

INSTALL += opera
opera: | gnome-desktop /etc/yum.repos.d/opera.repo
	@$(call dnf,opera-stable)

INSTALL += keybase
keybase: | gnome-desktop /etc/yum.repos.d/keybase.repo
	@$(call dnf,$@)

INSTALL += arduino
arduino: flatpak
	@flatpak -y --user install cc.arduino.arduinoide cc.arduino.IDE2
	@sudo usermod -aG dialout,tty,lock '$(USER)'

INSTALL += vscode
vscode: | com.vscodium.codium $(ext_vscode)

INSTALL += ddcutil
ddcutil: | /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:rockowitz\:ddcutil.repo
	@$(call dnf,$@)

INSTALL += morewaita-icon-theme
morewaita-icon-theme: | /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:dusansimic\:themes.repo
	@$(call dnf,$@)
	@sudo gtk-update-icon-cache -f -t /usr/share/icons/MoreWaita && xdg-desktop-menu forceupdate

INSTALL += ulauncher
ulauncher:
	@$(call dnf,$@)
	@systemctl --user daemon-reload
	@systemctl --user enable --now ulauncher.service

INSTALL += ulauncher-extensions
ulauncher-extensions: ulauncher $(ext_ulauncher)
	-@systemctl --user restart ulauncher.service

INSTALL += gnome-themes
gnome-themes: | gnome-desktop adwaita-icon-theme adwaita-cursor-theme morewaita-icon-theme arc-theme

INSTALL += gnome-shell-extensions
gnome-shell-extensions: | gnome-desktop $(packages_gshell) $(ext_gshell)
	@gsettings set org.gnome.shell disable-user-extensions false
	-@gnome-extensions disable 'window-list@gnome-shell-extensions.gcampax.github.com'
	-@gnome-extensions disable 'places-menu@gnome-shell-extensions.gcampax.github.com'

ifeq ($(ARC_THEME_SOURCE),git)
# `arc-theme` package from the official repository doesn't have latest patches
# Use patched Arc themes version from git: https://github.com/jnsh/arc-theme/blob/master/INSTALL.md
INSTALL += arc-theme
arc-theme: | gnome-desktop git arc-theme-git-install arc-them-git-build

arc-theme-git-install:
	@sudo dnf -y remove arc-theme
	# install pre-requisites
	@$(call dnf,optipng gnome-themes-extra gtk-murrine-engine meson inkscape sassc glib2-devel gdk-pixbuf2 \
		gtk3-devel gtk4-devel autoconf automake)

# Using SELF_CALL=xxx to avoid `inkscape` segfaults during build (https://gitlab.com/inkscape/inkscape/-/issues/4716)
arc-them-git-build:
	@mkdir -pv $(HOME_OPT)
	@rebuild_theme=false
	@if [ ! -d $(HOME_OPT)/arc-theme ]; then
		cd $(HOME_OPT) && git clone https://github.com/obatiuk/arc-theme --depth 1
		cd $(HOME_OPT)/arc-theme && git pull
		cd $(HOME_OPT)/arc-theme && meson setup --reconfigure --prefix=$(HOME)/.local \
			-Dvariants=dark,darker \
			-Dthemes=gnome-shell,gtk2,gtk3,gtk4 \
			build
		rebuild_theme=true
	fi
	@if [ $$rebuild_theme == true ] || [ ! z $$(cd $(HOME_OPT)/arc-theme && git diff --shortstat HEAD) ]; then
		cd $(HOME_OPT)/arc-theme && git pull
		cd $(HOME_OPT)/arc-theme && SELF_CALL=true bash -c 'meson install -C build'
		mkdir -p $(HOME)/.themes
		for theme in Arc{,-Dark,-Darker,-Lighter}{,-solid}; do
			if [ -d $(XDG_DATA_HOME)/themes/$${theme} ]; then
				ln -svfn $(XDG_DATA_HOME)/themes/$${theme} $(HOME)/.themes/$${theme}
			fi
		done
	fi

UPDATE += arc-theme-git-update
arc-theme-git-update: | git arc-them-git-build

CLEAN += arch-theme-git-clean
arch-theme-git-clean:
	@cd $(HOME_OPT)/arc-theme && meson compile --clean -C build

else
# Install `arc-theme` from the official repository. Updates will be tracked by default
INSTALL += arc-theme
arc-theme:
	@$(call dnf,arc-theme)
	@rm -rf $(HOME_OPT)/arc-theme
	@rm -rf $(XDG_DATA_HOME)/themes/Arc{,-Dark,-Darker,-Lighter}{,-solid}
	@rm -rf $(HOME)/.themes/Arc{,-Dark,-Darker,-Lighter}{,-solid}
endif

INSTALL += plymouth
plymouth:
	@$(call dnf,$@ plymouth-system-theme)
	@sudo plymouth-set-default-theme bgrt -R
	@sudo grub2-mkconfig -o /etc/grub2.cfg

INSTALL += power-profiles-daemon
power-profiles-daemon:
	@$(call dnf,$@)
	@sudo systemctl enable --now power-profiles-daemon

INSTALL += pass
pass: | git
	@$(call dnf,$@)
	@mkdir -pv "$(HOME)/.password-store"

INSTALL += pass-extensions
pass-extensions: | pass pass-otp pass-audit $(ext_pass_dest_files)

INSTALL += authselect
authselect: | pam-u2f ecryptfs-utils
	@# FIXME: add check if all settings are applied already
	@$(call dnf,$@)
	@authselect check \
		&& sudo authselect select sssd with-ecryptfs with-fingerprint with-pam-u2f without-nullok -b \
		|| $(call log,$(ERR),'Current authselect configuration is NOT valid. Aborting to avoid more damage.');

INSTALL += gnome-shell-extensions-bin
gnome-shell-extensions-bin: | gnome-desktop git
	@$(call clone,install-gnome-extensions.git)
	@ln -snvf $(HOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh $(HOME_BIN)/install-gnome-extensions
	@chmod u+x $(HOME_BIN)/install-gnome-extensions

UPDATE += gnome-shell-extensions-bin-update
gnome-shell-extensions-bin-update:
	@if [ -d $(HOME_OPT)/install-gnome-extensions.git ]; then cd $(HOME_OPT)/install-gnome-extensions.git && git pull; fi

INSTALL += pip
pip: | python3 python3-pip
	@python -m pip install --upgrade pip

INSTALL += streamdeck-ui
streamdeck-ui: | python3-devel pip $(streamdeck_conf_dest_files)
	@$(call dnf,hidapi)
	@python -m pip install streamdeck-linux-gui --user

INSTALL += smartmontools
smartmontools:
	@$(call dnf,$@)
	@sudo systemctl enable --now smartd

INSTALL += meld
meld: | gnome-desktop dconf
	@$(call dnf,$@)
	@dconf load '/' < $(INCLUDE)/meld.ini

INSTALL += obsidian
obsidian: | flatpak
	#@flatpak install md.obsidian.Obsidian

INSTALL += steam
steam: | flatpak /etc/yum.repos.d/rpmfusion-nonfree.repo
	@$(call dnf,steam-devices)
	@flatpak install --user flathub com.valvesoftware.Steam \
		com.valvesoftware.Steam.CompatibilityTool.Proton \
		com.valvesoftware.Steam.Utility.gamescope \
		org.freedesktop.Platform.VulkanLayer.gamescope
	@flatpak override --user --filesystem=/run/udev:ro com.valvesoftware.Steam

INSTALL += snap
snap: | snapd /snap
	@sudo snap set system refresh.retain=2

INSTALL += logrotate
logrotate:
	@$(call dnf,$@)
	@sudo systemctl enable --now logrotate.timer
	# Add missing logrotate rules (F39)
	@sudo tee /etc/logrotate.d/dnf <<- EOF
	#
	# Updated by dotfiles setup script on $$(date -I) by ${USER}
	#
	/var/log/hawkey.log /var/log/dnf.librepo.log /var/log/dnf.rpm.log /var/log/dnf.log {
		missingok
		notifempty
		rotate 4
		weekly
		create 0600 root root
	}
	EOF

INSTALL += browserpass-bin
browserpass-bin:
	@$(call clone,browserpass-native.git)
	@cd $(HOME_OPT)/browserpass-native.git && make browserpass configure
	@cd $(HOME_OPT)/browserpass-native.git && sudo make install
	@cd $(HOME_OPT)/browserpass-native.git && make hosts-chrome-user hosts-firefox-user hosts-vivaldi-user \
		policies-chrome-user policies-vivaldi-user

CLEAN += browserpass-clean
browserpass-clean:
	@cd $(HOME_OPT)/browserpass-native.git && make clean

INSTALL += browserpass
browserpass: | git coreutils golang pass pass-extensions $(PASS_HOME)/.browserpass.json vivaldi google-chrome firefox \
	browserpass-bin browserpass-clean

INSTALL += geoclue2
geoclue2: | crudini
	@$(call dnf, $@)
	@sudo crudini --ini-options=nospace --set /etc/geoclue/geoclue.conf wifi enable true
	@sudo crudini --ini-options=nospace --set /etc/geoclue/geoclue.conf wifi url 'https://beacondb.net/v1/geolocate'
	@sudo systemctl restart geoclue

INSTALL += proton-mail-bridge
proton-mail-bridge: | pass
	@sudo dnf -y install https://proton.me/download/bridge/protonmail-bridge-3.13.0-1.x86_64.rpm
	@if ! grep -q "protonmail-credentials" "$(HOME)/.password-store/.gitignore"; then \
		echo "protonmail-credentials" >> "$(HOME)/.password-store/.gitignore"; \
		echo "docker-credential-helpers" >> "$(HOME)/.password-store/.gitignore"; fi

########################################################################################################################
#
# GNOME settings
#

INSTALL += gnome-key-binding-settings
gnome-key-binding-settings: | gnome-desktop $(HOME_BIN)/dell-kvm-switch-input ulauncher
	@$(eval custom0=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/)
	@$(eval custom1=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/)
	@$(eval custom2=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/)
	@$(eval custom3=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/)

	@gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$(custom0)', '$(custom1)', '$(custom2)', '$(custom3)']"

	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom0) name 'Run Terminal'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom0) command '$(shell command -v gnome-terminal)'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom0) binding '<Super>t'

	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom1) name 'Dell KVM - Switch Input'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom1) command '$(HOME_BIN)/dell-kvm-switch-input'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom1) binding '<Alt>i'

	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom2) name 'Display Ulauncer'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom2) command '$(shell command -v ulauncher-toggle)'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom2) binding '<Super>r'

	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom3) name 'Run System Monitor'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom3) command '$(shell command -v gnome-system-monitor)'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom3) binding '<Shift><Control>Escape'

	@gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>h']"
	@gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>l']"
	@gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "['<Super>s']"

	# Possible fix for a sporadic flight-mode toggle
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill []
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-bluetooth []
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-bluetooth-static []
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-static []

INSTALL += gnome-theme-settings
gnome-theme-settings: | gnome-themes arc-theme gnome-shell-extension-user-theme \
		$(XDG_CONFIG_HOME)/gtk-2.0/gtkrc \
		$(XDG_CONFIG_HOME)/gtk-3.0/settings.ini $(XDG_CONFIG_HOME)/gtk-3.0/gtk.css \
		$(XDG_CONFIG_HOME)/gtk-4.0/settings.ini
	@gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Darker'
	@gsettings set org.gnome.desktop.wm.preferences theme 'Arc-Darker'
	@gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'
	@gsettings set org.gnome.desktop.wm.preferences titlebar-uses-system-font true
	@gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier '<Super>'

INSTALL += gnome-wallpaper
gnome-wallpaper: $(XDG_DATA_HOME)/backgrounds/current | gnome-desktop
	@gsettings set org.gnome.desktop.background picture-uri 'file://$<'
	@gsettings set org.gnome.desktop.background picture-uri-dark 'file://$<'
	@gsettings set org.gnome.desktop.background color-shading-type 'solid'
	@gsettings set org.gnome.desktop.background picture-options 'zoom'

INSTALL += gnome-input-settings
gnome-input-settings: | gnome-desktop
	@gsettings set org.gnome.desktop.wm.keybindings switch-applications []
	@gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward []
	@gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Primary>Tab']"
	@gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Primary><Shift>Tab']"
	@gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Primary>grave']"
	@gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Primary><Shift>grave']"
	@gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
	@gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
	@gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
	@gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
	@gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Shift><Super>x']"
	@gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Shift><Super>z']"
	@gsettings set org.gnome.desktop.wm.keybindings maximize "['<Shift><Super>f']"
	@gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up []
	@gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down []
	@gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left []
	@gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right []

	@gsettings set org.gnome.mutter.keybindings toggle-tiled-left []
	@gsettings set org.gnome.mutter.keybindings toggle-tiled-right []

	@gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru'), ('xkb', 'ua')]"
	@gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb', 'us'), ('xkb', 'ru'), ('xkb', 'ua')]"
	@gsettings set org.gnome.desktop.input-sources per-window false
	@gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:ralt_switch']"

	@gsettings set org.gnome.desktop.peripherals.keyboard numlock-state false
	@gsettings set org.gnome.desktop.peripherals.keyboard delay 180
	@gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 15
	@gsettings set org.gnome.desktop.peripherals.mouse speed -0.44

	@gsettings set org.gnome.desktop.peripherals.touchpad edge-scrolling-enabled false
	@gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
	@gsettings set org.gnome.desktop.peripherals.touchpad speed 0.068
	@gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true

INSTALL += gnome-desktop-settings
gnome-desktop-settings: | gnome-desktop fonts
	@# Desktop
	@gsettings set org.gnome.desktop.interface show-battery-percentage true
	@gsettings set org.gnome.desktop.interface clock-show-date true
	@gsettings set org.gnome.desktop.interface clock-show-weekday true
	@gsettings set org.gnome.desktop.interface text-scaling-factor '1.0'
	@gsettings set org.gnome.desktop.background show-desktop-icons false
	@gsettings set org.gnome.desktop.datetime automatic-timezone true
	@gsettings set org.gnome.desktop.screensaver lock-enabled true
	@gsettings set org.gnome.desktop.screensaver lock-delay 0
	@gsettings set org.gnome.desktop.session idle-delay 600
	@gsettings set org.gnome.desktop.sound event-sounds false
	@gsettings set org.gnome.desktop.calendar show-weekdate false
	@gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
	@gsettings set org.gnome.mutter dynamic-workspaces false
	@gsettings set org.gnome.mutter workspaces-only-on-primary false
	@gsettings set org.gnome.SessionManager logout-prompt false

	# Fonts
	@gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Mono 10'
	@gsettings set org.gnome.desktop.interface font-name 'Sans 9'
	@gsettings set org.gnome.desktop.interface document-font-name 'Sans 9'
	@gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
	@gsettings set org.gnome.desktop.interface font-hinting 'slight'
	@gsettings set org.gnome.desktop.interface cursor-size 24
	@gsettings set org.gnome.desktop.interface cursor-blink true

	@gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', \
		'intellij-idea-community_intellij-idea-community.desktop', 'com.vscodium.codium.desktop', \
		'vivaldi-stable.desktop', 'google-chrome.desktop', 'firefox.desktop', 'md.obsidian.Obsidian.desktop', \
		'xmind.desktop', 'org.gnome.gedit.desktop', 'chrome-cinhimbnkkaeohfgghhklpknlkffjgod-Profile_4.desktop', \
		'chrome-hpfldicfbfomlpcikngkocigghgafkph-Profile_4.desktop', 'org.gnome.Pomodoro.desktop', \
		'cc.arduino.IDE2.desktop', 'calibre-gui.desktop', 'com.valvesoftware.Steam.desktop']"


# GNOME display settings
INSTALL += gnome-display-settings
gnome-display-settings: | gnome-desktop
	@gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

	@gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4378
	@gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	@gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
	@gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 6.0
	@gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 20.0
	@gsettings set org.gnome.settings-daemon.plugins.color recalibrate-display-threshold 0

INSTALL += gnome-nautilus-settings
gnome-nautilus-settings: | gnome-desktop
	@gsettings set org.gnome.nautilus.preferences show-create-link true
	@gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
	@gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'where', 'date_modified']"
	@gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'
	@gsettings set org.gnome.nautilus.preferences always-use-location-entry true
	@gsettings set org.gnome.nautilus.preferences show-delete-permanently true
	@gsettings set org.gnome.nautilus.preferences show-hidden-files true

INSTALL += gnome-file-chooser-settings
gnome-file-chooser-settings: | gnome-desktop
	@gsettings set org.gtk.Settings.FileChooser sort-column 'name'
	@gsettings set org.gtk.Settings.FileChooser date-format 'regular'
	@gsettings set org.gtk.Settings.FileChooser show-hidden true
	@gsettings set org.gtk.Settings.FileChooser clock-format '24h'
	@gsettings set org.gtk.Settings.FileChooser startup-mode 'cwd'
	@gsettings set org.gtk.Settings.FileChooser show-type-column true
	@gsettings set org.gtk.Settings.FileChooser sort-order 'ascending'
	@gsettings set org.gtk.Settings.FileChooser type-format 'category'
	@gsettings set org.gtk.Settings.FileChooser show-size-column true
	@gsettings set org.gtk.Settings.FileChooser location-mode 'path-bar'
	@gsettings set org.gtk.Settings.FileChooser sort-directories-first true

INSTALL += gnome-screenshot-settings
gnome-screenshot-settings: | gnome-desktop
	@gsettings set org.gnome.gnome-screenshot auto-save-directory 'file://$(XDG_PICTURES_DIR)/Screenshots'
	@gsettings set org.gnome.gnome-screenshot last-save-directory 'file://$(XDG_PICTURES_DIR)/Screenshots'
	@gsettings set org.gnome.gnome-screenshot default-file-type 'png'
	@gsettings set org.gnome.gnome-screenshot include-pointer false
	@gsettings set org.gnome.gnome-screenshot delay 2
	@gsettings set org.gnome.gnome-screenshot take-window-shot false

INSTALL += gnome-power-settings
gnome-power-settings: | gnome-desktop
	@gsettings set org.gnome.settings-daemon.plugins.power idle-dim true
	@gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
	@gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 30
	@gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery true
	@gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled true
	@gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1200
	@gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
	@gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'
	@gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'

INSTALL += gnome-privacy-settings
gnome-privacy-settings: | gnome-desktop
	@gsettings set org.gnome.desktop.privacy old-files-age 10
	@gsettings set org.gnome.desktop.privacy remove-old-temp-files true
	@gsettings set org.gnome.desktop.privacy remove-old-trash-files false
	@gsettings set org.gnome.desktop.privacy usb-protection-level 'lockscreen'

	@gsettings set org.gnome.desktop.notifications show-banners false
	@gsettings set org.gnome.desktop.notifications show-in-lock-screen false
	@gsettings set org.gnome.login-screen disable-user-list true
	@gsettings set org.gnome.shell remember-mount-password false
	@gsettings set org.gnome.system.location enabled true
	@gsettings set org.gnome.desktop.search-providers disable-external true

INSTALL += gnome-gedit-settings
gnome-gedit-settings: | gedit dconf
	@dconf load '/' < $(INCLUDE)/gnome-gedit.ini

INSTALL += gnome-tracker-settings
gnome-tracker-settings: | dconf
	@dconf load '/' < $(INCLUDE)/gnome-tracker.ini

INSTALL += gnome-terminal-settings
gnome-terminal-settings: | gnome-terminal dconf
	@dconf load '/' < $(INCLUDE)/gnome-terminal.ini

INSTALL += gnome-pomodoro-settings
gnome-pomodoro-settings: | gnome-pomodoro dconf
	@dconf load '/' < $(INCLUDE)/gnome-pomodoro.ini

INSTALL += gnome-clocks-settings
gnome-clocks-settings: | gnome-clocks dconf
	@dconf load '/' < $(INCLUDE)/gnome-clocks.ini

########################################################################################################################
#
# Bulk installation rules
#

INSTALL += $(plugins_dnf)
$(plugins_dnf):
	@$(call dnf,$@)

INSTALL += $(packages_rpm)
$(packages_rpm): | gnome-desktop
	@$(call dnf,$@)

INSTALL += $(packages_fonts)
$(packages_fonts):
	@$(call dnf,$@)

INSTALL += $(packages_gshell)
$(packages_gshell): | gnome-desktop
	@$(call dnf,$@)
	@if [ -f $(INCLUDE)/$@.ini ]; then dconf load '/' < $(INCLUDE)/$@.ini; fi

INSTALL += $(packages_snap)
$(packages_snap): | gnome-desktop snapd /snap
	@sudo snap install $@

INSTALL += $(packages_flatpak)
$(packages_flatpak): | gnome-desktop flatpak
	@flatpak install --user $@

INSTALL += $(ext_ulauncher)
$(ext_ulauncher): | git ulauncher
	@$(call clone,$@)
	@mkdir -pv $(ULAUNCHER_EXT)
	@ln -svfn $(HOME_OPT)/$@ $(ULAUNCHER_EXT)/$(subst .git,,$@)

INSTALL += $(ext_gshell)
$(ext_gshell): | gnome-desktop dconf gnome-shell-extensions-bin
	@mkdir -pv $(HOME_OPT)
	@$(eval __ext=$(subst $(slash),$(space),$(subst https://extensions.gnome.org/extension/,,$(strip $@))))
	@$(eval __ext_id=$(word 1, $(__ext)))
	@$(eval __ext_name=$(word 2, $(__ext)))
	@if [ -f $(INCLUDE)/gnome-shell-extension-$(__ext_name).ini ]; then dconf load '/' < $(INCLUDE)/gnome-shell-extension-$(__ext_name).ini; fi
	@$(HOME_BIN)/install-gnome-extensions --enable $(__ext_id)

INSTALL += $(ext_vscode)
$(ext_vscode): | flatpak com.vscodium.codium
	@flatpak run --user com.vscodium.codium --force --install-extension '$@'

INSTALL += $(ext_intellij)
$(ext_intellij): | intellij-idea-community $(HOME_BIN)/acpi-battery-status
	@$$(command -v intellij-idea-community) installPlugins $@

INSTALL += $(ext_micro)
$(ext_micro): | micro fzf
	@$$(command -v micro) -plugin install $(subst micro_,,$@)

########################################################################################################################
#
# Files
#

FILES += /snap
/snap: /var/lib/snapd/snap | snapd
	@sudo ln -svnf $< $@

FILES += /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:gombosg\:better_fonts.repo
/etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:gombosg\:better_fonts.repo:
	@sudo dnf copr enable gombosg/better_fonts
	# Delete previously used copr repository (if available)
	-@sudo rm -fv /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:chriscowleyunix\:better_fonts.repo

FILES += /etc/yum.repos.d/docker-ce.repo
/etc/yum.repos.d/docker-ce.repo: | dnf-plugins
	@sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

FILES += /etc/yum.repos.d/google-chrome.repo
/etc/yum.repos.d/google-chrome.repo: | dnf-plugins fedora-workstation-repositories
	@sudo dnf config-manager --set-enabled google-chrome

FILES += /etc/yum.repos.d/vivaldi-fedora.repo
/etc/yum.repos.d/vivaldi-fedora.repo: | dnf-plugins
	@sudo dnf config-manager --add-repo https://repo.vivaldi.com/stable/vivaldi-fedora.repo

FILES += /etc/yum.repos.d/opera.repo
/etc/yum.repos.d/opera.repo:
	-@sudo rpm --import https://rpm.opera.com/rpmrepo.key
	@sudo tee $@ <<- EOF
		#
		# Created by dotfiles setup script on $$(date -I) by ${USER}
		#
		[opera]
		name=Opera packages
		type=rpm-md
		baseurl=https://rpm.opera.com/rpm
		enabled=1
		gpgcheck=1
		gpgkey=https://rpm.opera.com/rpmrepo.key
	EOF

FILES += /etc/yum.repos.d/keybase.repo
/etc/yum.repos.d/keybase.repo:
	@sudo tee $@ <<- EOF
		#
		# Created by dotfiles setup script on $$(date -I) by ${USER}
		#
		[keybase]
		name=keybase
		baseurl=http://prerelease.keybase.io/rpm/x86_64
		enabled=1
		gpgcheck=1
		gpgkey=https://keybase.io/docs/server_security/code_signing_key.asc
	EOF

FILES += /etc/yum.repos.d/rpmfusion-free.repo
/etc/yum.repos.d/rpmfusion-free.repo:
	@$(call dnf,\
		https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(shell rpm -E %fedora).noarch.rpm)

FILES += /etc/yum.repos.d/rpmfusion-nonfree.repo
/etc/yum.repos.d/rpmfusion-nonfree.repo:
	@$(call dnf,\
		https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(shell rpm -E %fedora).noarch.rpm)

FILES += /etc/yum.repos.d/fedora-cisco-openh264.repo
/etc/yum.repos.d/fedora-cisco-openh264.repo: | dnf-plugins
	@sudo dnf config-manager --set-enabled fedora-cisco-openh264

FILES += /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:rockowitz\:ddcutil.repo
/etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:rockowitz\:ddcutil.repo:
	@sudo dnf copr enable -y rockowitz/ddcutil

FILES += /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:dusansimic\:themes.repo
/etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:dusansimic\:themes.repo:
	@sudo dnf copr enable -y dusansimic/themes

FILES += $(HOME)/.bashrc
$(HOME)/.bashrc: $(DOTFILES)/.bashrc
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(HOME)/.bash_profile
$(HOME)/.bash_profile: $(DOTFILES)/.bash_profile
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(HOME)/.bash_logout
$(HOME)/.bash_logout: $(DOTFILES)/.bash_logout
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-git
$(BASHRCD)/bashrc-git: $(DOTFILES)/.bashrc.d/bashrc-git | git
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-base
$(BASHRCD)/bashrc-base: $(DOTFILES)/.bashrc.d/bashrc-base | git
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-fonts
$(BASHRCD)/bashrc-fonts: $(DOTFILES)/.bashrc.d/bashrc-fonts | fonts
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-xdg
$(BASHRCD)/bashrc-xdg: $(DOTFILES)/.bashrc.d/bashrc-xdg | xdg-utils
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-dev
$(BASHRCD)/bashrc-dev: $(DOTFILES)/.bashrc.d/bashrc-dev
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-pass
$(BASHRCD)/bashrc-pass: $(DOTFILES)/.bashrc.d/bashrc-pass | pass pass-extensions
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-steam
$(BASHRCD)/bashrc-steam: $(DOTFILES)/.bashrc.d/bashrc-steam
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(HOME)/.face.icon
$(HOME)/.face.icon: $(DOTFILES)/.face.icon
	@ln -svnf $< $@

FILES += $(XDG_CONFIG_HOME)/git/config
$(XDG_CONFIG_HOME)/git/config: $(DOTFILES)/.config/git/config | git git-lfs git-credential-libsecret \
		git-split-diffs bat meld perl-Image-ExifTool
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(HOME)/.trackerignore
$(HOME)/.trackerignore: $(DOTFILES)/.trackerignore | disable-gnome-tracker
	@ln -svnf $< $@

FILES += $(HOME)/.editorconfig
$(HOME)/.editorconfig : $(DOTFILES)/.editorconfig
	@ln -svfn $< $@

FILES += $(HOME)/.passgenrc
$(HOME)/.passgenrc : $(DOTFILES)/.passgenrc | pass
	@ln -svfn $< $@

FILES += $(HOME_BIN)/dell-kvm-switch-input
$(HOME_BIN)/dell-kvm-switch-input: $(DOTFILES)/.home/bin/dell-kvm-switch-input | ddcutil
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(HOME_BIN)/acpi-battery-status
$(HOME_BIN)/acpi-battery-status: $(DOTFILES)/.home/bin/acpi-battery-status | acpi
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(XDG_CONFIG_HOME)/gtk-2.0/gtkrc
$(XDG_CONFIG_HOME)/gtk-2.0/gtkrc: $(DOTFILES)/.config/gtk-2.0/gtkrc | gnome-desktop
	 @ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/gtk-3.0/settings.ini
$(XDG_CONFIG_HOME)/gtk-3.0/settings.ini: $(DOTFILES)/.config/gtk-3.0/settings.ini | gnome-desktop
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/gtk-3.0/gtk.css
$(XDG_CONFIG_HOME)/gtk-3.0/gtk.css: $(DOTFILES)/.config/gtk-3.0/gtk.css | gnome-desktop
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/gtk-3.0/bookmarks
$(XDG_CONFIG_HOME)/gtk-3.0/bookmarks: | gnome-desktop
	@tee $@ <<- EOF
		file://$(HOME)/Private/Sync
		file://$(HOME)/Projects
		file://$(HOME)/Temp
		file://$(HOME)/Documents/Private/Notes/Default/Files
	EOF

FILES += $(XDG_CONFIG_HOME)/gtk-4.0/settings.ini
$(XDG_CONFIG_HOME)/gtk-4.0/settings.ini: $(DOTFILES)/.config/gtk-4.0/settings.ini | gnome-desktop
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/user-dirs.dirs
$(XDG_CONFIG_HOME)/user-dirs.dirs: $(DOTFILES)/.config/user-dirs.dirs | xdg-user-dirs
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(XDG_CONFIG_HOME)/mc/ini
$(XDG_CONFIG_HOME)/mc/ini: $(DOTFILES)/.config/mc/ini | mc
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(vivaldi_conf_dest_files)
$(VIVALDI_CF_DEST)/%: $(VIVALDI_CF_SRC)/%
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(streamdeck_conf_dest_files)
$(STREAMDECK_CF_DEST)/%: $(STREAMDECK_CF_SRC)/%
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += /etc/udev/rules.d/81-ppm.auto.rules
/etc/udev/rules.d/81-ppm.auto.rules: | power-profiles-daemon
	@sudo tee $@ <<- EOF
		#
		# Created by dotfiles setup script on $$(date -I) by ${USER}
		#
		# Custom udev rules to select power-profiles-daemon profile based on power status
		#
		ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
		ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
	EOF
	@sudo udevadm control --reload-rules && sudo udevadm trigger

FILES += /etc/NetworkManager/conf.d/00-randomize-mac.conf
/etc/NetworkManager/conf.d/00-randomize-mac.conf: | gnome-desktop
	@sudo tee $@ <<- EOF
		#
		# Created by dotfiles setup script on $$(date -I) by ${USER}
		#
		[device]
		wifi.scan-rand-mac-address=yes

		[connection]
		wifi.cloned-mac-address=random
		ethernet.cloned-mac-address=random
		connection.stable-id=\$${CONNECTION}/\$${BOOT}
	EOF
	@sudo systemctl restart NetworkManager

FILES += /etc/systemd/logind.conf.d/power.conf
/etc/systemd/logind.conf.d/power.conf: | systemd
	@sudo mkdir -pv $(@D)
	@sudo tee $@ <<- EOF
		#
		# Created by dotfiles setup script on $$(date -I) by ${USER}
		#
		[Login]
		HandlePowerKey=ignore
		HandleLidSwitchExternalPower=ignore
	EOF

FILES += /etc/systemd/resolved.conf.d/dnssec.conf
/etc/systemd/resolved.conf.d/dnssec.conf: | systemd
	@sudo mkdir -pv $(@D)
	@sudo tee $@ <<- EOF
		#
		# Created by dotfiles setup script on $$(date -I) by ${USER}
		#
		[Resolve]
		DNSSEC=true
	EOF
	@sudo systemctl restart systemd-resolved

FILES += $(XDG_CONFIG_HOME)/systemd/user/streamdeck.service
$(XDG_CONFIG_HOME)/systemd/user/streamdeck.service: | systemd streamdeck-ui
	@mkdir -pv $(@D)
	@tee $@ <<- EOF
		#
		# Created by dotfiles setup script on $$(date -I) by ${USER}
		#
		[Unit]
		Description=A Linux compatible UI for the Elgato Stream Deck.
		Wants=gnome-session-initialized.target
		After=gnome-session-initialized.target

		[Service]
		Type=simple
		Environment="STREAMDECK_UI_LOG_FILE=/dev/null"
		Environment="STREAMDECK_UI_CONFIG=$(HOME)/.config/streamdeck-ui/ui.json"
		WorkingDirectory=$(HOME)
		ExecStart=$(HOME)/.local/bin/streamdeck -n
		Restart=on-failure

		[Install]
		WantedBy=graphical-session.target
	EOF
	@systemctl --user daemon-reload
	@systemctl --user enable --now streamdeck.service

FILES += /etc/udev/rules.d/60-streamdeck.rules
/etc/udev/rules.d/60-streamdeck.rules: | streamdeck-ui
	@sudo mkdir -pv $(@D)
	@sudo tee $@ <<- EOF
		#
		# Created by dotfiles setup script on $$(date -I) by ${USER}
		#
		# Custom udev rules to select power-profiles-daemon profile based on power status
		#
		SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0063", TAG+="uaccess"
		KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess", GROUP="input", MODE="0660"
	EOF
	@sudo udevadm control --reload-rules && sudo udevadm trigger

FILES += $(XDG_CONFIG_HOME)/wget/wgetrc
$(XDG_CONFIG_HOME)/wget/wgetrc: | wget $(BASHRCD)/bashrc-xdg
	@mkdir -pv $(@D)
	@mkdir -pv $(XDG_CACHE_HOME)/wget
	@echo -e "#\n# Created by dotfiles setup script on $$(date -I) by ${USER} \n#\n--hsts-file=$(XDG_CACHE_HOME)/wget/hsts" > $@

FILES += $(XDG_DATA_HOME)/backgrounds/current
$(XDG_DATA_HOME)/backgrounds/current: $(DOTFILES)/.local/share/backgrounds/morphogenesis-d.svg
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(PASS_HOME)/.gpg-id
$(PASS_HOME)/.gpg-id: | pass
	@mkdir -pv $(@D)
	@pass init 8D49EF72

FILES += $(PASS_HOME)/.gitattributes
$(PASS_HOME)/.gitattributes: | pass git
	@mkdir -pv $(@D)
	@pass git init
	@pass git config log.showsignature false

FILES += $(PASS_HOME)/.gitignore
$(PASS_HOME)/.gitignore: $(DOTFILES)/.password-store/.gitignore | pass
	@mkdir -pv $(@D)
	@\cp -vf $< $@

FILES += $(PASS_HOME)/.browserpass.json
$(PASS_HOME)/.browserpass.json: $(DOTFILES)/.password-store/.browserpass.json | pass
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(PASS_EXT)/symlink.bash
$(PASS_EXT)/symlink.bash: | git pass
	@$(call clone,pass-symlink.git)
	@mkdir -pv $(@D)
	@ln -svfn $(HOME_OPT)/pass-symlink.git/src/symlink.bash $@

FILES += $(PASS_EXT)/age.bash
$(PASS_EXT)/age.bash: | git pass
	@$(call clone,pass-age.git)
	@mkdir -pv $(@D)
	@ln -svfn $(HOME_OPT)/pass-age.git/age.bash $@

FILES += $(PASS_EXT)/file.bash
$(PASS_EXT)/file.bash: | git pass
	@$(call clone,pass-file.git)
	@mkdir -pv $(@D)
	@ln -svfn $(HOME_OPT)/pass-file.git/file.bash $@

FILES += $(PASS_EXT)/ln.bash
$(PASS_EXT)/ln.bash: | git pass
	@$(call clone,pass-ln.git)
	@mkdir -pv $(@D)
	@mkdir -pv $(XDG_DATA_HOME)/bash-completion/completions
	@ln -svfn $(HOME_OPT)/pass-ln.git/pass-ln.bash $@
	@ln -svfn $(HOME_OPT)/pass-ln.git/pass-ln.bash.completion $(XDG_DATA_HOME)/bash-completion/completions/pass-ln

FILES += $(PASS_EXT)/update.bash
$(PASS_EXT)/update.bash: | git pass
	@$(call clone,pass-update.git)
	@mkdir -pv $(@D)
	@mkdir -pv $(XDG_DATA_HOME)/bash-completion/completions
	@ln -svfn $(HOME_OPT)/pass-update.git/update.bash $@
	@ln -svfn $(HOME_OPT)/pass-update.git/share/bash-completion/completions/pass-update $(XDG_DATA_HOME)/bash-completion/completions/pass-update

FILES += $(PASS_EXT)/tessen.bash
$(PASS_EXT)/tessen.bash: | git pass
	@$(call clone,pass-tessen.git)
	@mkdir -pv $(@D)
	@mkdir -pv $(XDG_DATA_HOME)/bash-completion/completions
	@ln -svfn $(HOME_OPT)/pass-tessen.git/tessen.bash $@
	@ln -svfn $(HOME_OPT)/pass-tessen.git/completion/pass-tessen.bash-completion $(XDG_DATA_HOME)/bash-completion/completions/pass-tessen

FILES += $(PASS_EXT)/meta.bash
$(PASS_EXT)/meta.bash: | git pass
	@$(call clone,pass-extension-meta.git)
	@mkdir -pv $(@D)
	@mkdir -pv $(XDG_DATA_HOME)/bash-completion/completions
	@ln -svfn $(HOME_OPT)/pass-extension-meta.git/src/meta.bash $@
	@ln -svfn $(HOME_OPT)/pass-extension-meta.git/completion/pass-meta.bash.completion $(XDG_DATA_HOME)/bash-completion/completions/pass-meta

FILES += /usr/local/bin/pass-gen
/usr/local/bin/pass-gen: | git pass .passgenrc
	@$(call clone,pass-gen.git)
	@cd $(HOME_OPT)/pass-gen.git && sudo make install

FILES += /etc/usbguard/rules.conf
/etc/usbguard/rules.conf: | usbguard
	@sudo sh -c 'usbguard generate-policy > /etc/usbguard/rules.conf'
	@sudo chmod 0600 /etc/usbguard/rules.conf
	@sudo systemctl enable --now usbguard

FILES += /etc/pki/akmods/certs/public_key.der
/etc/pki/akmods/certs/public_key.der: | akmods mokutil openssl
	@sudo kmodgenca -a

########################################################################################################################
#
# Patches
#

# Set correct timezone and enable synchronization
PATCH += patch-time-sync
patch-time-sync: | systemd
	@timedatectl set-timezone 'America/New_York'
	@timedatectl set-ntp true

# Make sure that the system is configured to maintain the RTC in universal time
PATCH += patch-local-rtc
patch-local-rtc: | systemd
	@if [ "$$(timedatectl show -p LocalRTC --value)" == "yes" ]; then timedatectl set-local-rtc 0 --adjust-system-clock; fi

# Detect modules to be loaded by lm_sensors
PATCH += /etc/sysconfig/lm_sensors
/etc/sysconfig/lm_sensors: | lm_sensors
	@sudo sensors-detect

########################################################################################################################
#
# Updates
#

UPDATE += update-dnf
update-dnf: check-release-eol
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO),"\\nUpdating system packages using 'dnf' ... \\n")
	@sudo dnf update --refresh

UPDATE += update-check-rpmconf
update-check-rpmconf: | rpmconf update-dnf
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO),"\\nChecking for unmerged configuration files ...\\n")
	@sudo rpmconf -at > /dev/null || $(call log,$(WARN),"Warning: There are unmerged system configuration files. \
		use 'make check-rpmconf' to review them\\n")

UPDATE += update-flatpak
update-flatpak: | flatpak
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO),"\\nUpdating 'flatpak' packages ...\\n")
	@flatpak update
	@flatpak update --user

UPDATE += update-firmware
update-firmware: | fwupd
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO), "\\nUpdating firmware ...\\n")
	@fwupdmgr get-updates --force
	@fwupdmgr update

########################################################################################################################
#
# Cleaning
#

CLEAN += clean-dnf
clean-dnf:
	@sudo dnf clean all

CLEAN += clean-packages
clean-package: | dnf-plugins
	@sudo dnf autoremove
	@sudo remove-retired-packages

CLEAN += clean-journal
clean-journal: | systemd
	@sudo journalctl --rotate
	@sudo journalctl --vacuum-size=500M

CLEAN += clean-docker
clean-docker: | docker
	@docker system prune

CLEAN += clean-flatpak
clean-flatpak: | flatpak
	@flatpak uninstall --unused

CLEAN += clean-snap
clean-snap: | snap
	-@LANG=C snap list --all | awk '/disabled/{print $$1" --revision "$$3}' | xargs -rn3 sudo snap remove

########################################################################################################################
#
# Setup rules
#

SETUP += setup-ecryptfs
setup-private-home: ecryptfs-utils authselect
	@ecryptfs-setup-private

SETUP += setup-auth-keys
setup-auth-keys: pam-u2f pamu2fcfg authselect
	@# TODO: add implementation

SETUP += setup-mok-keys
setup-mok-keys: /etc/pki/akmods/certs/public_key.der
	@if [[ "$$(sudo mokutil --test-key $< 2>&1)" =~ "is not enrolled" ]]; then \
		sudo mokutil --import $<; \
		sudo mokutil --list-new; \
		sudo akmods --force; \
		$(call log,$(WARN),"Warning: You must restart ASAP to run MOK manager"); \
	fi

########################################################################################################################
#
# Verification rules
#

CHECK += check-security-updates
check-security-updates:
	@sudo dnf -q check-update --security || $(call log,$(WARN),"Warning: There are security updates available!");

CHECK += check-dnf-autoremove
check-dnf-autoremove:
	@if [ $$(sudo dnf list -q --autoremove | wc -l) -gt 0 ]; then $(call log,$(WARN),"Warning: There are candidate rpm packages for autoremoval"); fi

CHECK += check-rpmconf
check-rpmconf: | rpmconf meld
	@sudo rpmconf -a -f meld

CHECK += check-sys-configs
check-sys-configs: | rpm
	-@sudo rpm -Va

CHECK += check-disk-space
check-disk-space: | duf
	@duf -all -warnings

CHECK += check-ssh
check-ssh: | ssh-audit
	-@ssh-audit localhost

CHECK += check-cpu-vulnerabilities
check-cpu-vulnerabilities:
	@grep -r . /sys/devices/system/cpu/vulnerabilities/

CHECK += check-release-eol
check-release-eol: /etc/os-release
	-@[ "$(OS_RELEASE_EOL)" \< "$$(date +%Y-%m-%d)" ] \
	 && $(call log,$(ERR),"\\n\\n\\nCritical: Current date $$(date +%Y-%m-%d) is AFTER the support end date: \
	 $(OS_RELEASE_EOL). Update your OS ASAP\x21\\n\\n")

CHECK += check-fwupd-security
check-fwupd-security: | fwupd
	@sudo fwupdmgr security

#TODO: add rasdaemon checks

########################################################################################################################
#
# Backup rules
#

BACKUP += backup-home
backup-home: pass restic fastfetch redhat-lsb diffutils
	@cd $(HOME_BIN) && ./backup-home-restic

BACKUP += backup-system
backup-system: pass restic fastfetch redhat-lsb diffutils
	@cd $(HOME_BIN) && ./backup-system-restic

BACKUP += backup-router
backup-router: pass restic curl jq
	@cd $(HOME_BIN) && ./backup-router-restic

BACKUP += backup-pass
backup-pass: git pass pass-extensions
	@pass git push -u origin master

########################################################################################################################
#
# Aliases
#

.PHONY: snap
snap: | snapd /snap

.PHONY: ecryptfs
ecryptfs: ecryptfs-utils

.PHONY: gnome-settings
gnome-settings: gnome-key-binding-settings gnome-theme-settings gnome-wallpaper gnome-shell-extensions \
		gnome-input-settings gnome-desktop-settings gnome-display-settings \
		gnome-nautilus-settings gnome-file-chooser-settings gnome-gedit-settings gnome-screenshot-settings \
		gnome-tracker-settings gnome-power-settings gnome-privacy-settings gnome-terminal-settings

.PHONY: diff
diff: diffutils ydiff git-split-diffs

.PHONY: intellij
intellij: | intellij-idea-community $(ext_intellij)

.PHONY: geoclue
geoclue: geoclue2

########################################################################################################################
#
# Main targets
#

files: | $(FILES) ## Check that all managed files are up-to-date

install: | files $(INSTALL) ## Check all packages and managed files (except system patches)

patch: | $(PATCH) ## Check system patches

update: | $(UPDATE) ## Update installed software

clean: | $(CLEAN) ## Do a system cleanup

setup: | $(SETUP) ## Run setup scripts that require manual input

check: | $(CHECK) ## Perform different checks

backup: | $(BACKUP) ## Backup everything

all: | files install patch update clean setup check backup ## Check, update and clean everything including system patches, packages and firmware

help: ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ \
	{ printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' \
	$(MAKEFILE_LIST)

# Debug
printvars:
	@$(foreach V,$(sort $(.VARIABLES)), \
		$(if $(filter-out environment% default automatic, \
			$(origin $V)),$(warning $V=$($V) ($(value $V)))))

.PHONY: $(INSTALL) $(PATCH) $(UPDATE)$(CLEAN) $(SETUP) $(CHECK) $(BACKUP) \
	files install patch update clean setup check backup all help printvars
