#!/bin/sh
# encoding utf-8
# ------------------------------------------------------------------------------
# --- filename:
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
echo "# Use cfdisk, write dos gpt-table and create the partitions				"
echo "# Please replace ? with the letter of your drive									"
echo "#																																	"
echo "# /dev/sd{?}1 fat32   boot/esp-flag hex:ef00  /boot   <=512MB			"
echo "# /dev/sd{?}2 linuxfs               hex:8300  /root      32GB			"
echo "# /dev/sd{?}3 linuxswap             hex:8200  /swap ram x 2GB			"
echo "# /dev/sd{?}4 preffered linuxfs     hex:8300  /home       ?GB			"
echo "#																																	"
echo "# it depends on your drive and it's up to you how many G					"
echo "# !!! the drive-geometry must be: /boot /root swap /home					"
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

mkfs.vfat -F32 -n EFI /dev/${sdx}1
mkfs.ext4 -L ROOT /dev/${sdx}2
mkswap -L SWAP /dev/${sdx}3
swapon /dev/${sdx}3
mkfs.ext4 -L HOME /dev/${sdx}4

# --- it is IMPERATIV to begin the mount-operation with mounting root ----------
mount /dev/${sdx}2 /mnt

mkdir /mnt/boot
mount /dev/${sdx}1 /mnt/boot

mkdir /mnt/home
mount /dev/${sdx}4 /mnt/home
# ------------------------------------------------------------------------------
pacstrap  /mnt base base-devel linux linux-firmware --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
# ------------------------------------------------------------------------------
# --- adjust localtime ---------------------------------------------------------
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
echo $HN > /mnt/etc/hostname
echo 127.0.0.1   localhost localhost.ap.local  >> /mnt/etc/hosts
echo ::1                                       >> /mnt/etc/hosts
echo 127.0.0.1  "$HN"  "$HN".ap.local          >> /mnt/etc/hosts
# ------------------------------------------------------------------------------
# --- let's give root a password
echo Password for root:
arch-chroot /mnt passwd
# --- start dhcp service at boot-time ------------------------------------------
arch-chroot /mnt  pacman -S dhcpcd
arch-chroot /mnt  systemctl enable dhcpcd
# ------------------------------------------------------------------------------
# --- add the default user and adjust sudoers ----------------------------------
arch-chroot /mnt  useradd -m -g users -s /bin/bash $DU
arch-chroot /mnt  echo Password for $DU
arch-chroot /mnt  passwd "$DU"

echo "Adjusting the SUDOERS-file!"
echo "$DU ALL=(ALL) ALL"        >> /mnt/etc/sudoers
sed -i -- 's/# %wheel/%wheel/g'    /mnt/etc/sudoers
# --- add some useful tools ----------------------------------------------------
arch-chroot /mnt  pacman -S sudo bash-completion vim ranger vifm  --noconfirm
arch-chroot /mnt  pacman -S inetutils wget openssh git curl htop tmux --noconfirm
arch-chroot /mnt  pacman -S rsync cifs-utils dos2unix recode neofetch  --noconfirm
arch-chroot /mnt  systemctl enable sshd.service
# ------------------------------------------------------------------------------
# --- let's install bootctl
# arch-chroot /mnt mkinitcpio -p linux seemed not necessary
arch-chroot /mnt bootctl install

echo default arch >  /mnt/boot/loader/loader.conf
echo timeout 3    >> /mnt/boot/loader/loader.conf
echo editor 0     >> /mnt/boot/loader/loader.conf

echo title   ARCH LINUX UEFI        > /mnt/boot/loader/entries/arch.conf
echo linux   /vmlinuz-linux        >> /mnt/boot/loader/entries/arch.conf
echo initrd  /initramfs-linux.img  >> /mnt/boot/loader/entries/arch.conf
echo options root=LABEL=ROOT rw    >> /mnt/boot/loader/entries/arch.conf
# ------------------------------------------------------------------------------

echo +++ DONE! We UMOUNT! and REBOOT! Please install the desired DESKTOP!
read -p "Press any key to continue!"

umount -a
reboot
