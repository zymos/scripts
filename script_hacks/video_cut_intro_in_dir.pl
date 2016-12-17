#!/usr/bin/perl
############################################################################################
#                             Cut video intros and credits
# 
#  Description: Cuts the intros and credits from all videos in a directory and reencodes them
#  Author: ZyMOS
#  Date: 10/2016
#  Usage: video_cut_intro_in_dir.pl [DIRECTORY] [START_POSITION] [STOP_POSITION]
#  			[START_POSITION] is in seconds, or can be "BEGINNING"
#  			[STOP_POSITION] is in seconds, or can be "END"
#############################################################################################


########################################
# Config
#
$niceness="nice -n 19 ionice -c2 -n7";

# $FFMPEG_CMD='/opt/ffmpeg-0.11.2/bin/ffmpeg';
$FFMPEG_CMD="avconv";


$FFMPEG_SETTINGS="-c:v libx265 -preset medium -crf 28 -c:a libopus -b:a 64k";

$LOG_DIR="/tmp"; # to be added

###############################################################################3
# Code
#
use File::Glob ':glob';

$start_pos=$ARGV[1];
$stop_pos= $ARGV[2];
$dirname = $ARGV[0];



sub print_usage() {
	 print "Usage: \n  video_cut_intro_in_dir.pl [DIRECTORY] [START_POSITION] [STOP_POSITION]\n\n";
  print "  START_POSITION must be an integer in seconds,\n    or use \"BEGINNING\"to have the intro uncut\n";
    print "  STOP_POSITION must be an integer in seconds,\n    or use \"END\"to have the ending uncut\n\n";
	print "Examples:\n";
	print "  video_cut_intro_in_dir.pl /home/bob/videos 10 100\n";
	print "  video_cut_intro_in_dir.pl /home/bob/videos BEGINNING 1000\n";
	print "  video_cut_intro_in_dir.pl /home/bob/videos 10 END\n\n";
  exit;
}

if( $start_pos eq "" ){
	&print_usage;
	exit;
}
$cut_begin_opt='';
$cut_end_opt='';
if( $start_pos eq "BEGINNING" ){
	$cut_begin_opt=''; # no cut
	$start_pos = 0;
}elsif( $start_pos =~ /\d/ ){
	$cut_begin_opt="-ss $start_pos";
}else{
	 print "Input error: START_POSITION != integer or BEGINNING\n\n";
	&print_usage;
	exit 1;

}
if( $stop_pos eq "END" ){
	$cut_end_opt=''; # no cut
}elsif( $stop_pos =~ /\d/ ){
	$duration = $stop_pos - $start_pos;
	$cut_end_opt="-t $duration";
}else{
	print "Input error: STOP_POSITION != integer or END\n\n";
	&print_usage;
	exit 1;
}
if( $stop_pos <= $start_pos ){
	print "Input error: STOP_POSITION can not be less than or equal to START_POSITION \n\n";
	&print_usage;
	exit 1;
}
if( ! -d  $dirname || $dirname eq ""){
	print "Input error: DIRECTORY entered is not valid\n\n";
	&print_usage;
	exit 1;
}




print "starting processes....\n";

sub the_operation {
	my $file = $_[0];
	if( not( $file eq '.' || $file eq '..') && -f $file  ) {
		$file =~ s/\!/\\\!/g;
		$file2 = $file;
		$file_name = $file;
		$file2 =~ s/$/.no.intro.mkv/;

		$file_name =~ s/^.*\///;
#		print " $video_length\n";
		print "Processing...\n   $file_name\n --------------------------------------------------\n";
		sleep 1;
		$cmd = "$niceness $FFMPEG_CMD -i \"$file\" $cut_begin_opt $cut_end_opt $FFMPEG_SETTINGS \"$file2\" 2>&1";
		$cmd_out = `$cmd`;
		print FILE "$file\n";
		print FILE "-----------------------------------------------------------------------\n";
		print FILE "$cmd_out\n";
		print FILE "-----------------------------------------------------------------------\n";
		print FILE "-----------------------------------------------------------------------\n";
		print "Complete, -----------------------------------------------------------------------\n";
		sleep 1;
	}
}



# create log
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year += 1900;
$time_string = "$year-$mon-$mday--$hour-$min";
open FILE, ">>", "$LOG_DIR/video_cut_intro-$time_string.log" or die $!;
print FILE "Started encoding directory: $dirname\n";



my @files = glob("$dirname/*");
foreach my $file (@files) {
	&the_operation($file);
}

mkdir "$dirname/processed";
system("mv $dirname/*.no.intro.* $dirname/processed/");

# close log
close FILE;
print "Done...\n\n";

