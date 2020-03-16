#!/bin/sh
# rem: xorg-minimal failed to startx
pkg install -y xorg libXft libXinerama
pkg install -y gpu-firmware-kmod
pkg install -y drm-kmod

pkg install -y zathura
pkg install -y zathura-pdf-poppler

# may be all necessary fonts
pkg install -y dejavu
pkg install -y dmenu
