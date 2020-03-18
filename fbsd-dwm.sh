#!/bin/sh
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: fbsd-dwm.sh
# --- last ver: 2020-03-18
# ---   author: p. andree
# ------------------------------------------------------------------------------

clear
echo " ----------------------------------------------------------------------- "
echo " `uname -a`"

UN=""
echo " ----------------------------------------------------------------------- "
echo " Post-install dwm and st from suckless.org!"
echo " Hostname: $HOSTNAME"
echo " ----------------------------------------------------------------------- "
read -p " Username: " UN

mkdir /home/$UN/git/
cd /home/peandr/git/
git clone https://git.suckless.org/dwm
git clone https://github.com/LukeSmithxyz/st.git

cd dwm
cp config.mk config.mk.ori
sed -i .tmp 's/X11R6/local/g' config.mk
sed -i .tmp 's/include\//local\/include\//g' config.mk
rm *.mk.tmp
sudo make install clean
cd ..

cd st
cp config.mk config.mk.ori
sed -i .tmp 's/X11R6/local/g' config.mk
rm *.mk.tmp
sudo make install clean
cd

echo "setxkbmap ch" >> /home/$UN/.xinitrc
echo "feh --bg-fill ~/pictures/game-code.jpg" >> /home/$UN/.xinitrc
echo "exec dwm"  >> /home/$UN/.xinitrc
