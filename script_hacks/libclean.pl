#!/usr/bin/perl

$direc = '/';
print "h";
opendir(DIR, '/usr/lib/') || die "can't opendir $some_dir: $1";
while (defined($dir = readdir(DIR))) {
  print "g";
  if ( $dir =~ /\.la/)
  { 
	print "/us/lib/$dir\n";
  }
}
closedir(DIR);
