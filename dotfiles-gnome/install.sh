#!/usr/bin/env bash

[ -n "$(echo $@ | grep "\-debug")" ] && set -x

#
# Variables
#

dotfiles_dir=$(dirname $(readlink -f $0))

#
# Imports
#

. ${dotfiles_dir}/../functions

#
# Setup
#

if ask "Do you want to install 'Gnome' configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    #
    # Settings
    #

    ## Arc themne

    gsettings set org.gnome.desktop.interface gtk-theme "Arc-Darker"
    gsettings set org.gnome.desktop.wm.preferences theme "Arc-Darker"
    gsettings set org.gnome.desktop.interface icon-theme "Adwaita"

    # Dash-to-Dock

    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
    gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed: false
    gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
    gsettings set org.gnome.shell.extensions.dash-to-dock show-windows-preview true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
    gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts true
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.8
    gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
    gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true

    ## Wallpaper

    gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/.config/wallpaper/default.png"

    ## Keyboard shortcuts

    gsettings set org.gnome.desktop.wm.keybindings switch-applications "@as []"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "@as []"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Primary>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Primary><Shift>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Primary>grave']"
    gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Primary><Shift>grave']"

    ## Workspace

    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
    gsettings set org.gnome.mutter workspaces-only-on-primary false
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Shift><Super>x']"
    gsettings set org.gnome.desktop.wm.keybindings maximize "['<Shift><Super>f']"
    gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Shift><Super>Left']"
    gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Shift><Super>Right']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>h']"

    ## Power management

    gsettings set org.gnome.desktop.interface show-battery-percentage true

    ## Fonts

    gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
    gsettings set org.gnome.desktop.interface font-name 'Sans 9'
    gsettings set org.gnome.desktop.interface document-font-name 'Sans 9'

    ## Display settings

    gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

    ## Nautilus

    gsettings set org.gnome.nautilus.preferences show-create-link true
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
    gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'where', 'date_modified']"
    gsettings set org.gnome.nautilus.list-view default-zoom-level 'standard'
    gsettings set org.gnome.nautilus.preferences always-use-location-entry true

    ## gEdit

    gsettings set org.gnome.gedit.preferences.editor auto-save true
    gsettings set org.gnome.gedit.preferences.ui statusbar-visible true
    gsettings set org.gnome.gedit.preferences.ui toolbar-visible true
    gsettings set org.gnome.gedit.preferences.editor bracket-matching true
    gsettings set org.gnome.gedit.preferences.editor highlight-current-line true
    gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
    gsettings set org.gnome.gedit.preferences.print print-header false
    gsettings set org.gnome.gedit.preferences.ui side-panel-visible true

    ## Terminal

    gsettings set org.gnome.Terminal.Legacy.Settings shortcuts-enabled false
    gsettings set org.gnome.Terminal.Legacy.Settings menu-accelerator-enabled false

    echo "Gnome configuration files were successfully installed"
else
    echo "Gnome configuration files were not installed"
fi