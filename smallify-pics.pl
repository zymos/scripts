#!/usr/bin/perl

print "hello\n\n";

system("mkdir small");
system("cp *.JPG small/");
# system("mogrify -border 0x3% -bordercolor \"#000000\" -fill \"#ffffff\" -font '-adobe-utopia-bold-r-normal-*-*-240-*-*-p-*-iso10646-1' -draw 'text 1450,1258 \"Jeff Israel\"' -verbose -format jpg small/*.jpg");
system("mogrify -resize 640x -verbose -format jpg small/*.JPG");


#opendir(DIR, '.');
#while (defined($filein = readdir(DIR))) {
#    $fileout= $filein . "_sm.jpg";

#}
#closedir(DIR);

