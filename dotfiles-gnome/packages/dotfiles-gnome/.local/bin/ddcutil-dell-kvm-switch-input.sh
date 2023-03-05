#!/usr/bin/env bash

#
# How to use ddcutil to switch input of a Dell screen
#
# Source: https://jeancharles.quillet.org/posts/2021-08-20-How-to-use-ddcutil-to-switch-input-of-a-Dell-screen.html
#

set -o nounset
set -o errexit

# Get current input
current=$(ddcutil getvcp 60 | sed -n "s/.*(sl=\(.*\))/\1/p")

# Get the other input
case $current in

    # Usb
    0x1b)
        output=0x0f
        ;;

    # Display port
    0x0f)
        output=0x1b
        ;;

    *)
        echo "Unknown input"
        exit 1
        ;;
esac

# Set new input
ddcutil setvcp 60 $output