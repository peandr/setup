#!/bin/sh

mkdir /home/peandr/src/
cd /home/peandr/src/
git clone https://git.suckless.org/dwm
git clone https://github.com/LukeSmithxyz/st.git

cd dwm
cp config.mk config.mk.ori
sed -i .tmp 's/X11R6/local/g' config.mk
sed -i .tmp 's/include\//local\/include\//g' config.mk
rm *.mk.tmp
make install clean
cd 

cd /home/peandr/src/st
cp config.mk config.mk.ori
sed -i .tmp 's/X11R6/local/g' config.mk
rm *.mk.tmp
make install clean
cd

