#!/usr/bin/env bash

sudo dnf install arduino
sudo usermod -a -G dialout,tty,lock,uucp $USER
