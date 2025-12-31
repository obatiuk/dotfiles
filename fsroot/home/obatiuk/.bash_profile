#
# ~/.bash_profile: Executed by bash(1) for login shells (e.g., console login, SSH).
# This file is used primarily for environment setup and sourcing ~/.bashrc.
#
# shellcheck disable=SC1090

# Source the interactive shell configuration file.
# This ensures that all aliases, functions, and prompt settings
# defined in ~/.bashrc are available in login shells
if [[ -f ~/.bashrc ]]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
