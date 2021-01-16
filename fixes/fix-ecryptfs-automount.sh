#!/bin/sh

# Fedora 29 - fix ecryptfs automount upon login
# 
# Bug: https://bugzilla.redhat.com/show_bug.cgi?id=1577174
#

sudo /usr/bin/authselect select sssd --force with-ecryptfs
