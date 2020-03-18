#!/bin/sh
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: fbsd-xorg.sh
# --- last ver: 2020-03-18
# ---   author: p. andree
# ------------------------------------------------------------------------------

# rem: xorg-minimal failed to startx

UN="?"
if [ $UN != "?" ]; then
	pkg install -y xorg libXft libXinerama
	pkg install -y gpu-firmware-kmod
	pkg install -y drm-kmod
	sysrc kld_list="amdgpu"
	pw groupmod  video -M $UN

	pkg install -y zathura
	pkg install -y zathura-pdf-poppler
	pkk install -y feh
  # may be all necessary fonts
	pkg install -y dejavu
	pkg install -y dmenu

	pkg install -y aspell en-aspell de-aspell
	if [ ! -d /home$UN/pictures/ ]; then
		mkdir /home/$UN/pictures
	fi
	echo " Copy some wallpapers to the host!"
	scp -P 47513 $UN@raspberrypi:/home/$UN/how-to-files/wallpapers/*.jpg /home/$UN/pictures
	if [ ! -d /root/src/ ]; then
		mkdir src
	fi
	wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
	mv install-tl-unx.tar.gz src/
	tar -C src/ -xvf src/install-tl-unx.tar.gz
else
	echo "Specify the USER for video group!"
fi

