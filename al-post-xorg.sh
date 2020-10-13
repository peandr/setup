#!/bin/bash
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: al-post-xorg.sh
# --- last ver: 2020-10-13
# ---   author: p. andree
# ------------------------------------------------------------------------------
clear
UN=""

echo " ------------------------------------------------------------------------"
echo " `uname -a`"
echo " ----------------------------------------------------------------------- "
echo " Installing post-xorg-SOFTWARE"
echo " Hostname: $HOSTNAME"
echo " ----------------------------------------------------------------------- "
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

	# --- the archlinux helper
	cd git
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
	sudo pacman -Rns go
	cd

	# --- system aferent programs
	install ntfs-3g
	install meld
	install terminus-font
	sudo bash -c "echo ""FONT=ter-c20n"" >> /etc/vconsole.conf"
	install leafpad

	# --- printer driver
	install cups
	install cups-pdf
	sudo systemctl enable org.cups.cupsd.service

	# --- compiler and build tools
	install tcc
	install fpc
	install cmake

	# --- supplementary filemanager
	install mc

	# --- install sound
	install alsa-utils
	install pulseaudio
	install vlc

	# --- the browser I use
	install firefox

	# --- typesetting
	install aspell
	install aspell-en
	install aspell-de
	install scribus
	install zathura
	install zathura-pdf-poppler
	install zathura-ps

	# --- graphic section
	install gimp
	install darktable
	install scrot

	# --- mathematical programs
	install wxmaxima
	install gnuplot

	# --- install virtualbox
	install virtualbox
  install virtualbox-host-modules-arch
	install linux-headers

	# --- another filemanager
	yay -S xfe
	# --- install texlive
	sudo pacman -S texlive-most
	sudo pacman -S texlive-lang

	sudo mkdir /mnt/{vol-a,vol-b,wdigital-1t}
	sudo chown -R peandr:users /mnt/vol-a/
	sudo chown -R peandr:users /mnt/vol-b/
	sudo chown -R peandr:users /mnt/wdigital-1t/

else
	echo " User $UN does NOT exist on $HOSTNAME!"
	exit
fi

