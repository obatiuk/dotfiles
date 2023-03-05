#!/usr/bin/env bash

[ -n "$(echo $@ | grep "\-debug")" ] && set -x

#
# Variables
#

dotfiles_dir=$(dirname $(readlink -f $0))
templates_dir=$(xdg-user-dir TEMPLATES)
: ${templates_dir:=${HOME}/Templates}

#
# Imports
#

. ${dotfiles_dir}/../functions

#
# Setup
#

if ask "Do you want to apply 'Gnome' configuration?" N; then

    bash "./dependencies-${distro}@${release}.sh"

    #
    # Configuration files
    #

    stow --dir=packages --target=${HOME} -vv --stow --no-folding dotfiles-gnome

    #
    # Make sure `ddcutil` works
    #

    sudo groupadd --force --system i2c
    sudo ln -svf /usr/share/ddcutil/data/45-ddcutil-i2c.rules /etc/udev/rules.d
    sudo usermod ${USER} -aG i2c

    #
    # Settings
    #

    ## Arc theme

    gsettings set org.gnome.desktop.interface gtk-theme "Arc-Darker"
    gsettings set org.gnome.desktop.wm.preferences theme "Arc-Darker"
    gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
    gsettings set org.gnome.desktop.wm.preferences titlebar-uses-system-font true
    gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier '<Super>'

    # Dash-to-Dock

    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
    gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
    gsettings set org.gnome.shell.extensions.dash-to-dock show-windows-preview true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts true
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.8
    gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
    gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top false

    ## Wallpaper

    gsettings set org.gnome.desktop.background picture-uri "file:///home/${USER}/.config/wallpaper/wallpaper-gnome.png"

    ## Keyboard

    gsettings set org.gnome.desktop.wm.keybindings switch-applications "@as []"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "@as []"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Primary>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Primary><Shift>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Primary>grave']"
    gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Primary><Shift>grave']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Shift><Super>x']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-lefet "['<Shift><Super>z']"
    gsettings set org.gnome.desktop.wm.keybindings maximize "['<Shift><Super>f']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up []
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down []
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left []
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right []

    gsettings set org.gnome.mutter.keybindings toggle-tiled-left []
    gsettings set org.gnome.mutter.keybindings toggle-tiled-right []

    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru'), ('xkb', 'ua')]"
    gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb', 'us'), ('xkb', 'ru'), ('xkb', 'ua')]"

    ## Custom global keyboard shortcuts

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Run Terminal'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "$(command -v gnome-terminal)"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>t'

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Dell KVM - Switch Input'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "${HOME}/.local/bin/ddcutil-dell-kvm-switch-input.sh"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Alt>i'

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Display Ulauncer'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command "$(command -v ulauncher-toggle)"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Super>r'

    ## Top pannel settings

    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.interface clock-show-weekday true

    ## Workspace

    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
    gsettings set org.gnome.mutter workspaces-only-on-primary false
    gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>h']"
    
    ## Fonts

    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Mono 10'
    gsettings set org.gnome.desktop.interface font-name 'Sans 9'
    gsettings set org.gnome.desktop.interface document-font-name 'Sans 9'
    gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
    gsettings set org.gnome.desktop.interface font-hinting 'slight'

    ## Display settings

    gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature uint32 4378
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 6.0
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 20.0
    gsettings set org.gnome.settings-daemon.plugins.color recalibrate-display-threshold uint32 0

    ## Nautilus / FileChooser

    gsettings set org.gnome.nautilus.preferences show-create-link true
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
    gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'where', 'date_modified']"
    gsettings set org.gnome.nautilus.list-view default-zoom-level 'standard'
    gsettings set org.gnome.nautilus.preferences always-use-location-entry true

    gsettings set org.gtk.Settings.FileChooser sort-column 'name'
    gsettings set org.gtk.Settings.FileChooser date-format 'regular'
    gsettings set org.gtk.Settings.FileChooser show-hidden true
    gsettings set org.gtk.Settings.FileChooser clock-format '24h'
    gsettings set org.gtk.Settings.FileChooser startup-mode 'recent'
    gsettings set org.gtk.Settings.FileChooser show-type-column true
    gsettings set org.gtk.Settings.FileChooser sort-order 'ascending'
    gsettings set org.gtk.Settings.FileChooser type-format 'category'
    gsettings set org.gtk.Settings.FileChooser show-size-column true
    gsettings set org.gtk.Settings.FileChooser location-mode 'path-bar'
    gsettings set org.gtk.Settings.FileChooser sort-directories-first true

    ## gEdit

    gsettings set org.gnome.gedit.preferences.editor auto-save true
    gsettings set org.gnome.gedit.preferences.ui statusbar-visible true
    gsettings set org.gnome.gedit.preferences.ui toolbar-visible true
    gsettings set org.gnome.gedit.preferences.editor bracket-matching true
    gsettings set org.gnome.gedit.preferences.editor highlight-current-line true
    gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
    gsettings set org.gnome.gedit.preferences.print print-header false
    gsettings set org.gnome.gedit.preferences.ui side-panel-visible true
    gsettings set org.gnome.gedit.plugins active-plugins ['docinfo', 'filebrowser', 'spell', 'modelines', 'time']

    ## Terminal

    gsettings set org.gnome.Terminal.Legacy.Settings shortcuts-enabled false
    gsettings set org.gnome.Terminal.Legacy.Settings menu-accelerator-enabled false

    ## Privacy

    gsettings set org.gnome.desktop.privacy old-files-age 10
    gsettings set org.gnome.desktop.privacy remove-old-temp-files true
    gsettings set org.gnome.desktop.privacy remove-old-trash-files false
    gsettings set org.gnome.desktop.notifications show-banners false
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false

    ## Folders

    gsettings set org.gnome.gnome-screenshot auto-save-directory "file:///home/${USER}/Pictures/Screenshots"

    ## Login screen / Session manager

    gsettings set org.gnome.SessionManager logout-prompt false
    gsettings set org.gnome.login-screen banner-message-text "Don't even try!"
    gsettings set org.gnome.login-screen disable-user-list true
    gsettings set org.gnome.login-screen banner-message-enable true
    gsettings set org.gnome.desktop.datetime automatic-timezone false
    gsettings set org.gnome.desktop.screensaver lock-enabled true
    gsettings set org.gnome.desktop.screensaver lock-delay uint32 0
    gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>l']"

    ## Screenshots

    gsettings set org.gnome.gnome-screenshot default-file-type 'png'
    gsettings set org.gnome.gnome-screenshot include-pointer false
    gsettings set org.gnome.gnome-screenshot delay 2
    gsettings set org.gnome.gnome-screenshot take-window-shot false
    gsettings set org.gnome.gnome-screenshot last-save-directory "file:///home/${USER}/Pictures/Screenshots"

    ## Indexing

    gsettings set org.freedesktop.Tracker3.Miner.Files index-optical-discs false
    gsettings set org.freedesktop.Tracker3.Miner.Files enable-monitors false
    gsettings set org.freedesktop.Tracker3.Miner.Files index-on-battery-first-time false
    gsettings set org.freedesktop.Tracker3.Miner.Files index-on-battery false
    gsettings set org.freedesktop.Tracker3.Miner.Files index-applications false
    gsettings set org.freedesktop.Tracker3.Miner.Files index-removable-devices false

    ## Power management

    gsettings set org.gnome.settings-daemon.plugins.power idle-dim true
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
    gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 30
    gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery true
    gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled true
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1200
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend'
    gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'

    ## Other

    gsettings set org.gnome.desktop.interface cursor-size 24
    gsettings set org.gnome.desktop.interface cursor-blink true
    gsettings set org.gnome.desktop.datetime automatic-timezone false

    ## Basic templates

    touch ${templates_dir}/'New Text File.txt'

    sudo systemctl enable gdm

    checkAllResources

    echo "'Gnome' configuration was successfully applied"
else
    echo "'Gnome' configuration was not applied"
fi
