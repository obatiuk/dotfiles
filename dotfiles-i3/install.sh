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
    [ -d ${target_dir}/.bash_profile.d ] || mkdir -vp ${target_dir}/.bash_profile.d

    # i3 Configuration

    ln -svfn ${dotfiles_dir}/.i3 ${target_dir}/.i3
    ln -svfn ${dotfiles_dir}/.config/i3status.conf ${target_dir}/.config/i3status.conf
    ln -svfn ${dotfiles_dir}/.config/compton.conf ${target_dir}/.config/compton.conf

    # Wallpaper

    ln -svfn ${dotfiles_dir}/.config/wallpaper ${target_dir}/.config/wallpaper

    # X settings

    ln -svfn ${dotfiles_dir}/.Xresources.d/.Xresources-rofi ${target_dir}/.Xresources.d/.Xresources-rofi

    # custom bash_profile settings

    ln -svfn ${dotfiles_dir}/.bash_profile.d/.bash_profile-java ${target_dir}/.bash_profile.d/.bash_profile-java

    # Power management

    if ask "Apply default power-management configuration?"; then
        ## Enabling Xfce4 power manager icon
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/show-tray-icon -n -t int -s 1
        ## Lid action configuration
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-lid-switch -n -t bool -s false
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -n -t uint -s 1
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -n -t uint -s 1
        ## Lock screen
        xfconf-query -v -c xfce4-power-manager -p /xfce4-power-manager/lock-screen-suspend-hibernate -n -t bool -s true
        xfconf-query -v -c xfce4-session -p /general/LockCommand -n -t string -s "${target_dir}/.i3/i3lock"
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
    fi

    # Display configuration
    
    # Enable xfce to detect monitors automatically
    xfconf-query -v -c displays -p /Notify -n -t bool -s true

    # Check all required resources

    checkAllResources

    echo "i3 configuration files were successfully installed"
else
    echo "i3 configuration files were not installed".
fi

