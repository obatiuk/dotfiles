#!/usr/bin/env bash

sudo dnf install ecryptfs-utils
sudo modprobe ecryptfs
sudo usermod -a -G ecryptfs "$(id -un)"

sudo authselect select sssd with-ecryptfs --force

ecryptfs-setup-private
