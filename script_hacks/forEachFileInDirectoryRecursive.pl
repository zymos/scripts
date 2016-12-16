#!/usr/bin/perl -w
#
use File::Find;
# Config
$test = 0;

$dirname = $ARGV[0];

if($dirname eq ""){
  print "the first arg is the directory\n";
  exit;
}


print "starting processes....\n";

sub the_operation {
	my $file = $_;
	if( not( $file eq '.' || $file eq '..') ) {
		$file2 = $file;
		$file2 =~ s/ - stand alone story//;
		# $file2 =~ s/\.JPG/_mod.JPG/;
		# system("convert \"$ARGV[0]/$file\" -recolor \"1.143 0 0 0 1.128 0 0 0 1.000\" \"$ARGV[0]/mod/$file2\"");
		# $file2 =~ s/^south_park_00/south_park_0/;
		# $file2 = 'infox-' . $file;
		 # print "$file \n";
#		 $file1 = $dir_name . '/' . $file;
#		 $file2 = $dir_name . '/' . $file2;
#		print "ddrescue \"$file1\" \"/home/zymos/$file\"";
#		 rename($file, $file2);
#		system("ddrescue \"$file1\" \"/home/zymos/$file\"");
		if ( $file ne $file2 ){
			system("mv \"$file\" \"$file2\"");
		}
#		system("gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=”small/$file” $file");

		# if( $file =~ /rpm$/ ){
			# system("rpm2cpio $file| cpio -idmv");
		# }
	}
}

find(\&the_operation, $dirname);

print "done...\n\n";

