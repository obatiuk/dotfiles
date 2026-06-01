ARC_THEME_SOURCE ?= git

# GNOME Shell extensions (RPM packages)
PKG_GSHELL := gnome-shell-extension-dash-to-dock gnome-shell-extension-appindicator
PKG_GSHELL += gnome-shell-extension-frippery-move-clock gnome-shell-extension-gsconnect
PKG_GSHELL += gnome-shell-extension-sound-output-device-chooser gnome-shell-extension-freon
PKG_GSHELL += gnome-shell-extension-blur-my-shell gnome-shell-extension-user-theme
PKG_GSHELL += gnome-shell-extension-no-overview

# GNOME Shell extensions
EXT_GSHELL := https\://extensions.gnome.org/extension/1401/bluetooth-quick-connect
EXT_GSHELL += https\://extensions.gnome.org/extension/3780/ddterm
EXT_GSHELL += https\://extensions.gnome.org/extension/7065/tiling-shell
EXT_GSHELL += https\://extensions.gnome.org/extension/4470/media-controls
EXT_GSHELL += https\://extensions.gnome.org/extension/277/impatience
EXT_GSHELL += https\://extensions.gnome.org/extension/4099/no-overview
EXT_GSHELL += https\://extensions.gnome.org/extension/517/caffeine

# Ulauncher extensions
EXT_ULAUNCHER := ulauncher-emoji.git pass-ulauncher.git pass-for-ulauncher.git pass-otp-for-ulauncher.git
EXT_ULAUNCHER += ulauncher-obsidian.git ulauncher-numconverter.git ulauncher-list-keywords.git

# GNOME RPM packages
PKG_RPM += gnome-shell gnome-terminal seahorse gnome-keyring pinentry-gnome3
PKG_RPM += gparted baobab gimp gedit gedit-plugins gedit-plugin-editorconfig fedora-chromium-config-gnome
PKG_RPM += gnome-browser-connector gnome-pomodoro gnome-clocks gnome-monitor-config
PKG_RPM += gnome-system-monitor adwaita-icon-theme adwaita-cursor-theme gtk-update-icon-cache

PKG_FLATPACK += org.gtk.Gtk3theme.Arc-Darker

DF_GNOME_FSROOT := $(DF_GNOME)/fsroot
DF_GNOME_FSHOME := $(DF_GNOME_FSROOT)/home/obatiuk
DF_GNOME_RES    := $(DF_GNOME)/resources

COPR_THEMES_REPO := /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:dusansimic\:themes.repo

########################################################################################################################
#
# GNOME Installation Customizations
#

INSTALL += gnome-desktop
gnome-desktop:
	@# Force group installation if -B flag is present
	@$(if $(findstring B,$(firstword -$(MAKEFLAGS))), \
		sudo dnf -y group install $@, \
		dnf group list --installed --hidden | grep $@ > /dev/null || sudo dnf -y group install $@)

INSTALL += gdm
gdm:
	@$(call dnf,$@)
	@sudo systemctl enable gdm
	@sudo systemctl set-default graphical.target

INSTALL += morewaita-icon-theme
morewaita-icon-theme: $(COPR_THEMES_REPO) | xdg-utils gtk-update-icon-cache
	@$(call dnf,$@)
	@sudo /usr/bin/gtk-update-icon-cache -f -t /usr/share/icons/MoreWaita
	@/usr/bin/xdg-desktop-menu forceupdate

INSTALL += gnome-themes
gnome-themes: | adwaita-icon-theme adwaita-cursor-theme morewaita-icon-theme arc-theme flatpak-themes

INSTALL += flatpak-themes
flatpak-themes:
	@$(if $(PKG_FLATPACK), flatpak install -y flathub $(PKG_FLATPACK) || true)

ifeq ($(ARC_THEME_SOURCE),git)
INSTALL += arc-theme
arc-theme: | gnome-shell git install-arc-theme-git build-arc-theme-git clean-arc-theme-git

.PHONY: install-arc-theme-git
install-arc-theme-git:
	-@sudo dnf -y remove arc-theme
	@$(call dnf,optipng gnome-themes-extra gtk-murrine-engine meson inkscape sassc \
		glib2-devel gdk-pixbuf2 gtk3-devel gtk4-devel autoconf automake)

.PHONY: build-arc-theme-git
build-arc-theme-git:
	@install -d $(DOTHOME_OPT)
	@_rebuild=false
	@if [ ! -d "$(DOTHOME_OPT)/arc-theme" ]; then
	@	git clone https://github.com/obatiuk/arc-theme --depth 1 $(DOTHOME_OPT)/arc-theme
	@	_rebuild=true
	@fi
	@git -C $(DOTHOME_OPT)/arc-theme remote update
	@if git -C $(DOTHOME_OPT)/arc-theme status -uno | grep -q 'Your branch is behind'; then
	@	_rebuild=true
	@fi
	@if [ "$$_rebuild" = true ]; then
	@	git -C $(DOTHOME_OPT)/arc-theme pull
	@	meson setup --reconfigure --prefix=$(HOME)/.local \
			-Dvariants=dark,darker \
			-Dthemes=gnome-shell,gtk2,gtk3,gtk4 \
			$(DOTHOME_OPT)/arc-theme/build $(DOTHOME_OPT)/arc-theme
	@	SELF_CALL=true bash -c 'meson install -C $(DOTHOME_OPT)/arc-theme/build'
	@	install -d $(HOME)/.themes
	@	for theme in Arc{,-Dark,-Darker,-Lighter}{,-solid}; do
	@		if [ -d "$(XDG_DATA_HOME)/themes/$$theme" ]; then
	@			ln -svfn "$(XDG_DATA_HOME)/themes/$$theme" "$(HOME)/.themes/$$theme"
	@		fi
	@	done
	@fi

UPDATE += update-arc-theme-git
update-arc-theme-git: | git build-arc-theme-git clean-arc-theme-git

CLEAN += clean-arc-theme-git
clean-arc-theme-git:
	@meson compile --clean -C $(DOTHOME_OPT)/arc-theme/build

else
INSTALL += arc-theme
arc-theme:
	@$(call dnf,arc-theme)
	@rm -rf $(DOTHOME_OPT)/arc-theme $(XDG_DATA_HOME)/themes/Arc* $(HOME)/.themes/Arc*
endif

########################################################################################################################
#
# GNOME Settings & Extensions
#

INSTALL += gnome-shell-extensions
gnome-shell-extensions: | gnome-shell $(PKG_GSHELL) $(EXT_GSHELL)
	@/usr/bin/gnome-extensions disable 'window-list@gnome-shell-extensions.gcampax.github.com' || true
	@/usr/bin/gnome-extensions disable 'places-menu@gnome-shell-extensions.gcampax.github.com' || true

INSTALL += ulauncher
ulauncher:
	@$(call dnf,$@)
	@systemctl --user enable --now $@

INSTALL += ulauncher-extensions
ulauncher-extensions: ulauncher $(EXT_ULAUNCHER)
	-@systemctl --user restart ulauncher.service

INSTALL += meld
meld: $(DF_GNOME_RES)/meld.ini | dconf
	@$(call dnf,$@)
	@dconf load '/' < $<

INSTALL += gnome-core-settings
gnome-core-settings: $(DF_GNOME_RES)/gnome-core-settings.ini.template | \
		gnome-desktop gnome-shell gnome-terminal ulauncher gnome-system-monitor \
		gnome-themes arc-theme gnome-shell-extension-user-theme \
		$(DOTHOME_BIN)/dell-kvm-switch-input \
		$(XDG_CONFIG_HOME)/gtk-2.0/gtkrc \
		$(XDG_CONFIG_HOME)/gtk-3.0/settings.ini \
		$(XDG_CONFIG_HOME)/gtk-3.0/gtk.css \
		$(XDG_CONFIG_HOME)/gtk-4.0/settings.ini \
		$(XDG_DATA_HOME)/backgrounds/current \
		fonts dconf gettext-envsubst
	@export GNOME_TERMINAL_CMD=$$(command -v gnome-terminal)
	@export ULAUNCHER_CMD=$$(command -v ulauncher-toggle)
	@export SYS_MONITOR_CMD=$$(command -v gnome-system-monitor)
	@export KVM_SWITCH_INPUT_CMD="$(DOTHOME_BIN)/dell-kvm-switch-input"
	@export WALLPAPER_PATH="$(XDG_DATA_HOME)/backgrounds/current"
	@envsubst '$$GNOME_TERMINAL_CMD $$ULAUNCHER_CMD $$SYS_MONITOR_CMD $$KVM_SWITCH_INPUT_CMD $$WALLPAPER_PATH' \
		< $< | dconf load '/'
	@systemctl --user mask --now org.gnome.SettingsDaemon.Rfkill.service

# Standard dconf loads
INSTALL += gnome-gedit-settings gnome-tracker-settings gnome-terminal-settings
INSTALL += gnome-pomodoro-settings gnome-clocks-settings
gnome-%-settings: $(DF_GNOME_RES)/gnome-%.ini | dconf
	@dconf load '/' < $<

########################################################################################################################
#
# Bulk Installers
#

INSTALL += $(PKG_GSHELL)
$(PKG_GSHELL): | gnome-desktop
	@$(call dnf,$@)
	@if [ -f "$(DF_GNOME_RES)/$@.ini" ]; then
	@	dconf load '/' < "$(DF_GNOME_RES)/$@.ini"
	@fi

INSTALL += $(EXT_GSHELL)
$(EXT_GSHELL): $(DOTHOME_BIN)/install-gnome-extensions | gnome-desktop dconf
	@install -d $(DOTHOME_OPT)
	@target_str="$@"
	@url_stripped="$${target_str#https://extensions.gnome.org/extension/}"
	@ext_id="$${url_stripped%%/*}"
	@ext_name="$${url_stripped#*/}"
	@ini_file="$(DF_GNOME_RES)/gnome-shell-extension-$${ext_name}.ini"
	@if [ -f "$${ini_file}" ]; then
	@	dconf load '/' < "$${ini_file}"
	@fi
	@$< --enable "$${ext_id}"

INSTALL += $(EXT_ULAUNCHER)
$(EXT_ULAUNCHER): | git ulauncher
	@$(call clone,$@)
	@install -d $(ULAUNCHER_EXT)
	@ln -svfn $(DOTHOME_OPT)/$@ $(ULAUNCHER_EXT)/$(subst .git,,$@)

########################################################################################################################
#
# Files
#

FILES += $(HOME)/.trackerignore
$(HOME)/.trackerignore: $(DF_FSHOME)/.trackerignore
	@ln -svnf $< $@

FILES += $(COPR_THEMES_REPO)
$(COPR_THEMES_REPO):
	@sudo dnf copr enable -y dusansimic/themes

FILES += $(DOTHOME_BIN)/install-gnome-extensions
$(DOTHOME_BIN)/install-gnome-extensions: $(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh
	@ln -svfn $< $@
	@chmod u+x $@

FILES += $(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh
$(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh: | git
	@$(call clone,install-gnome-extensions.git)

########################################################################################################################
#
# Patches
#

PATCH += disable-gnome-tracker
disable-gnome-tracker: | gnome-desktop gnome-tracker-settings $(HOME)/.trackerignore
	-@sudo systemctl --user mask \
		tracker-extract-3.service \
		tracker-miner-fs-3.service \
		tracker-miner-rss-3.service \
		tracker-writeback-3.service \
		tracker-xdg-portal-3.service \
		tracker-miner-fs-control-3.service
	-@tracker3 reset -s -r || true

PATCH += patch-gnome-suspend
patch-gnome-suspend: | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $(DF_GNOME_FSROOT)/etc/systemd/system/gnome-shell-suspend.service.template \
		| sudo install -m 644 -DC /dev/stdin /etc/systemd/system/gnome-shell-suspend.service
	@envsubst '$$TODAY $$USER' < $(DF_GNOME_FSROOT)/etc/systemd/system/gnome-shell-resume.service.template \
		| sudo install -m 644 -DC /dev/stdin /etc/systemd/system/gnome-shell-resume.service
	@sudo systemctl daemon-reload
	@sudo systemctl enable gnome-shell-suspend gnome-shell-resume

########################################################################################################################
#
# Updates
#

UPDATE += update-gnome-extensions
update-gnome-extensions:
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO), "\\nScheduling GNOME extension auto-update ...\\n")
	-@gdbus call --session \
		--dest org.gnome.Shell.Extensions \
		--object-path /org/gnome/Shell/Extensions \
		--method org.gnome.Shell.Extensions.CheckForUpdates

UPDATE += update-gnome-shell-extensions-bin
update-gnome-shell-extensions-bin: $(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh | git
	@git -C $(DOTHOME_OPT)/install-gnome-extensions.git pull

########################################################################################################################
#
# Aliases
#

.PHONY: gnome-settings
gnome-settings: gnome-shell-extensions \
		gnome-core-settings \
		gnome-gedit-settings \
		gnome-tracker-settings \
		gnome-terminal-settings \
		gnome-pomodoro-settings \
		gnome-clocks-settings
