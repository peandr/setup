#!/usr/local/bin/bash
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: al-post-config.sh
# --- last ver: 2020-03-10
# ---   author: p. andree
# ------------------------------------------------------------------------------

clear
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
  wget  https://raw.github.com/peandr/dotfiles/master/fbsd-dotfiles.tar.gz
  if [ ! -d /home/$UN/.config/  ]; then
	  mkdir /home/$UN/.config
  fi
  tar -C /home/$UN/.config/ -xvf fbsd-dotfiles.tar.gz
  sudo rm -r fbsd-dotfiles.tar.gz
  rm /home/$UN/.config/fbsd-dotfiles.tar.gz
  # --------------------------------------------------------------------------

  # --- config BASH for root and user ----------------------------------------
	grep 'source' /home/$UN/.bash_profile
	if [ $? -ne 0 ]; then
    echo "source /home/$UN/.config/bash/bashrc-glob" >> /home/$UN/.bash_profile
    echo "source /home/$UN/.config/bash/.bashrc-pa" >> /home/$UN/.bash_profile
  fi
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
  which tex > /dev/null
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
  if [ ! -f /home/$UN/.vim/plugin/html-umlaute.vim ]; then
    mv /home/$UN/.config/vim/html-umlaute.vim /home/$UN/.vim/plugin
  fi
  #
  # --- config TMUX for root and user  --------------------------------------
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
  #sudo reboot
else
  echo " User $UN does NOT exist on host $HOSTNAME!"
fi
