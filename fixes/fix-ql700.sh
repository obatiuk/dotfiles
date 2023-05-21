#!/bin/sh

#
# Fix QL-700 brother printer access if SELinux is enabled
#
# * Make sure that the latest drivers are installed (http://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=lpql700eus)
# * Run this script to fix SELinux rules
#
# Source:
# - http://support.brother.com/g/s/id/linux/en/faq_prn.html?c=us_ot&lang=en&comple=on&redirect=on#f00115
# - http://www.pclinuxos.com/forum/index.php?topic=138727.0
#

sudo restorecon -RFv /usr/lib/cups/filter/*
sudo setsebool -P cups_execmem 1
sudo setsebool mmap_low_allowed 1
