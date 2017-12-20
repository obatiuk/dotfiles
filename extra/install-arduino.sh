#!/usr/bin/env bash

sudo dnf install arduino
sudo usermod -a -G dialout,lock,tty $USER