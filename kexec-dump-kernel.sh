#!/bin/bash

die() {
        echo "$@"
        exit 1
}

DEFAULT_KERNEL_IMAGE='/boot/vmlinuz-'$(uname -r)
DEFAULT_INITRD='/boot/initramfs-'$(uname -r)'.img'
DEFAULT_ROOT='UUID=cf69d350-2c98-4539-82fd-dfdd06bdac82'

KEXEC_CMD='/usr/local/sbin/kexec'
if [ -z "$KEXEC_CMD" ]; then
	die "kexec command not found. Maybe you should install kexec-tool."
fi

if [ $(id -u) -ne 0 ]; then
	die "You must be root to run this script."
fi

if [ $# -eq 0 ];then
	kernel=$DEFAULT_KERNEL_IMAGE
	initrd=$DEFAULT_INITRD
	root=$DEFAULT_ROOT
else
	if [[ -z "$1" ]] || [[ "$1" != *vmlinuz* ]]; then
		die "The first argument should be a path to the dump-capture kernel image."
	fi	
	if [[ -z "$2" ]] || [[ "$2" != *initramfs* ]]; then
		die "The second argument should be a path to the initrd."
	fi	
	if [[ -z "$3" ]] || [[ "$3" != *UUID* ]] || [[ ! -d "$3" ]]; then
		die "The third argument should be a path to the the root partition."
	fi	
	kernel="$1"
	initrd="$2"
	root="$3"
fi

echo "Loading the dump-capture kernel..."
$KEXEC_CMD -d -p $kernel \
	--initrd=$initrd \
	--append="root=$root 1 irqpoll maxcpus=1 reset_devices"

