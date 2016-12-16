#!/usr/bin/perl



$file = "/mnt/ogre/privy/backup/backup/bbking.txt";
$name = $ARGV[0];
#print $name;
if($name ne ""){
	open(FD, "$file") or die("Couldn't open file\n") ;
	@bbking = <FD>;
	close(FB);

	foreach $bb (@bbking){
		if($bb =~ /$name/i){
			print "\n$bb\n";
		}
	}
}
else{
system "less $file";
}
