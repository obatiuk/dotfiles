#!/usr/bin/env bash

[ -n "$(echo $@ | grep "\-debug")" ] && set -x

. ../functions

#
# Variables
#

dotfiles_dir=$(pwd)

#
# Setup
#

if ask "Do you want to install i3 configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    # Target folders

    [ -d ${target_dir}/.config ] || mkdir -vp ${target_dir}/.config
    [ -d ${target_dir}/.Xresources.d ] || mkdir -vp ${target_dir}/.Xresources.d

    # i3 Configuration

    ln -svfn ${dotfiles_dir}/.config/i3 ${target_dir}/.config/i3
    ln -svfn ${dotfiles_dir}/.config/i3status ${target_dir}/.config/i3status

    # Wallpaper

    ln -svfn ${dotfiles_dir}/.config/wallpaper ${target_dir}/.config/wallpaper

    # X settings

    ln -svfn ${dotfiles_dir}/.Xresources.d/.Xresources-rofi ${target_dir}/.Xresources.d/.Xresources-rofi
    ln -svfn ${dotfiles_dir}/.Xresources.d/.Xresources-i3 ${target_dir}/.Xresources.d/.Xresources-i3

    # Power management

    if ask "Apply default power-management configuration?"; then
        ## Enabling Xfce4 power manager icon & notifications
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/show-tray-icon -n -t int -s 1
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/general-notification -n -t bool -s true
        ## Lid action configuration
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-lid-switch -n -t bool -s false
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -n -t uint -s 1
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -n -t uint -s 1
        ## Lock screen
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/lock-screen-suspend-hibernate -n -t bool -s true
        xfconf-query -v -c xfce4-session -p /general/LockCommand -n -t string -s "${target_dir}/.config/i3/i3lock"
        ## Hibernate on low power
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/critical-power-action -n -t uint -s 2
    fi

    # Keyboard configuration

    if ask "Apply default keyboard configuration?"; then
	xfconf-query -v -c keyboard-layout -p /Default/XkbDisable -n -t bool -s false
	xfconf-query -v -c keyboard-layout -p /Default/XkbLayout -n -t string -s "us,ru"
	xfconf-query -v -c keyboard-layout -p /Default/XkbOptions/Group -n -t string -s "grp:alt_caps_toggle"
	xfconf-query -v -c keyboard-layout -p /Default/XkbVariant -n -t string -s "os_winkeys"

	## Removing default shortcuts, they should be handled by i3 
	xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom -r -R
	xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom/override -n -t bool -s true
	xfconf-query -c xfce4-keyboard-shortcuts -p /xfwm4 -r -R
	xfconf-query -c xfce4-keyboard-shortcuts -p /xfwm4/custom/override -n -t bool -s true
	xfconf-query -c xfce4-keyboard-shortcuts -p /providers -r -R
    fi

    # Appearance configuration

    if ask "Appply default appearance configuration?"; then
	xfconf-query -v -c xsettings -p /Gtk/ButtonImages -n -t bool -s true
	xfconf-query -v -c xsettings -p /Gtk/FontName -n -t string -s "Sans 9"
	xfconf-query -v -c xsettings -p /Net/IconThemeName -n -t string -s "Fedora"
	xfconf-query -v -c xsettings -p /Net/ThemeName -n -t string -s "Arc-X"

	xfconf-query -v -c xfce4-notifyd -p /theme -n -t string -s "Default"
	xfconf-query -v -c xfce4-notifyd -p /notify-location -n -t uint -s 2
	xfconf-query -v -c xfce4-notifyd -p /initial-opacity -n -t double -s 0.9
	
	#Gnome 3
	gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com']"
	gsettings set org.gnome.desktop.interface gtk-theme "Arc-X"
	gsettings set org.gnome.desktop.wm.preferences theme "Arc-X"
	gsettings set org.gnome.shell.extensions.user-theme name "Arc-X"
	gsettings set org.gnome.desktop.interface icon-theme "Fedora"

	#Gnome 2
	gconftool-2 --type=string --set /desktop/gnome/interface/gtk_theme "Arc-X"
	gconftool-2 --type=string --set /apps/metacity/general/theme "Arc-X"
    fi

    # Display configuration

    ## Enable xfce to detect monitors automatically
    xfconf-query -v -c displays -p /Notify -n -t bool -s true

    # Some default mime associations contains extra ";" character at the end. Fixing that.

    xdg-mime default eog.desktop image/jpeg
    xdg-mime default eog.desktop image/jpg
    xdg-mime default eog.desktop image/png

    xdg-mime default evince.desktop application/pdf

    xdg-mime default org.gnome.FileRoller.desktop application/zip

    xdg-mime default org.gnome.Totem.desktop video/mp4

    # Check all required resources

    checkAllResources

    echo "i3 configuration files were successfully installed"
else
    echo "i3 configuration files were not installed".
fi

