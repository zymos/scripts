#!/bin/sh


##################################################
# # Licence: GPLv3 #
##################################################
#
# Name:		isomount.sh
# Author: 	ZyMOS
# Date: 	6/2014
#
# based on http://ubuntuforums.org/archive/index.php/t-1082688.html
# Copywrite Dr Erdal Suvar, Frankfurt Oder, Germany, February 25th, 2009

#config
MNT_POINT1=/mnt/isomount
MNT_POINT2=/mnt/isomount2
MNT_POINT3=/mnt/isomount3

ISO_LINK1=/tmp/iso_image_link1.iso
ISO_LINK2=/tmp/iso_image_link2.iso
ISO_LINK3=/tmp/iso_image_link3.iso



# CODE

ISO_IMAGE=$1

# echo "${ISO_IMAGE}"

if [ -z ${ISO_IMAGE} ]; then
		echo "isomount.sh"
		echo "Desc: gives a normal user the ability to mount ISO images"
		echo ""
        echo "Usage: isomount.sh file_name.iso"
		echo ""
		echo "Mounts to ${MNT_POINT1} or ${MNT_POINT2} or ${MNT_POINT3}"
		echo ""
		echo "To use, following must be in /etc/fstab"
		echo " ${ISO_LINK1} ${MNT_POINT1} auto ro,noauto,loop,user 0 0"
		echo " ${ISO_LINK2} ${MNT_POINT2} auto ro,noauto,loop,user 0 0"
		echo " ${ISO_LINK3} ${MNT_POINT3} auto ro,noauto,loop,user 0 0"
		echo "and the mount points must exist."
		echo ""
		echo "To unmount:"
	    echo "  \$umount ${MNT_POINT1}"
        exit 0;
elif [[ ! -f "$ISO_IMAGE" ]] ; then
        echo "  Error: File DNE, can not mount";
		exit 1;
fi

# Intro
echo "Atempting to mount ISO"

#make sure it is its full path
ISO_IMAGE=`readlink -f "${ISO_IMAGE}"`

# get current mount status
MNT_STATUS=`mount`
MNT_POINT=${MNT_POINT1}
ISO_LINK=${ISO_LINK1}
if [[ -n `echo ${MNT_STATUS} |grep ${MNT_POINT1}` ]]; then
	MNT_STATUS1="TRUE"
	MNT_POINT=${MNT_POINT2}
	ISO_LINK=${ISO_LINK2}
	echo " ${MNT_POINT1} is already mounted, trying ${MNT_POINT2}..."
	if [[ -n `echo ${MNT_STATUS} |grep ${MNT_POINT2}` ]]; then
		MNT_STATUS2="TRUE"
		MNT_POINT=${MNT_POINT3}
		ISO_LINK=${ISO_LINK3}
		echo " ${MNT_POINT2} is already mounted, trying ${MNT_POINT3}..."
		if [[ -n `echo ${MNT_STATUS} |grep ${MNT_POINT3}` ]]; then
			# MNT_STATUS3="TRUE"
			echo " Error: sorry all mount points are already mounted! exiting"
			exit 1
		fi
	fi
fi

# Check to see if you can create the ISO link
if [[ -a ${ISO_LINK} && ! -w ${ISO_LINK} ]]; then
	echo " Error: can not create the ISO link needed for this script to work"
	echo "  You may have run this script as another user, making the link unwritable"
	exit 1
fi

# Linking
ln -sf "${ISO_IMAGE}" ${ISO_LINK}

# Mounting
echo " Mounting ${MNT_POINT} ..."
MOUNT_STATUS=`mount ${MNT_POINT}`
if [[ -n ${MOUNT_STATUS} ]]; then
	echo " Error: mount failed"
	echo " Error output:"
	echo "   ${MOUNT_STATUS}"
	exit 1;
else
	echo " ISO mounted successfully @ ${MNT_POINT}"
	exit
fi
