#!/usr/bin/perl

#################################################################################
#   			Audiobook Encoder
#
#	Description: reencodes a mp3 into a optimize audiobook mp3 file
#	Specs: 	bitrate: 32kbps; 
#			sample-rate: 22050Hz;
#			bandwidth: 7kHz
#			ID3v2 content type: "Audiobook"
#			Volume nomalized: Yes
#			Backup directory: "original/"
#	Author:	ZyMOS
#	Date: 	17 June 2016
#	License: GPLv2
#	Requirments:
#		LAME MP3 Encoder (http://lame.sourceforge.net/)
#		MP3Gain (http://mp3gain.sourceforge.net/)
#		id3v2 (http://id3v2.sourceforge.net/)
#
#################################################################################




###############
# Config
#

$test = 0;
$log_dir = "/home/zymos/tmp/";
$backup_dir = "/home/zymos/tmp/original_audio_files";


#################################
#  Code
#

use File::Find;
# use File::Path;
use File::Path qw(make_path);
# use Cwd;
use Cwd 'abs_path';


# input must inckude dir
$dirname = $ARGV[0];
if($dirname eq ""){
  print "the first arg is the directory\n";
  exit;
}



sub the_operation {
	my $file = $_;
	my $top_dir = $File::Find::dir;
	$top_dir =~ s/.*\///;
	
	# print "$top_dir\n";

	if( not( $file eq '.' || $file eq '..' ) && $file =~ /\.mp3$/ && $top_dir ne "original") { #make sure its an mp3

		# new file name
		$file2 = $file;
		$file2 =~ s/\.mp3$/-32k.mp3/;
	
		print "Encoding: [$file] in [$top_dir]\n";
			# $out = `avconv -i "$file" -c:a libmp3lame -q:a 9 -ar 22050 -c:v mjpeg "$file2" >/dev/null`;
		# $out = `lame --resample 22050 --lowpass 9 --vbr-old -V 9.5 -B 64 --add-id3v2 "$file" "$file2"`;
		# encoding mp3
		
		if(! $test ){
			$out = `lame --resample 22050 --cbr -b 32 --noreplaygain --lowpass 7 "$file" "$file2"`;

			if($?){ # lame encode failed
				print "ERROR encoding: $file \n";
				print FILE "Fail: $file\n";
				print "EXITING (1)\n";
				exit 1;
			}else{ #lame sucseded
				print FILE "Good: $file2\n";
				$out = `id3v2 --TCON "Audiobook" "$file2"`; # ID3 tag content->"Audiobook"
				$out = `mp3gain "$file2"`;	# replay gain
				if( -e $backup_dir . "/" . $file ){ 
					#if file already exists, move to dup filename
					$dup = $backup_dir . "/" . $file . "-dup.mp3";
					$out = `mv "$file" "$dup"`;
				}else{
					# move original
					$out = `mv "$file" "$backup_dir"`;
				}
				#if( -e $orig_dir . "/" . $file ){ 
				#	#if file already exists, move to dup filename
				#	$dup = $orig_dir . "/" . $file . "-dup.mp3";
				#	$out = `mv "$file" "$dup"`;
				#}else{
				#	# move original
				#	$out = `mv "$file" "$orig_dir"`;
				#}
			}
			print "\n\n\n\n\n\n";
			# $out = `rm -f "$file"`;
			# if($?){
				# print FILE "delprob: $file2\n";
				# print "error deleting: $file";
				# exit 1;
			# }
		}
	}
}



# create log
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year += 1900;
$time_string = "$year-$mon-$mday--$hour-$min";
open FILE, ">>", "$log_dir/audiobook_encode-$time_string.log" or die $!;
print FILE "Started encoding directory: $dirname\n";


print "starting processes....\n";

# create dir for origonals
# $orig_dir = $dirname . "/original";
# mkdir($orig_dir);
# $orig_dir = abs_path($orig_dir);

$backup_dir = abs_path($backup_dir);
$backup_dir = $backup_dir . "/" . $time_string; #global var for the backup_dir
make_path($backup_dir); #create the backup dir

# process each file
find(\&the_operation, $dirname);

# close log
close FILE;
print "Done...\n\n";

