#
# ~/.bashrc: Executed by bash(1) for interactive non-login shells.
#
# shellcheck disable=SC1090,SC1091

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment

# Ensure user-specific binaries directories are at the beginning of the PATH.
# This prevents duplication checks if they are already present.
# shellcheck disable=SC2076
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# Load user-specific aliases, functions, and environment variables
# from configuration files placed in the ~/.bashrc.d directory.
if [ -d ~/.bashrc.d ]; then
    for rc_file in ~/.bashrc.d/*; do
        if [ -f "$rc_file" ]; then
            . "$rc_file"
        fi
    done
fi
unset rc_file
