#!/bin/bash

if [ -z $1 ] ;then
	echo "Usage: smallify-pics-250.sh [directory]"
	echo "bye..."
	exit;
fi

if [ -d $1 ] ;then
	echo "Entering directory..."
	cd $1
	if [ -d "sm" ] ;then
		echo 'Backing up "sm"...'
		mv -f sm/ sm_bak/
	fi
	mkdir -p sm

	echo 'Copying files to "sm"...'
	cp *.* sm/
	
	cd sm
	#touch boobies

	mkdir -p backup
	
	for filename in *.*
	do
		filename_sm=${filename}'_sm.jpg'
		echo "Converting $filename -> $filename_sm ..."
		convert $filename -resize 250x -format jpg $filename_sm
		mv -f $filename backup/
		#rm -f $filename
	done;

fi


echo 'All done.'
exit
