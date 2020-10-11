#!/bin/bash
# --- filename: al-inst-xorg.sh
# ---   update: 2020-10-11
# ---   author: p. andree
# --- encoding: utf-8
# ------------------------------------------------------------------------------

clear

echo " ------------------------------------------------------------------------"
echo " `uname -a`"
echo " --------------------------------------------------------- "
echo " Installing programs and adjusting SUDOERS"
echo " Hostname: $HOSTNAME"
echo " --------------------------------------------------------- "

HN=raspi
UN=peandr

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

	install dmenu
	install xorg
	install xorg-xinit
	install xterm
	install feh

	if [ ! -d /home$UN/pictures/ ]; then
		mkdir /home/$UN/pictures
	fi
	echo " Copy some wallpapers to the host!"
	wget http://$HN/sh/wallpapers.tar.gz
	if [ ! -d /home/$UN/pictures/ ]; then
		mkdir /home/peandr/pictures
	fi
	chown -R peandr:peandr /home/$UN/pictures
	tar -C /home/$UN/pictures -xvf wallpapers.tar.gz

	cd /home/$UN/git/
	git clone https://git.suckless.org/dwm
	git clone https://github.com/LukeSmithxyz/st.git
	cd dwm
	sudo make clean install
	cd ../st
	sudo make clean install
	cd
	echo "setxkbmap ch" >> /home/$UN/.xinitrc
	echo "feh --bg-fill ~/pictures/wallpapers/game-code.jpg" >> /home/$UN/.xinitrc
	echo "exec dwm"  >> /home/$UN/.xinitrc

else
	echo " User $UN does NOT exist on $HOSTNAME!"
	exit
fi
