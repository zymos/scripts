#!/usr/bin/perl 
#
use Time::HiRes qw ( time );
##################################
# Name: Video directory Smallifier
# Version: 0.2
# Creator: Jeff Israel
# Date: Oct 21, 2009
# License: GPL 3.0
# Description: This script reduces the file size of every video file 
#  in a directory
# Requirements: 
# Usage: video_dir_smallify.pl [video directory]
# Example: video_dir_smallify.pl /pub/video/tv/castle/

##################################
# Configure




$video_output_dir = 'small'; # where the new videos go, relative dir, example input='videos/' output='videos/small/'
$min_file_size =10; # skips encoding video if small than x in MB, recomended 150MB for 1h videos, 100MB for 30m videos 


$log_file = '/tmp/video_dir_smallify.log';

@video_file_extentions = ("avi","rm","mpg","mpeg","asf","ram","wmv","mp4","ogg",'ogm',"m4v","mkv",'rmvb','mov','divx','flv'); #will only encode files with these extensions

$niceness="nice -n 19 ionice -c2 -n7";

$encoder_cmd="avconv";

$vcodec="-vcodec libx264 -crf 23 -threads 0 -s 640x480"; 
# $vcodec="-c:v libx265 -preset medium -crf 28 -s 640x480"; 
$acodec="-c:a libvorbis -q 1"; 

# command~ "$niceness $encoder_cmd -i $filein $vcodec $acodec $fileout"

# lq: x264 -crf 26, vorbis -q 0

# x264
# 18 nearly lossless
# crf 23 default
# 28 lowest acceptable for cartoon

# vorbis
# http://wiki.hydrogenaudio.org/index.php?title=Recommended_Ogg_Vorbis#Recommended_Encoder_Settings
# q 0 - 64
# q 1 - 80kbps
# q 4 - 128
# q 5 - 160 most used

# VGA: -s 640x480
# (16:9): -s 720x480
# 720p(16:9): -s 1280x720

#####################################
# Code
#
$directory_name = $ARGV[0];

#commands
# if ( $audio_codec eq 'vorbis' ) {
	# $audio_var = "-oac lavc -lavcopts acodec=vorbis:abitrate=$audio_bitrate"}
# if ( $video_codec eq 'xvid') {
	# $video_var = "-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=$video_bitrate:vhq -ffourcc XVID";
# }

############################
# Some input error checking

if($directory_name eq ""){
  print "Error: no directory entered.\n the first arg is the directory\n";
  exit;
}

if ( !( -d $directory_name) ){ #check if directory exists
	print "Error: $directory_name is not a directory\n";
	exit;
}
if ( !( -w $directory_name) ){ #check if directory exists
	print "Error: $directory_name is not writeable\n";
	exit;
}


open(LOG, ">>$log_file");

opendir(DIR, "$directory_name"); #precheck if video files in dir
$video_cnt=0;
while (defined($dir = readdir(DIR))) {
	if ( isVideo($dir) ) { 	$video_cnt++; }
} closedir(DIR);
if ( $video_cnt == 0 ) {
	print "Error: not video files in $directory_name\n";
	exit;
}

sub isVideo {	
	# doo
	my $filename = $_[0];
	foreach $ext (@video_file_extentions) {
		if ($filename =~ /$ext$/i) {
#			print "$ext: $filename: match\n";
			return 1;
		} else {
#			print "$ext: $filename: no match\n";
		}
	}
	0;
}
	

$est_time = 0.5 * $video_cnt;
print "Detected $video_cnt video files.  \nRoughly est. $est_time h to completion, based on encoding time 30min/file.\n";

if ( -d "$directory_name/$video_output_dir" ) { #checks to see if new dir exists
	print "Warning: directory, $video_output_dir, exists.  This is OK, but files within $video_output_dir may be overwritten\n";
} else {
	mkdir("$directory_name/$video_output_dir");
	print "Creating \'$video_output_dir\' directory\n";
}

if ( -e $log_file ) {
	my $log_file_old = $log_file . '.old';
	system("mv $log_file $log_file_old");
}

print "To Exit before completion hit Ctrl-C twice.\n\n";
$cnt=0;
$summary="\n\n==========================================\nSummary of encoding\n------------------------------------------\n";
$total_start_time=time;
opendir(DIR, "$directory_name");
$first=1;
while (defined($dir = readdir(DIR))) {
	if ( ($dir ne '.') && ($dir ne '..') && !( -d "$directory_name/$dir" ) ) {
		if ( isVideo($dir) ) { 
			$cnt++;			
			$file_size = (-s "$directory_name/$dir")/1024/1024;
			$file_size =~ s/\..*//;
			if ( $file_size < $min_file_size ) {
				print "Copying instead of re-encoding: $dir < $min_file_size\MB\n";
				system("cp \"$directory_name/$dir\" \"$directory_name/$video_output_dir/$dir\"");
				sleep(1);

			} else {	
				# system("rm -f divx2pass.log frameno.avi"); # deleting temp files the might be left over
				$file_name_full = "$directory_name/$dir";
				$new_file_name = "$directory_name/$video_output_dir/$dir";
				$new_file_name =~ s/\.[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]$/_sm.mkv/;				

				print "Smallifying: $dir ($cnt of $video_cnt files)\n";
				if ( $first == 0 ) {
					$time_elapst = sprintf("%.1f",($stop_time - $start_time) / 3600 ); # rounding time to one decimal
					print "    Updated est. time left " . ( 1 + $video_cnt - $cnt)*$time_elapst . " h, based on last encoding \n";
				}
				$first=0;
				$start_time = time;
				# print " Encoding audio...\n";
				# print "$audio_enc_command \"$file_name_full\"";
				# system();
				# print " Encoding video...\n";
				# print "$video_enc_command \"$file_name_full\" -o \"$new_file_name\"";
				# system();
				print "    Encoding video...  \n";
				system("echo \"\n\n\n============================================================\" >> $log_file");
				system("echo \"Encoding $dir\" >> $log_file");
				system("echo \"============================================================\" >> $log_file");

				# Encoder Command
				$cmd = "$niceness $encoder_cmd -i \"$file_name_full\" $vcodec $acodec -y \"$new_file_name\" 2>&1";
				# print "$cmd \n";
				$cmd_out = `$cmd`;

				print LOG $cmd_out;
				print LOG "\n\n#########################################";
				print LOG "###########################################";
				print LOG "###########################################\n\n";

				# exec "$niceness $encoder_cmd -i \"$file_name_full\" $vcodec $acodec -y \"$new_file_name\" &>> $log_file" or die "Unable to exec: $!\n";
				# system("echo \"$mencoder_out\"  >> $log_file");
				sleep(1);
				print "    Encoding finished.\n";
			   	print "    Original file size: $file_size\MB\n";
				$org_file_size = $file_size;
				$file_size = (-s "$new_file_name")/1024/1024;
				$file_size =~ s/\..*//;
				print "    Final file size: $file_size MB\n";
				$summary .= "$dir\n   Original Size: $org_file_size MB Final: $file_size MB\n";
				$stop_time = time;
$time_elapst1 = ($stop_time - $start_time) / 3600 ;
				$time_elapst = sprintf("%.1f", ($stop_time - $start_time) / 3600 ); # rounding time to one decimal
				# print " start=$start_time, $stop_time, $time_elapst, $time_elapst1\n";
				print "    Encoding took $time_elapst h\n";
			}
		} else {
			print "Skipping: $dir is not a recognised video file\n";
		}	
	} 
}
closedir(DIR);
close(LOG);


$total_stop_time=time;
$total_time=  sprintf("%.1f",($total_stop_time - $total_start_time) / 3600);
$summary .= "\n-----------------------------------------------\nOriginal dir: $directory_name\nFinal dir: $directory_name/$video_output_dir\nLog file: $log_file\nTotal encoding time: $total_time h\n\n";

print $summary;
system ("echo \"$summary\" >> $log_file");


#Post processing log file
# system("cat $log_file |grep -v '^Pos' |grep -v '^1 duplicate frame(s)!'|grep -v '^Skipping frame!' ");
$out_text = '';
open FILE, "<", "$log_file";
while (<FILE>) { 
	my $line = $_;
	if ( $line !~ /^Pos/ && $line !~ /^Skipping frame!/ && $line !~ /^. duplicate frame\(s\)!/ ) {
		$out_text .= $line;
	}
}
close FILE;
open FILE, ">$log_file" ;
print FILE $out_text;
close FILE;


print "All done.\n";
print "Before deleting old files:\n";
print " Check a few files\n";
print " Check log for errors\n";
print " Look at the file sizes for inconsistency\n";
print "\n";


