#!/usr/bin/perl
#
use File::Find;
# Config
$test = 0;

$dirname = $ARGV[0];



if($dirname eq ""){
  print "the first arg is the directory\n";
  exit;
}

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year += 1900;
open FILE, ">>", "/home/zymos/tmp/audiobook_vbr_encode-$year-$mon-$mday.log" or die $!;
print FILE "Started encoding directory: $dirname\n";

print "starting processes....\n";

sub the_operation {
	my $file = $_;
	if( not( $file eq '.' || $file eq '..' ) && $file =~ /\.wma$/  ) {
		$file2 = $file;
		$file2 =~ s/\.wma$/-32k.mp3/;
	
		print "encoding: $file\n";
		$out = `avconv -i "$file" -c:a libmp3lame -b:a 32k -ar 22050 -c:v mjpeg "$file2" >/dev/null`;
		# $out = `lame --resample 22050 --lowpass 9 --vbr-old -V 9.5 -B 64 --add-id3v2 "$file" "$file2"`;
		# $out = `lame --resample 22050 --cbr -b 32 --noreplaygain --lowpass 7 "$file" "$file2"`;

		if($?){
			print "error encoding: $file";
			print FILE "Fail: $file\n";
			exit 1;
		}else{
			print FILE "Good: $file2\n";
			$out = `id3v2 --TCON "Audiobook" "$file2"`;
			$out = `mp3gain "$file2"`;
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

find(\&the_operation, $dirname);


close FILE;
print "done...\n\n";

