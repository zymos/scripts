#!/usr/bin/perl
#
use Cwd;


#################
# Configs
#

$pic_root="/pub/images/digcam/new";
$tmp_dir="/tmp";
$cam_dir="/store_00010001/DCIM/101CANON";

#################
# Date and Time
#

($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
$year = 1900 + $yearOffset;
$month++;

if ( $month < 10 ) { $month = '0' . $month; }
if ( $dayOfMonth < 10 ) { $dayOfMonth = '0' . $dayOfMonth; }
if ( $hour < 10 ) { $hour = '0' . $hour; }
if ( $minute < 10 ) { $minute = '0' . $minute; }



# creating dir/file names
$arg_string=join('_',@ARGV);
$date_now = "$year\y-$month\m-$dayOfMonth\d--$hour\h-$minute\m";
# print "$year\y-$month\m-$dayOfMonth\d--$hour\h-$minute\m\n";
$date_now_tmp = "gphoto-photos--$year\y-$month\m-$dayOfMonth\d--$hour\h-$minute\m-$second\s";

if ($#ARGV >= 0) {
	$file_name_prefix = "$arg_string-$year\y$month\m$dayOfMonth\d-";
	$last_dir_name = "$year\y-$month\m-$dayOfMonth\d--$hour\h-$minute\m--$arg_string";
} else {
	$file_name_prefix = "$year\y$month\m$dayOfMonth\d-";
	$last_dir_name = "$year\y-$month\m-$dayOfMonth\d--$hour\h-$minute\m";
}

################
# Make dir
#

# some error testing

if ( ! -d $tmp_dir ) { print "*ERROR: temp directory -> $tmp_dir DNE!!!!\n";exit; }
if ( ! -d $pic_root ) { print "*ERROR: root picture dir -> $pic_root DNE!!!!\n";exit; }
# if ( system('which gphoto2' ) print "*ERROR: gphoto2 is not installed!!!\n";exit; }


# Entering and coping to tmp dir
chdir($tmp_dir) || die "*error: bad coding: /some/path ($!)";
mkdir("$date_now_tmp", 0755);
chdir($date_now_tmp) || die "*error: bad coding: /some/path ($!)";
system("gphoto2 --get-all-files");

@file_contents = <*>;
foreach $file (@file_contents) {
	$new_file_name = $file_name_prefix . $file;
	rename($file,$new_file_name);
}

# print "@file_contents\n--------------------\n";
# print "$#file_contents\n\n";


if ($#file_contents == -1) { 
	print "No files dloaded, \n"; 
} else {
	chdir($pic_root);
	foreach $dir_name ($year,$last_dir_name){ #no more month dir
		if (-d $dir_name) {
			chdir($dir_name) || die "*error: entering /some/path ($!)";
			# print "dir $dir_name entered\n";
		} else {
			mkdir("$dir_name", 0755) || die "*error: cannot mkdir newdir: $!";
			chdir($dir_name) || die "*error: entering /some/path ($!)";
			# print "dir $dir_name created\n";
		}
	}

	$tmp_pic_files=$tmp_dir . '/' . $date_now_tmp . '/*';
	system("mv $tmp_pic_files .");
	$cwd=getcwd;
	# print "Photos are now in $cwd\n";	
	system("gphoto2 -D --folder=$cam_dir"); # rm pics on cam
	print "Camera cleared\n";
	print "Photos are now in $cwd\n";
}
# $currDir = `pwd`;
# print $currDir;

#################
# Copying files
#

# system("gphoto2 --get-all-files") || die "*error: maybe no-pics ($!)";



print "Exiting :-)\n";
