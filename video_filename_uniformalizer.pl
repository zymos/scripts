#!/usr/bin/perl 

##################################
# Name: Video filename uniformalizer
# Version: 0.3
# Creator: Jeff Israel
# Date: 12 Jan, 2010
# License: GPL 3.0
# Description: This script renames files in a dir to a standard
#  format
# Requirements: perl 
#
# Usage: video_filename_uniformalizer.pl [video directory]
# Example: video_filename_uniformalizer.pl /pub/video/tv/castle/
#
# Output naming format: [title].[season][episode].[episode name].[extension]
# Example: the.good.guy.0102.the.math.test.avi
#
#

##################################
# Configure
#

$test = 0;

@fileExt = ("avi","rm","mpg","mpeg","asf","ram","wmv","mp4","ogg",'ogm',"m4v","mkv",'rmvb','mov','divx');

# Pre transform
# '\(1\)','\(1\)','\(ipod\)','\[bt\]','\[fixed\]','\[tvm\]','\[vpc\]','\[vtv\]','\{c_p\}',

@commonRemovalPre = ('^\[...\]\W'); #Operates before lowercase de-special char

@commonRemoval = ('xvid\.0tv','xvid\.2hd','xvid\.aaf','xvid\.angelic','xvid\.fov','xvid\.river','xvid\.sfm','xvid\.stfu','xvid\.xor','xvid\.notv','xvid\.bwb','xvid\.fever','xvid\.lol','hdtv\.2hd','hdtv\.lol','hdtv\.aaf','hdtv\.bia','hdtv\.ctu','hdtv\.ctu','hdtv\.fqm','hdtv\.lol','hdtv\.xor','hdtv\.yestv','pdtv\.angelic','pdtv\.lol','pdtv\.river','pdtv\.saints','pdtv\.sfm','divx\.svm','divx\.tv','dsr\._loki','dsr\.lol','dsr\.umd','dsrip\.0tv','dsrip\.0tv','dsrip\.stfu','0tv','2hd','[0-9][0-9][0-9]kbps','a4e','aaf','ac3','avi_sm','digitaldistractions','divx','divx5.1.1','dsrip','dvdrip','eztv','fqm\.sharconnector','h264','hdtv','hqtv','ipod\.mpg','ipod\.mpg4','ipodnova\.net','ipodnova\.tv','ipodtvnova\.com','irc\.tveps\.net','niteshdw','pdtv','proper_hdtv','spcomplete\.com','spepisode','tvrip','videoseed\.com','www\.mrtwig\.net','www\.southparkx\.net','x264','xor','xvid','yestv','yg\.divx4s','lol\.vtv','fqm\.vtv','fqm','dvdscr','p0w4','vtv','dbnl','1080p','720p','dd5.1','h264','x264','it00nz','ctrlhd','web.dl');


if($ARGV[0] eq ""){
  print "the first arg is the directory\n";
  exit;
}

sub isVideo {	
	# doo
	my $filename = $_[0];
	foreach $ext (@fileExt) {
		if ($filename =~ /$ext$/i) {
#			print "$ext: $filename: match\n";
			return 1;
		} else {
#			print "$ext: $filename: no match\n";
		}
	}
	0;
}
	
sub renamer {
	# poo
	my $oldname = $_[0];

	foreach $removal (@commonRemovalPre) { #remove all the common tags
		$oldname =~ s/($removal)/./i;
	}
	
	$oldname =~ s/[\'\`]s/s/g;# changes aposterphy s to just s
	$oldname =~ s/[-_,\[\]\(\)\.\s\!]/./g; #all special chars to .
	$oldname =~ tr/A-Z/a-z/; #lowercase
	
	foreach $removal (@commonRemoval) { #remove all the common tags
		$oldname =~ s/\.($removal)\././i;
	}

	$oldname =~ s/s0([0-9])e([0-9]{2})/.\1\2./; # s01e01 to 101
	$oldname =~ s/\.([0-9]{1,2})x([0-9]{2})\./.\1\2./; # 1x01 to 101
	$oldname =~ s/s([0-9]{2})\.e([0-9]{2})/.\1\2./;	# s10_e01 to 1001
	$oldname =~ s/s([0-9]{2})e([0-9]{2})/.\1\2./; # s10e01 to 1001
	$oldname =~ s/\.([0-9]{3})\./.0\1./; # 101 to 0101

	# I removed this because of bug listed below, now use method above
	# $oldname =~ s/\.([0-9])x([0-9]{2})\./.s0\1e\2./; # 1x01 to s01e01 
	# $oldname =~ s/\.([0-9]{2})x([0-9]{2})\./.s\1e\2./; # 11x01 to s11e01
	# $oldname =~ s/s([0-9]{2})\.e([0-9]{2})/.s\1e\2./;	# s10.e01 to s10e01
	# $oldname =~ s/([0-9]{2})([0-9]{2})/.s\1e\2./;	# 1101 to s11e01
	# $oldname =~ s/([0-9])([0-9]{2})/.s0\1e\2./;	# 101 to s01e01
	# one bug, if title is Castle 1990 103, it would switch to s19e90
	

	# $oldname =~ s/^([0-9])/south_park_\1/;
    for ($x=0;$x<=$#findit;$x++){
    	$oldname =~ s/@findit($x)/@replaceit($x)_/i;
		# print "peep-";
    }


	
	$oldname =~ s/\.+/\./g; # removes double dots
	$oldname =~ s/^\.//; # removes initail dots

	#some personal stuff
	$oldname =~ s/^v\.a\.//;
	$oldname =~ s/\.avi\.avi$/.avi/;
	$oldname =~ s/\.sm\.mkv$/.mkv/;
	$oldname =~ s/\.sm\.mp4$/.mp4/;
	$oldname =~ s/southpark/south_park/;
	$oldname =~ s/^backup\.//;
	#if($oldname =~ /^house\.[0-9]/ ){
	#	$oldname =~ s/^house/house.md/;
	#}
	# $oldname =~ s/south_park([0-9])/south_park_\1/;

	$oldname;
}

sub reext {
		my $fname = $_[0];
		$fname =~ s/_([a-z0-9]{2,4})$/\.\1/;
		$fname;
}

print "Starting the renaming\n";


opendir(DIR, "$ARGV[0]");
$x = 0;
@file_list = ();
while (defined($dir = readdir(DIR))) {
#	print "$dir";
	if ( $dir ne '.' && $dir ne '..' && not -d $dir ) {
		$file_list[$x] = $dir;
		$x++;
	}
}
closedir(DIR);


foreach $dir (@file_list){
  if ( isVideo($dir) ) { 

	# print "---$dir\n";
	
	$newname = renamer($dir);
	$newnewname = reext($newname);

	$dir =~ s/\`/\\\`/g; #deal with filenames with backtics in them
	if ( $dir ne $newnewname ) {
		print "Moving:\n$dir\nTo:\n$newnewname\n\n";	
		if(!$test) {
			system("mv \"$ARGV[0]/$dir\" \"$ARGV[0]/$newnewname\"");
		}
	} else {
		print "File: $dir\n";
		print "No change needed.\n\n";
	}
  } else {
	print "File: $dir\n";
	print "non-video file\n\n";
  }	
 
}


print "\n";



