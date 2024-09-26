#!/usr/bin/env make -f
.ONESHELL:
.DEFAULT_GOAL := help

SHELL = /bin/bash

colon := :
$(colon) := :
space := $(subst ,, )
dash := -
slash := /

export XDG_CONFIG_HOME ?= $${HOME}/.config
export XDG_DATA_HOME ?= $${HOME}/.local/share
export XDG_PICTURES_DIR ?= $${HOME}/Private/Pictures
export NVM_DIR ?= $${XDG_DATA_HOME}/nvm

top := $(shell pwd)
now := $(shell date +%Y-%m-%d_%H:%M:%S)
uid	:= $(shell id -u)
model := $(shell (if command -v hostnamectl > /dev/null 2>&1; \
	then hostnamectl | grep 'Hardware Model:' | sed 's/^.*: //'; \
	else sudo dmidecode -s system-product-name ; fi) | tr "[:upper:]" "[:lower:]")

INCLUDE = ./include

XDG_CONFIG_HOME_PATH := $(shell echo $(XDG_CONFIG_HOME))
XDG_DATA_HOME_PATH := $(shell echo $(XDG_DATA_HOME))
XDG_PICTURES_DIR_PATH := $(shell echo $(XDG_PICTURES_DIR))

NVM_PATH = $(shell echo $(NVM_DIR))
NVM_CMD = . $(NVM_PATH)/nvm.sh && nvm

MAKEFILE_NAME := $(abspath $(lastword $(MAKEFILE_LIST)))
DOTFILES_PATH := $(abspath $(dir $(MAKEFILE_NAME)))
DOTHOME_PATH := $(abspath $(HOME)/.home)
BASHRCD_PATH := $(abspath $(DOTHOME_PATH)/.bashrc.d)
HOMEBIN_PATH := $(abspath $(DOTHOME_PATH)/bin)
OPT_PATH := $(abspath $(DOTHOME_PATH)/opt)

VIVALDI_CF_SRC_PATH := $(DOTFILES_PATH)/.config/vivaldi/CustomUIModifications
VIVALDI_CF_DEST_PATH := $(XDG_CONFIG_HOME_PATH)/vivaldi/CustomUIModifications

INSTALL =
PATCH =
UPDATE =
CLEAN =

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
packages_rpm := dnf avahi avahi-tools redhat-lsb-core nano samba-client tree rpmconf pwgen htop fzf gh systemd
packages_rpm += iwl*-firmware fwupd bluez bluez-utils bash bash-completion
packages_rpm += hplip hplip-gui xsane ffmpeg feh
packages_rpm += ImageMagick baobab gimp gparted diffuse gnome-terminal seahorse
packages_rpm += libreoffice-core libreoffice-writer libreoffice-calc libreoffice-filters
packages_rpm += gnome-pomodoro fd-find ydiff webp-pixbuf-loader
packages_rpm += screenfetch usbutils pciutils acpi
packages_rpm += gnupg2 pinentry-gtk pinentry-tty pinentry-gnome3
packages_rpm += gvfs-mtp screen tio
packages_rpm += restic rsync rclone micro
packages_rpm += unrar lynx crudini sysstat p7zip nmap cabextract iotop qrencode uuid
packages_rpm += git git-lfs git-extras git-credential-libsecret bat mc meld
packages_rpm += snapd flatpak
packages_rpm += fedora-workstation-repositories
packages_rpm += adwaita-icon-theme adwaita-cursor-theme dconf

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
packages_gshell += gnome-shell-extension-mediacontrols gnome-shell-extension-openweather
packages_gshell += gnome-shell-extension-places-menu gnome-shell-extension-pop-shell
packages_gshell += gnome-shell-extension-pop-shell-shortcut-overrides
packages_gshell += gnome-shell-extension-sound-output-device-chooser gnome-shell-extension-window-list

# VSCode extensions
ext_vscode := EditorConfig.EditorConfig jianbingfang.dupchecker mechatroner.rainbow-csv bierner.markdown-mermaid
ext_vscode += bpruitt-goddard.mermaid-markdown-syntax-highlighting eamodio.gitlens ecmel.vscode-html-css
ext_vscode += humao.rest-client jebbs.plantuml moshfeu.compare-folders ms-azuretools.vscode-docker ph-hawkins.arc-plus
ext_vscode += PKief.material-icon-theme redhat.java redhat.vscode-xml redhat.vscode-yaml
ext_vscode += streetsidesoftware.code-spell-checker timonwong.shellcheck usernamehw.errorlens vscjava.vscode-maven
ext_vscode += yzhang.markdown-all-in-one

vivaldi_conf_files := $(shell find .config/vivaldi/CustomUIModifications -type f -name '*.*')
vivaldi_conf_dest_files := $(addprefix $(HOME)/, $(vivaldi_conf_files))

########################################################################################################################
#
# Package installation customizations and aliases
#

INSTALL += dnf-plugins
dnf-plugins: $(plugins_dnf)

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

INSTALL += snap
snap: | snapd /snap

INSTALL += nvm
nvm: git
	@mkdir -pv $(NVM_PATH)
	@PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

INSTALL += npm
npm: nvm $(BASHRCD_PATH)/.bashrc-nvm
	@. $(NVM_PATH)/nvm.sh && nvm install --lts

INSTALL +=git-split-diffs
git-split-diffs: npm
	@. $(NVM_PATH)/nvm.sh && npm install -g git-split-diffs

# Disable GNOME search engine
INSTALL += disable-gnome-tracker
disable-gnome-tracker: | gnome-desktop gnome-tracker-settings
	@sudo systemctl --user mask \
		tracker-extract-3.service \
		tracker-miner-fs-3.service \
		tracker-miner-rss-3.service \
		tracker-writeback-3.service \
		tracker-xdg-portal-3.service \
		tracker-miner-fs-control-3.service

	-@tracker3 reset -s -r

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
	@sudo usermod -aG docker "$(USER)"
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
keybase: gnome-desktop /etc/yum.repos.d/keybase.repo
	@$(call dnf, $@)

INSTALL += arduino
arduino: flatpak
	@flatpak -y install cc.arduino.arduinoide cc.arduino.IDE2
	@sudo usermod -aG dialout,tty,lock "$(USER)"

INSTALL += $(ext_vscode)
$(ext_vscode): com.vscodium.codium
	@flatpak run com.vscodium.codium --force --install-extension '$@'

INSTALL += vscode
vscode: | com.vscodium.codium $(ext_vscode)

INSTALL += ddcutil
ddcutil: | /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:rockowitz\:ddcutil.repo \
		/etc/udev/rules.d/60-ddcutil-i2c.rules
	@$(call dnf, ddcutil)

INSTALL += ulauncher-bin
ulauncher-bin: gnome-desktop
	@$(call dnf, ulauncher)

INSTALL += ext_ulauncher
ext_ulauncher:
	# TODO: install extensions

INSTALL += ulauncher
ulauncher: | ulauncher-bin ext_ulauncher

INSTALL += gnome-themes
gnome-themes: | gnome-desktop adwaita-icon-theme adwaita-cursor-theme arc-theme

INSTALL += gnome-shell-extensions
gnome-shell-extensions: | gnome-desktop $(packages_gshell)

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
			if [ -d $(XDG_DATA_HOME_PATH)/themes/$$theme ]; then
				ln -svfn $(XDG_DATA_HOME_PATH)/themes/$$theme $(HOME)/.themes/$$theme
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
gnome-theme-settings: | gnome-themes arc-theme gnome-shell-user-theme \
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

# GNOME shell extensions
INSTALL += gnome-shell-extensions-settings
gnome-shell-extensions-settings: | gnome-shell-extensions
	@gsettings set org.gnome.shell.extensions.dash-to-dock apply-glossy-effect true
	@gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
	@gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false
	@gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
	@gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
	@gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
	@gsettings set org.gnome.shell.extensions.dash-to-dock force-straight-corner true
	@gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items false
	@gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
	@gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
	@gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.28
	@gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
	@gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top false
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-windows-preview true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-network true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-running true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0.1
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-dock-urgent-notify true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-favorites true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-icons-emblems true
	@gsettings set org.gnome.shell.extensions.dash-to-dock show-icons-notifications-counter true
	@gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed true
	@gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
	@gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
	@gsettings set org.gnome.shell.extensions.dash-to-dock manualhide false

# GNOME Shell user theme extension settings
INSTALL += gnome-shell-extensions-settings
gnome-shell-user-theme: | gnome-shell-extensions \
		/usr/share/glib-2.0/schemas/org.gnome.shell.extensions.user-theme.gschema.xml
	@gsettings set org.gnome.shell.extensions.user-theme name 'Arc-Dark'

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
	@gsettings set org.gnome.desktop.screensaver lock-delay uint32 0
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

	@gsettings set org.gnome.shell favorite-apps ['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'intellij-idea-community_intellij-idea-community.desktop', 'com.vscodium.codium.desktop', 'vivaldi-stable.desktop', 'google-chrome.desktop', 'firefox.desktop', 'md.obsidian.Obsidian.desktop', 'xmind.desktop', 'org.gnome.gedit.desktop', 'chrome-cinhimbnkkaeohfgghhklpknlkffjgod-Profile_4.desktop', 'chrome-hpfldicfbfomlpcikngkocigghgafkph-Profile_4.desktop', 'org.gnome.Pomodoro.desktop', 'cc.arduino.IDE2.desktop', 'calibre-gui.desktop', 'com.valvesoftware.Steam.desktop']


# GNOME display settings
INSTALL += gnome-display-settings
gnome-display-settings: | gnome-desktop
	@gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
	@gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

	@gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature uint32 4378
	@gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	@gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
	@gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 6.0
	@gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 20.0
	@gsettings set org.gnome.settings-daemon.plugins.color recalibrate-display-threshold uint32 0

# GNOME app settings
INSTALL += gnome-app-settings
gnome-app-settings:
	@# Nautilus
	@gsettings set org.gnome.nautilus.preferences show-create-link true
	@gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
	@gsettings set org.gnome.nautilus.list-view default-visible-columns \
		"['name', 'size', 'type', 'where', 'date_modified']"
	@gsettings set org.gnome.nautilus.list-view default-zoom-level 'standard'
	@gsettings set org.gnome.nautilus.preferences always-use-location-entry true
	@gsettings set org.gnome.nautilus.preferences show-delete-permanently true
	@gsettings set org.gnome.nautilus.preferences sort-directories-first true
	@gsettings set org.gnome.nautilus.preferences show-hidden-files true

	# File chooser
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

	# gEdit
	@gsettings set org.gnome.gedit.preferences.editor auto-save true
	@gsettings set org.gnome.gedit.preferences.ui statusbar-visible true
	@gsettings set org.gnome.gedit.preferences.ui toolbar-visible true
	@gsettings set org.gnome.gedit.preferences.editor bracket-matching true
	@gsettings set org.gnome.gedit.preferences.editor highlight-current-line true
	@gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
	@gsettings set org.gnome.gedit.preferences.print print-header false
	@gsettings set org.gnome.gedit.preferences.ui side-panel-visible true
	@gsettings set org.gnome.gedit.plugins active-plugins "['docinfo', 'filebrowser', 'spell', 'modelines', 'time']"

	# Screenshot
	@gsettings set org.gnome.gnome-screenshot auto-save-directory 'file://$(XDG_PICTURES_DIR_PATH)/Screenshots'
	@gsettings set org.gnome.gnome-screenshot last-save-directory 'file://$(XDG_PICTURES_DIR_PATH)/Screenshots'
	@gsettings set org.gnome.gnome-screenshot default-file-type 'png'
	@gsettings set org.gnome.gnome-screenshot include-pointer false
	@gsettings set org.gnome.gnome-screenshot delay 2
	@gsettings set org.gnome.gnome-screenshot take-window-shot false

# Disable GNOME Tracker3 service
INSTALL += gnome-tracker-settings
gnome-tracker-settings:
	@gsettings set org.freedesktop.Tracker3.Miner.Files index-optical-discs false
	@gsettings set org.freedesktop.Tracker3.Miner.Files enable-monitors false
	@gsettings set org.freedesktop.Tracker3.Miner.Files index-on-battery-first-time false
	@gsettings set org.freedesktop.Tracker3.Miner.Files index-on-battery false
	@gsettings set org.freedesktop.Tracker3.Miner.Files index-applications false
	@gsettings set org.freedesktop.Tracker3.Miner.Files index-removable-devices false

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

INSTALL += gnome-terminal-settings
gnome-terminal-settings: gnome-desktop gnome-terminal dconf
	@gsettings set org.gnome.Terminal.Legacy.Settings shortcuts-enabled false
	@gsettings set org.gnome.Terminal.Legacy.Settings menu-accelerator-enabled false
	@gsettings set org.gnome.Terminal.Legacy.Settings shell-integration-enabled true
	@gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
	@gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'
	@gsettings set org.gnome.Terminal.Legacy.Settings new-terminal-mode 'window'
	@gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar true
	@gsettings set org.gnome.Terminal.Legacy.Settings always-check-default-terminal true


	@dconf load /org/gnome/terminal/legacy/ <<< "
	[profiles:]
	default='21d40fb8-4721-4265-a563-5cef1638998d'
	list=['21d40fb8-4721-4265-a563-5cef1638998d']

	[profiles:/:21d40fb8-4721-4265-a563-5cef1638998d]
	audible-bell=false
	background-color='rgb(0,0,0)'
	background-transparency-percent=5
	bold-is-bright=false
	font='JetBrainsMono Nerd Font Mono 10'
	foreground-color='rgb(255,255,255)'
	login-shell=true
	palette=['rgb(0,0,0)', 'rgb(227,89,81)', 'rgb(35,180,126)', 'rgb(232,180,112)', 'rgb(83,125,177)', 'rgb(183,107,196)', 'rgb(74,178,170)', 'rgb(255,255,255)', 'rgb(255,255,255)', 'rgb(249,117,89)', 'rgb(62,207,142)', 'rgb(250,219,108)', 'rgb(25,151,198)', 'rgb(215,130,218)', 'rgb(125,214,207)', 'rgb(255,255,255)']
	use-system-font=false
	use-theme-colors=true
	use-transparent-background=false
	visible-name='My Profile'
	"

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
$(packages_gshell):
	@$(call dnf, $@)

INSTALL += $(packages_snap)
$(packages_snap): | gnome-desktop snap /snap
	@sudo snap install $@

INSTALL += $(packages_flatpak)
$(packages_flatpak): | gnome-desktop flatpak
	@flatpak install $@

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

FILES += $(BASHRCD_PATH)/.bashrc-nvm
$(BASHRCD_PATH)/.bashrc-nvm: $(DOTFILES_PATH)/.home/.bashrc.d/.bashrc-nvm | nvm
	@mkdir -pv "$(@D)"
	@ln -svnf $< $@

FILES += $(BASHRCD_PATH)/.bashrc-git
$(BASHRCD_PATH)/.bashrc-git: $(DOTFILES_PATH)/.home/.bashrc.d/.bashrc-git | git
	@mkdir -pv "$(@D)"
	@ln -svnf $< $@

FILES += $(BASHRCD_PATH)/.bashrc-base
$(BASHRCD_PATH)/.bashrc-base: $(DOTFILES_PATH)/.home/.bashrc.d/.bashrc-base | git
	@mkdir -pv "$(@D)"
	@ln -svnf $< $@

FILES += $(HOME)/.face.icon
$(HOME)/.face.icon: $(DOTFILES_PATH)/.face.icon
	@ln -svnf $< $@

FILES += $(XDG_CONFIG_HOME_PATH)/git/config
$(XDG_CONFIG_HOME_PATH)/git/config: $(DOTFILES_PATH)/.config/git/config | git git-lfs git-credential-libsecret git-split-diffs bat meld
	@mkdir -pv "$(@D)"
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

FILES += /etc/udev/rules.d/60-ddcutil-i2c.rules
/etc/udev/rules.d/60-ddcutil-i2c.rules: /usr/share/ddcutil/data/60-ddcutil-i2c.rules
	# TODO use copy (e.g. install)?
	@sudo ln -svfn $< $@

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
	@mkdir -pv "$(@D)"
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME_PATH)/gtk-3.0/gtk.css
$(XDG_CONFIG_HOME_PATH)/gtk-3.0/gtk.css: $(DOTFILES_PATH)/.config/gtk-3.0/gtk.css | gnome-desktop
	@mkdir -pv "$(@D)"
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
	@mkdir -pv "$(@D)"
	@ln -svfn $< $@

FILES += $(XDG_CONFIG_HOME_PATH)/mc/ini
$(XDG_CONFIG_HOME_PATH)/mc/ini: $(DOTFILES_PATH)/.config/mc/ini | mc
	@mkdir -pv "$(@D)"
	@ln -svfn $< $@

FILES += $(vivaldi_conf_dest_files)
$(VIVALDI_CF_DEST_PATH)/% : $(VIVALDI_CF_SRC_PATH)/%
	@mkdir -pv "$(@D)"
	@ln -svfn $< $@

# Manual fix for the `No such schema “org.gnome.shell.extensions.user-theme”` error
FILES += /usr/share/glib-2.0/schemas/org.gnome.shell.extensions.user-theme.gschema.xml
/usr/share/glib-2.0/schemas/org.gnome.shell.extensions.user-theme.gschema.xml: \
		$(XDG_DATA_HOME_PATH)/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com/schemas/org.gnome.shell.extensions.user-theme.gschema.xml
	@sudo ln -svnf $< $@
	@sudo glib-compile-schemas /usr/share/glib-2.0/schemas

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

########################################################################################################################
#
# Patches
#

# Make sure that the system is configured to maintain the RTC in universal time
PATCH += local-rtc
local-rtc:
	@[[ $$(timedatectl show -p LocalRTC --value) == 'no' ]] || timedatectl set-local-rtc 0

########################################################################################################################
#
# Updates
#

UPDATE += dnf-update
dnf-update:
	@sudo dnf update --refresh

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

all: files install patch update updatefw updateall clean ## Check, update and clean everything including system patches, packages and firmware

help: ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ \
	{ printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' \
	 $(MAKEFILE_LIST)

printvars:
	@$(foreach V,$(sort $(.VARIABLES)), \
		$(if $(filter-out environment% default automatic, \
			$(origin $V)),$(warning $V=$($V) ($(value $V)))))

.PHONY: $(INSTALL) $(PATCH) $(UPDATE) install patch update updatefw updateall updateall all help printvars
