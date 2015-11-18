#!/bin/bash
 
# Dependencies:
# imagemagick
# i3lock
# scrot
 
IMAGE=/tmp/i3lock.png
 
BASEDIR=$(dirname $0)
 
BLURTYPE="0x8"

scrot $IMAGE
convert $IMAGE -blur $BLURTYPE -paint 10 $IMAGE
i3lock -i $IMAGE
rm $IMAGE