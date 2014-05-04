#!/bin/bash

make mrproper
make O=/home/larmbr/linux_build && 
make O=/home/larmbr/linux_build modules_install && 
make O=/home/larmbr/linux_build install

grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
