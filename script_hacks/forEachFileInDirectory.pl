#!/usr/bin/perl -w
#
#

use File::Glob ':glob';
# Config

$dirname = $ARGV[0];

if($dirname eq ""){
  print "the first arg is the directory\n";
  exit;
}


print "starting processes....\n";

sub the_operation {
	my $file = $_[0];
	if( not( $file eq '.' || $file eq '..') && -f $file  ) {
		# print ">";
		$file2 = $file;
		$file3 = $file;
		$file2 =~ s/\....$/.ppm/;
		$file3 =~ s/\....$/.svg/;

		print "$file > $file2 > $file3\n";
		system("convert \"$file\" -resize 800% \"$file2\"");
		system("potrace -s \"$file2\" -o \"$file3\"");
		system("rm \"$file2\"");
		# print "$file $file2\n";
		if( $file ne $file2 ){
			# system("avconv -i \"$file\" -b:a 64k \"$file2\"");
			# print ">$file\n>>$file2\n";
		}else{
			print "No change: $file\n";
		}

	}
}


chdir($dirname);

my @files = glob("*");
foreach my $file (@files) {
	&the_operation($file);
}

print "done...\n\n";

