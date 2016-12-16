#!/usr/bin/perl 

############################
# Creator: Jeff Israel
#
# Script:	./simple-rss-reader-v3.pl
# Version: 	3.002
#
# Coded for for Wikihowto http://howto.wikia.com
#
# Description: 	This code downloads an RSS feed, 
# 		extracts the <title> lines,
# 		cleans them up lines,
# 		prints the pretty lines
# 		exits on max-lines
# Usage:
# .conkyrc: ${execi [time] /path/to/script/simple-rss-reader-v3.pl}
#
# Usage Example
# ${execi 300 /path/to/script/simple-rss-reader-v3.pl}
#

use LWP::Simple qw($ua get);
$ua->timeout(30);

############################
# Configs
#
$rssPage = $ARGV[0];
if( $rssPage eq '' ){
	#$rssPage = "http://tvrss.net/feed/combined/";
	# $rssPage = 'http://twitter.com/statuses/user_timeline/37039456.rss';
	# $rssPage = "http://tvrss.net/feed/eztv/";
	# $rssPage = 'http://rss.bt-chat.com/?group=3&cat=9';
	$rssPage = 'http://www.rlslog.net/category/tv-shows/feed/';
}

$numLines = 10;
$maxTitleLenght = 35;

###########################
# Code
#

# Downloading RSS feed
my $pageCont = get($rssPage);

# Spliting the page to lines
@pageLines = split(/\n/,$pageCont);

# Parse each line, strip no-fun data, exit on max-lines
$numLines--; #correcting count for loop
$x = 0;
$out='';
foreach $line (@pageLines) {
	if($line =~ /\<title\>/ && $line !~ /Twitter \/ / && $line !~ /BT-Chat.com/ && $line !~ /Releaselog/ && $line !~ /Binverse - get/ && $line !~ /Relaselog/){ # Is a good line? and ignore the initial line for Twitter
		#print "- $line\n";
		$lineCat = $line;
		$lineCat =~ s/.*\<title\>//;
		$lineCat =~ s/\<\/title\>.*//;
		$lineCat =~ s/\[.{4,25}\]$//; # strip no-fun data ( [from blaaa] )

		#some optional substitutions/removal
		$lineCat =~ s/eztv_it: //;

		$lineCat = substr($lineCat, 0, $maxTitleLenght);
		$out .= "- $lineCat \n";
		$x++;
	}
	if($x > $numLines) {
		last; #exit on max-lines
	}
	
}

if( length($out) < 40 ){
	$out = "-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n";
}

print $out;

#print $page;
#print "\nBy Bye\n";
