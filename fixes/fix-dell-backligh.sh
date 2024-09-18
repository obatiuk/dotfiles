#!/bin/sh

# Source: https://wiki.archlinux.org/index.php/Dell_XPS_15_7590#Backlight

sudo dnf install inotify-tools

sudo tee /usr/local/bin/xbacklightmon <<- 'EOF'
	#!/bin/sh
	#use LC_NUMERIC if you are using an European LC, else printf will not work because it expects an comma instead of a decimal point
	LC_NUMERIC="en_US.UTF-8"

	#Exit with 1 if $DISPLAY env isn't set. Helps when using the start up script below
	[ -z "$DISPLAY" ] && exit 1;

	# modify this path to the location of your backlight class
	path=/sys/class/backlight/intel_backlight

	read -r max < "$path"/max_brightness

	luminance() {
	    read -r level < "$path"/actual_brightness
	    factor=$((max))
	    new_brightness="$(bc -l <<< "scale = 2; $level / $factor")"
	    printf '%f\n' $new_brightness
	}

	# support both intel and nvidia
	DEVICE=eDP-1
	if [ ! -z "$(xrandr -q --output $DEVICE 2>&1)" ]; then
	  DEVICE=eDP-1-1
	fi

	xrandr --output $DEVICE --brightness "$(luminance)"

	inotifywait -me modify --format '' "$path"/actual_brightness | while read; do
	    xrandr --output $DEVICE --brightness "$(luminance)"
	done
EOF

sudo chown root:root /usr/local/bin/xbacklightmon
sudo chmod 755 /usr/local/bin/xbacklightmon

mkdir -p "${HOME}/.config/systemd/user/"

tee "${HOME}/.config/systemd/user/xbacklightmon.service" <<- 'EOF'
	[Unit]
	Description=Ugly fix to be able to control the brightness of OLED screens via keyboard brightness
	After=multi-user.target

	[Service]
	Type=simple
	ExecStart=/usr/local/bin/xbacklightmon
	Restart=on-failure
	RestartSec=1

	[Install]
	WantedBy=default.target
EOF

systemctl --user enable -now xbacklightmon.service
