#!/bin/sh
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename: inst-al-mbr.sh
# --- last ver: 2020-03-11
# ---   author: p. andree
# ------------------------------------------------------------------------------

clear
# --- let's agree upon some variables ------------------------------------------
kmap="de_CH-latin1"
pclang="de_CH.UTF-8"
# ------------------------------------------------------------------------------
# --- keymap, updating and mirrorlist before starting---------------------------
loadkeys $kmap
pacman -Sy --noconfirm
pacman -S reflector --noconfirm
reflector --verbose --latest 6 --country 'Switzerland' --sort rate --save /etc/pacman.d/mirrorlist
echo +++ DONE: keyboard, sync, update, fastest mirror!
read -p "Press any key to continue!"

clear
# --- this is a script for a fast way to install ArchLinux ---------------------
# ------------------------------------------------------------------------------
echo "################## Install Script for ArchLinux ##################"
echo "#																																	"
echo "# Use cfdisk, write dos part-table and create the partitions			"
echo "# Please replace ? with the letter of your drive									"
echo "#             /dev/sd{?}1    bootflag    /root    32GB						"
echo "#             /dev/sd{?}2                /swap    ram x 2 GB			"
echo "#             /dev/sd{?}3                /home    ?GB							"
echo "# it depends on your drive and it's up to you how many GB					"
echo "# ! the drive-geometry must be the same: /root /swap /home				"
echo "# by 'lsblk' figure out the drive sda, sdb, sdc, ...							"
echo "##################################################################"
# --- information about the drive to install ARCH ------------------------------
printf "### The drive ArchLinux to be installed: "
read sdx
# --- let's give our computer the right name -----------------------------------
printf "### Hostname: "
read HN
# --- add one user as defaultuser ----------------------------------------------
printf "### Add a defaultuser (not root): "
read DU
# ------------------------------------------------------------------------------
cfdisk /dev/$sdx
mkfs.ext4 /dev/${sdx}1
mkswap /dev/${sdx}2
swapon /dev/${sdx}2
mkfs.ext4 /dev/${sdx}3

mount /dev/${sdx}1 /mnt
mkdir /mnt/home
mount /dev/${sdx}3 /mnt/home
# ------------------------------------------------------------------------------
pacstrap  /mnt base base-devel linux linux-firmware --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
# ------------------------------------------------------------------------------
# --- adjust localtime -------------------------------------------------------
# rm /mnt/etc/localtime
arch-chroot /mnt  ln -s /usr/share/zoneinfo/Europe/Zurich /etc/localtime
arch-chroot /mnt  hwclock --systohc --utc
# ------------------------------------------------------------------------------
# --- adjust local LANG, KEYMAP
# sed -i -- 's/#$pclang/'$pclang'/g' /mnt/etc/locale.gen
echo $pclang UTF-8 >> /mnt/etc/locale.gen
arch-chroot /mnt  locale-gen
echo LANG=$pclang    >> /mnt/etc/locale.conf
echo KEYMAP=$kmap    >> /mnt/etc/vconsole.conf
# ------------------------------------------------------------------------------
# --- adjust hostname and hosts
echo "$HN" > /mnt/etc/hostname
echo 127.0.0.1   localhost localhost.ap.local  >> /mnt/etc/hosts
echo ::1                                       >> /mnt/etc/hosts
echo 127.0.0.1  "$HN"  "$HN".ap.local          >> /mnt/etc/hosts
# ------------------------------------------------------------------------------
# --- let's give root a password
echo Password for root:
arch-chroot /mnt passwd
# ------------------------------------------------------------------------------
arch-chroot /mnt mkinitcpio -p
# ------------------------------------------------------------------------------
# --- let's install grub and configure it
arch-chroot /mnt  pacman -S grub --noconfirm
arch-chroot /mnt  grub-install /dev/$sdx
arch-chroot /mnt  grub-mkconfig -o /boot/grub/grub.cfg
# ------------------------------------------------------------------------------
# --- start dhcp service at boot-time ------------------------------------------
arch-chroot /mnt  pacman -S dhcpcd --noconfirm
arch-chroot /mnt  systemctl enable dhcpcd.service
# ------------------------------------------------------------------------------
# --- add the default user and adjust sudoers ----------------------------------
arch-chroot /mnt  useradd -m -g users -s /bin/bash $DU
arch-chroot /mnt  echo Password for $DU
arch-chroot /mnt  passwd "$DU"

echo "Adjusting the SUDOERS-file!"
echo "$DU ALL=(ALL) ALL"        >> /mnt/etc/sudoers
sed -i -- 's/# %wheel/%wheel/g'    /mnt/etc/sudoers
# --- add some useful tools ----------------------------------------------------
arch-chroot /mnt  pacman -S sudo bash-completion vim vifm ranger --noconfirm
arch-chroot /mnt  pacman -S inetutils wget openssh git htop tmux --noconfirm
arch-chroot /mnt  pacman -S rsync cifs-utils dos2unix recode neofetch  --noconfirm
arch-chroot /mnt  systemctl enable sshd.service
umount -R /mnt
echo +++ DONE! We will REBOOT! Please install the desired DESKTOP!
read -p "Press any key to continue!"
reboot
