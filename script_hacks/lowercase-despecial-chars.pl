#!/usr/bin/perl -w
#

# Config
$test = 0;
$disableExt = 0;

@fileExt = ("avi","rm","mpg","mpeg","asf","ram","wmv","mp4","ogg","m4v","rmvb","mp3"."wav","mp2","au","ram","wma","ogm");

@commonRemoval = ('a4e','YG_DivX4s','DivX_TV','divx-svm','xvid-stfu','xvid-aaf','xvid-fov','xvid-sfm','xvid-xor','xvid-river','xvid-angelic','xvid-0tv','xvid-2hd','hdtv-xor','HDTV-CTU','PROPER_hdtv','hdtv-2HD','HDTV-YESTV','HDTV-CTU','HDTV-AAF','HDTV-BIA','PDTV-RIVER','HDTV-FQM','HDTV-LOL','PDTV-ANGELIC','PDTV-SAINTS','PDTV\.SFM','DSRIP-0TV','DSRIP-0TV','divx5.1.1','divx','xvid','digitaldistractions','www\.mrtwig\.net','irc\.tveps\.net','www\.southparkx\.net','fqm\.sharconnector','spepisode','Videoseed\.com','iPodNova\.net','iPodNova\.tv','iPodTVNova\.com','Videoseed_com','iPodNova_net','ipodnova_tv','dsr_lol','avi_sm','spcomplete_com','dsr_umd','ipod_mpg4','ipod_mpg','dsr_loki','dsrip-stfu','pdtv-lol','DVDRip','dvdrip','dsrip','HQTV','HDTV','PDTV','YesTV','TVrip','eztv','ac3','-sfm-','NiteShdw','\[fixed\]','\[VTV\]','\[bt\]','\[tvm\]','\[vpc\]','\{C_P\}','\(1\)','\(iPod\)','x264','h264','[0-9][0-9][0-9]kbps');

if($ARGV[0] eq ""){
  print "the first arg is the directory\n";
  exit;
}

sub isVideo { #if I wanted to only do videos	
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
	my $oldname = $_[0];
	
	$oldname =~ tr/A-Z/a-z/;
	foreach $removal (@commonRemoval) {
		$oldname =~ s/($removal)/_/i;
	}

#	$outname =~ s/\.([a-z]{2,4})$/\1/;

	$oldname =~ s/[_\!\[\]\(\)\.\s]/_/g;

#	$oldname =~ s/s0([0-9])e([0-9]{2})/_\1\2_/;
#	$oldname =~ s/_([0-9]{1,2})x([0-9]{2})_/_\1\2_/;
#	$oldname =~ s/s([0-9]{2})_e([0-9]{2})/_\1\2_/;
#	$oldname =~ s/s([0-9]{2})e([0-9]{2})/_\1\2_/;
#	$oldname =~ s/^([0-9])/south_park_\1/;

	for ($x=0;$x<=$#findit;$x++){
                $oldname =~ s/@findit($x)/@replaceit($x)_/i;
		print "peep-";
        }

#	$oldname =~ s/southpark/south_park/;
#	$oldname =~ s/south_park([0-9])/south_park_\1/;

	$oldname =~ s/_+/_/g;
	$oldname =~ s/_-_/-/g;
	$oldname =~ s/^_//;
	$oldname;
}

sub reext {
		my $fname = $_[0];
		$fname =~ s/_([a-z0-9]{2,4})$/\.\1/;
		$fname;
}

print "starting processes....\n";

opendir(DIR, "$ARGV[0]");

while (defined($dir = readdir(DIR))) {
#	print "$dir";
  # if($dir eq "." || $dir eq ".."){
	  # ignore
  # }elsif ( isVideo($dir) || $disableExt )  { 
	#print "---$dir\n";
	$newname = renamer($dir);
	$newnewname = reext($newname);
	if($dir eq $newnewname){
		print "\nNo change: $dir";
	}else{
		print "\nMoving: $dir  -->  $newnewname\n";	
		if(!$test) {
			system("mv \"$ARGV[0]/$dir\" \"$ARGV[0]/$newnewname\"");
		}
	}
  # } else {
	  # print "Not a know extention: $dir\n";
  # }	
  
}

closedir(DIR);
print "\n\nDone...\n\n";

