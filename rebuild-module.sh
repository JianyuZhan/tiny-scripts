#!/bin/bash

#dir_list=$(find /usr/share -maxdepth 1  -type d -name "VirtualBox-kmod*")
#if [ -z $dir_list ]; then
#    echo "No module directories found! Bail out!"
#    exit 1
#fi
#newest=

BASE_MODULE_DIR=/usr/share/VirtualBox-kmod-4.3.10/VirtualBox-kmod-4.3.10
TO_BUILD_MODULES=$(cat /etc/modules-load.d/VirtualBox.conf)

if [ $(id -u) -ne 0 ]; then
    echo "You must be root to run this script."
    exit 1
fi 

for i in $TO_BUILD_MODULES
do
    if [ -d $BASE_MODULE_DIR/$i ]; then
        echo -n "Building $i..."
        cd $BASE_MODULE_DIR/$i
	(make && make install) > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    echo OK
	else
	    echo "Failed!"
	    exit 1
	fi
    else
	echo "Module $i not found! Bail out!"
	exit 2
    fi
done

echo "Reloading the kernel module..."
systemctl restart systemd-modules-load.service && echo Done || echo Failed

