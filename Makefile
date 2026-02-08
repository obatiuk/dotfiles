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
export XDG_STATE_HOME ?= $(HOME)/.local/state
export XDG_CACHE_HOME ?= $(HOME)/.cache
export XDG_PICTURES_DIR ?= $(HOME)/Private/Pictures
export NVM_DIR ?= $(XDG_DATA_HOME)/nvm
export NOW := $(shell date +%Y-%m-%d_%H:%M:%S)
export TODAY := $(shell date -I)
export BACKUP_HOST := backup.lan

MODEL := $(shell (if command -v hostnamectl > /dev/null 2>&1; \
	then hostnamectl | grep 'Hardware Model:' | sed 's/^.*: //'; \
	else sudo dmidecode -s system-product-name ; fi) | tr "[:upper:]" "[:lower:]" | sed 's/ /-/g')
OS_RELEASE_EOL=$(shell grep -o 'SUPPORT_END=.*' /etc/os-release | sed 's/SUPPORT_END=//' )

DF_MAKEFILE_NAME := $(abspath $(lastword $(MAKEFILE_LIST)))
DF_ROOT := $(abspath $(dir $(DF_MAKEFILE_NAME)))
DF_FSROOT := $(abspath $(DF_ROOT)/fsroot)
DF_FSHOME := $(abspath $(DF_FSROOT)/home/obatiuk)
DF_FSETC := $(abspath $(DF_FSROOT)/etc)
DF_INCLUDE := $(abspath $(DF_ROOT)/include)
DF_DEVICE := $(abspath $(DF_INCLUDE)/device)
DF_GNOME := $(abspath $(DF_INCLUDE)/DE/GNOME)
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

########################################################################################################################
#
# Includes
#

# Include model-specific patches
-include $(DF_DEVICE)/$(MODEL)/$(MODEL).mk
-include $(DF_GNOME)/GNOME.mk

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
PKG_RPM += rpm deltarpm dnf5 dnf-utils lsb_release rpmconf pam-u2f pamu2fcfg audit plymouth-system-theme NetworkManager
PKG_RPM += akmods fwupd bluez mokutil brightnessctl ssh-audit coreutils openssl tuned acpi lm_sensors sysstat thermald
PKG_RPM += make tree usbguard-selinux usbguard-notifier usbguard-dbus cifs-utils sharutils binutils usbutils pciutils
PKG_RPM += iwlwifi-dvm-firmware iwlwifi-mld-firmware iwlwifi-mvm-firmware
PKG_RPM += xdg-utils xdg-user-dirs dconf man-pages
PKG_RPM += bash bash-completion screen progress pv tio dialog catimg wget2 bc uuid crudini gettext-envsubst symlinks
PKG_RPM += fastfetch duf fd-find ydiff webp-pixbuf-loader feh nano htop btop fzf less httpie lynis cheat tldr golang
PKG_RPM += policycoreutils-devel mdns-scan fping nmap iotop-c tcpdump avahi avahi-tools samba-client
PKG_RPM += gnupg2 pinentry-tty pass-otp pass-audit curl jq libnotify libsecret pwgen
PKG_RPM += gvfs-mtp 7zip-standalone unrar cabextract bsdtar odt2txt qrencode
PKG_RPM += glow micro bat mc git gh diffutils git-lfs git-extras git-credential-libsecret git-crypt lynx whois
PKG_RPM += perl-Image-ExifTool calibre ebook-tools dos2unix graphviz
PKG_RPM += java-latest-openjdk java-21-openjdk java-25-openjdk adoptium-temurin-java-repository
PKG_RPM += python3 python3-pip python3-devel python3-virtualenv
PKG_RPM += libreoffice-writer libreoffice-calc libreoffice-filters minder firefox ImageMagick xsensors ffmpeg
PKG_RPM += xsane diff-pdf media-player-info steam-devices
PKG_RPM += dracut-network dracut-squash NetworkManager-config-connectivity-fedora
PKG_RPM += clamav clamav-freshclam clamav-data
PKG_RPM += syncthing restic rsync rclone
PKG_RPM += cups hplip hplip-gui

# DNF plugins
EXT_DNF := dnf-plugins-core dnf-plugin-diff python3-dnf-plugin-tracer python3-dnf-plugin-rpmconf
EXT_DNF += remove-retired-packages dracut-config-rescue clean-rpm-gpg-pubkey python3-dnf-plugin-show-leaves

# All `snap` packages that do not require manual installation steps
PKG_SNAP := chromium-ffmpeg mqtt-explorer

# All **user** `flatpak` that do not require manual installation steps
PKG_FLATPAK := org.gnupg.GPA be.alexandervanhee.gradia com.core447.StreamController

# Font packages
PKG_FONT := google-droid-sans-fonts google-droid-serif-fonts google-droid-sans-mono-fonts
PKG_FONT += google-roboto-fonts adobe-source-code-pro-fonts dejavu-sans-fonts dejavu-sans-mono-fonts
PKG_FONT += dejavu-serif-fonts liberation-mono-fonts liberation-narrow-fonts liberation-sans-fonts
PKG_FONT += liberation-serif-fonts jetbrains-mono-fonts-all fontawesome-fonts-all fontawesome4-fonts fira-code-fonts

# VSCode extensions
EXT_VSCODE := EditorConfig.EditorConfig jianbingfang.dupchecker mechatroner.rainbow-csv bierner.markdown-mermaid
EXT_VSCODE += bpruitt-goddard.mermaid-markdown-syntax-highlighting eamodio.gitlens ecmel.vscode-html-css
EXT_VSCODE += humao.rest-client jebbs.plantuml moshfeu.compare-folders ms-azuretools.vscode-docker ph-hawkins.arc-plus
EXT_VSCODE += PKief.material-icon-theme redhat.java redhat.vscode-xml redhat.vscode-yaml
EXT_VSCODE += streetsidesoftware.code-spell-checker timonwong.shellcheck usernamehw.errorlens vscjava.vscode-maven
EXT_VSCODE += yzhang.markdown-all-in-one ms-python.python lintangwisesa.arduino ms-vscode.makefile-tools
EXT_VSCODE += keesschollaart.vscode-home-assistant

# IntelliJ extensions
EXT_INTELLIJ := ru.adelf.idea.dotenv lermitage.intellij.battery.status Docker name.kropp.intellij.makefile
EXT_INTELLIJ += com.jetbrains.plugins.ini4idea net.sjrx.intellij.plugins.systemdunitfiles

# `micro` editor extensions
EXT_MICRO += $(addprefix micro_,editorconfig fzf filemanager)

# pass extensions
EXT_PASS := symlink.bash age.bash ln.bash file.bash update.bash tessen.bash meta.bash

# Backup configuration names
CONF_BACKUP := system home nebula

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
# Package installation customizations
#

INSTALL += dnf-plugins
dnf-plugins: $(EXT_DNF)

INSTALL += dnf-settings
dnf-settings: /etc/dnf/dnf.conf crudini
	@sudo crudini --ini-options=nospace --set $< main fastestmirror 1
	@sudo crudini --ini-options=nospace --set $< main max_parallel_downloads 10
	@sudo crudini --ini-options=nospace --set $< main ip_resolve 4

INSTALL += fedora-workstation-repositories
fedora-workstation-repositories:
	@$(call dnf,$@)
	@sudo dnf config-manager setopt google-chrome.enabled=1

INSTALL += core
core:
	@sudo dnf -y install @core

INSTALL += ecryptfs-utils
ecryptfs-utils:
	@$(call dnf,$@)
	@sudo modprobe ecryptfs
	@sudo usermod -aG ecryptfs '$(USER)'

INSTALL += fonts-ms
fonts-ms: | curl
	@$(call dnf,xorg-x11-font-utils)
	@curl -sL -O --output-dir /tmp "https://phoenixnap.dl.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm"
	@sudo rpm -ivh --nodigest --nofiledigest /tmp/msttcore-fonts-installer-2.6-1.noarch.rpm
	@rm -fv /tmp/msttcore-fonts-installer-2.6-1.noarch.rpm

INSTALL += fonts-nerd
fonts-nerd: | curl bsdtar
	@install -d ${XDG_DATA_HOME}/fonts/NerdFonts
	@curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip" | bsdtar -xv -f - -C ${XDG_DATA_HOME}/fonts/NerdFonts
	@curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip" | bsdtar -xv -f - -C ${XDG_DATA_HOME}/fonts/NerdFonts
	@fc-cache -fv

INSTALL += fonts-better
fonts-better: /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:hyperreal\:better_fonts.repo
	@dnf download --releasever=42 --destdir=/tmp mozilla-fira-fonts-common mozilla-fira-mono-fonts mozilla-fira-sans-fonts
	@sudo rpm -ivh /tmp/mozilla-fira-fonts-common*.rpm /tmp/mozilla-fira-mono-fonts*.rpm /tmp/mozilla-fira-sans-fonts*.rpm
	@rm -f /tmp/mozilla*.rpm
	@$(call dnf,fontconfig-font-replacements)

INSTALL += fonts
fonts: $(PKG_FONT) fonts-ms fonts-nerd fonts-better
	@sudo dnf -y install @fonts

INSTALL += flatpak
flatpak:
	@$(call dnf,$@)
	@sudo flatpak --system remotes | grep 'flathub' > /dev/null || sudo flatpak --system remote-add --if-not-exists \
		flathub https://flathub.org/repo/flathub.flatpakrepo
	@flatpak --user remotes | grep 'flathub' > /dev/null || flatpak --user remote-add --if-not-exists \
		flathub https://flathub.org/repo/flathub.flatpakrepo
	@sudo flatpak --system remote-modify --no-filter --enable flathub
	@flatpak --user remote-modify --no-filter --enable flathub
	@flatpak install -y --system org.gtk.Gtk3theme.Arc-Darker

INSTALL += nodejs-lts
nodejs-lts: | $(NVM_DIR)/nvm.sh
	@[ -n "$$( source $(NVM_DIR)/nvm.sh && nvm ls | grep -v 'N/A' | grep -o 'lts/[a-zA-Z]*' | head -n 1)" ] \
		|| { . $(NVM_DIR)/nvm.sh && nvm install --lts; }

INSTALL += git-split-diffs
git-split-diffs: | nodejs
	@. $(NVM_DIR)/nvm.sh && npm list -g $@ > /dev/null || { . $(NVM_DIR)/nvm.sh && npm install -g $@; }

INSTALL += docker
docker: /etc/yum.repos.d/docker-ce.repo
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
video-codecs: /etc/yum.repos.d/rpmfusion-free.repo \
	/etc/yum.repos.d/rpmfusion-nonfree.repo \
	/etc/yum.repos.d/fedora-cisco-openh264.repo
	@sudo dnf -y swap --allowerasing ffmpeg-free ffmpeg
	@sudo dnf -y --setopt=strict=0 install \
		gstreamer{1,}-{ffmpeg,libav,vaapi,plugins-{good,ugly,bad{,-free,-nonfree,-freeworld,-extras}}}
	@sudo dnf -y install *openh264
	@sudo dnf -y install @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

INSTALL += google-chrome
google-chrome: /etc/yum.repos.d/google-chrome.repo
	@$(call dnf,google-chrome-stable)

INSTALL += vivaldi-bin
vivaldi-bin: /etc/yum.repos.d/vivaldi-fedora.repo
	@$(call dnf,vivaldi-stable)

INSTALL += vivaldi
vivaldi: vivaldi-bin $(VIVALDI_CONF_FILES)

INSTALL += opera
opera: /etc/yum.repos.d/opera.repo
	@$(call dnf,opera-stable)

INSTALL += keybase
keybase: /etc/yum.repos.d/keybase.repo
	@$(call dnf,$@)

INSTALL += arduino
arduino: flatpak
	@flatpak -y --user install cc.arduino.arduinoide cc.arduino.IDE2
	@sudo usermod -aG dialout,tty,lock '$(USER)'

INSTALL += code
code: snapd
	@sudo snap install $@ --classic

INSTALL += ddcutil
ddcutil: /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:rockowitz\:ddcutil.repo
	@$(call dnf,$@)

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

INSTALL += obsidian
obsidian: | flatpak
	#@flatpak install md.obsidian.Obsidian - disabled for now to keep current locked version

INSTALL += steam
steam: | flatpak steam-devices /etc/yum.repos.d/rpmfusion-nonfree.repo
	@flatpak install -y --user flathub com.valvesoftware.Steam \
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
browserpass-bin: | git make coreutils golang
	@$(call clone,browserpass-native.git)
	@make -C $(DOTHOME_OPT)/browserpass-native.git browserpass configure
	@sudo make -C $(DOTHOME_OPT)/browserpass-native.git install
	@make -C $(DOTHOME_OPT)/browserpass-native.git hosts-chrome-user hosts-firefox-user hosts-vivaldi-user \
		policies-chrome-user policies-vivaldi-user

CLEAN += clean-browserpass
clean-browserpass: | make
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
	@$(foreach editor,$(EDITORS),sudo alternatives --install '/usr/bin/editor' editor '$(editor)' 0;$(NEWLINE))
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
	$(DOTHOME_BACKUP)/.env.restic.primary \
	$(DOTHOME_BACKUP)/.env.restic.secondary \
	$(DOTHOME_BACKUP)/.env.restic.cloud \
	$(DOTHOME_BACKUP)/.conf.backup.home \
	$(DOTHOME_BACKUP)/.conf.backup.nebula \
	$(DOTHOME_BACKUP)/.conf.backup.system
	@$(NEWLINE)# Enable all `restic-stats` services
	@$(foreach conf,$(CONF_BACKUP),\
		$(foreach env,$(ENV_BACKUP),\
			$(NEWLINE)@systemctl enable --user restic-stats@$(conf)-$(env).service))

INSTALL += mosquitto
mosquitto:
	@$(call dnf,$@)
	@if systemctl -q is-enabled $@ > /dev/null; then
		# Disable mosquitto services, we need only mosquitto_pub/sub binaries
	@	sudo systemctl stop $@
	@	sudo systemctl disable $@
	@fi

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

INSTALL += vlc
vlc:
	@sudo dnf -y install @vlc vlc-plugin*

########################################################################################################################
#
# Bulk installation rules
#

INSTALL += $(EXT_DNF)
$(EXT_DNF):
	@$(call dnf,$@)

INSTALL += $(PKG_RPM)
$(PKG_RPM):
	@$(call dnf,$@)

INSTALL += $(PKG_FONT)
$(PKG_FONT):
	@$(call dnf,$@)

INSTALL += $(PKG_SNAP)
$(PKG_SNAP): | snapd
	@sudo snap install $@

INSTALL += $(PKG_FLATPAK)
$(PKG_FLATPAK): | flatpak
	@flatpak install -y --user $@

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

FILES += $(HOME)/.passgenrc
$(HOME)/.passgenrc : $(DF_FSHOME)/.passgenrc | pass
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME)/git/config
$(XDG_CONFIG_HOME)/git/config: $(DF_FSHOME)/.config/git/config | git git-lfs git-credential-libsecret \
		git-split-diffs bat perl-Image-ExifTool
	@install -d $(@D)
	@ln -svfn $< $@

FILES += $(DOTHOME_BIN)/dell-kvm-switch-input
$(DOTHOME_BIN)/dell-kvm-switch-input: $(DF_FSHOME)/.home/bin/dell-kvm-switch-input | ddcutil
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/switch-monitor
$(DOTHOME_BIN)/switch-monitor: $(DF_FSHOME)/.home/bin/switch-monitor
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/start-steam
$(DOTHOME_BIN)/start-steam: $(DF_FSHOME)/.home/bin/start-steam | $(DOTHOME_BIN)/switch-monitor
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(DOTHOME_BIN)/restic-backup
$(DOTHOME_BIN)/restic-backup: $(DF_FSHOME)/.home/bin/restic-backup | restic jq mosquitto curl libsecret lsb_release \
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
	@LC_ALL=C.UTF-8 xdg-user-dirs-update

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
	@envsubst '$$TODAY $$USER $$XDG_CACHE_HOME' < $< | install -m 644 -DC /dev/stdin $@

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
	@install -m 600 -DC $< $@

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

FILES += $(XDG_STATE_HOME)/bash/history
$(XDG_STATE_HOME)/bash/history: $(BASHRCD)/bashrc-xdg
	@install -d $(@D)
	@touch $@

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service
$(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service: \
	$(DF_FSHOME)/.config/systemd/user/restic-backup@.service.template \
	| $(XDG_CONFIG_HOME)/systemd/user/network-check.service \
	$(DOTHOME_BIN)/restic-backup \
	gettext-envsubst
	@WORKDIR=$(DF_ROOT) envsubst '$$TODAY $$USER $$WORKDIR' < $< | install -m 644 -DC /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-stats@.service
$(XDG_CONFIG_HOME)/systemd/user/restic-stats@.service: \
	$(DF_FSHOME)/.config/systemd/user/restic-stats@.service.template \
	| $(XDG_CONFIG_HOME)/systemd/user/network-check.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service \
	$(DOTHOME_BIN)/restic-stats \
	gettext-envsubst
	@WORKDIR=$(DF_ROOT) envsubst '$$TODAY $$USER $$WORKDIR' < $< | install -m 644 -DC /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-check@.service
$(XDG_CONFIG_HOME)/systemd/user/restic-check@.service: \
	$(DF_FSHOME)/.config/systemd/user/restic-check@.service.template \
	| $(XDG_CONFIG_HOME)/systemd/user/network-check.service \
	$(DOTHOME_BIN)/restic-check \
	gettext-envsubst
	@WORKDIR=$(DF_ROOT) envsubst '$$TODAY $$USER $$WORKDIR' < $< | install -m 644 -DC /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-backup-daily@.timer
$(XDG_CONFIG_HOME)/systemd/user/restic-backup-daily@.timer: \
	$(DF_FSHOME)/.config/systemd/user/restic-backup-daily@.timer.template \
	| $(XDG_CONFIG_HOME)/systemd/user/network-check.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service \
	gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | install -m 644 -DC /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-backup-monthly@.timer
$(XDG_CONFIG_HOME)/systemd/user/restic-backup-monthly@.timer: \
	$(DF_FSHOME)/.config/systemd/user/restic-backup-monthly@.timer.template \
	| $(XDG_CONFIG_HOME)/systemd/user/network-check.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service \
	gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | install -m 644 -DC /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/restic-check-monthly@.timer
$(XDG_CONFIG_HOME)/systemd/user/restic-check-monthly@.timer: \
	$(DF_FSHOME)/.config/systemd/user/restic-check-monthly@.timer.template \
	| $(XDG_CONFIG_HOME)/systemd/user/network-check.service \
	$(DOTHOME_BIN)/restic-check \
	gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | install -m 644 -DC /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/network-online.service
$(XDG_CONFIG_HOME)/systemd/user/network-online.service: $(DF_FSHOME)/.config/systemd/user/network-online.service.template \
	| NetworkManager \
	gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | install -m 644 -DC /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload
	@systemctl --user enable --now $(@F)

FILES += $(XDG_CONFIG_HOME)/systemd/user/network-online.target
$(XDG_CONFIG_HOME)/systemd/user/network-online.target: $(DF_FSHOME)/.config/systemd/user/network-online.target.template \
	| $(XDG_CONFIG_HOME)/systemd/user/network-online.service \
	NetworkManager \
	gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | install -m 644 -DC /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload

FILES += $(XDG_CONFIG_HOME)/systemd/user/network-check.service
$(XDG_CONFIG_HOME)/systemd/user/network-check.service: $(DF_FSHOME)/.config/systemd/user/network-check.service.template \
	| $(XDG_CONFIG_HOME)/systemd/user/network-online.target \
	NetworkManager \
	gettext-envsubst
	@envsubst '$$TODAY $$USER $$BACKUP_HOST' < $< | install -m 644 -DC /dev/stdin $@
	@systemd-analyze verify $@
	@systemctl --user daemon-reload
	@systemctl --user enable --now $(@F)

FILES += $(NVM_DIR)/nvm.sh
$(NVM_DIR)/nvm.sh: | curl
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
	@sudo dnf copr remove -y chriscowleyunix/better_fonts || true
	@sudo dnf copr remove -y gombosg/better_fonts || true

FILES += /etc/yum.repos.d/docker-ce.repo
/etc/yum.repos.d/docker-ce.repo: | dnf-plugins
	@sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

FILES += /etc/yum.repos.d/google-chrome.repo
/etc/yum.repos.d/google-chrome.repo: | fedora-workstation-repositories

FILES += /etc/yum.repos.d/vivaldi-fedora.repo
/etc/yum.repos.d/vivaldi-fedora.repo: | dnf-plugins
	@sudo dnf config-manager addrepo --from-repofile=https://repo.vivaldi.com/stable/vivaldi-fedora.repo

FILES += /etc/yum.repos.d/opera.repo
/etc/yum.repos.d/opera.repo: $(DF_FSETC)/yum.repos.d/opera.repo.template | gettext-envsubst
	-@sudo rpm --import https://rpm.opera.com/rpmrepo.key
	@sudo install -d $(@D)
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@

FILES += /etc/yum.repos.d/keybase.repo
/etc/yum.repos.d/keybase.repo: $(DF_FSETC)/yum.repos.d/keybase.repo.template | gettext-envsubst
	@sudo install -d $(@D)
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@

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

FILES += /etc/NetworkManager/conf.d/00-randomize-mac.conf
/etc/NetworkManager/conf.d/00-randomize-mac.conf: $(DF_FSETC)/NetworkManager/conf.d/00-randomize-mac.conf.template \
	| gettext-envsubst NetworkManager
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@
	@sudo systemctl restart NetworkManager

FILES += /etc/systemd/logind.conf.d/power.conf
/etc/systemd/logind.conf.d/power.conf: $(DF_FSETC)/systemd/logind.conf.d/power.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@

FILES += /etc/systemd/resolved.conf.d/dnssec.conf
/etc/systemd/resolved.conf.d/dnssec.conf: $(DF_FSETC)/systemd/resolved.conf.d/dnssec.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@
	@sudo systemctl restart systemd-resolved

FILES += /etc/udev/rules.d/60-streamdeck.rules
/etc/udev/rules.d/60-streamdeck.rules: $(DF_FSETC)/udev/rules.d/60-streamdeck.rules.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@
	@sudo udevadm control --reload-rules && sudo udevadm trigger

FILES += /etc/pki/akmods/certs/public_key.der
/etc/pki/akmods/certs/public_key.der: | akmods mokutil openssl
	@# Safe to run multiple times. It will not recreate existing keys
	@sudo kmodgenca -a

FILES += /etc/polkit-1/rules.d/10-admin-auth-ignore-inhibit.rules
/etc/polkit-1/rules.d/10-admin-auth-ignore-inhibit.rules: \
	$(DF_FSETC)/polkit-1/rules.d/10-admin-auth-ignore-inhibit.rules.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@

FILES += /etc/polkit-1/rules.d/70-allow-usbguard.rules
/etc/polkit-1/rules.d/70-allow-usbguard.rules: $(DF_FSETC)/polkit-1/rules.d/70-allow-usbguard.rules.template \
	| gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@

FILES += /etc/udev/rules.d/71-sony-controllers.rules
/etc/udev/rules.d/71-sony-controllers.rules: $(DF_FSETC)/udev/rules.d/71-sony-controllers.rules.template \
	| gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@
	@sudo udevadm control --reload-rules && sudo udevadm trigger

FILES += /etc/logrotate.d/dnf
/etc/logrotate.d/dnf: $(DF_FSETC)/logrotate.d/dnf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@

########################################################################################################################
#
# Patches
#

# Set correct timezone and enable date/time synchronization
PATCH += patch-time-sync
patch-time-sync:
	@timedatectl set-timezone 'America/New_York'
	@timedatectl set-ntp true

# Ensure the system is configured to maintain the RTC in Universal Time (UTC).
PATCH += patch-local-rtc
patch-local-rtc:
	@if [ "$$(timedatectl show -p LocalRTC --value)" == "yes" ]; then timedatectl set-local-rtc 0 --adjust-system-clock; fi

# Potential fix for mouse lag (e.g., disabling autosuspend for the Dell Universal Receiver)
PATCH += /etc/udev/rules.d/50-usb-power-save.rules
/etc/udev/rules.d/50-usb-power-save.rules: $(DF_FSETC)/udev/rules.d/50-usb-power-save.rules.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -DC /dev/stdin $@
	@sudo udevadm control --reload-rules && sudo udevadm trigger

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
	@flatpak update -y
	@flatpak update -y --user

UPDATE += update-snap
update-snap:
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO),"\\nUpdating 'snap' packages ...\\n")
	@sudo snap refresh

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
clean-journal:
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

# Initial setup to detect which sensors can be reported
SETUP += /etc/sysconfig/lm_sensors
/etc/sysconfig/lm_sensors: | lm_sensors
	@sudo sensors-detect

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
	-@sudo fwupdmgr security

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

.PHONY: dnf-upgrade
dnf-upgrade: dnf-plugins dnf-settings
	@sudo dnf -y upgrade --refresh

# Speed up the initial run by installing all RPM packages in one go
.PHONY: install-all-rpm-packages
install-all-rpm-packages: dnf-upgrade
	@sudo dnf -y install $(PKG_RPM) $(EXT_DNF) $(PKG_FONT)

.PHONY: start-backup-timers
start-backup-timers: $(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-stats@.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-check@.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-backup-daily@.timer \
	$(XDG_CONFIG_HOME)/systemd/user/restic-check-monthly@.timer
	@$(NEWLINE)# Start all daily backup timers
	@$(foreach conf,home,\
		$(foreach env,$(ENV_BACKUP),\
			$(NEWLINE)@systemctl enable --now --user restic-backup-daily@$(conf)-$(env).timer))

	@$(NEWLINE)# Start all monthly backup timers
	@$(foreach conf,nebula,\
		$(foreach env,$(ENV_BACKUP),\
			$(NEWLINE)@systemctl enable --now --user restic-backup-monthly@$(conf)-$(env).timer))

	@$(NEWLINE)# Start all monthly repository check timer
	@$(foreach env,$(ENV_BACKUP),\
		$(NEWLINE)@systemctl enable --now --user restic-check-monthly@$(env).timer)

.PHONY: stop-backup-timers
stop-backup-timers: $(XDG_CONFIG_HOME)/systemd/user/restic-backup@.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-stats@.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-check@.service \
	$(XDG_CONFIG_HOME)/systemd/user/restic-backup-daily@.timer \
	$(XDG_CONFIG_HOME)/systemd/user/restic-check-monthly@.timer
	@$(NEWLINE)# Stop all daily backup timers
	@$(foreach conf,home,\
		$(foreach env,$(ENV_BACKUP),\
			$(NEWLINE)@systemctl disable --now --user restic-backup-daily@$(conf)-$(env).timer))

	@$(NEWLINE)# Stop all monthly backup timers
	@$(foreach conf,nebula,\
		$(foreach env,$(ENV_BACKUP),\
			$(NEWLINE)@systemctl disable --now --user restic-backup-monthly@$(conf)-$(env).timer))

	@$(NEWLINE)# Stop all monthly repository check timers
	@$(foreach env,$(ENV_BACKUP),\
		$(NEWLINE)@systemctl disable --now --user restic-check-monthly@$(env).timer)

########################################################################################################################
#
# Main targets
#

init: dnf-upgrade install-all-rpm-packages files install patch start-backup-timers ## Run initial setup (install all packages, files and patches)

install: $(INSTALL) ## Check all packages and managed files (except system patches)

files: $(FILES) ## Check that all managed files are up-to-date

patch: $(PATCH) ## Check system patches

update: $(UPDATE) ## Update installed software

clean: $(CLEAN) ## Do a system cleanup

setup: $(SETUP) ## Run setup scripts that require manual input

check: $(CHECK) ## Perform different checks

backup: $(BACKUP) ## Backup everything

all: install files patch update clean setup check backup ## install, check, update, patch packages and firmware; check and backup everything

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
