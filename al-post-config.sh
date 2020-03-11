#!/bin/bash
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: al-post-config.sh
# --- last ver: 2020-03-10
# ---   author: p. andree
# ------------------------------------------------------------------------------

clear
UN=""
echo " --------------------------------------------------------- "
echo " Config Script for post-install!"
echo " Hostname: $HOSTNAME"
echo " --------------------------------------------------------- "
echo " Hostname: $HOSTNAME"
read -p " Username: " UN

if [ -d /home/$UN/ ]; then
	if [ ! -d /home/$UN/share/ ]; then
		wget http://raspberrypi/al/mount-share.sh
		chmod 700 mount-share.sh
		mkdir share
		sudo ./mount-share.sh
	fi

	if [ ! -d /home/$UN/.config/  ]; then
		mkdir /home/$UN/.config
	fi
	cp -r ~/share/how-to-files/dotfiles/* .config/

	# --- config BASH for root and user
	POWERLINEPATH=`sudo find /usr -name powerline.sh | grep 'bash'`
	sudo sed -i "s|powerlinepath|$POWERLINEPATH|g" ~/.config/bash/bashrc-glob
	if [ ! -f /etc/bash.bashrc.ori ]; then
		sudo cp /etc/bash.bashrc /etc/bash.bashrc.ori
	fi
	sudo cp /etc/bash.bashrc.ori /etc/bash.bashrc
	sudo bash -c "echo ""source /home/$UN/.config/bash/bashrc-glob"" >> /etc/bash.bashrc"
	#
	if [ ! -f ~/.bashrc.ori ]; then
		sudo cp ~/.bashrc ~/.bashrc.ori
	fi
	cp ~/.bashrc.ori ~/.bashrc
	echo "source ~/.config/bash/.bashrc-pa" >> ~/.bashrc
	#
	# --- config VIMRC for root and user --------------------------------------------
	sudo ln -sf /home/$UN/.config/vim/vimrc-root /root/.vimrc
	ln -sf /home/$UN/.config/vim/vimrc-$UN ~/.vimrc

	if [ ! -f ~/.vimrc.ori ]; then
		sudo cp ~/.vimrc ~/.vimrc.ori
	fi
	cp ~/.vimrc.ori ~/.vimrc

	# --- if tex is installed we need VIMRC-TEX-SEC ---------------------------------
	which tex &> /dev/null
	if [ $? -eq 0 ]; then
		echo "source ~/.config/tex/vimrc-tex-sec" >> ~/.config/vim/vimrc-$UN
	fi
	#
	if [ ! -d /home/$UN/.vim/ ]; then
	mkdir /home/$UN/.vim
	fi

	# --- adjust UMLAUTE, only for german -----------------------------------------
	if [ ! -d /home/$UN/.vim/plugin/ ]; then
	mkdir /home/$UN/.vim/plugin
	fi
	mv /home/$UN/.config/vim/html-umlaute.vim ~/.vim/plugin

	# --- config TMUX for root and user  ------------------------------------------
	POWERLINEPATH=`sudo find /usr -name powerline.conf | grep 'tmux'`
	sudo sed -i "s|powerlinepath|$POWERLINEPATH|g" ~/.config/tmux/tmux.conf
	sudo ln -sf /home/$UN/.config/tmux/tmux.conf  /root/.tmux.conf
	ln -sf /home/$UN/.config/tmux/tmux.conf  /home/$UN/.tmux.conf

	# --- config ranger, vifm for root --------------------------------------------
	if [ ! -d /root/.config/  ]; then
		sudo mkdir /root/.config
	fi
	sudo ln -sf /home/$UN/.config/ranger /root/.config
	sudo ln -sf /home/$UN/.config/vifm /root/.config

	# --- instal PLUG for VIM -----------------------------------------------------
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	# --- prepare the PLUGIN- and COC.NVIM install --------------------------------
	sudo curl -sL install-node.now.sh | sudo bash
	curl --compressed -o- -L https://yarnpkg.com/install.sh | bash && yarn
	vim +PlugInstall +qall

	# --- put the folder UltiSnips in the right place -----------------------------
	mv /home/$UN/.config/vim/UltiSnips ~/.vim/plugged/ultisnips
else
	echo " User $UN does NOT exist on host $HOSTNAME!"
fi
