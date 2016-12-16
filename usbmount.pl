#!/usr/bin/perl


##################################################
# # Licence: GPLv3 #
##################################################
# based on http://ubuntuforums.org/archive/index.php/t-1082688.html
# Copywrite Dr Erdal Suvar, Frankfurt Oder, Germany, February 25th, 2009. #

# add to /etc/fstab
# /tmp/usb_dev_link1.iso	/mnt/usb_mount	auto	defaults,user,noauto	0 0

#config
$MNT_POINT1='/mnt/usb_mount';
$MNT_POINT2='/mnt/usb_mount2';
$MNT_POINT3='/mnt/usb_mount3';

$USB_LINK1='/tmp/usb_dev_link1';
$USB_LINK2='/tmp/usb_dev_link2';
$USB_LINK3='/tmp/usb_dev_link3';

# devices to ignore, comma seperated "sda,sdb"
$IGNORE_DEV="sda";

# CODE

# print "${USB_IMAGE}";

if( $1 eq "-h" ){
		print "usbmount.pl";
		print "Desc: gives a normal user the ability to mount ISO images";
		print "";
        print "Usage: usbmount.pl";
		print "";
		print "Mounts to ${MNT_POINT1} or ${MNT_POINT2} or ${MNT_POINT3}";
		print "";
		print "To use, following must be in /etc/fstab";
		print " ${USB_LINK1} ${MNT_POINT1} auto ro,noauto,loop,user 0 0";
		print " ${USB_LINK2} ${MNT_POINT2} auto ro,noauto,loop,user 0 0";
		print " ${USB_LINK3} ${MNT_POINT3} auto ro,noauto,loop,user 0 0";
		print "and the mount points must exist.";
		print "";
		print "To unmount:";
	    print "  \$umount ${MNT_POINT1}";
        exit 0;
}

# Intro
print "Displaying removable devices...\n";

# $available_partitions=`cat /proc/partitions |sed 's/.* //'`;

# $part_list = '';
# open(FILE, "</proc/partitions");
# while (<FILE>) { 
	# my $part_line = $_; 	
	# if( $part_line =~ / sd/ ){
		# $part_line =~ s/.* //;
		# my @ignored_list = split(/\,/, $IGNORE_DEV);
		# print "$ignored_list[0]";
		# foreach $ignored (@ignored_list){
			# print "$IGNORE_DEV $ignored_list $part_line";
			# if( ! $part_line =~ $ignored ){
				# $part_list .= " /dev/$part_line\n";
			# }
		# }
	# }
# }
# close(FILE);

# print $available_partitions;

$part_list=`lsblk --noheadings --output KNAME,SIZE,RM | egrep \'1\$\' | sed \'s/1\$//\' | sed \'s/^/\\/dev\\//\'`;

$cur_mount=`mount`;
# print $cur_mount;

if($cur_mount !~ /$MNT_POINT1 /s ){
	# print "$MNT_POINT1\n";
	$mnt_point = $MNT_POINT1;
	$mnt_link = $USB_LINK1;
}elsif( $cur_mount !~ /$MNT_POINT2 /s ){
	# print "$MNT_POINT2\n";
	$mnt_point = $MNT_POINT2;
	$mnt_link = $USB_LINK2;
}elsif( $cur_mount !~ /$MNT_POINT3 /s ){
	# print "$MNT_POINT3\n";
	$mnt_point = $MNT_POINT3;
	$mnt_link = $USB_LINK3;
}else{
	print "Out of USB mount points, try unmounting some\n";
	exit 1;
}


print $part_list . "\n";;
print "Enter desired partition to mount: /dev/sd";
chomp($mount_part = <>);


print "\nCreating sym link to /dev/sd$mount_part...\n";

# print("ln -sf /dev/sd$mount_part $mnt_link\n");
system("ln -sf /dev/sd$mount_part $mnt_link");

print "Mounting: /dev/sd$mount_part to $mnt_point\n";

# print("mount $mnt_point\n");
system("mount $mnt_point");

print "to unmount type: umount $mnt_point\n";


exit;

