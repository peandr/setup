#!/bin/bash
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: du-post-inst.sh
# --- last ver: 2020-03-12
# ---   author: p. andree
# ------------------------------------------------------------------------------

clear
UN=""
echo " ------------------------------------------------------------------------"
echo " `uname -a`"
echo " ----------------------------------------------------------------------- "
echo " Installing programs and adjusting SUDOERS"
echo " Hostname: $HOSTNAME"
echo " ----------------------------------------------------------------------- "
echo " Hostname: $HOSTNAME"
read -p " Username: " UN

if [ -d /home/$UN/ ]; then
	function install {
		which $1 &> /dev/null
		if [ $? -ne 0 ]; then
			echo "Installing: ${1}"
			apt-get install $1 -y
		else
			echo "Already installed on $HOSTNAME: ${1}"
		fi
	}

	# --- first of all update and upgrade the os -----------------------------------
	apt-get update -y && apt-get dist-upgrade -y
	install cifs-utils

	# --- installl the necessary software ------------------------------------------
	install sudo
	install vim
	install tmux
	install ranger
	install vifm
	install git
	install curl
	install htop
	install rsync
	install dos2unix
	install recode
	install neofetch
	install powerline

	if [ ! -d fonts/ ]; then
		git clone https://github.com/powerline/fonts.git
		cd fonts
		./install.sh
		cd ../
	fi

	grep $UN /etc/sudoers &> /dev/null
	if [ $? -ne 0 ]; then
		echo "$UN  ALL=(ALL:ALL) ALL" >> /etc/sudoers
	fi
else
	echo " User $UN does NOT exist on $HOSTNAME!"
	exit
fi
