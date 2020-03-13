#!/bin/bash
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: al-post-config.sh
# --- last ver: 2020-03-10
# ---   author: p. andree
# ------------------------------------------------------------------------------
clear
UN=""

echo " ------------------------------------------------------------------------"
echo " `uname -a`"
echo " --------------------------------------------------------- "
echo " Installing programs and adjusting SUDOERS"
echo " Hostname: $HOSTNAME"
echo " --------------------------------------------------------- "
read -p " Username: " UN

if [ -d /home/$UN/ ]; then
	sudo pacman -Syyu --noconfirm

  function install {
		which $1 &> /dev/null
		if [ $? -ne 0 ]; then
			echo "Installing: ${1}"
			sudo pacman -S ${1} --noconfirm
		else
		  echo " Already installed on $HOSTNAME: ${1}"
		fi
	}

	install powerline

	cd /home/$UN/git
		git clone https://github.com/powerline/fonts.git
		cd fonts
		./install.sh
	cd ../

	sudo grep $UN /etc/sudoers &> /dev/null
	if [ $? -ne 0  ]; then
		sudo 'echo "$UN  ALL=(ALL:ALL) ALL" >> /etc/sudoers'
	else
		echo " User $UN is in SUDOERS-file!"
	fi
else
	echo " User $UN does NOT exist on $HOSTNAME!"
	exit
fi

