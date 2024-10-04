#!/usr/bin/env make -f
.ONESHELL:
.DEFAULT_GOAL := help

SHELL = /bin/bash
# .SHELLFLAGS := -eu -o pipefail -c # Useful debug options
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

colon := :
$(colon) := :
space := $(subst ,, )
dash := -
slash := /

export XDG_CONFIG_HOME ?= $(HOME)/.config
export XDG_DATA_HOME ?= $(HOME)/.local/share
export XDG_PICTURES_DIR ?= $(HOME)/Private/Pictures
export NVM_DIR ?= $(XDG_DATA_HOME)/nvm

top := $(shell pwd)
now := $(shell date +%Y-%m-%d_%H:%M:%S)
uid := $(shell id -u)
model := $(shell (if command -v hostnamectl > /dev/null 2>&1; \
	then hostnamectl | grep 'Hardware Model:' | sed 's/^.*: //'; \
	else sudo dmidecode -s system-product-name ; fi) | tr "[:upper:]" "[:lower:]")

INCLUDE = ./include

XDG_CONFIG_HOME_PATH := $(XDG_CONFIG_HOME)
XDG_DATA_HOME_PATH := $(XDG_DATA_HOME)
XDG_PICTURES_DIR_PATH := $(XDG_PICTURES_DIR)

NVM_PATH = $(NVM_DIR)
NVM_CMD = . $(NVM_PATH)/nvm.sh && nvm

MAKEFILE_NAME := $(abspath $(lastword $(MAKEFILE_LIST)))
DOTFILES_PATH := $(abspath $(dir $(MAKEFILE_NAME)))
DOTHOME_PATH := $(abspath $(HOME)/.home)
BASHRCD_PATH := $(abspath $(HOME)/.bashrc.d)
HOMEBIN_PATH := $(abspath $(DOTHOME_PATH)/bin)
OPT_PATH := $(abspath $(DOTHOME_PATH)/opt)

VIVALDI_CF_SRC_PATH := $(DOTFILES_PATH)/.config/vivaldi/CustomUIModifications
VIVALDI_CF_DEST_PATH := $(XDG_CONFIG_HOME_PATH)/vivaldi/CustomUIModifications
ULAUNCHER_EXT_PATH := $(XDG_DATA_HOME_PATH)/ulauncher/extensions

INSTALL =
PATCH =
UPDATE =
CLEAN =
SETUP =
VERIFY =
BACKUP =

ARC_THEME_SOURCE ?= git

# TODO: Any way to not execute this when only `help` is requested?

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

define dnf
	@$(foreach pkg, $(strip $(1)),
		$(eval $@_PACKAGE = $(pkg))
		$(eval $@_SOURCE = $(pkg))
		# Remove all URI components except package name and arch if the package is the URL
		$(if $(findstring $(slash),$($@_PACKAGE)),
			$(eval $@_PACKAGE = $(subst .rpm,$(space),$(lastword $(subst $(slash),$(space),$(pkg))))))
		# Force package installation if -B flag is present
		$(if $(findstring B,$(firstword -$(MAKEFLAGS))),
			sudo dnf -y install $($@_SOURCE),
			rpm -q $($@_PACKAGE) >& /dev/null || sudo dnf -y install $($@_SOURCE)))
endef

# TODO consider to use dot function
#define dot =
#	ln -sfn $(DIR)/$(1) $(HOME)/.$(1)
#endef

########################################################################################################################
#
# Packages
#

# All rpm packages that are not directly referenced
packages_rpm := rpm dnf redhat-lsb redhat-lsb-core rpmconf pwgen systemd pam-u2f pamu2fcfg xdg-user-dirs
packages_rpm += iwl*-firmware fwupd bluez bash bash-completion avahi avahi-tools samba-client tree
packages_rpm += hplip hplip-gui xsane ffmpeg feh nano htop fzf less xdg-utils
packages_rpm += ImageMagick baobab gimp gparted diffuse gnome-terminal seahorse
packages_rpm += libreoffice-core libreoffice-writer libreoffice-calc libreoffice-filters
packages_rpm += gnome-pomodoro fd-find ydiff webp-pixbuf-loader
packages_rpm += screenfetch usbutils pciutils acpi
packages_rpm += gnupg2 pinentry-gtk pinentry-tty pinentry-gnome3
packages_rpm += gvfs-mtp screen tio dialog
packages_rpm += restic rsync rclone micro
packages_rpm += unrar lynx crudini sysstat p7zip nmap cabextract iotop qrencode uuid
packages_rpm += git diffutils git-lfs git-extras git-credential-libsecret git-crypt bat mc meld gh perl-Image-ExifTool
packages_rpm += snapd ulauncher
packages_rpm += fedora-workstation-repositories
packages_rpm += adwaita-icon-theme adwaita-cursor-theme dconf
packages_rpm += python3-virtualenv

# DNF plugins
plugins_dnf := dnf-plugins-core dnf-plugin-diff python3-dnf-plugin-tracer

# All `snap` packages that are not directly referenced
packages_snap := chromium-ffmpeg brave intellij-idea-community remarkable-desktop

# All `flatpak` packages that are not directly referenced
packages_flatpak := com.valvesoftware.Steam md.obsidian.Obsidian com.vscodium.codium

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

# VSCode extensions
ext_vscode := EditorConfig.EditorConfig jianbingfang.dupchecker mechatroner.rainbow-csv bierner.markdown-mermaid
ext_vscode += bpruitt-goddard.mermaid-markdown-syntax-highlighting eamodio.gitlens ecmel.vscode-html-css
ext_vscode += humao.rest-client jebbs.plantuml moshfeu.compare-folders ms-azuretools.vscode-docker ph-hawkins.arc-plus
ext_vscode += PKief.material-icon-theme redhat.java redhat.vscode-xml redhat.vscode-yaml
ext_vscode += streetsidesoftware.code-spell-checker timonwong.shellcheck usernamehw.errorlens vscjava.vscode-maven
ext_vscode += yzhang.markdown-all-in-one

ext_ulauncher += ulauncher-emoji.git pass-ulauncher.git pass-for-ulauncher.git pass-otp-for-ulauncher.git
ext_ulauncher += ulauncher-obsidian.git ulauncher-numconverter.git ulauncher-list-keywords.git

ext_intellij := ru.adelf.idea.dotenv lermitage.intellij.battery.status Docker
ext_intellij += name.kropp.intellij.makefile com.jetbrains.packagesearch.intellij-plugin

vivaldi_conf_files := $(shell find .config/vivaldi/CustomUIModifications -type f -name '*.*')
vivaldi_conf_dest_files := $(addprefix $(HOME)/, $(vivaldi_conf_files))

########################################################################################################################
#
# Package installation customizations and aliases
#

INSTALL += dnf-plugins
dnf-plugins: $(plugins_dnf)

INSTALL += ecryptfs-utils
ecryptfs-utils:
	@$(call dnf, $@)
	@sudo modprobe ecryptfs
	@sudo usermod -aG ecryptfs '$(USER)'

# Install fontconfig enhancements for better fonts rendering
INSTALL += fonts_better
fonts_better: /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:chriscowleyunix\:better_fonts.repo
	@$(call dnf, fontconfig-enhanced-defaults fontconfig-font-replacements)

# Install Microsoft proprietary fonts
INSTALL += fonts_ms
fonts_ms:
	@$(call dnf, http://sourceforge.net/projects/mscorefonts2/files/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm)

# Install all fonts and fontconfig enhancements
INSTALL += fonts
fonts: $(packages_fonts) fonts_better fonts_ms

INSTALL += flatpak
flatpak:
	@$(call dnf, $@)
	@flatpak remotes | grep 'flathub' > /dev/null || flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

INSTALL += nvm
nvm: git
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
	@$(call dnf, docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
	@sudo groupadd --force docker
	@sudo usermod -aG docker '$(USER)'
	@sudo systemctl enable --now docker

INSTALL += ql700
ql700:
	@$(call dnf, https://download.brother.com/welcome/dlfp002191/ql700pdrv-3.1.5-0.i386.rpm)
	# Fix QL-700 brother printer access when SELinux is enabled
	# Source:
	# - http://support.brother.com/g/s/id/linux/en/faq_prn.html?c=us_ot&lang=en&comple=on&redirect=on#f00115
	# - http://www.pclinuxos.com/forum/index.php?topic=138727.0
	@sudo restorecon -RFv /usr/lib/cups/filter/*
	@sudo setsebool -P cups_execmem 1
	@sudo setsebool mmap_low_allowed 1

INSTALL += codecs
codecs:
	@sudo dnf -y --setopt=strict=0 install \
		gstreamer{1,}-{ffmpeg,libav,vaapi,plugins-{good,ugly,bad{,-free,-nonfree,-freeworld,-extras}}}

INSTALL += gnome-desktop
gnome-desktop:
	@# Force group installation if -B flag is present
	@$(if $(findstring B,$(firstword -$(MAKEFLAGS))), \
		@sudo dnf -y group install $@, \
		@sudo dnf group list installed -v | grep $@ > /dev/null || dnf -y group install $@)

INSTALL += google-chrome
google-chrome: | gnome-desktop /etc/yum.repos.d/google-chrome.repo
	@$(call dnf, google-chrome-stable)

INSTALL += vivaldi-bin
vivaldi-bin: | gnome-desktop /etc/yum.repos.d/vivaldi-fedora.repo
	@$(call dnf, vivaldi-stable)

INSTALL += vivaldi
vivaldi: | vivaldi-bin $(vivaldi_conf_dest_files)

INSTALL += opera
opera: | gnome-desktop /etc/yum.repos.d/opera.repo
	@$(call dnf, opera-stable)

INSTALL += keybase
keybase: | gnome-desktop /etc/yum.repos.d/keybase.repo
	@$(call dnf, $@)

INSTALL += arduino
arduino: flatpak
	@flatpak -y install cc.arduino.arduinoide cc.arduino.IDE2
	@sudo usermod -aG dialout,tty,lock '$(USER)'

INSTALL += $(ext_vscode)
$(ext_vscode): | flatpak com.vscodium.codium
	@flatpak run com.vscodium.codium --force --install-extension '$@'

INSTALL += vscode
vscode: | com.vscodium.codium $(ext_vscode)

INSTALL += ddcutil
ddcutil: | /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:rockowitz\:ddcutil.repo
	@$(call dnf, $@)

INSTALL += ulauncher-extensions
ulauncher-extensions: ulauncher $(ext_ulauncher)

INSTALL += gnome-themes
gnome-themes: | gnome-desktop adwaita-icon-theme adwaita-cursor-theme arc-theme

# GNOME shell extensions
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
	@$(call dnf, optipng gnome-themes-extra gtk-murrine-engine meson inkscape sassc glib2-devel gdk-pixbuf2 \
		gtk3-devel gtk4-devel autoconf automake)

# Using SELF_CALL=xxx to avoid `inkscape` segfaults during build (https://gitlab.com/inkscape/inkscape/-/issues/4716)
arc-them-git-build:
	@mkdir -pv $(OPT_PATH)
	@rebuild_theme=false
	@if [ ! -d $(OPT_PATH)/arc-theme ]; then
		cd $(OPT_PATH) && git clone https://github.com/obatiuk/arc-theme --depth 1
		cd $(OPT_PATH)/arc-theme && git pull
		cd $(OPT_PATH)/arc-theme && meson setup --reconfigure --prefix=$(HOME)/.local \
			-Dvariants=dark,darker \
			-Dthemes=gnome-shell,gtk2,gtk3,gtk4 \
			build
		rebuild_theme=true
	fi
	@if [ $$rebuild_theme == true ] || [ ! z $$(cd $(OPT_PATH)/arc-theme && git diff --shortstat HEAD) ]; then
		cd $(OPT_PATH)/arc-theme && git pull
		cd $(OPT_PATH)/arc-theme && SELF_CALL=true bash -c 'meson install -C build'
		mkdir -p $(HOME)/.themes
		for theme in Arc{,-Dark,-Darker,-Lighter}{,-solid}; do
			if [ -d $(XDG_DATA_HOME_PATH)/themes/$${theme} ]; then
				ln -svfn $(XDG_DATA_HOME_PATH)/themes/$${theme} $(HOME)/.themes/$${theme}
			fi
		done
	fi

UPDATE += arc-theme-git-update
arc-theme-git-update: | git arc-them-git-build

CLEAN += arch-theme-git-clean
arch-theme-git-clean:
	@cd $(OPT_PATH)/arc-theme && meson compile --clean -C build

else
# Install `arc-theme` from the official repository. Updates will be tracked by default
INSTALL += arc-theme
arc-theme:
	@$(call dnf, arc-theme)
	@rm -rf $(OPT_PATH)/arc-theme
	@rm -rf $(XDG_DATA_HOME_PATH)/themes/Arc{,-Dark,-Darker,-Lighter}{,-solid}
	@rm -rf $(HOME)/.themes/Arc{,-Dark,-Darker,-Lighter}{,-solid}
endif

INSTALL += plymouth
plymouth:
	@$(call dnf, $@ plymouth-system-theme)
	@sudo plymouth-set-default-theme bgrt -R
	@sudo grub2-mkconfig -o /etc/grub2.cfg

INSTALL += power-profiles-daemon
power-profiles-daemon:
	@$(call dnf, $@)
	@sudo systemctl enable --now power-profiles-daemon

INSTALL += pass
pass:
	@$(call dnf, $@ pass-otp)

INSTALL += authselect
authselect: pam-u2f ecryptfs-utils
	@# FIXME: add check if all settings are applied already
	@$(call dnf, $@)
	@authselect check \
		&& sudo authselect select sssd with-ecryptfs with-fingerprint with-pam-u2f without-nullok -b \
		|| echo 'Current authselect configuration is NOT valid. Aborting to avoid more damage.'

INSTALL += gnome-shell-extensions-bin
gnome-shell-extensions-bin: | gnome-desktop git
	@if [ ! -d $(OPT_PATH)/install-gnome-extensions.git ]; then git clone 'https://github.com/obatiuk/install-gnome-extensions.git' $(OPT_PATH)/install-gnome-extensions.git; fi
	@cd $(OPT_PATH)/install-gnome-extensions.git && git pull
	@ln -snvf $(OPT_PATH)/install-gnome-extensions.git/install-gnome-extensions.sh $(HOMEBIN_PATH)/install-gnome-extensions
	@chmod u+x $(HOMEBIN_PATH)/install-gnome-extensions

UPDATE += gnome-shell-extensions-bin-update
gnome-shell-extensions-bin-update:
	@if [ -d $(OPT_PATH)/install-gnome-extensions.git ]; then cd $(OPT_PATH)/install-gnome-extensions.git && git pull; fi

########################################################################################################################
#
# GNOME settings
#

# GNOME global keyboard shortcuts
INSTALL += gnome-key-binding-settings
gnome-key-binding-settings: | gnome-desktop $(HOMEBIN_PATH)/dell-kvm-switch-input ulauncher
	@$(eval custom0=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/)
	@$(eval custom1=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/)
	@$(eval custom2=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/)

	@gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$(custom0)', '$(custom1)', '$(custom2)']"

	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom0) name 'Run Terminal'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom0) command '$(shell command -v gnome-terminal)'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom0) binding '<Super>t'

	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom1) name 'Dell KVM - Switch Input'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom1) command '$(HOMEBIN_PATH)/dell-kvm-switch-input'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom1) binding '<Alt>i'

	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom2) name 'Display Ulauncer'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom2) command '$(shell command -v ulauncher-toggle)'
	@gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(custom2) binding '<Super>r'

	@gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>h']"
	@gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>l']"

	# Possible fix for a sporadic flight-mode toggle
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill []
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-bluetooth []
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-bluetooth-static []
	@gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-static []


# GNOME theme
INSTALL += gnome-theme-settings
gnome-theme-settings: | gnome-themes arc-theme gnome-shell-extension-user-theme \
		$(HOME)/.gtkrc-2.0 \
		$(XDG_CONFIG_HOME_PATH)/gtk-3.0/settings.ini $(XDG_CONFIG_HOME_PATH)/gtk-3.0/gtk.css \
		$(XDG_CONFIG_HOME_PATH)/gtk-4.0/settings.ini
	@gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Darker'
	@gsettings set org.gnome.desktop.wm.preferences theme 'Arc-Darker'
	@gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
	@gsettings set org.gnome.desktop.wm.preferences titlebar-uses-system-font true
	@gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier '<Super>'

# GNOME wallpaper
INSTALL += gnome-wallpaper
gnome-wallpaper: $(DOTFILES_PATH)/.config/wallpaper/morphogenesis-l.svg | gnome-desktop
	@gsettings set org.gnome.desktop.background picture-uri \
		'file://$(XDG_CONFIG_HOME_PATH)/wallpaper/morphogenesis-l.svg'

# GNOME keyboard settings
INSTALL += gnome-keyboard-settings
gnome-keyboard-settings: | gnome-desktop
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

# GNOME desktop settings
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
gnome-nautilus-settings:
	@gsettings set org.gnome.nautilus.preferences show-create-link true
	@gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
	@gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'where', 'date_modified']"
	@gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'
	@gsettings set org.gnome.nautilus.preferences always-use-location-entry true
	@gsettings set org.gnome.nautilus.preferences show-delete-permanently true
	@gsettings set org.gnome.nautilus.preferences show-hidden-files true

INSTALL += gnome-file-chooser-settings
gnome-file-chooser-settings:
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
gnome-screenshot-settings:
	@gsettings set org.gnome.gnome-screenshot auto-save-directory 'file://$(XDG_PICTURES_DIR_PATH)/Screenshots'
	@gsettings set org.gnome.gnome-screenshot last-save-directory 'file://$(XDG_PICTURES_DIR_PATH)/Screenshots'
	@gsettings set org.gnome.gnome-screenshot default-file-type 'png'
	@gsettings set org.gnome.gnome-screenshot include-pointer false
	@gsettings set org.gnome.gnome-screenshot delay 2
	@gsettings set org.gnome.gnome-screenshot take-window-shot false

INSTALL += gnome-power-settings
gnome-power-settings:
	@gsettings set org.gnome.settings-daemon.plugins.power idle-dim true
	@gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
	@gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 30
	@gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery true
	@gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled true
	@gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1200
	@gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
	@gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'
	@gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'

INSTALL +=
gnome-privacy-settings:
	@gsettings set org.gnome.desktop.privacy old-files-age 10
	@gsettings set org.gnome.desktop.privacy remove-old-temp-files true
	@gsettings set org.gnome.desktop.privacy remove-old-trash-files false
	@gsettings set org.gnome.desktop.notifications show-banners false
	@gsettings set org.gnome.desktop.notifications show-in-lock-screen false
	@gsettings set org.gnome.login-screen disable-user-list true
	@gsettings set org.gnome.shell remember-mount-password false

INSTALL += gnome-gedit-settings
gnome-gedit-settings:
	@dconf load '/' < $(INCLUDE)/gnome-gedit.ini

# Disable GNOME Tracker3 service
INSTALL += gnome-tracker-settings
gnome-tracker-settings:
	@dconf load '/' < $(INCLUDE)/gnome-tracker.ini

INSTALL += gnome-terminal-settings
gnome-terminal-settings: gnome-desktop gnome-terminal dconf
	@dconf load '/' < $(INCLUDE)/gnome-terminal.ini

INSTALL += gnome-pomodoro-settings
gnome-pomodoro-settings: | gnome-pomodoro
	@dconf load '/' < $(INCLUDE)/gnome-pomodoro.ini

########################################################################################################################
#
# Balk installation rules
#

INSTALL += $(plugins_dnf)
$(plugins_dnf):
	@$(call dnf, $@)

INSTALL += $(packages_rpm)
$(packages_rpm): | gnome-desktop
	@$(call dnf, $@)

INSTALL += $(packages_fonts)
$(packages_fonts):
	@$(call dnf, $@)

INSTALL += $(packages_gshell)
$(packages_gshell): gnome-desktop
	@$(call dnf, $@)
	@if [ -f $(INCLUDE)/$@.ini ]; then dconf load '/' < $(INCLUDE)/$@.ini; fi

INSTALL += $(packages_snap)
$(packages_snap): | gnome-desktop snapd /snap
	@sudo snap install $@

INSTALL += $(packages_flatpak)
$(packages_flatpak): | gnome-desktop flatpak
	@flatpak install $@

INSTALL += $(ext_ulauncher)
$(ext_ulauncher): | git ulauncher
	@mkdir -pv $(OPT_PATH)
	@if [ ! -d $(OPT_PATH)/$@ ]; then git clone 'https://github.com/obatiuk/$@' $(OPT_PATH)/$@; fi
	@cd $(OPT_PATH)/$@ && git pull
	@mkdir -pv $(ULAUNCHER_EXT_PATH)
	@ln -svfn $(OPT_PATH)/$@ $(ULAUNCHER_EXT_PATH)/$(subst .git,,$@)

INSTALL += $(ext_gshell)
$(ext_gshell): | gnome-desktop dconf gnome-shell-extensions-bin
	@mkdir -pv $(OPT_PATH)
	@$(eval __ext=$(subst $(slash),$(space),$(subst https://extensions.gnome.org/extension/,,$(strip $@))))
	@$(eval __ext_id=$(word 1, $(__ext)))
	@$(eval __ext_name=$(word 2, $(__ext)))
	@if [ -f $(INCLUDE)/gnome-shell-extension-$(__ext_name).ini ]; then dconf load '/' < $(INCLUDE)/gnome-shell-extension-$(__ext_name).ini; fi
	@$(HOMEBIN_PATH)/install-gnome-extensions --enable $(__ext_id)

INSTALL += $(ext_intellij)
$(ext_intellij): | intellij-idea-community $(HOMEBIN_PATH)/acpi-battery-status
	@$$(command -v intellij-idea-community) installPlugins $@

########################################################################################################################
#
# Files
#

FILES += /snap
/snap: /var/lib/snapd/snap | snapd
	@sudo ln -svnf $< $@

FILES += /etc/dnf/dnf.conf
/etc/dnf/dnf.conf: crudini
	@sudo crudini --set /etc/dnf/dnf.conf main fastestmirror 1
	@sudo crudini --set /etc/dnf/dnf.conf main max_parallel_downloads 10
	@sudo crudini --set /etc/dnf/dnf.conf main deltarpm true

FILES += /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:chriscowleyunix\:better_fonts.repo
/etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:chriscowleyunix\:better_fonts.repo:
	@sudo dnf copr enable -y chriscowleyunix/better_fonts

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
	@$(call dnf, \
		https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(shell rpm -E %fedora).noarch.rpm)

FILES += /etc/yum.repos.d/rpmfusion-nonfree.repo
/etc/yum.repos.d/rpmfusion-nonfree.repo:
	@$(call dnf, \
		https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(shell rpm -E %fedora).noarch.rpm)

FILES += /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:rockowitz\:ddcutil.repo
/etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:rockowitz\:ddcutil.repo:
	@sudo dnf copr enable -y rockowitz/ddcutil


FILES += $(HOME)/.bashrc
$(HOME)/.bashrc: $(DOTFILES_PATH)/.bashrc
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(HOME)/.bash_profile
$(HOME)/.bash_profile: $(DOTFILES_PATH)/.bash_profile
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(HOME)/.bash_logout
$(HOME)/.bash_logout: $(DOTFILES_PATH)/.bash_logout
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD_PATH)/bashrc-nvm
$(BASHRCD_PATH)/bashrc-nvm: $(DOTFILES_PATH)/.home/.bashrc.d/.bashrc-nvm | nvm
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD_PATH)/bashrc-git
$(BASHRCD_PATH)/bashrc-git: $(DOTFILES_PATH)/.home/.bashrc.d/.bashrc-git | git
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD_PATH)/bashrc-base
$(BASHRCD_PATH)/bashrc-base: $(DOTFILES_PATH)/.home/.bashrc.d/.bashrc-base | git
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD_PATH)/bashrc-fonts
$(BASHRCD_PATH)/bashrc-fonts: $(DOTFILES_PATH)/.home/.bashrc.d/.bashrc-fonts | fonts
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(BASHRCD_PATH)/bashrc-xdg
$(BASHRCD_PATH)/bashrc-xdg: $(DOTFILES_PATH)/.home/.bashrc.d/.bashrc-xdg | xdg-utils
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(HOME)/.face.icon
$(HOME)/.face.icon: $(DOTFILES_PATH)/.face.icon
	@ln -svnf $< $@

FILES += $(XDG_CONFIG_HOME_PATH)/git/config
$(XDG_CONFIG_HOME_PATH)/git/config: $(DOTFILES_PATH)/.config/git/config | git git-lfs git-credential-libsecret \
		git-split-diffs bat meld perl-Image-ExifTool
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(HOME)/.trackerignore
$(HOME)/.trackerignore: $(DOTFILES_PATH)/.trackerignore | disable-gnome-tracker
	@ln -svnf $< $@

FILES += $(HOME)/.editorconfig
$(HOME)/.editorconfig : $(DOTFILES_PATH)/.editorconfig
	@ln -svfn $< $@

FILES += $(HOME)/.passgenrc
$(HOME)/.passgenrc : $(DOTFILES_PATH)/.passgenrc | pass
	@ln -svfn $< $@

FILES += $(HOMEBIN_PATH)/dell-kvm-switch-input
$(HOMEBIN_PATH)/dell-kvm-switch-input: $(DOTFILES_PATH)/.home/bin/dell-kvm-switch-input | ddcutil
	@ln -svfn $< $@
	@chmod +x $<

FILES += $(HOMEBIN_PATH)/acpi-battery-status
$(HOMEBIN_PATH)/acpi-battery-status: $(DOTFILES_PATH)/.home/bin/acpi-battery-status | acpi
	@ln -svfn $< $@
	@chmod +x $<

# GTK2 settings
FILES += $(HOME)/.gtkrc-2.0
$(HOME)/.gtkrc-2.0: $(DOTFILES_PATH)/.gtkrc-2.0 | gnome-desktop
	 @ln -svfn $< $@

# GTK3 settings
FILES += $(XDG_CONFIG_HOME_PATH)/gtk-3.0/settings.ini
$(XDG_CONFIG_HOME_PATH)/gtk-3.0/settings.ini: $(DOTFILES_PATH)/.config/gtk-3.0/settings.ini | gnome-desktop
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME_PATH)/gtk-3.0/gtk.css
$(XDG_CONFIG_HOME_PATH)/gtk-3.0/gtk.css: $(DOTFILES_PATH)/.config/gtk-3.0/gtk.css | gnome-desktop
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME_PATH)/gtk-3.0/bookmarks
$(XDG_CONFIG_HOME_PATH)/gtk-3.0/bookmarks: | gnome-desktop
	@tee $@ <<- EOF
		file://$(HOME)/Private/Sync
		file://$(HOME)/Projects
		file://$(HOME)/Temp
		file://$(HOME)/Documents
		file://$(HOME)/Music
		file://$(HOME)/Pictures
		file://$(HOME)/Videos
		file://$(HOME)/Downloads
		file://$(HOME)/Documents/Private/Notes/Default/Files
	EOF

# GTK4 settings
FILES += $(XDG_CONFIG_HOME_PATH)/gtk-4.0/settings.ini
$(XDG_CONFIG_HOME_PATH)/gtk-4.0/settings.ini: $(DOTFILES_PATH)/.config/gtk-4.0/settings.ini | gnome-desktop
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME_PATH)/user-dirs.dirs
$(XDG_CONFIG_HOME_PATH)/user-dirs.dirs: $(DOTFILES_PATH)/.config/user-dirs.dirs | xdg-user-dirs
	@mkdir -pv $(@D)
	@ln -svnf $< $@

FILES += $(XDG_CONFIG_HOME_PATH)/mc/ini
$(XDG_CONFIG_HOME_PATH)/mc/ini: $(DOTFILES_PATH)/.config/mc/ini | mc
	@mkdir -pv $(@D)
	@ln -svfn $< $@

FILES += $(vivaldi_conf_dest_files)
$(VIVALDI_CF_DEST_PATH)/% : $(VIVALDI_CF_SRC_PATH)/%
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

########################################################################################################################
#
# Patches
#

# Make sure that the system is configured to maintain the RTC in universal time
PATCH += local-rtc
local-rtc:
	@if [ "$$(timedatectl show -p LocalRTC --value)" == "yes" ]; then timedatectl set-local-rtc 0; fi

########################################################################################################################
#
# Updates
#

UPDATE += dnf-update
dnf-update:
	@sudo dnf update --refresh


UPDATE += check-rpmconf
check-rpmconf: | rpmconf
	@sudo rpmconf -at > /dev/null || echo "There are unmerged system configuration files. use 'make verify-rpmconf' to review them"

########################################################################################################################
#
# Cleaning
#

CLEAN += dnf-clean
dnf-clean:
	@sudo dnf clean all

CLEAN += journal-clean
journal-clean: | systemd
	@sudo journalctl --rotate
	@sudo journalctl --vacuum-size=500M

CLEAN += docker-clean
docker-clean: | docker
	@docker system prune

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

########################################################################################################################
#
# Verification rules
#

VERIFY += verify-rpmconf
verify-rpmconf: | rpmconf meld
	@sudo rpmconf -a -f meld

VERIFY += verify-sys-configs
verify-sys-configs: | rpm
	@sudo rpm -Va

########################################################################################################################
#
# Backup rules
#

BACKUP += backup-home
backup-home: pass restic screenfetch redhat-lsb diffutils
	@cd $(HOMEBIN_PATH) && ./backup-home-restic


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
				gnome-keyboard-settings gnome-desktop-settings gnome-display-settings \
				gnome-nautilus-settings gnome-file-chooser-settings gnome-gedit-settings gnome-screenshot-settings \
				gnome-tracker-settings gnome-power-settings gnome-privacy-settings gnome-terminal-settings

.PHONY: diff
diff: diffutils ydiff git-split-diffs

.PHONY: intellij
intellij: | intellij-idea-community $(ext_intellij)

########################################################################################################################
#
# Main targets
#
files: | $(FILES) ## Check that all managed files are up-to-date

install: | files $(INSTALL) ## Check all packages (except system patches) and managed files

patch: | $(PATCH) ## Check model-specific patches

update: | $(UPDATE) ## Update installed software
	# TODO: check `/etc/os-release` for the SUPPORT_END and display warning during update

updatefw: | fwupd ## Update firmware
	@fwupdmgr get-updates --force
	@fwupdmgr update

updateall: | update updatefw ## Update everything

clean: $(CLEAN) ## Do a system cleanup

setup: $(SETUP) ## Run setup scripts that require manual input

verify: $(VERIFY) ## Verify system configuration

backup: $(BACKUP) ## Backup everything

all: files install patch updateall clean setup verify ## Check, update and clean everything including system patches, packages and firmware

help: ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ \
	{ printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' \
	 $(MAKEFILE_LIST)

# Debug
printvars:
	@$(foreach V,$(sort $(.VARIABLES)), \
		$(if $(filter-out environment% default automatic, \
			$(origin $V)),$(warning $V=$($V) ($(value $V)))))

.PHONY: $(INSTALL) $(PATCH) $(UPDATE)$(CLEAN) $(SETUP) $(VERIFY) $(BACKUP) \
	install patch update updatefw updateall updateall clean setup verify backup all help printvars
