#!/bin/bash

# Dependencies:
# imagemagick
# i3lock
# scrot

IMAGE=/tmp/i3lock.png

scrot $IMAGE
convert $IMAGE -blur 0x8 -paint 10 $IMAGE
i3lock -i $IMAGE
rm $IMAGE