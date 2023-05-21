#!/usr/bin/env bash

#
# Simple ask function
# Source http://djm.me/ask
#
ask() {

	while true; do

		if [ "${2:-}" = "Y" ]; then
			prompt="Y/n"
			default=Y
		elif [ "${2:-}" = "N" ]; then
			prompt="y/N"
			default=N
		else
			prompt="y/n"
			default=
		fi

		# Ask the question - use /dev/tty in case stdin is redirected from somewhere else
		read -p "$1 [$prompt] " REPLY < /dev/tty

		# Default?
		if [ -z "$REPLY" ]; then
			REPLY=$default
		fi

		# Check if the reply is valid
		case "$REPLY" in
			Y* | y*) return 0 ;;
			N* | n*) return 1 ;;
		esac

	done
}

editor_bin="/usr/bin/editor"

editors=(
	"/usr/bin/vi"
	"/usr/bin/nano"
	"/usr/bin/micro")

priority=0

for editor in "${editors[@]}"; do

	echo -e "\n\n Processing editor: [${editor}]"

	if [[ -f ${editor} ]]; then
		sudo update-alternatives --install "${editor_bin}" editor "${editor}" ${priority}
	else
		echo "ERR: (${editor}) does not exist or not a file"
	fi

	((priority += 10))

	if ! ask "Do you want continue?"; then
		break
	fi
done

unset priority
unset editors
unset editor_bin
