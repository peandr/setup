#!/bin/bash
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: al-post-config.sh
# --- last ver: 2020-03-10
# ---   author: p. andree
# ------------------------------------------------------------------------------

clear
WWWHN=raspi
echo " ----------------------------------------------------------------------- "
echo " `uname -a`"

UN=""
echo " ----------------------------------------------------------------------- "
echo " Config Script for post-install!"
echo " Hostname: $HOSTNAME"
echo " ----------------------------------------------------------------------- "
read -p " Username: " UN

if [ -d /home/$UN/ ]; then
  # --- clone the dotfiles-repo ----------------------------------------------
  wget https://raw.github.com/peandr/dotfiles/master/linux-dotfiles.tar.gz
  if [ ! -d /home/$UN/.config/  ]; then
		mkdir /home/$UN/.config
  fi
  tar -C /home/$UN/.config/ -xvf linux-dotfiles.tar.gz
  rm /home/$UN/git/linux-dotfiles.tar.gz
  # --------------------------------------------------------------------------

  # --- config BASH for root and user
  POWERLINEPATH=`sudo find /usr -name powerline.sh | grep 'bash'`
  sudo sed -i "s|powerlinepath|$POWERLINEPATH|g" /home/$UN/.config/bash/.xtra
  if [ ! -f /etc/bash.bashrc.ori ]; then
    sudo cp /etc/bash.bashrc /etc/bash.bashrc.ori
  fi
	sudo cp /etc/bash.bashrc.ori /etc/bash.bashrc
  sudo bash -c "echo ""source /home/$UN/.config/bash/.aliases"" >> /etc/bash.bashrc"
  sudo bash -c "echo ""source /home/$UN/.config/bash/.exports"" >> /etc/bash.bashrc"
  sudo bash -c "echo ""source /home/$UN/.config/bash/.functions"" >> /etc/bash.bashrc"
  sudo bash -c "echo ""source /home/$UN/.config/bash/.prompt"" >> /etc/bash.bashrc"
  sudo bash -c "echo ""source /home/$UN/.config/bash/.xtra"" >> /etc/bash.bashrc"

	if [ ! -f /root/.bashrc ]; then
		touch /root/.bashrc
	fi
	if [ ! -f /root/.bashrc.ori ]; then
  	sudo mv /root/.bashrc /root/.bashrc.ori
	else
		sudo mv /root/.bashrc.ori /root/.bashrc
  fi
	sudo bash -c "echo ""source /etc/bash.bashrc"" >> /root/.bashrc"
  #

  if [ ! -f /home/$UN/.bashrc.ori ]; then
    mv /home/$UN/.bashrc /home/$UN/.bashrc.ori
	else
		mv /home/$UN/.bashrc.ori /home/$UN/.bashrc
  fi
	echo "source /etc/bash.bashrc" >> /home/$UN/.bashrc
  # --------------------------------------------------------------------------

  # --- config VIMRC for root and user ---------------------------------------
  if [ -f /root/.vimrc ]; then
    sudo rm /root/.vimrc
  fi
  sudo ln -sf /home/$UN/.config/vim/vimrc-root /root/.vimrc

  if [ -f /home/$UN/.vimrc ]; then
    rm /home/$UN/.vimrc
  fi
  ln -sf /home/$UN/.config/vim/vimrc-$UN /home/$UN/.vimrc

  #
  # --- if tex is installed we need VIMRC-TEX-SEC ---------------------------
  which tex &> /dev/null
  if [ $? -eq 0 ]; then
	echo "source /home/$UN/.config/tex/vimrc-tex-sec" >> /home/$UN/.config/vim/vimrc-$UN
  fi
  #
  if [ ! -d /home/$UN/.vim/ ]; then
    mkdir /home/$UN/.vim
  fi
  # --- adjust UMLAUTE, only for german -------------------------------------
  if [ ! -d /home/$UN/.vim/plugin/ ]; then
   mkdir /home/$UN/.vim/plugin
  fi
  #
  # --- config TMUX for root and user  --------------------------------------
  POWERLINEPATH=`sudo find /usr -name powerline.conf | grep 'tmux'`
  sudo sed -i "s|powerlinepath|$POWERLINEPATH|g" /home/$UN/.config/tmux/tmux.conf

  if [ -f /root/.tmux.conf ]; then
    sudo rm /root/.tmux.conf
  fi
  sudo ln -sf /home/$UN/.config/tmux/tmux.conf  /root/.tmux.conf
  if [ -f /home/$UN/.tmux.conf ]; then
    sudo rm /home/$UN/.tmux.conf
  fi
  ln -sf /home/$UN/.config/tmux/tmux.conf  /home/$UN/.tmux.conf
  #
  # --- config ranger, vifm for root ----------------------------------------
  if [ ! -d /root/.config/  ]; then
    sudo mkdir /root/.config
  fi
  if [ -d /root/.config/ranger/ ]; then
    sudo rm ranger
  fi
  sudo ln -sf /home/$UN/.config/ranger /root/.config
  if [ -d /root/.config/vifm/ ]; then
    sudo rm /root/.config/vifm
  fi
  sudo ln -sf /home/$UN/.config/vifm /root/.config
  #
  # --- instal PLUG for VIM -------------------------------------------------
  curl -fLo /home/$UN/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  # --- prepare the PLUGIN- and COC.NVIM install ----------------------------
  sudo curl -sL install-node.now.sh | sudo bash
  curl --compressed -o- -L https://yarnpkg.com/install.sh | bash && yarn
  vim +PlugInstall +qall
  #
  # --- put the folder UltiSnips in the right place -------------------------
  mv /home/$UN/.config/vim/UltiSnips /home/$UN/.vim/plugged/ultisnips

	# --- neofetch for root ---------------------------------------------------
	[ ! -d /root/.config/neofetch/ ] && sudo mkdir /root/.config/neofetch
	sudo ln -sf /home/peandr/.config/neofetch/config.conf /root/.config/neofetch/config.conf

	wget http://$WWWHN/sh/mount-share-linux.sh
	chmod 700 mount-share-linux.sh
	mkdir -p /home/$UN/.local/sh
	mv mount-share-linux.sh /home/$UN/.local/sh/mount-share.sh

	sudo reboot
else
  echo " User $UN does NOT exist on host $HOSTNAME!"
fi
