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
	portsnap fetch
	portsnap extract
	portsnap update

	pinstall sudo
	pinstall wget
	pinstall rsync
	pinstall htop
	pinstall vifm
	pinstall tmux
	pinstall git
	#pinstall curl				# installed by git
	pinstall neofetch
	pinstall dbus
	pinstall bash
	pinstall pkgconf
	pinstall recode
	pinstall python				# imperativ for vim: needed by UltiSnips with tex
  pinstall node
	pinstall yarn
	pinstall doas

	which ranger > /dev/null
	if [ $? -ne 0 ]; then
		pkg install -y py37-ranger
	fi
	if [ ! -d /home/$UN/git/vim/ ]; then
	  git clone https://github.com/vim/vim.git
	  cd vim/src/
	  ./configure --with-features=huge --enable-multibyte --enable-python3interp=yes --with-python3-config-dir=$(python3-config --configdir) --prefix=/usr/local
	  make install clean
	  cd ../../
	fi

	if [ ! -d /home/$UN/git/fonts/ ]; then
	  git clone https://github.com/powerline/fonts.git
	  cd fonts
	  ./install.sh
 	  cd ../
	fi

	chsh -s /usr/local/bin/bash peandr

	sysrc dbus_enable=yes

	grep $UN /usr/local/etc/sudoers > /dev/null
	if [ $? -ne 0 ]; then
		  echo "$UN  ALL=(ALL:ALL) ALL" >> /usr/local/etc/sudoers
	fi
	echo 'autoboot_delay="1"'  >> /boot/loader.conf
	echo 'kern.vty="vt"'  >> /boot/loader.conf

else
	echo " User $UN does NOT exist on $HN!"
fi
