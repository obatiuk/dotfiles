#!/usr/bin/env bash

# Sanity checks
command -v git > /dev/null 2>&1 || { echo "'git' command not found. Aborting!" && exit 1; }
command -v dconf > /dev/null 2>&1 || { echo "'dconf' command not found. Aborting!" && exit 1; }

# make sure that required environment variables are set during installation
: "${HOME_STORAGE:=${HOME}/.home}"
: "${APP_STORAGE:=${HOME_STORAGE}/opt}"
: "${LOCAL_BIN:=${HOME}/.local/bin}"

mkdir -p "${APP_STORAGE}"
mkdir -p "${LOCAL_BIN}"

git clone 'https://github.com/obatiuk/install-gnome-extensions' "${APP_STORAGE}/install-gnome-extensions"
ln -s "${APP_STORAGE}/install-gnome-extensions/install-gnome-extensions.sh" "${LOCAL_BIN}/install-gnome-extensions.sh"
chmod u+x "${APP_STORAGE}/install-gnome-extensions/install-gnome-extensions.sh"

# https://extensions.gnome.org/extension/3499/application-volume-mixer/
# https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/
# https://extensions.gnome.org/extension/3193/blur-my-shell/
# https://extensions.gnome.org/extension/517/caffeine/
# https://extensions.gnome.org/extension/3210/compiz-windows-effect/
# https://extensions.gnome.org/extension/4135/espresso/
# https://extensions.gnome.org/extension/4451/logo-menu/
# https://extensions.gnome.org/extension/4099/no-overview/
# https://extensions.gnome.org/extension/2120/sound-percentage/
# https://extensions.gnome.org/extension/989/syncthing-icon/
# https://extensions.gnome.org/extension/3733/tiling-assistant/
# https://extensions.gnome.org/extension/3258/wi-fi-power-management-toggle/

. "${LOCAL_BIN}/install-gnome-extensions.sh" --enable 3499 1401 3193 3210 4135 4451 4099 2120 989 3733 3258

dconf load /org/gnome/shell/extensions/ <<< "
[Logo-menu]
menu-button-icon-image=26
menu-button-icon-size=18
show-lockscreen=true
show-power-options=true

[appindicator]
icon-size=0
tray-pos='right'

[bluetooth-quick-connect]
bluetooth-auto-power-on=false
keep-menu-on-toggle=true
refresh-button-on=true
show-battery-value-on=true

[blur-my-shell]
appfolder-dialog-opacity=0.080000000000000002
blur-applications=true
blur-dash=false
brightness=0.68999999999999995
dash-opacity=0.080000000000000002
debug=false
hacks-level=0
hidetopbar=false
sigma=109

[caffeine]
user-enabled=false

[com/github/hermes83/compiz-windows-effect]
friction=4.7000000000000002
mass=61.0
resize-effect=true
speedup-factor-divider=4.7000000000000002
spring-k=9.4000000000000004

[dash-to-dock]
animation-time=0.20000000000000001
apply-custom-theme=false
autohide=true
autohide-in-fullscreen=false
background-opacity=0.28000000000000003
custom-background-color=false
custom-theme-shrink=true
dash-max-icon-size=48
dock-fixed=false
dock-position='BOTTOM'
extend-height=false
force-straight-corner=false
height-fraction=1.0
hide-delay=0.20000000000000001
hot-keys=false
icon-size-fixed=true
intellihide=false
intellihide-mode='ALL_WINDOWS'
multi-monitor=true
preferred-monitor=0
pressure-threshold=100.0
require-pressure-to-show=false
running-indicator-style='DEFAULT'
show-apps-at-top=false
show-delay=0.25
show-mounts=true
show-trash=true
show-windows-preview=true
transparency-mode='FIXED'
unity-backlit-items=false

[espresso]
has-battery=true
restore-state=true
user-enabled=false

[gamemode]
active-color='rgb(115,210,22)'
always-show-icon=true

[mediacontrols]
mouse-actions=['toggle_play', 'toggle_menu', 'none', 'none', 'none', 'none', 'none', 'none']

[syncthing]
api-key=''
autoconfig=true
"
