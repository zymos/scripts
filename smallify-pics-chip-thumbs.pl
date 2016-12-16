#!/usr/bin/perl

use File::Copy;

print "\n\n $#ARGV";

if ( $#ARGV != 0 ) {
	print "First argument is the directory\n";
	exit;
}
$path = $ARGV[0];

chdir($path) or die "Error: Cant chdir to $path $!";
mkdir("sm", 0777) || print "Error: Cant mkdir _sm_ $!";

print "Copying files";
my $tic=0;
opendir(DIR, '.');
while (defined($filein = readdir(DIR))) {
	if ( $filein =~ /\.(jpg|JPG|png)/i ) {
		$fileout = $filein;
		$fileout =~ s/$/_sm\.jpg/;
		$fileout = 'sm/' . $fileout;
		copy($filein, $fileout) or die "Error: File cannot be copied.";
		print ".";
		$tic=1;
	}
}
closedir(DIR);

if ( $tic == 0 ) {
	print "Error: no jpg in dir\n";
	exit;
}
chdir('sm') or die "Error: Cant chdir to _sm_ $!";

print "\nResizing images to width=250px.\n";
system("mogrify -resize 250x -verbose -format jpg *.jpg");

# system("mogrify -border 0x3% -bordercolor \"#000000\" -fill \"#ffffff\" -font '-adobe-utopia-bold-r-normal-*-*-240-*-*-p-*-iso10646-1' -draw 'text 1450,1258 \"Jeff Israel\"' -verbose -format jpg small/*.jpg");
# system("mogrify -resize 640x -verbose -format jpg small/*.JPG");



