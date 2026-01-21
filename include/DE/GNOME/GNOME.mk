
ARC_THEME_SOURCE ?= git

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

# Ulauncher extensions
EXT_ULAUNCHER := ulauncher-emoji.git pass-ulauncher.git pass-for-ulauncher.git pass-otp-for-ulauncher.git
EXT_ULAUNCHER += ulauncher-obsidian.git ulauncher-numconverter.git ulauncher-list-keywords.git

PKG_RPM += gdm gnome-shell gnome-terminal seahorse gnome-keyring pinentry-gnome3
PKG_RPM += gparted baobab gimp gedit gedit-plugins gedit-plugin-editorconfig
PKG_RPM += gnome-browser-connector gnome-pomodoro gnome-clocks gnome-monitor-config gnome-system-monitor
PKG_RPM += adwaita-icon-theme adwaita-cursor-theme gtk-update-icon-cache

DF_GNOME_FSHOME := $(DF_GNOME)/fsroot/home/obatiuk
DF_GNOME_RES := $(DF_GNOME)/resources

INSTALL += gnome-desktop
gnome-desktop:
	@# Force group installation if -B flag is present
	@$(if $(findstring B,$(firstword -$(MAKEFLAGS))), \
		@sudo dnf -y group install $@, \
		@dnf group list --installed --hidden | grep $@ > /dev/null || sudo dnf -y group install $@;)

INSTALL += morewaita-icon-theme
morewaita-icon-theme: /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:dusansimic\:themes.repo xdg-utils gtk-update-icon-cache
	@$(call dnf,$@)
	@sudo /usr/bin/gtk-update-icon-cache -f -t /usr/share/icons/MoreWaita && /usr/bin/xdg-desktop-menu forceupdate

INSTALL += gnome-themes
gnome-themes: | adwaita-icon-theme adwaita-cursor-theme morewaita-icon-theme arc-theme

ifeq ($(ARC_THEME_SOURCE),git)
# `arc-theme` package from the official repository doesn't have latest patches
# Use patched Arc themes version from git: https://github.com/jnsh/arc-theme/blob/master/INSTALL.md
INSTALL += arc-theme
arc-theme: | gnome-shell git install-arc-theme-git build-arc-theme-git clean-arc-theme-git

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
	@_rebuild_theme=false
	@if [ ! -d $(DOTHOME_OPT)/arc-theme ]; then
	@	git clone https://github.com/obatiuk/arc-theme --depth 1 $(DOTHOME_OPT)/arc-theme
	@	_rebuild_theme=true
	@fi
	@git -C $(DOTHOME_OPT)/arc-theme remote update
	@_has_changes=$$(git -C $(DOTHOME_OPT)/arc-theme status -uno | grep -q 'Your branch is behind' && echo 'true' || echo 'false')
	@if [ $${_rebuild_theme} == true ] || [ $${_has_changes} == true ]; then
	@	git -C $(DOTHOME_OPT)/arc-theme pull
	@	meson setup --reconfigure --prefix=$(HOME)/.local \
			-Dvariants=dark,darker \
			-Dthemes=gnome-shell,gtk2,gtk3,gtk4 \
			$(DOTHOME_OPT)/arc-theme/build $(DOTHOME_OPT)/arc-theme
	@	SELF_CALL=true bash -c 'meson install -C $(DOTHOME_OPT)/arc-theme/build'
	@	install -d $(HOME)/.themes
	@	for theme in Arc{,-Dark,-Darker,-Lighter}{,-solid}; do
	@		if [ -d $(XDG_DATA_HOME)/themes/$${theme} ]; then
	@			ln -svfn $(XDG_DATA_HOME)/themes/$${theme} $(HOME)/.themes/$${theme}
	@		fi
	@	done
	@fi

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

INSTALL += gnome-shell-extensions
gnome-shell-extensions: | gnome-shell $(PKG_GSHELL) $(EXT_GSHELL)
	@gsettings set org.gnome.shell disable-user-extensions false
	-@/usr/bin/gnome-extensions disable 'window-list@gnome-shell-extensions.gcampax.github.com'
	-@/usr/bin/gnome-extensions disable 'places-menu@gnome-shell-extensions.gcampax.github.com'

INSTALL += ulauncher
ulauncher:
	@$(call dnf,$@)
	@systemctl --user enable --now $@

INSTALL += ulauncher-extensions
ulauncher-extensions: ulauncher $(EXT_ULAUNCHER)
	-@systemctl --user restart ulauncher.service

########################################################################################################################
#
# GNOME settings
#

INSTALL += gnome-key-binding-settings
gnome-key-binding-settings: | gnome-shell gnome-terminal ulauncher gnome-system-monitor $(DOTHOME_BIN)/dell-kvm-switch-input
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
		$(XDG_CONFIG_HOME)/gtk-3.0/settings.ini \
		$(XDG_CONFIG_HOME)/gtk-3.0/gtk.css \
		$(XDG_CONFIG_HOME)/gtk-4.0/settings.ini
	@gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Darker'
	@gsettings set org.gnome.desktop.wm.preferences theme 'Arc-Darker'
	@gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'
	@gsettings set org.gnome.desktop.wm.preferences titlebar-uses-system-font true
	@gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier '<Super>'

INSTALL += gnome-wallpaper
gnome-wallpaper: | $(XDG_DATA_HOME)/backgrounds/current gnome-desktop
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

#INSTALL += gnome-screenshot-settings
#gnome-screenshot-settings: | gnome-desktop
#	@gsettings set org.gnome.gnome-screenshot auto-save-directory 'file://$(XDG_PICTURES_DIR)/Screenshots'
#	@gsettings set org.gnome.gnome-screenshot last-save-directory 'file://$(XDG_PICTURES_DIR)/Screenshots'
#	@gsettings set org.gnome.gnome-screenshot default-file-type 'png'
#	@gsettings set org.gnome.gnome-screenshot include-pointer false
#	@gsettings set org.gnome.gnome-screenshot delay 2
#	@gsettings set org.gnome.gnome-screenshot take-window-shot false

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
gnome-gedit-settings: $(DF_GNOME_RES)/gnome-gedit.ini | dconf
	@dconf load '/' < $<

INSTALL += gnome-tracker-settings
gnome-tracker-settings: $(DF_GNOME_RES)/gnome-tracker.ini | dconf
	@dconf load '/' < $<

INSTALL += gnome-terminal-settings
gnome-terminal-settings: $(DF_GNOME_RES)/gnome-terminal.ini | dconf
	@dconf load '/' < $<

INSTALL += gnome-pomodoro-settings
gnome-pomodoro-settings: $(DF_GNOME_RES)/gnome-pomodoro.ini | dconf
	@dconf load '/' < $<

INSTALL += gnome-clocks-settings
gnome-clocks-settings: $(DF_GNOME_RES)/gnome-clocks.ini | dconf
	@dconf load '/' < $<

INSTALL += $(PKG_GSHELL)
$(PKG_GSHELL): | gnome-desktop
	@$(call dnf,$@)
	@if [ -f $(DF_GNOME_RES)/$@.ini ]; then dconf load '/' < $(DF_GNOME_RES)/$@.ini; fi

INSTALL += $(EXT_GSHELL)
$(EXT_GSHELL): $(DOTHOME_BIN)/install-gnome-extensions | gnome-desktop dconf
	@install -d $(DOTHOME_OPT)
	@$(eval __ext=$(subst $(slash),$(space),$(subst https://extensions.gnome.org/extension/,,$(strip $@))))
	@$(eval __ext_id=$(word 1, $(__ext)))
	@$(eval __ext_name=$(word 2, $(__ext)))
	@if [ -f $(DF_GNOME_RES)/gnome-shell-extension-$(__ext_name).ini ]; then
	@	dconf load '/' < $(DF_GNOME_RES)/gnome-shell-extension-$(__ext_name).ini;
	@fi
	@$< --enable $(__ext_id)

INSTALL += $(EXT_ULAUNCHER)
$(EXT_ULAUNCHER): | git ulauncher
	@$(call clone,$@)
	@install -d $(ULAUNCHER_EXT)
	@ln -svfn $(DOTHOME_OPT)/$@ $(ULAUNCHER_EXT)/$(subst .git,,$@)

FILES += $(HOME)/.trackerignore
$(HOME)/.trackerignore: $(DF_FSHOME)/.trackerignore
	@ln -svnf $< $@

FILES += /etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:dusansimic\:themes.repo
/etc/yum.repos.d/_copr\:copr.fedorainfracloud.org\:dusansimic\:themes.repo:
	@sudo dnf copr enable -y dusansimic/themes

FILES += $(DOTHOME_BIN)/install-gnome-extensions
$(DOTHOME_BIN)/install-gnome-extensions: $(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh
	@ln -svfn $< $@
	@chmod u+x $@

FILES += $(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh
$(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh: | git
	@$(call clone,install-gnome-extensions.git)

FILES += $(DOTHOME_BIN)/switch-monitor
$(DOTHOME_BIN)/switch-monitor: $(DF_GNOME_FSHOME)/.home/bin/switch-monitor | gnome-monitor-config
	@install -d $(@D)
	@ln -svfn $< $@
	@chmod +x $<

UPDATE += update-gnome-extensions
update-gnome-extensions:
	@echo -e "\n*******************************************************************************************************"
	@$(call log,$(INFO), "\\nScheduling GNOME extension auto-update ...\\n")
	-@gdbus call --session \
		--dest org.gnome.Shell.Extensions \
		--object-path /org/gnome/Shell/Extensions \
		--method org.gnome.Shell.Extensions.CheckForUpdates

UPDATE += update-gnome-shell-extensions-bin
update-gnome-shell-extensions-bin: $(DOTHOME_OPT)/install-gnome-extensions.git/install-gnome-extensions.sh
	@git -C $(DOTHOME_OPT)/install-gnome-extensions.git pull

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

# Fix for the NVIDIA suspend issue
# TODO: move files to GNOME/fsroot
PATCH += patch-gnome-suspend
patch-gnome-suspend: | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $(DF_FSETC)/systemd/system/gnome-shell-suspend.service.template \
		| sudo install -m 644 -DC /dev/stdin /etc/systemd/system/gnome-shell-suspend.service

	@envsubst '$$TODAY $$USER' < $(DF_FSETC)/systemd/system/gnome-shell-resume.service.template \
		| sudo install -m 644 -DC /dev/stdin /etc/systemd/system/gnome-shell-resume.service

	@sudo systemctl daemon-reload
	@sudo systemctl enable gnome-shell-suspend
	@sudo systemctl enable gnome-shell-resume

.PHONY: gnome-settings
gnome-settings: gnome-key-binding-settings gnome-theme-settings gnome-wallpaper gnome-shell-extensions \
		gnome-input-settings gnome-desktop-settings gnome-display-settings \
		gnome-nautilus-settings gnome-file-chooser-settings gnome-gedit-settings gnome-screenshot-settings \
		gnome-tracker-settings gnome-power-settings gnome-privacy-settings gnome-terminal-settings
