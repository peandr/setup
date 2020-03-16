#!/bin/sh
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: fbsd-post-inst.sh
# --- last ver: 2020-03-11
# ---   author: p. andree
# ------------------------------------------------------------------------------
clear
HN=`hostname`

# --- user to be configured
UN=""

echo " ------------------------------------------------------------------------"
echo " `uname -a`"
echo " --------------------------------------------------------- "
echo " Installing programs and adjusting SUDOERS"
echo " Hostname: $HN"
echo " --------------------------------------------------------- "
read -p " Username: " UN

if [ -d /home/$UN/ ]; then
	pinstall() {
	  which $1 > /dev/null
	  if [ $? -ne 0 ]; then
	    echo "Installing: ${1}"
	    pkg install -y $1
	  else
	    echo "Already installed on $HOSTNAME: ${1}"
	  fi
	}

	freebsd-update fetch
	freebsd-update install
	pkg update
	pkg upgrade -y

	pinstall sudo
	pinstall wget
	pinstall rsync
	pinstall vim-console
	pinstall htop
	pinstall vifm
	pinstall tmux
	pinstall git
	pinstall curl
	pinstall neofetch
	pinstall dbus
	pinstall bash
	pinstall pkgconf
	pinstall recode
	pinstall doas

	chsh -s /usr/local/bin/bash root
	chsh -s /usr/local/bin/bash peandr

	sysrc dbus_enable=yes

	grep peandr /usr/local/etc/sudoers > /dev/null
	if [ $? -ne 0 ]; then
		  echo "$UN  ALL=(ALL:ALL) ALL" >> /usr/local/etc/sudoers
	fi
	cat "autoboot_delay="1"" >> /boot/loader.conf
	cat "kern.vty="vt"" >> /boot/loader.conf

	reboot
else
	echo " User $UN does NOT exist on $HN!"
fi
