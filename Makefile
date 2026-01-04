#!/usr/bin/env make -f
.ONESHELL:
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

SHELL = /bin/bash
MAKEFLAGS += --no-builtin-rules --no-builtin-variables --warn-undefined-variables

# Useful debug options
# .SHELLFLAGS := -eu -o pipefail -c

ifeq ($(shell id -u), 0)
$(error This Makefile MUST NOT be executed as root.)
endif

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

define NEWLINE :=


endef

export XDG_CONFIG_HOME ?= $(HOME)/.config
export XDG_DATA_HOME ?= $(HOME)/.local/share
export XDG_CACHE_HOME ?= $(HOME)/.cache
export XDG_PICTURES_DIR ?= $(HOME)/Private/Pictures
export NVM_DIR ?= $(XDG_DATA_HOME)/nvm
export NOW := $(shell date +%Y-%m-%d_%H:%M:%S)
export TODAY := $(shell date -I)

MODEL := $(shell (if command -v hostnamectl > /dev/null 2>&1; \
	then hostnamectl | grep 'Hardware Model:' | sed 's/^.*: //'; \
	else sudo dmidecode -s system-product-name ; fi) | tr "[:upper:]" "[:lower:]" | sed 's/ /-/g')
OS_RELEASE_EOL=$(shell grep -o 'SUPPORT_END=.*' /etc/os-release | sed 's/SUPPORT_END=//' )

DF_MAKEFILE_NAME := $(abspath $(lastword $(MAKEFILE_LIST)))
DF_ROOT := $(abspath $(dir $(DF_MAKEFILE_NAME)))
DF_FSROOT := $(abspath $(DF_ROOT)/fsroot)
DF_FSHOME := $(abspath $(DF_FSROOT)/home/obatiuk)
DF_FSETC := $(abspath $(DF_FSROOT)/etc)
DF_INCLUDE = $(abspath $(DF_ROOT)/include)
DF_DEVICE = $(abspath $(DF_ROOT)/device)
DF_VIVALDI_CONF := $(DF_FSHOME)/.config/vivaldi/CustomUIModifications
DF_BACKUP_CONF :=  $(DF_FSHOME)/.home/backup

DOTHOME := $(abspath $(HOME)/.home)
BASHRCD := $(abspath $(HOME)/.bashrc.d)
DOTHOME_BIN := $(abspath $(DOTHOME)/bin)
DOTHOME_OPT := $(abspath $(DOTHOME)/opt)
DOTHOME_BACKUP := $(abspath $(DOTHOME)/backup)
PASS_HOME := $(abspath $(HOME)/.password-store)
PASS_EXT := $(abspath $(PASS_HOME)/.extensions)
ULAUNCHER_EXT := $(XDG_DATA_HOME)/ulauncher/extensions
VIVALDI_CONF := $(XDG_CONFIG_HOME)/vivaldi/CustomUIModifications
BACKUP_CONF := $(DOTHOME_BACKUP)

INSTALL =
PATCH =
UPDATE =
CLEAN =
SETUP =
CHECK =
BACKUP =

ARC_THEME_SOURCE ?= git

EDITOR_BIN := $(shell command -v editor)

########################################################################################################################
#
# Includes
#

# Include model-specific patches
-include $(DF_DEVICE)/$(MODEL)/$(MODEL).mk

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
			sudo dnf -y install $($@_SOURCE);$(NEWLINE), \
			rpm -q $($@_PACKAGE) >& /dev/null || sudo dnf -y install $($@_SOURCE);$(NEWLINE)))
endef

define clone
	install -d $(DOTHOME_OPT)
	if [ ! -d $(DOTHOME_OPT)/$(1) ]; then git clone 'https://github.com/obatiuk/$(1)' $(DOTHOME_OPT)/$(1); fi
	git -C $(DOTHOME_OPT)/$(1) pull
endef

define log
	echo -e "$(subst ",,$(1))$(subst ",,$(2))$(END_COLOR)"
endef

########################################################################################################################
#
# Packages
#

# All RPM packages that do not require manual installation steps
PKG_RPM := rpm dnf5 dnf-utils redhat-lsb rpmconf pwgen systemd pam-u2f pamu2fcfg xdg-user-dirs audit golang akmods
PKG_RPM += fwupd bluez bash bash-completion avahi avahi-tools samba-client tree brightnessctl mokutil
PKG_RPM += hplip hplip-gui xsane ffmpeg feh nano htop btop fzf less xdg-utils httpie lynis cheat tldr
PKG_RPM += ImageMagick baobab gimp gparted gnome-terminal seahorse cups duf ssh-audit coreutils openssl
PKG_RPM += libreoffice-core libreoffice-writer libreoffice-calc libreoffice-filters minder firefox vlc
PKG_RPM += gnome-pomodoro gnome-clocks fd-find ydiff webp-pixbuf-loader tuned usbguard-selinux usbguard-notifier
PKG_RPM += usbguard-dbus fastfetch bc usbutils pciutils acpi policycoreutils-devel pass-otp pass-audit
PKG_RPM += gnupg2 pinentry-tty pinentry-gnome3 gedit gedit-plugins gedit-plugin-editorconfig
PKG_RPM += gvfs-mtp screen progress pv tio dialog catimg cifs-utils sharutils binutils odt2txt
PKG_RPM += restic rsync rclone micro wget2 xsensors lm_sensors curl jq libnotify glow libsecret
PKG_RPM += unrar lynx crudini sysstat p7zip nmap cabextract iotop-c qrencode uuid tcpdump plymouth-system-theme
PKG_RPM += git diffutils git-lfs git-extras git-credential-libsecret git-crypt bat mc gh perl-Image-ExifTool
PKG_RPM += calibre ebook-tools clamav clamav-freshclam mdns-scan fping gettext-envsubst steam-devices
PKG_RPM += fedora-workstation-repositories gnome-monitor-config java-latest-openjdk java-21-openjdk java-25-openjdk
PKG_RPM += adwaita-icon-theme adwaita-cursor-theme dconf adoptium-temurin-java-repository
PKG_RPM += python3 python3-pip python3-devel python3-virtualenv
PKG_RPM += iwlwifi-dvm-firmware iwlwifi-mld-firmware iwlwifi-mvm-firmware

# DNF plugins
EXT_DNF := dnf-plugins-core dnf-plugin-diff python3-dnf-plugin-tracer python3-dnf-plugin-rpmconf
EXT_DNF += remove-retired-packages dracut-config-rescue clean-rpm-gpg-pubkey python3-dnf-plugin-show-leaves

# All `snap` packages that do not require manual installation steps
PKG_SNAP := chromium-ffmpeg mqtt-explorer

# All **user** `flatpak` that do not require manual installation steps
PKG_FLATPAK := org.gnupg.GPA org.gtk.Gtk3theme.Arc-Darker be.alexandervanhee.gradia com.core447.StreamController

# Font packages
PKG_FONT := google-droid-sans-fonts google-droid-serif-fonts google-droid-sans-mono-fonts
PKG_FONT += google-roboto-fonts adobe-source-code-pro-fonts dejavu-sans-fonts dejavu-sans-mono-fonts
PKG_FONT += dejavu-serif-fonts liberation-mono-fonts liberation-narrow-fonts liberation-sans-fonts
PKG_FONT += liberation-serif-fonts jetbrains-mono-fonts-all fontawesome4-fonts

# GNOME Shell extensions (rpm packages)
PKG_GSHELL := gnome-shell-extension-dash-to-dock gnome-shell-extension-appindicator
PKG_GSHELL += gnome-shell-extension-frippery-move-clock gnome-shell-extension-gsconnect
PKG_GSHELL += gnome-shell-extension-sound-output-device-chooser gnome-shell-extension-freon
PKG_GSHELL += gnome-shell-extension-blur-my-shell gnome-shell-extension-user-theme
PKG_GSHELL += gnome-shell-extension-no-overview

# GNOME shell extensions
EXT_GSHELL := https\://extensions.gnome.org/extension/1401/bluetooth-quick-connect
EXT_GSHELL += https\://extensions.gnome.org/extension/3780/ddterm
EXT_GSHELL += https\://extensions.gnome.org/extension/7065/tiling-shell
EXT_GSHELL += https\://extensions.gnome.org/extension/4470/media-controls
EXT_GSHELL += https\://extensions.gnome.org/extension/277/impatience
EXT_GSHELL += https\://extensions.gnome.org/extension/4099/no-overview
EXT_GSHELL += https\://extensions.gnome.org/extension/517/caffeine

# VSCode extensions
EXT_VSCODE := EditorConfig.EditorConfig jianbingfang.dupchecker mechatroner.rainbow-csv bierner.markdown-mermaid
EXT_VSCODE += bpruitt-goddard.mermaid-markdown-syntax-highlighting eamodio.gitlens ecmel.vscode-html-css
EXT_VSCODE += humao.rest-client jebbs.plantuml moshfeu.compare-folders ms-azuretools.vscode-docker ph-hawkins.arc-plus
EXT_VSCODE += PKief.material-icon-theme redhat.java redhat.vscode-xml redhat.vscode-yaml
EXT_VSCODE += streetsidesoftware.code-spell-checker timonwong.shellcheck usernamehw.errorlens vscjava.vscode-maven
EXT_VSCODE += yzhang.markdown-all-in-one ms-python.python lintangwisesa.arduino ms-vscode.makefile-tools
EXT_VSCODE += keesschollaart.vscode-home-assistant

# Ulauncher extensions
EXT_ULAUNCHER := ulauncher-emoji.git pass-ulauncher.git pass-for-ulauncher.git pass-otp-for-ulauncher.git
EXT_ULAUNCHER += ulauncher-obsidian.git ulauncher-numconverter.git ulauncher-list-keywords.git

# IntelliJ extensions
EXT_INTELLIJ := ru.adelf.idea.dotenv lermitage.intellij.battery.status Docker name.kropp.intellij.makefile
EXT_INTELLIJ += com.jetbrains.plugins.ini4idea

# `micro` editor extensions
EXT_MICRO += $(addprefix micro_,editorconfig fzf filemanager)

# pass extensions
EXT_PASS := symlink.bash age.bash ln.bash file.bash update.bash tessen.bash meta.bash

# Backup configuration names
CONF_BACKUP := home nebula system

# Backup environment names
ENV_BACKUP:= primary secondary cloud

# Vivaldi configuration files
FILES_VIVALDI := $(shell find $(DF_VIVALDI_CONF) -type f -print)

# Backup configuration files
FILES_BACKUP_CONF := $(shell find $(DF_BACKUP_CONF) -type f -print)

VIVALDI_CONF_FILES := $(patsubst $(DF_VIVALDI_CONF)/%,$(VIVALDI_CONF)/%,$(FILES_VIVALDI))
EXT_PASS_FILES := $(addprefix $(PASS_EXT)/,$(EXT_PASS))
BACKUP_CONF_FILES := $(patsubst $(DF_BACKUP_CONF)/%,$(BACKUP_CONF)/%,$(FILES_BACKUP_CONF))

# Editors
EDITORS := /usr/bin/vi /usr/bin/nano /usr/bin/micro

########################################################################################################################
#
# Package installation customizations and aliases
#

INSTALL += dnf-plugins
dnf-plugins: $(EXT_DNF)

INSTALL += dnf-settings
dnf-settings: /etc/dnf/dnf.conf crudini
	@sudo crudini --ini-options=nospace --set $< main fastestmirror 1
	@sudo crudini --ini-options=nospace --set $< main max_parallel_downloads 10
	@sudo crudini --ini-options=nospace --set $< main ip_resolve 4

INSTALL += ecryptfs-utils
ecryptfs-utils:
	@$(call dnf,$@)
	@sudo modprobe ecryptfs
	@sudo usermod -aG ecryptfs '$(USER)'

INSTALL += fonts-better
fonts-better: /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:hyperreal\:better_fonts.repo
	@$(call dnf,fontconfig-font-replacements)

INSTALL += fonts_ms
fonts-ms:
	@$(call dnf,http://sourceforge.net/projects/mscorefonts2/files/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm)

INSTALL += fonts
fonts: $(PKG_FONT) fonts-better fonts-ms

INSTALL += flatpak
flatpak: gnome-desktop
	@$(call dnf,$@)
	@sudo flatpak --system remotes | grep 'flathub' > /dev/null || sudo flatpak --system remote-add --if-not-exists \
		flathub https://flathub.org/repo/flathub.flatpakrepo
	@flatpak --user remotes | grep 'flathub' > /dev/null || flatpak --user remote-add --if-not-exists \
		flathub https://flathub.org/repo/flathub.flatpakrepo
	@sudo flatpak --system remote-modify --no-filter --enable flathub
	@flatpak --user remote-modify --no-filter --enable flathub
	@flatpak install --system org.gtk.Gtk3theme.Arc-Darker

INSTALL += nodejs-lts
nodejs-lts: | $(NVM_DIR)/nvm.sh
	@[ -n "$$( source $(NVM_DIR)/nvm.sh && nvm ls | grep -v 'N/A' | grep -o 'lts/[a-zA-Z]*' | head -n 1)" ] \
		|| { . $(NVM_DIR)/nvm.sh && nvm install --lts; }

INSTALL += git-split-diffs
git-split-diffs: | nodejs
	@. $(NVM_DIR)/nvm.sh && npm list -g $@ > /dev/null || { . $(NVM_DIR)/nvm.sh && npm install -g $@; }

INSTALL += docker
docker: /etc/yum.repos.d/docker-ce.repo | systemd
	-@sudo dnf -y remove --exclude=container-selinux \
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
	@sudo systemctl enable --now $@

INSTALL += ql700
ql700: | cups
	@$(call dnf,https://download.brother.com/welcome/dlfp002191/ql700pdrv-3.1.5-0.i386.rpm)
	@# Fix QL-700 brother printer access when SELinux is enabled
	@# Source:
	@# - http://support.brother.com/g/s/id/linux/en/faq_prn.html?c=us_ot&lang=en&comple=on&redirect=on#f00115
	@# - http://www.pclinuxos.com/forum/index.php?topic=138727.0
	@sudo restorecon -RFv /usr/lib/cups/filter/*
	@sudo setsebool -P cups_execmem 1
	@sudo setsebool mmap_low_allowed 1

INSTALL += video-codecs
video-codecs: | /etc/yum.repos.d/rpmfusion-free.repo \
	/etc/yum.repos.d/rpmfusion-nonfree.repo \
	/etc/yum.repos.d/fedora-cisco-openh264.repo
	@sudo dnf -y --setopt=strict=0 install \
		gstreamer{1,}-{ffmpeg,libav,vaapi,plugins-{good,ugly,bad{,-free,-nonfree,-freeworld,-extras}}}
	@sudo dnf -y install *openh264
	@sudo dnf -y swap ffmpeg-free ffmpeg
	@sudo dnf -y install @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

INSTALL += gnome-desktop
gnome-desktop:
	@# Force group installation if -B flag is present
	@$(if $(findstring B,$(firstword -$(MAKEFLAGS))), \
		@sudo dnf -y group install $@, \
		@dnf group list --installed --hidden | grep $@ > /dev/null || sudo dnf -y group install $@;)

INSTALL += google-chrome
google-chrome: | gnome-desktop /etc/yum.repos.d/google-chrome.repo
	@$(call dnf,google-chrome-stable)

INSTALL += vivaldi-bin
vivaldi-bin: | gnome-desktop /etc/yum.repos.d/vivaldi-fedora.repo
	@$(call dnf,vivaldi-stable)

INSTALL += vivaldi
vivaldi: | vivaldi-bin $(VIVALDI_CONF_FILES)

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

INSTALL += code
code: | snapd
	@sudo snap install $@ --classic

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
	@systemctl --user enable --now $@

INSTALL += ulauncher-extensions
ulauncher-extensions: ulauncher $(EXT_ULAUNCHER)
	-@systemctl --user restart ulauncher.service

INSTALL += gnome-themes
gnome-themes: | gnome-desktop adwaita-icon-theme adwaita-cursor-theme morewaita-icon-theme arc-theme

INSTALL += gnome-shell-extensions
gnome-shell-extensions: | gnome-desktop $(PKG_GSHELL) $(EXT_GSHELL)
	@gsettings set org.gnome.shell disable-user-extensions false
	-@gnome-extensions disable 'window-list@gnome-shell-extensions.gcampax.github.com'
	-@gnome-extensions disable 'places-menu@gnome-shell-extensions.gcampax.github.com'

ifeq ($(ARC_THEME_SOURCE),git)
# `arc-theme` package from the official repository doesn't have latest patches
# Use patched Arc themes version from git: https://github.com/jnsh/arc-theme/blob/master/INSTALL.md
INSTALL += arc-theme
arc-theme: | gnome-desktop git install-arc-theme-git build-arc-theme-git clean-arc-theme-git

.PHONY: install-arc-theme-git
install-arc-theme-git:
	-@sudo dnf -y remove arc-theme
	@# install prerequisites
	@$(call dnf,optipng gnome-themes-extra gtk-murrine-engine meson inkscape sassc glib2-devel gdk-pixbuf2 \
		gtk3-devel gtk4-devel autoconf automake)

# Using SELF_CALL=xxx to avoid `inkscape` segfaults during build (https://gitlab.com/inkscape/inkscape/-/issues/4716)
.PHONY: build-arc-theme-git
build-arc-theme-git:
	@install -d $(DOTHOME_OPT)
	@rebuild_theme=false
	@if [ ! -d $(DOTHOME_OPT)/arc-theme ]; then
		git clone https://github.com/obatiuk/arc-theme --depth 1 $(DOTHOME_OPT)/arc-theme
		rebuild_theme=true
	fi
	@git -C $(DOTHOME_OPT)/arc-theme remote update
	@has_changes=$$(git -C $(DOTHOME_OPT)/arc-theme status -uno | grep -q 'Your branch is behind' && echo 'true' || echo 'false')
	@if [ $${rebuild_theme} == true ] || [ $${has_changes} == true ]; then
		git -C $(DOTHOME_OPT)/arc-theme pull
		meson setup --reconfigure --prefix=$(HOME)/.local \
			-Dvariants=dark,darker \
			-Dthemes=gnome-shell,gtk2,gtk3,gtk4 \
			$(DOTHOME_OPT)/arc-theme/build $(DOTHOME_OPT)/arc-theme
		SELF_CALL=true bash -c 'meson install -C $(DOTHOME_OPT)/arc-theme/build'
		install -d $(HOME)/.themes
		for theme in Arc{,-Dark,-Darker,-Lighter}{,-solid}; do
			if [ -d $(XDG_DATA_HOME)/themes/$${theme} ]; then
				ln -svfn $(XDG_DATA_HOME)/themes/$${theme} $(HOME)/.themes/$${theme}
			fi
		done
	fi

UPDATE += update-arc-theme-git
update-arc-theme-git: | git build-arc-theme-git clean-arc-theme-git

CLEAN += clean-arc-theme-git
clean-arc-theme-git:
	@meson compile --clean -C $(DOTHOME_OPT)/arc-theme/build

else
# Install `arc-theme` from the official repository
INSTALL += arc-theme
arc-theme:
	@$(call dnf,arc-theme)
	@rm -rf $(DOTHOME_OPT)/arc-theme
	@rm -rf $(XDG_DATA_HOME)/themes/Arc{,-Dark,-Darker,-Lighter}{,-solid}
	@rm -rf $(HOME)/.themes/Arc{,-Dark,-Darker,-Lighter}{,-solid}
endif

INSTALL += plymouth
plymouth: plymouth-system-theme
	@$(call dnf,$@)
	@sudo plymouth-set-default-theme bgrt -R
	@sudo grub2-mkconfig -o /etc/grub2.cfg

INSTALL += tuned-ppd
tuned-ppd: | tuned
	@$(call dnf,$@)
	@sudo systemctl enable --now tuned
	@sudo systemctl enable --now $@
	@sudo tuned-adm profile $(shell tuned-adm recommend)

INSTALL += pass
pass: | git
	@$(call dnf,$@)
	@install -d $(HOME)/.password-store

INSTALL += pass-extensions
pass-extensions: | pass pass-otp pass-audit $(EXT_PASS_FILES)

INSTALL += authselect
authselect: | pam-u2f ecryptfs-utils
	@# FIXME: add check if all settings are applied already
	@$(call dnf,$@)
	@authselect check \
		&& sudo authselect select sssd with-ecryptfs with-fingerprint with-pam-u2f without-nullok -b \
		|| $(call log,$(ERR),"Current authselect configuration is NOT valid. Aborting to avoid more damage.");

INSTALL += pip
pip: | python3 python3-pip
	@python -m $@ install --upgrade $@

INSTALL += smartmontools
smartmontools:
	@$(call dnf,$@)
	@sudo systemctl enable --now smartd

INSTALL += meld
meld: | gnome-desktop dconf
	@$(call dnf,$@)
	@dconf load '/' < $(DF_INCLUDE)/meld.ini

INSTALL += obsidian
obsidian: | flatpak
	#@flatpak install md.obsidian.Obsidian - disabled for now to keep current locked version

INSTALL += steam
steam: | flatpak steam-devices /etc/yum.repos.d/rpmfusion-nonfree.repo
	@flatpak install --user flathub com.valvesoftware.Steam \
		com.valvesoftware.Steam.CompatibilityTool.Proton \
		com.valvesoftware.Steam.Utility.gamescope \
		org.freedesktop.Platform.VulkanLayer.gamescope
	@flatpak override --user --filesystem=/run/udev:ro com.valvesoftware.Steam

INSTALL += snapd
snapd:
	@$(call dnf,$@)
	@sudo [ ! -L /snap ] && sudo ln -svnf /var/lib/snapd/snap /snap
	@# A manual fix for the broken snap when `/usr/lib/snapd` link exists
	@# (see https://discussion.fedoraproject.org/t/snap-stopped-working-on-f41/161371 and
	@# https://github.com/canonical/snapd/commit/858801cf47fe5e8dc6307e4cf02191b7157fc0c2)
	@sudo [ -L '/usr/lib/snapd' ] && sudo rm -rfi '/usr/lib/snapd'
	@sudo snap set system refresh.retain=2
	@sudo systemctl daemon-reload
	@sudo systemctl restart $@

INSTALL += logrotate
logrotate: /etc/logrotate.d/dnf
	@$(call dnf,$@)
	@sudo systemctl enable --now $@.timer

.PHONY: browserpass-bin
browserpass-bin: | git coreutils golang
	@$(call clone,browserpass-native.git)
	@make -C $(DOTHOME_OPT)/browserpass-native.git browserpass configure
	@sudo make -C $(DOTHOME_OPT)/browserpass-native.git install
	@make -C $(DOTHOME_OPT)/browserpass-native.git hosts-chrome-user hosts-firefox-user hosts-vivaldi-user \
		policies-chrome-user policies-vivaldi-user

CLEAN += clean-browserpass
clean-browserpass:
	@make -C $(DOTHOME_OPT)/browserpass-native.git clean

INSTALL += browserpass
browserpass: | pass pass-extensions $(PASS_HOME)/.browserpass.json browserpass-bin clean-browserpass

INSTALL += geoclue2
geoclue2: /etc/geoclue/geoclue.conf | crudini
	@$(call dnf,$@)
	@sudo crudini --ini-options=nospace --set $< wifi enable true
	@sudo crudini --ini-options=nospace --set $< wifi url 'https://beacondb.net/v1/geolocate'
	@sudo systemctl restart geoclue

INSTALL += proton-mail-bridge
proton-mail-bridge: $(PASS_HOME)/.gitignore | pass
	@sudo dnf -y install https://proton.me/download/bridge/protonmail-bridge-3.13.0-1.x86_64.rpm
	@if ! grep -q 'protonmail-credentials' $<; then \
		echo 'protonmail-credentials' >> $<; \
		echo 'docker-credential-helpers' >> $<; fi

INSTALL += editor-alternatives
editor-alternatives: micro
	@$(foreach editor,$(EDITORS),sudo alternatives --install '$(EDITOR_BIN)' editor '$(editor)' 0;$(NEWLINE))
	@sudo alternatives --set editor '/usr/bin/micro'

INSTALL += firewall-profiles
firewall-profiles:
# TODO:
# - public and home profiles
# - find a way to assign firewall profile to an interface

INSTALL += backup-services
backup-services: rclone | $(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-stats@.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-check@.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-backup-daily@.timer \
	$(XDG_CONFIG_HOME)/systemd/user/restic-backup-monthly@.timer \
	$(XDG_CONFIG_HOME)/systemd/user/restic-check-monthly@.timer

	@systemctl --user enable 'restic-stats@home-primary.service'
	@systemctl --user enable 'restic-stats@home-secondary.service'
	@systemctl --user enable 'restic-stats@home-cloud.service'

	@systemctl --user enable 'restic-stats@nebula-primary.service'
	@systemctl --user enable 'restic-stats@nebula-secondary.service'
	@systemctl --user enable 'restic-stats@nebula-cloud.service'

	@systemctl --user enable 'restic-check@primary.service'
	@systemctl --user enable 'restic-check@secondary.service'
	@systemctl --user enable 'restic-check@cloud.service'

	@systemctl --user enable --now 'restic-backup-daily@home-primary.timer'
	@systemctl --user enable --now 'restic-backup-daily@home-secondary.timer'
	@systemctl --user enable --now 'restic-backup-daily@home-cloud.timer'

	@systemctl --user enable --now 'restic-backup-monthly@nebula-primary.timer'
	@systemctl --user enable --now 'restic-backup-monthly@nebula-secondary.timer'
	@systemctl --user enable --now 'restic-backup-monthly@nebula-cloud.timer'

	@systemctl --user enable --now 'restic-check-monthly@primary.timer'
	@systemctl --user enable --now 'restic-check-monthly@secondary.timer'
	@systemctl --user enable --now 'restic-check-monthly@cloud.timer'

INSTALL += mosquitto
mosquitto:
	@$(call dnf,$@)

	@# Disable mosquitto services, we need only mosquitto_pub/sub binaries
	@sudo systemctl stop $@
	@sudo systemctl disable $@

.PHONY: usbguard-bin
usbguard-bin:
	@$(call dnf,usbguard)

INSTALL += usbguard
usbguard: | usbguard-bin usbguard-selinux usbguard-notifier usbguard-dbus /etc/polkit-1/rules.d/70-allow-usbguard.rules

INSTALL += rasdaemon
rasdaemon:
	@$(call dnf,$@)
	@sudo systemctl enable --now $@

INSTALL += jre
jre: java-21-openjdk
	@sudo alternatives --set java /usr/lib/jvm/$</bin/java

INSTALL += kse
kse: | jre
	@$(call dnf,https://github.com/kaikramer/keystore-explorer/releases/download/v5.6.0/kse-5.6.0-1.noarch.rpm)

INSTALL += intellij-idea-community
intellij-idea-community: | snapd
	@sudo snap install $@ --classic

########################################################################################################################
#
# GNOME settings
#

INSTALL += gnome-key-binding-settings
gnome-key-binding-settings: | gnome-desktop $(DOTHOME_BIN)/dell-kvm-switch-input ulauncher
	@$(eval custom0=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/)
	@$(eval custom1=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/)
	@$(eval custom2=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/)
	@$(eval custom3=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/)

	@gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$(custom0)', '$(custom1)', '$(custom2)', '$(custom3)']"

	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom0) name 'Run Terminal'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom0) command '$(shell command -v gnome-terminal)'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom0) binding '<Super>t'

	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom1) name 'Dell KVM - Switch Input'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom1) command '$(DOTHOME_BIN)/dell-kvm-switch-input'
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

	@# Possible fix for a sporadic flight-mode toggle
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill []
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-bluetooth []
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-bluetooth-static []
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-static []
	@systemctl --user mask --now org.gnome.SettingsDaemon.Rfkill.service

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
	@gsettings set org.gnome.desktop.peripherals.keyboard repeat true
	@gsettings set org.gnome.desktop.peripherals.keyboard delay 250
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
	@gsettings set org.gnome.desktop.interface toolkit-accessibility false
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
	@gsettings set org.gnome.SessionManager auto-save-session true

	# Fonts
	@gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Mono 10'
	@gsettings set org.gnome.desktop.interface font-name 'Sans 9'
	@gsettings set org.gnome.desktop.interface document-font-name 'Sans 9'
	@gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
	@gsettings set org.gnome.desktop.interface font-hinting 'slight'
	@gsettings set org.gnome.desktop.interface cursor-size 24
	@gsettings set org.gnome.desktop.interface cursor-blink true

	@gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', \
		'intellij-idea-community_intellij-idea-community.desktop', 'code_code.desktop', \
		'vivaldi-stable.desktop', 'google-chrome.desktop', 'firefox.desktop', 'md.obsidian.Obsidian.desktop', \
		'xmind.desktop', 'org.gnome.gedit.desktop', 'chrome-cinhimbnkkaeohfgghhklpknlkffjgod-Profile_4.desktop', \
		'chrome-hpfldicfbfomlpcikngkocigghgafkph-Profile_4.desktop', 'org.gnome.Pomodoro.desktop', \
		'cc.arduino.IDE2.desktop', 'calibre-gui.desktop', 'com.valvesoftware.Steam.desktop', 'slack_slack.desktop', \
		 'wine-Programs-reMarkable-reMarkable.desktop']"

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

	@# Disable unusable `usb-protection` GNOME settings until this bug is fixed:
	@# https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/issues/735
	@gsettings set org.gnome.desktop.privacy usb-protection false
	@gsettings set org.gnome.desktop.privacy usb-protection-level 'lockscreen'

	@gsettings set org.gnome.desktop.notifications show-banners false
	@gsettings set org.gnome.desktop.notifications show-in-lock-screen false
	@gsettings set org.gnome.login-screen disable-user-list true
	@gsettings set org.gnome.shell remember-mount-password false
	@gsettings set org.gnome.system.location enabled true
	@gsettings set org.gnome.desktop.search-providers disable-external true

INSTALL += gnome-gedit-settings
gnome-gedit-settings: | gedit dconf
	@dconf load '/' < $(DF_INCLUDE)/gnome-gedit.ini

INSTALL += gnome-tracker-settings
gnome-tracker-settings: | dconf
	@dconf load '/' < $(DF_INCLUDE)/gnome-tracker.ini

INSTALL += gnome-terminal-settings
gnome-terminal-settings: | gnome-terminal dconf
	@dconf load '/' < $(DF_INCLUDE)/gnome-terminal.ini

INSTALL += gnome-pomodoro-settings
gnome-pomodoro-settings: | gnome-pomodoro dconf
	@dconf load '/' < $(DF_INCLUDE)/gnome-pomodoro.ini

INSTALL += gnome-clocks-settings
gnome-clocks-settings: | gnome-clocks dconf
	@dconf load '/' < $(DF_INCLUDE)/gnome-clocks.ini

########################################################################################################################
#
# Bulk installation rules
#

INSTALL += $(EXT_DNF)
$(EXT_DNF):
	@$(call dnf,$@)

INSTALL += $(PKG_RPM)
$(PKG_RPM): | gnome-desktop
	@$(call dnf,$@)

INSTALL += $(PKG_FONT)
$(PKG_FONT):
	@$(call dnf,$@)

INSTALL += $(PKG_GSHELL)
$(PKG_GSHELL): | gnome-desktop
	@$(call dnf,$@)
	@if [ -f $(DF_INCLUDE)/$@.ini ]; then dconf load '/' < $(DF_INCLUDE)/$@.ini; fi

INSTALL += $(PKG_SNAP)
$(PKG_SNAP): | snapd
	@sudo snap install $@

INSTALL += $(PKG_FLATPAK)
$(PKG_FLATPAK): | flatpak
	@flatpak install --user $@

INSTALL += $(EXT_ULAUNCHER)
$(EXT_ULAUNCHER): | git ulauncher
	@$(call clone,$@)
	@install -d $(ULAUNCHER_EXT)
	@ln -svfn $(DOTHOME_OPT)/$@ $(ULAUNCHER_EXT)/$(subst .git,,$@)

INSTALL += $(EXT_GSHELL)
$(EXT_GSHELL): $(DOTHOME_BIN)/install-gnome-extensions | gnome-desktop dconf
	@install -d $(DOTHOME_OPT)
	@$(eval __ext=$(subst $(slash),$(space),$(subst https://extensions.gnome.org/extension/,,$(strip $@))))
	@$(eval __ext_id=$(word 1, $(__ext)))
	@$(eval __ext_name=$(word 2, $(__ext)))
	@if [ -f $(DF_INCLUDE)/gnome-shell-extension-$(__ext_name).ini ]; then
	@	dconf load '/' < $(DF_INCLUDE)/gnome-shell-extension-$(__ext_name).ini;
	@fi
	@$< --enable $(__ext_id)

INSTALL += $(EXT_VSCODE)
$(EXT_VSCODE): code
	@snap run $< --force --install-extension '$@'

INSTALL += $(EXT_INTELLIJ)
$(EXT_INTELLIJ): intellij-idea-community | acpi
	@snap run $< installPlugins $@

INSTALL += $(EXT_MICRO)
$(EXT_MICRO): | micro fzf
	@micro -plugin install $(subst micro_,,$@)

########################################################################################################################
#
# Files
#

#
# /home
#

FILES += $(HOME)/.bashrc
$(HOME)/.bashrc: $(DF_FSHOME)/.bashrc
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(HOME)/.bash_profile
$(HOME)/.bash_profile: $(DF_FSHOME)/.bash_profile
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(HOME)/.bash_logout
$(HOME)/.bash_logout: $(DF_FSHOME)/.bash_logout
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-git
$(BASHRCD)/bashrc-git: $(DF_FSHOME)/.bashrc.d/bashrc-git
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-base
$(BASHRCD)/bashrc-base: $(DF_FSHOME)/.bashrc.d/bashrc-base
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-xdg
$(BASHRCD)/bashrc-xdg: $(DF_FSHOME)/.bashrc.d/bashrc-xdg
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-dev
$(BASHRCD)/bashrc-dev: $(DF_FSHOME)/.bashrc.d/bashrc-dev
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-pass
$(BASHRCD)/bashrc-pass: $(DF_FSHOME)/.bashrc.d/bashrc-pass
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD)/bashrc-steam
$(BASHRCD)/bashrc-steam: $(DF_FSHOME)/.bashrc.d/bashrc-steam
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(HOME)/.face.icon
$(HOME)/.face.icon: $(DF_FSHOME)/.face.icon
	@ln -svnf $< $@

FILES += $(HOME)/.editorconfig
$(HOME)/.editorconfig : $(DF_FSHOME)/.editorconfig
	@ln -svfn $< $@

FILES += $(HOME)/.trackerignore
$(HOME)/.trackerignore: $(DF_FSHOME)/.trackerignore | disable-gnome-tracker
	@ln -svnf $< $@

FILES += $(HOME)/.passgenrc
$(HOME)/.passgenrc : $(DF_FSHOME)/.passgenrc | pass
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/git/config
$(XDG_CONFIG_HOME)/git/config: $(DF_FSHOME)/.config/git/config | git git-lfs git-credential-libsecret \
		git-split-diffs bat meld perl-Image-ExifTool
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(DOTHOME_BIN)/dell-kvm-switch-input
$(DOTHOME_BIN)/dell-kvm-switch-input: $(DF_FSHOME)/.home/bin/dell-kvm-switch-input | ddcutil
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/switch-monitor
$(DOTHOME_BIN)/switch-monitor: $(DF_FSHOME)/.home/bin/switch-monitor | gnome-monitor-config
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/start-steam
$(DOTHOME_BIN)/start-steam: $(DF_FSHOME)/.home/bin/start-steam | $(DOTHOME_BIN)/switch-monitor
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/restic-backup
$(DOTHOME_BIN)/restic-backup: $(DF_FSHOME)/.home/bin/restic-backup | restic jq curl redhat-lsb \
	diffutils mosquitto libsecret $(BACKUP_CONF_FILES)
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/restic-stats
$(DOTHOME_BIN)/restic-stats: $(DF_FSHOME)/.home/bin/restic-stats | restic jq curl mosquitto libsecret \
	$(BACKUP_CONF_FILES)
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/restic-check
$(DOTHOME_BIN)/restic-check: $(DF_FSHOME)/.home/bin/restic-check | restic jq mosquitto libsecret \
	$(BACKUP_CONF_FILES)
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/hass-retrieve-roomba-token
$(DOTHOME_BIN)/hass-retrieve-roomba-token: $(DF_FSHOME)/.home/bin/hass-retrieve-roomba-token | docker pass
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/sync-mqtt-env-primary
$(DOTHOME_BIN)/sync-mqtt-env-primary: $(DF_FSHOME)/.home/bin/sync-mqtt-env-primary | libsecret pass
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/sync-nebula-creds
$(DOTHOME_BIN)/sync-nebula-creds: $(DF_FSHOME)/.home/bin/sync-nebula-creds | libsecret pass
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/sync-restic-env-cloud
$(DOTHOME_BIN)/sync-restic-env-cloud: $(DF_FSHOME)/.home/bin/sync-restic-env-cloud | libsecret pass
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/sync-restic-env-primary
$(DOTHOME_BIN)/sync-restic-env-primary: $(DF_FSHOME)/.home/bin/sync-restic-env-primary | libsecret pass
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/sync-restic-env-secondary
$(DOTHOME_BIN)/sync-restic-env-secondary: $(DF_FSHOME)/.home/bin/sync-restic-env-secondary | libsecret pass
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(XDG_CONFIG_HOME)/gtk-2.0/gtkrc
$(XDG_CONFIG_HOME)/gtk-2.0/gtkrc: $(DF_FSHOME)/.config/gtk-2.0/gtkrc
	 @install -d $(@D)
	 @ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/gtk-3.0/settings.ini
$(XDG_CONFIG_HOME)/gtk-3.0/settings.ini: $(DF_FSHOME)/.config/gtk-3.0/settings.ini
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/gtk-3.0/gtk.css
$(XDG_CONFIG_HOME)/gtk-3.0/gtk.css: $(DF_FSHOME)/.config/gtk-3.0/gtk.css
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/gtk-3.0/bookmarks
$(XDG_CONFIG_HOME)/gtk-3.0/bookmarks: $(DF_FSHOME)/.config/gtk-3.0/bookmarks
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/gtk-4.0/settings.ini
$(XDG_CONFIG_HOME)/gtk-4.0/settings.ini: $(DF_FSHOME)/.config/gtk-4.0/settings.ini
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/user-dirs.dirs
$(XDG_CONFIG_HOME)/user-dirs.dirs: $(DF_FSHOME)/.config/user-dirs.dirs | xdg-user-dirs
	@install -d $(@D)
	@ln -svnf $< $@

FILES += $(XDG_CONFIG_HOME)/micro/bindings.json
$(XDG_CONFIG_HOME)/micro/bindings.json: $(DF_FSHOME)/.config/micro/bindings.json | micro
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/micro/settings.json
$(XDG_CONFIG_HOME)/micro/settings.json: $(DF_FSHOME)/.config/micro/settings.json | micro
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/mc/ini
$(XDG_CONFIG_HOME)/mc/ini: $(DF_FSHOME)/.config/mc/ini | mc
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(VIVALDI_CONF_FILES)
$(VIVALDI_CONF)/%: $(DF_VIVALDI_CONF)/%
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/Code/User/settings.json
$(XDG_CONFIG_HOME)/Code/User/settings.json: $(DF_FSHOME)/.config/Code/User/settings.json
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/glow/glow.yml
$(XDG_CONFIG_HOME)/glow/glow.yml: $(DF_FSHOME)/.config/glow/glow.yml | glow
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(BACKUP_CONF_FILES)
$(BACKUP_CONF)/%: $(DF_BACKUP_CONF)/%
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/wget/wgetrc
$(XDG_CONFIG_HOME)/wget/wgetrc: $(DF_FSHOME)/.config/wget/wgetrc.template | wget $(BASHRCD)/bashrc-xdg gettext-envsubst
	@install -d $(@D)
	@install -d $(XDG_CACHE_HOME)/wget
	@envsubst '$$TODAY $$USER $$XDG_CACHE_HOME' < $< | install -m 644 -D /dev/stdin $@

FILES += $(XDG_DATA_HOME)/backgrounds/current
$(XDG_DATA_HOME)/backgrounds/current: $(DF_FSHOME)/.local/share/backgrounds/morphogenesis-d.svg
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(PASS_HOME)/.gpg-id
$(PASS_HOME)/.gpg-id: | pass
	@install -d $(@D)
	@pass init 8D49EF72

FILES += $(PASS_HOME)/.gitattributes
$(PASS_HOME)/.gitattributes: | pass git
	@install -d $(@D)
	@pass git init
	@pass git config log.showsignature false

FILES += $(PASS_HOME)/.gitignore
$(PASS_HOME)/.gitignore: $(DF_FSHOME)/.password-store/.gitignore | pass
	@install -m 600 -D $< $@

FILES += $(PASS_HOME)/.browserpass.json
$(PASS_HOME)/.browserpass.json: $(DF_FSHOME)/.password-store/.browserpass.json | pass
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(PASS_EXT)/symlink.bash
$(PASS_EXT)/symlink.bash: | git pass
	@$(call clone,pass-symlink.git)
	@install -d $(@D)
	@ln -svfn $(DOTHOME_OPT)/pass-symlink.git/src/symlink.bash $@

FILES += $(PASS_EXT)/age.bash
$(PASS_EXT)/age.bash: | git pass
	@$(call clone,pass-age.git)
	@install -d $(@D)
	@ln -svfn $(DOTHOME_OPT)/pass-age.git/age.bash $@

FILES += $(PASS_EXT)/file.bash
$(PASS_EXT)/file.bash: | git pass
	@$(call clone,pass-file.git)
	@install -d $(@D)
	@ln -svfn $(DOTHOME_OPT)/pass-file.git/file.bash $@

FILES += $(PASS_EXT)/ln.bash
$(PASS_EXT)/ln.bash: | git pass
	@$(call clone,pass-ln.git)
	@install -d $(@D)
	@install -d $(XDG_DATA_HOME)/bash-completion/completions
	@ln -svfn $(DOTHOME_OPT)/pass-ln.git/pass-ln.bash $@
	@ln -svfn $(DOTHOME_OPT)/pass-ln.git/pass-ln.bash.completion $(XDG_DATA_HOME)/bash-completion/completions/pass-ln

FILES += $(PASS_EXT)/update.bash
$(PASS_EXT)/update.bash: | git pass
	@$(call clone,pass-update.git)
	@install -d $(@D)
	@install -d $(XDG_DATA_HOME)/bash-completion/completions
	@ln -svfn $(DOTHOME_OPT)/pass-update.git/update.bash $@
	@ln -svfn $(DOTHOME_OPT)/pass-update.git/share/bash-completion/completions/pass-update \
		$(XDG_DATA_HOME)/bash-completion/completions/pass-update

FILES += $(PASS_EXT)/tessen.bash
$(PASS_EXT)/tessen.bash: | git pass
	@$(call clone,pass-tessen.git)
	@install -d $(@D)
	@install -d $(XDG_DATA_HOME)/bash-completion/completions
	@ln -svfn $(DOTHOME_OPT)/pass-tessen.git/tessen.bash $@
	@ln -svfn $(DOTHOME_OPT)/pass-tessen.git/completion/pass-tessen.bash-completion \
		$(XDG_DATA_HOME)/bash-completion/completions/pass-tessen

FILES += $(PASS_EXT)/meta.bash
$(PASS_EXT)/meta.bash: | git pass
	@$(call clone,pass-extension-meta.git)
	@install -d $(@D)
	@install -d $(XDG_DATA_HOME)/bash-completion/completions
	@ln -svfn $(DOTHOME_OPT)/pass-extension-meta.git/src/meta.bash $@
	@ln -svfn $(DOTHOME_OPT)/pass-extension-meta.git/completion/pass-meta.bash.completion \
 		$(XDG_DATA_HOME)/bash-completion/completions/pass-meta

FILES += $(XDG_DATA_HOME)/python/history
$(XDG_DATA_HOME)/python/history: $(BASHRCD)/bashrc-xdg
	@install -d $(@D)
	@touch $@

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service
$(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service: \
	$(DF_FSHOME)/.config/systemd/user/restic-backup@.service.template \
	| $(DOTHOME_BIN)/restic-backup gettext-envsubst
	@WORKDIR=$(DF_ROOT) envsubst '$$TODAY $$USER $$WORKDIR' < $< | install -m 644 -D /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-stats@.service
$(XDG_CONFIG_HOME)/systemd/user/restic-stats@.service: \
	$(DF_FSHOME)/.config/systemd/user/restic-stats@.service.template \
	| $(DOTHOME_BIN)/restic-stats $(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service gettext-envsubst
	@WORKDIR=$(DF_ROOT) envsubst '$$TODAY $$USER $$WORKDIR' < $< | install -m 644 -D /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-check@.service
$(XDG_CONFIG_HOME)/systemd/user/restic-check@.service: \
	$(DF_FSHOME)/.config/systemd/user/restic-check@.service.template \
	| $(DOTHOME_BIN)/restic-check gettext-envsubst
	@WORKDIR=$(DF_ROOT) envsubst '$$TODAY $$USER $$WORKDIR' < $< | install -m 644 -D /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-backup-daily@.timer
$(XDG_CONFIG_HOME)/systemd/user/restic-backup-daily@.timer: \
	$(DF_FSHOME)/.config/systemd/user/restic-backup-daily@.timer.template \
	| $(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | install -m 644 -D /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-backup-monthly@.timer
$(XDG_CONFIG_HOME)/systemd/user/restic-backup-monthly@.timer: \
	$(DF_FSHOME)/.config/systemd/user/restic-backup-monthly@.timer.template \
	| $(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | install -m 644 -D /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-check-monthly@.timer
$(XDG_CONFIG_HOME)/systemd/user/restic-check-monthly@.timer: \
	$(DF_FSHOME)/.config/systemd/user/restic-check-monthly@.timer.template \
	| $(DOTHOME_BIN)/restic-check gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | install -m 644 -D /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(DOTHOME_BIN)/install-gnome-extensions
$(DOTHOME_BIN)/install-gnome-extensions: $(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh
	@ln -svfn $< $@
	@chmod u+x $@

FILES += $(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh
$(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh: | gnome-desktop git
	@$(call clone,install-gnome-extensions.git)

FILES += $(NVM_DIR)/nvm.sh
$(NVM_DIR)/nvm.sh:
	@install -d $(NVM_DIR)
	@PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

#
# /usr
#

FILES += /usr/local/bin/pass-gen
/usr/local/bin/pass-gen: | git pass $(DF_FSHOME)/.passgenrc
	@$(call clone,pass-gen.git)
	@sudo make -C $(DOTHOME_OPT)/pass-gen.git install

#
#  /etc
#

FILES += /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:hyperreal\:better_fonts.repo
/etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:hyperreal\:better_fonts.repo:
	@sudo dnf copr enable -y hyperreal/better_fonts
	@# Delete previously used copr repository (if available)
	-@sudo dnf copr remove chriscowleyunix/better_fonts
	-@sudo dnf copr remove gombosg/better_fonts

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
/etc/yum.repos.d/opera.repo: $(DF_FSETC)/yum.repos.d/opera.repo.template | gettext-envsubst
	-@sudo rpm --import https://rpm.opera.com/rpmrepo.key
	@sudo install -d $(@D)
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@

FILES += /etc/yum.repos.d/keybase.repo
/etc/yum.repos.d/keybase.repo: $(DF_FSETC)/yum.repos.d/keybase.repo.template | gettext-envsubst
	@sudo install -d $(@D)
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@

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

FILES += /etc/NetworkManager/conf.d/00-randomize-mac.conf
/etc/NetworkManager/conf.d/00-randomize-mac.conf: $(DF_FSETC)/NetworkManager/conf.d/00-randomize-mac.conf.template \
	| gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@
	@sudo systemctl restart NetworkManager

FILES += /etc/systemd/logind.conf.d/power.conf
/etc/systemd/logind.conf.d/power.conf: $(DF_FSETC)/systemd/logind.conf.d/power.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@

FILES += /etc/systemd/resolved.conf.d/dnssec.conf
/etc/systemd/resolved.conf.d/dnssec.conf: $(DF_FSETC)/systemd/resolved.conf.d/dnssec.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@
	@sudo systemctl restart systemd-resolved

FILES += /etc/udev/rules.d/60-streamdeck.rules
/etc/udev/rules.d/60-streamdeck.rules: $(DF_FSETC)/udev/rules.d/60-streamdeck.rules.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@
	@sudo udevadm control --reload-rules && sudo udevadm trigger

FILES += /etc/pki/akmods/certs/public_key.der
/etc/pki/akmods/certs/public_key.der: | akmods mokutil openssl
	@# Safe to run multiple times. It will not recreate existing keys
	@sudo kmodgenca -a

FILES += /etc/polkit-1/rules.d/10-admin-auth-ignore-inhibit.rules
/etc/polkit-1/rules.d/10-admin-auth-ignore-inhibit.rules: \
	$(DF_FSETC)/polkit-1/rules.d/10-admin-auth-ignore-inhibit.rules.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@

FILES += /etc/polkit-1/rules.d/70-allow-usbguard.rules
/etc/polkit-1/rules.d/70-allow-usbguard.rules: $(DF_FSETC)/polkit-1/rules.d/70-allow-usbguard.rules.template \
	| gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@

FILES += /etc/udev/rules.d/71-sony-controllers.rules
/etc/udev/rules.d/71-sony-controllers.rules: $(DF_FSETC)/udev/rules.d/71-sony-controllers.rules.template \
	| gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@
	@sudo udevadm control --reload-rules && sudo udevadm trigger

FILES += /etc/logrotate.d/dnf
/etc/logrotate.d/dnf: $(DF_FSETC)/logrotate.d/dnf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@

########################################################################################################################
#
# Patches
#

# Set correct timezone and enable date/time synchronization
PATCH += patch-time-sync
patch-time-sync: | systemd
	@timedatectl set-timezone 'America/New_York'
	@timedatectl set-ntp true

# Ensure the system is configured to maintain the RTC in Universal Time (UTC).
PATCH += patch-local-rtc
patch-local-rtc: | systemd
	@if [ "$$(timedatectl show -p LocalRTC --value)" == "yes" ]; then timedatectl set-local-rtc 0 --adjust-system-clock; fi

# Initial setup to detect which sensors can be reported
PATCH += /etc/sysconfig/lm_sensors
/etc/sysconfig/lm_sensors: | lm_sensors
	@sudo sensors-detect

# Potential fix for mouse lag (e.g., disabling autosuspend for the Dell Universal Receiver)
PATCH += /etc/udev/rules.d/50-usb-power-save.rules
/etc/udev/rules.d/50-usb-power-save.rules: $(DF_FSETC)/udev/rules.d/50-usb-power-save.rules.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@
	@sudo udevadm control --reload-rules && sudo udevadm trigger

# Fix for the NVIDIA suspend issue
PATCH += patch-gnome-suspend
patch-gnome-suspend: | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $(DF_FSETC)/systemd/system/gnome-shell-suspend.service.template \
		| sudo install -m 644 -D /dev/stdin /etc/systemd/system/gnome-shell-suspend.service

	@envsubst '$$TODAY $$USER' < $(DF_FSETC)/systemd/system/gnome-shell-resume.service.template \
		| sudo install -m 644 -D /dev/stdin /etc/systemd/system/gnome-shell-resume.service

	@sudo systemctl daemon-reload
	@sudo systemctl enable gnome-shell-suspend
	@sudo systemctl enable gnome-shell-resume

PATCH += disable-gnome-tracker
disable-gnome-tracker: | gnome-desktop gnome-tracker-settings
	-@sudo systemctl --user mask \
		tracker-extract-3.service \
		tracker-miner-fs-3.service \
		tracker-miner-rss-3.service \
		tracker-writeback-3.service \
		tracker-xdg-portal-3.service \
		tracker-miner-fs-control-3.service
	-@tracker3 reset -s -r || true

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

UPDATE += update-snap
update-snap:
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO),"\\nUpdating 'snap' packages ...\\n")
	@sudo snap refresh

UPDATE += update-gnome-extensions
update-gnome-extensions:
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO), "\\nScheduling GNOME extension auto-update ...\\n")
	-@gdbus call --session \
		--dest org.gnome.Shell.Extensions \
		--object-path /org/gnome/Shell/Extensions \
		--method org.gnome.Shell.Extensions.CheckForUpdates

UPDATE += update-micro-plugins
update-micro-plugins: | micro
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO), "\\nUpdating micro plugins ...\\n")
	@$(foreach plugin,$(EXT_MICRO),$$(command -v micro) -plugin update $(subst micro_,,$(plugin);$(NEWLINE)))

UPDATE += update-firmware
update-firmware: | fwupd
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO), "\\nUpdating firmware ...\\n")
	@fwupdmgr get-updates --force
	@fwupdmgr update

UPDATE += update-gnome-shell-extensions-bin
update-gnome-shell-extensions-bin: $(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh
	@git -C $(DOTHOME_OPT)/install-gnome-extensions.git pull

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
	@# Fix for the journal warning:
	@# "Permissions 0664 for '/home/user/.config/Yubico/u2f_keys' are too open. Please change the file mode bits to
	@# 0644 or more restrictive. This may become an error in the future!"
	@chmod 0644 $(HOME)/.config/Yubico/u2f_keys

SETUP += setup-mok-keys
setup-mok-keys: /etc/pki/akmods/certs/public_key.der
	@if [[ "$$(sudo mokutil --test-key $< 2>&1)" =~ "is not enrolled" ]]; then \
		sudo mokutil --import $<; \
		sudo mokutil --list-new; \
		sudo akmods --force; \
		$(call log,$(WARN),"Warning: You must restart ASAP to run MOK manager"); \
	fi

SETUP += setup-usbguard
setup-usbguard: | usbguard usbguard-notifier usbguard-dbus
	@sudo sh -c 'usbguard generate-policy > /etc/usbguard/rules.conf'
	@sudo chmod 600 /etc/usbguard/rules.conf
	@sudo systemctl enable --now usbguard.service
	@sudo systemctl enable --now usbguard-dbus.service
	@systemctl --user enable --now usbguard-notifier.service

########################################################################################################################
#
# Verification rules
#

CHECK += check-security-updates
check-security-updates:
	@sudo dnf -q check-update --security || $(call log,$(WARN),"Warning: There are security updates available!");

CHECK += check-dnf-autoremove
check-dnf-autoremove:
	@if [ $$(sudo dnf list -q --autoremove | wc -l) -gt 0 ]; then
	@	$(call log,$(WARN),"Warning: There are candidate rpm packages for auto-removal");
	@fi

CHECK += check-dnf-needs-restarting
check-dnf-needs-restarting:
	-@sudo dnf needs-restarting

CHECK += check-rpmconf
check-rpmconf: | rpmconf meld
	@sudo rpmconf -a -f meld

CHECK += check-sys-configs
check-sys-configs: | rpm
	-@sudo rpm -Va

CHECK += check-disk-space
check-disk-space: | duf
	@duf -all -warnings

CHECK += check-docker-disk-usage
check-docker-disk-usage: | docker
	-@docker system df

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
	 $(OS_RELEASE_EOL). Update your OS ASAP\x21\\n\\n") || true

CHECK += check-fwupd-security
check-fwupd-security: | fwupd
	@sudo fwupdmgr security

CHECK += check-journal
check-journal:
	@journalctl --verify

CHECK += check-ecryptfs
check-ecryptfs: | ecryptfs-utils
	@ecryptfs-verify -p

define restic-check-rule-set
# Target called by a systemd service to generate state report for the specific environment
.PHONY: check-restic-$(1)-no-deps
check-restic-$(1)-no-deps:
	@$(DOTHOME_BIN)/restic-check --env-file "$(DOTHOME_BACKUP)/.env.restic.$(1)"

CHECK += check-restic-$(1)
check-restic-$(1): $(DOTHOME_BIN)/restic-check check-restic-$(1)-no-deps
endef

# Generate dynamic check rules for each restic environment
$(foreach env, $(ENV_BACKUP),\
	$(eval $(call restic-check-rule-set,$(env))))

CHECK += check-rasdaemon
check-rasdaemon: | rasdaemon
	@sudo ras-mc-ctl --summary

CHECK += check-firewalld-config
check-firewalld-config:
	@sudo firewall-cmd --check-config

CHECK += check-missing-packages
check-missing-packages:
	@# Check that defined packages are installed and correctly named
	@$(foreach package,$(PKG_RPM) $(EXT_DNF) $(PKG_FONT),\
		rpm -q $(package) > /dev/null || \
			{ $(call log,$(ERR),"Error: Package [$(package)] is defined\x2C but not installed \
				or has a different name\x21"); exit 1;}$(NEWLINE))

########################################################################################################################
#
# Backup rules
#

define restic-backup-rule-set
# Target called by a systemd service to execute a backup using the specific backup configuration and restic environment
.PHONY: backup-restic-$(1)-$(2)-no-deps
backup-restic-$(1)-$(2)-no-deps:
	@$(DOTHOME_BIN)/restic-backup --conf-file "$(DOTHOME_BACKUP)/.conf.backup.$(1)" --env-file "$(DOTHOME_BACKUP)/.env.restic.$(2)"

# Target called by a systemd service to generate a stats report for the specific restic environment
.PHONY: stats-restic-$(1)-$(2)-no-deps
stats-restic-$(1)-$(2)-no-deps:
	@$(DOTHOME_BIN)/restic-stats --backup-conf-name "$(1)" --env-file "$(DOTHOME_BACKUP)/.env.restic.$(2)"

BACKUP += backup-$(1)-$(2)
backup-$(1)-$(2): $(DOTHOME_BACKUP)/.conf.backup.$(1) $(DOTHOME_BACKUP)/.env.restic.$(2) $(DOTHOME_BIN)/restic-backup $(DOTHOME_BIN)/restic-stats backup-restic-$(1)-$(2)-no-deps
endef

# Generate dynamic backup rules for every pair of backup config and environment (e.g. <conf>-<env>)
$(foreach config, $(CONF_BACKUP),\
 	$(foreach env, $(ENV_BACKUP),\
 		$(eval $(call restic-backup-rule-set,$(config),$(env)))))

BACKUP += backup-pass
backup-pass: git pass pass-extensions
	@pass git push -u origin master

########################################################################################################################
#
# Aliases
#

.PHONY: snap
snap: snapd

.PHONY: vscode
vscode: code $(EXT_VSCODE)

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
intellij: intellij-idea-community $(EXT_INTELLIJ)

.PHONY: geoclue
geoclue: geoclue2

.PHONY: streamcontroller
streamcontroller: com.core447.StreamController

.PHONY: backup-home
backup-home: backup-home-primary backup-home-secondary backup-home-cloud

.PHONY: backup-router
backup-router: backup-nebula-primary backup-nebula-secondary backup-nebula-cloud

.PHONY: backup-system
backup-system: backup-system-primary backup-system-secondary backup-system-cloud

.PHONY: wget
wget: wget2

.PHONY: dnf
dnf: dnf5

.PHONY: nvm
nvm: $(NVM_DIR)/nvm.sh

.PHONY: nodejs
nodejs: nodejs-lts

########################################################################################################################
#
# Main targets
#

install: | files $(INSTALL) ## Check all packages and managed files (except system patches)

files: | $(FILES) ## Check that all managed files are up-to-date

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
	@$(foreach v,$(sort $(.VARIABLES)), \
		$(if $(filter-out environment% default automatic, \
			$(origin $v)),$(warning $v=$($v) ($(value $v)))))

.PHONY: $(INSTALL) $(PATCH) $(UPDATE) $(CLEAN) $(SETUP) $(CHECK) $(BACKUP) \
	files install patch update clean setup check backup all help printvars
