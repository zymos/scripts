#!/usr/bin/perl 


####################################
# Modules
#

use CMS::MediaWiki;
use LWP::Simple;
use Net::hostent;
use Socket;
use IO::Socket;
use Time::HiRes qw(time);
use Getopt::Std;



#########################################
# Test options
#

# yes or no (1/0)
$download = 1;
$downloadWanted = 1;
$writePages = 1;


#########################################
#     Time Server Settings
# some setting that 
# need to be done first
# to enable the time 
# getter in a extreamly 
# rediculus way
#

my $server = "1.pool.ntp.org";
my $serverIPv4 ="";
if (gethostbyname($server)) {
    $serverIPv4 = sprintf("%d.%d.%d.%d",unpack("C4",gethostbyname($server)));
}
my $timeout = 2;



########################################
########################################
###     Variables
###
###

$dblocation="http://wikistats.wikia.com/dbdumps/howto/pages_current.xml.gz";
# $root = "http://howto.wikia.com"; #no slash
$rootDir = "";
# $host2 = "http://howto.wikia.com/index.php?title=Special:Wantedpages&limit=500&offset=0";
$backupFileName='pages_current.xml'; #name of file save on you computer (via wget)
$dbfile=$backupFileName;
$dbfilegzip='pages_current.xml.gz';

$username = 'Admin-Bot-ZyMOS';
$password = $ARGV[0]; # The password is the first command line argument



$wantedLink = "http://howto.wikia.com/index.php?title=Special:Wantedpages&limit=500&offset="; #without offset #
$numberWantedPages = 2;


$sleepInt = 4; # max time(sec) for random sleep interval between extractions, and posts (integer or float)


####################
# Page Names

# File named for lists or pages

$objectPage = $rootDir . "Help:Objects List";
$objectEmptyPage = $rootDir . "Help:Empty Objects";
$objectWantedPage = $rootDir . "Help:Wanted Objects";

$howtoPage = $rootDir . "Help:Howto List";
$howtoStubPage = $rootDir . "Help:Howto Stub List";
$howtoWantedPage = $rootDir . "Help:Wanted Howtos";

$guidePage = $rootDir . "Help:Guide List";
$guideStubPage = $rootDir . "Help:Guide Stub List";
$guideWantedPage = $rootDir . "Help:Wanted Guides";

$helpPage = $rootDir . "Help:Help Pages List";
$redirectPage = $rootDir . "Help:Redirects List";
$unknownPage = $rootDir . "Help:Unknown List";
$metaPage = $rootDir . "Help:Meta List";



# Templates to write the total amount of each page type
$tmpStubHowto = $rootDir . "Template:numOfStubHowtos";
$tmpHowto = $rootDir . "Template:numOfHowtos";
$tmpWantedHowto = $rootDir . "Template:numOfWantedHowtos";

$tmpStubGuide = $rootDir . "Template:numOfStubGuides";
$tmpGuide = $rootDir . "Template:numOfGuides";
$tmpWantedGuide = $rootDir . "Template:numOfWantedGuides";


$tmpWantedObject = $rootDir . "Template:numOfWantedObjects";
$tmpEmptyObject = $rootDir . "Template:numOfEmptyObjects";
$tmpObject = $rootDir . "Template:numOfObjects";

$tmpUnknown = $rootDir . "Template:numOfUnknowns";
$tmpHelp = $rootDir . "Template:numOfHelps";
$tmpRedir = $rootDir . "Template:numOfRedirects";

$tmpMeta = $rootDir . "Template:numOfMetas";





#############################
# Messages
 
# Messages to be printed on the page lists
$pageBodyIntro = "\nThis page contains a list of all";
$pageBodyIntro2 = "on Wikihowto. It is not intended to be used as a catalog, but more of an index. If you are searching for a specific subject use the search box or See: The full [[Help:Object Lists|]]\n\n\nThis page was created by a bot and the page is refreshed weekly. You can add a link on this page and it will be processed the next rotation, but its recomended you make a link on your user page, and add it to an appropriate Object page.  \n\n\nSee Also: [[Object List]], [[Howto List]], [[Guide List]], [[Help:All_page_types]]\n----";






##################################
#  Write woli paghes subroutine
#

sub updatePage
{
  local($a, $b);		
  ($a, $b) = ($_[0], $_[1]);	
  #Post the page
  if($a eq ''){
	  print "!!!!!!!!!!!!!!!!!!!!!!!!!!";
	  print "!! name error: name empty";
	  print "!!!!!!!!!!!!!!!!!!!!!!!!!!";
  }else{
	  $rc = $mw->editPage(   
	  title   => "$a" ,
	  section => '' , 
	  text    => "$b" ,
	  summary => "Updated via Administrative Bot." ,
	  );
	# randome sleep from 0-n in sec
	# to put less load on server
  }
  my $b = rand($sleepInt);
  system(" sleep $b");
}





###########################################
# Downloading Database
#
$wantedPagesContent = "";
if($download){
  print "\n# Get the database\n\n";
  system("rm -f $dbfile");
  system("rm -f $dbfilegzip");
  system("wget $dblocation");
  system("gzip -d $dbfilegzip");
}
if($downloadWanted){
  print "\n# Getting wanted pages\n\n";
	for($x=0;$x<$numberWantedPages;$x++){
        	#$content2 = get($host2);  
        	$offset = 500 * $x;
        	#print $wantedLink . $offset . " page name\n\n\n\n\n\n\n\n<><><><><><><><><><><><><><>\n\n\n\n";
		$wantedPagesContent = $wantedPagesContent . "\n\n\n\n\n\n\n\n\n=================================================\n\n\n\n\n\n\n\n\n\n" . get($wantedLink . $offset);
	}
}



#########################################
#     Time Server Settings
# some setting that 
# need to be done first
# to enable the time 
# getter in a extreamly 
# rediculus way
#

my $server = "1.pool.ntp.org";
my $serverIPv4 ="";
if (gethostbyname($server)) {
    $serverIPv4 = sprintf("%d.%d.%d.%d",unpack("C4",gethostbyname($server)));
}
my $timeout = 2;



########################################################
########################################################
#### Initialization
####
####


$pageNumber = 0;
@pageData = ();
@pageNames = ();
@pageType =();
@pageAttrib =();
$count=0;
$pageOn=0;

##############################
#  Initializing the time variables
#  
 my ($LocalTime0, $LocalTime0F, $LocalTime0H, $LocalTime0FH, $LocalTime0FB);
  my ($LocalTime1, $LocalTime2);
  my ($LocalTime, $LocalTimeF, $LocalTimeT);
  my ($NetTime, $NetTime2, $Netfraction);
  my ($netround, $netdelay, $off);
  
  my ($Byte1, $Stratum, $Poll, $Precision,
      $RootDelay, $RootDelayFB, $RootDisp, $RootDispFB, $ReferenceIdent,
      $ReferenceTime, $ReferenceTimeFB, $OriginateTime, $OriginateTimeFB,
      $ReceiveTime, $ReceiveTimeFB, $TransmitTime, $TransmitTimeFB);
  my ($dummy, $RootDelayH, $RootDelayFH, $RootDispH, $RootDispFH, $ReferenceIdentT,
      $ReferenceTimeH, $ReferenceTimeFH, $OriginateTimeH, $OriginateTimeFH,
      $ReceiveTimeH, $ReceiveTimeFH, $TransmitTimeH, $TransmitTimeFH);
  my ($LI, $VN, $Mode, $sc, $PollT, $PrecisionV, $ReferenceT, $ReferenceIPv4);
  
  my $ntp_msg;  # NTP message according to NTP/SNTP protocol specification







  #######################################################
  ########################################################
  #### Page Sorting
  ####
  ####

  
#########################
# Inital page sorting
#

print "# Page Extraction\n\n";

open(LINKS, "<$backupFileName") || die("Could not open file!");
while(<LINKS>){
  if($_ !~ /((\<namespace )|([\/\<]namespaces\>)|(^\<mediawiki xmlns)|(\<sitename\>.*\<\/sitename\>)|(\<generator\>.*\<\/generator\>)|(\<base\>.*\<\/base\>)|(\<case\>.*\<\/case\>)|([\/\<]siteinfo\>))/){
	if($_ !~ /((\<id\>)|(contributor\>)|(\<.?revision\>)|(\<timestamp\>.*\<\/timestamp\>)|(\<comment\>.*\<\/comment\>)|(\<username\>.*\<\/username\>)|(\<minor\/\>)|(\<id\>.*\<\/id\>)|(\<restrictions\>.*\<\/restrictions\>))/){

	  #  Minimize Data(removing multiply spaces and newlines)
	  s/((\&lt\;)|(\&gt\;)|(\&amp;))/ /gm;
	  s/ +/ /gm;
	  s/\n+/\n/gm;
	 
	  # Sorting into pages
	  if(($_ =~ /^ ?\<\/page\>/ || $count >= 4) && $pageOn){
		#end of page
		$pageOn = 0;
		$count = 0;
		$pageTypeSet = 0;
		$pageAttribSet = 0;
		$pageNumber++;
#		print "##############END###################\n";
	  }
	  if($_ =~ /\<title\>.*\<\/title\>/ && $pageOn){
		#grabing the ---------title------------
		$pageName = $_;
		$pageName =~ s/\<title\>//;
		$pageName =~ s/\<\/title\>//;
		$pageName =~ s/^ //;		
		chomp($pageName);
		$pageNames[$pageNumber] = $pageName;
#		print "[$pageNames[$pageNumber]]\n";
#		print "($pageNumber)>>[Title]>> $pageName\n";
#		print "$pageNumber, ";
		if($pageName =~ /\//){
		  #ignore
		  $pageType[$pageNumber] = 'sub-pages';
		  $pageTypeSet = 1;
		}elsif($pageName =~ /^(MediaWiki\:|Main Page)/){
		  $pageType[$pageNumber] = 'other';
		  $pageTypeSet = 1;
		}elsif($pageName =~ /^Category\:/){
		  $pageType[$pageNumber] = 'category';
		  $pageTypeSet = 1;
		}elsif($pageName =~ /^(Help|HowTo Wiki|About|WikiHowTo\:|Wikihowto\:)/){
		  $pageType[$pageNumber] = 'help';
		  $pageTypeSet = 1;
  		}elsif($pageName =~ /^Image\:/){
		  $pageType[$pageNumber] = 'image';
		  $pageTypeSet = 1;
#		  print "image ";
  		}elsif($pageName =~ /^(Talk\:|User talk\:)/){
		  $pageType[$pageNumber] = 'talk';
		  $pageTypeSet = 1;
  		}elsif($pageName =~ /^User\:/){
		  $pageType[$pageNumber] = 'user';
		  $pageTypeSet = 1;
  		}elsif($pageName =~ /^Guide /){
		  $pageType[$pageNumber] = 'guide';
		  $pageTypeSet = 1;
		}elsif($pageName =~ /^(Howto|How to|HowTo) /){
		  $pageType[$pageNumber] = 'howto';
		  $pageTypeSet = 1;
		}elsif($pageName =~ /^Template\:/){
		  $pageType[$pageNumber] = 'template';
		  $pageTypeSet = 1;
		}elsif($pageName =~ /^Historical\:/){
		  $pageType[$pageNumber] = 'historical';
		  $pageTypeSet = 1;
			}elsif($pageName =~ /^Meta\:/){
		  $pageType[$pageNumber] = 'meta';
		  $pageTypeSet = 1;
			}else{
		  $pageType[$pageNumber] = 'unknown';
		  $pageTypeSet = 1;
		}
	  }elsif($pageOn){
		#page content
		# maybe just check for page type here and not record data
		$pageData[$pageNumber] = $pageData[$pageNumber] . $_;
		$count++;
		if(!$pageAttribSet){
		  # getting the ---------Attributes-----------
		  if($_ =~ /(\{\{del\}\}|\{\{0\}\})/){
			$pageAttrib[$pageNumber] = 'delete';
			$pageAttribSet = 1;
		  }elsif($_ =~ /\#redirect/i){
			$pageAttrib[$pageNumber] = 'redirect';
			$pageTypeSet = 1;
		  }elsif($_ =~ /\{\{Stub\}\}/i){
			$pageAttrib[$pageNumber] = 'howto stub';
			$pageTypeSet = 1;
		  }elsif($_ =~ /\{\{Guide Stub\}\}/i){
			$pageAttrib[$pageNumber] = 'guide stub';
			$pageTypeSet = 1;
		  }elsif($_ =~ /\{\{object Stub\}\}/i){
$pageAttrib[$pageNumber] = 'empty';
			$pageTypeSet = 1;
		  }

		}
		if($pageType[$pageNumber] eq 'unknown'){
		  $lineObjectCheck = $_;
		  $lineObjectCheck =~ s/(\'|\:|\[|\])//gm;
		  $lineObjectCheck =~ s/  / /gm;
		  if($lineObjectCheck =~ /object wikipedia/i){
			$pageType[$pageNumber] = 'object';
		  }
		}

#		print "($pageNumber)>>[Content]>> $_\n";
#		print "($pageNumber)>>Attrib>> $pageAttrib[$pageNumber]\n";	i
#		print "($pageNumber)>>NAME>>$pageNames[$pageNumber]\n";
#		print "($pageNumber)>>Type>> $pageType[$pageNumber] >>Attrib $pageAttrib[$pageNumber]\n";		
		
	  }
	}
	  if($_ =~ /^ ?\<page\>/){
		#start of new page
		$pageOn = 1;
		$count = 0;
		$pageData[$pageNumber] ='';
		$pageType[$pageNumber] = '';
		$pageNames[$pageNumber] = '';
#		print "#############Page Start######################\n";
#		print ".";
	  }
		
	  
#	  $processedPage = $processedPage . $_;
#	  if($_ =~ /(\<)|(\>)/){
#		print $_;
#	  }
	
  }
}
close LINKS;





########################
#Clear names and Vars
#

$x=0;
$objectEmptyPages = '';
$objectPages = '';
$howtoStubPages = '';
$howtoPages = '';
$guideStubPages = '';
$guidePages = '';
$helpPages = '';
$unknownPages ='';
$redirectPages = '';
$otherPages = '';

$numOfObjects = 0;
$numOfEmptyObjects = 0;
$numOfHowtos = 0;
$numOfHowtoStubs = 0;
$numOfGuides = 0;
$numOfGuideStubs = 0;
$numOfUnknownPages = 0;
$numOfHelpPages = 0;
$numOfRedirects= 0;
$numOfOtherPages= 0;








##########################################################
# Sort page types
#

print "# Sorting Page Types\n\n";

for($x=0;$x<=$pageNumber;$x++){
#  print "\n[$x]: $pageNames[$x] <<< ";
  if( $pageType[$x] eq 'user' | $pageType[$x] eq 'talk' | $pageType[$x] eq 'image' |  $pageType[$x] eq 'category' | $pageType[$x] eq 'sub-pages' | $pageType[$x] eq 'template' | $pageType[$x] eq 'historical' ){
	#ignore
	print  "x.";#"ignored";
  }elsif($pageAttrib[$x] eq 'redirect'){
	  $redirectPages = $redirectPages . "# [[$pageNames[$x]]]\n";
	  $numOfRedirects++;
	  print "r.";#"redirect.";
  }elsif($pageAttrib[$x] eq 'delete'){
	  print "x.";#"delete.";
  }elsif($pageType[$x] eq 'object'){
	  if($pageAttrib[$x] eq 'empty'){
		$objectEmptyPages = $objectEmptyPages . "# [[$pageNames[$x]]]\n";
		$numOfEmptyObjects++;
		print "Oe.";#"empty object.";
	  }else{
		$objectPages = $objectPages . "# [[$pageNames[$x]]]\n";
		$numOfObjects++;
		print "O.";# object.";	  
	  }
  }elsif($pageType[$x] eq 'howto'){
	  if($pageAttrib[$x] eq 'howto stub'){
		$howtoStubPages = $howtoStubPages . "# [[$pageNames[$x]]]\n";
		;#"howto stub.";
		$numOfHowtoStubs++;
		$howtoPages = $howtoPages . "# [[$pageNames[$x]]] (stub)\n";
		$numOfHowtos++;
	  }else{
		$howtoPages = $howtoPages . "# [[$pageNames[$x]]]\n";
		$numOfHowtos++;
	  }
	  print "H.";#"howto.";	
  }elsif($pageType[$x] eq 'guide'){
	  if($pageAttrib[$x] eq 'guide stub'){
		$guideStubPages = $guideStubPages . "# [[$pageNames[$x]]]\n";
		$numOfGuideStubs++;
#		print "guide stub.";
		$guidePages = $guidePages . "# [[$pageNames[$x]]] (stub)\n";
		$numOfGuides++;
	  }else{
		$guidePages = $guidePages . "# [[$pageNames[$x]]]\n";
		$numOfGuides++;
	  }
	  print "G.";#"guide";	
  }elsif($pageType[$x] eq 'meta'){
	  $metaPages = $metaPages . "# [[$pageNames[$x]]]\n";
	  $numOfMetas++;
	  print "m.";#"meta.";
  }elsif($pageType[$x] eq 'unknown'){
	$unknownPages = $unknownPages . "# [[$pageNames[$x]]]\n";
	$numOfUnknownPages++;
	print "?.";#"unknown";	  
  }elsif($pageType[$x] eq 'help'){
	$helpPages = $helpPages . "# [[$pageNames[$x]]]\n";
	$numOfHelpPages++;
	print "h.";#"help";
  }elsif($pageType[$x] eq 'other'){
	$otherPages = $otherPages . "# [[$pageNames[$x]]]\n";
	$numOfOtherPages++;
	print "o.";#"Other";
  }

}

#############################################
# Extracting and Sorting Wanted Pages
#


# initialising vars
$howtoWantedPageBody = '';
$guideWantedPageBody ='';
$objectWantedPageBody ='';


@matchedLine = 0;
@wantedHowtos = 0;
@wantedGuides = 0;
@wantedObjects = 0;
@wantedHowtos = 0;

@lines = split(/\n/,$wantedPagesContent);

print "\n\n\n\n\nProcessing Wanted Pages:\n\n";
foreach $line (@lines){
        if($line =~ /index\.php\?title/){
                #print "$line\n.......\n";
                @matchedLine = (@matchedLine,$line);
                @break1 = split(/<\/a>/,$line);
                #print "$break1[0]<><<>>>><>>>\n";
                @break2 = split(/>/,$break1[0]);
                $pageName = @break2[$#break2];
                #print "$break2[$#break2]<><>>>>\n";
                if($pageName =~ /^Howto /i) {
                        @wantedHowtos = (@wantedHowtos,"*[[$pageName]]\n");
			$howtoWantedPages = $howtoWantedPages . "*[[$pageName]] \n";
                        #print "$pageName))))";
			print "h.";
                }elsif($pageName =~ /^Guide /i){
                        @wantedGuides = (@wantedGuides,"*[[$pageName]]\n");
			$guideWantedPages = $howtoWantedPages . "*[[$pageName]] \n";
                        #print "$pageName))))";
			print "g.";
                }elsif($pageName !~ /[\:\(\)\?\"\@\<\>\;\&\^\#\%\\\/\.\,\-\+\=]/ && $pageName !~ /^[a-z0-9]$/i  && $pageName !~ /500$/ && $pageName ne "Special"){
                        @wantedObjects = (@wantedObjects,"*[[$pageName]]\n");
			$objectWantedPages = $objectWantedPages . "*[[$pageName]] \n";
                        #print "$pageName))))";
			print "o.";
                }
        }
}

# $howtoWantedPages 
# $objectWantedPages
# $guideWantedPages


$numOfWantedHowtos = $#wantedHowtos;
$numOfWantedObjects = $#wantedObjects;
$numOfWantedGuides = $#wantedGuides;



#print "$numOfWantedHowtos, $numOfWantedObjects, $numOfWantedGuides";




#
#print "\n# Extracting Wanted pages.\n\n";
#@scraps = split(/( |<|>)/,$content2);
#
#$x=0;
#$y=0;
###########   NEEDS WORK  cut out the first word only??????????
#foreach $scrap (@scraps){
#  if($scrap =~ /title/ && $scrap !~ /(\?|\;|\:|Special)/){
#    @scopes = split(/"/,$scrap) ;
#    $scope = $scopes[1];  
#	print "$scope\n";
#	if($scope =~ /^Howto/i || $scope =~ /^How to/i){
#        print "Hw."; #"* [[$scope]]\n";
#		$howtoWantedPages =$howtoWantedPages . "# [[$scope]] \n";
#		$numOfWantedHowtos++;
#    }elsif($scope =~ /^Guide/i){ ##### Wanted Guide Pages
#        print "Gw."; #"G [[$scope]]\n";
#		$guideWantedPages =$guideWantedPages . "# [[$scope]] \n";
#		$numOfWantedGuides++;
#    }elsif($scope !~ / /){ ##### Wanted Guide Pages
#        print "Ow."; #"G [[$scope]]\n";
#		$objectWantedPages =$objectWantedPages . "# [[$scope]] \n";
#		$numOfWantedObjects++;
#	  }
#  }
#}






#############################################
# Page Content Assembly
#
$begining = "<center>''Number of";
# $begining Objects:{{NumOfObjects}}, Last Updated:{{NumUpdateDate}}''</center>\n\n  

$objectPageBody = "$pageBodyIntro '''Object''' $pageBodyIntro2 \n\n{| border=1 cellpadding=2 width=100%\n!width=50% valign=top|Objects<br>\n!width=50% valign=top|Empty Objects<br>\n|-\n|width=50% valign=top|<br>\n$objectPages\n|width=50% valign=top|<br>\n$objectEmptyPages\n|}\n";
$objectEmptyPageBody = "$pageBodyIntro '''Object Empty''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$objectEmptyPages\n|}\n\n";
$objectWantedPageBody = "$pageBodyIntro '''Object Empty''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$objectWantedPages\n|}\n\n";


$howtoPageBody = "$pageBodyIntro '''Howto''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$howtoPages\n|}\n\n";
$howtoStubPageBody = "$pageBodyIntro '''HowtoStub''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$howtoStubPages\n|}\n\n";
$howtoWantedPageBody = "$pageBodyIntro '''HowtoStub''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$howtoWantedPages\n|}\n\n";


$guidePageBody =  "$pageBodyIntro '''Guide''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$guidePages\n|}\n\n";
$guideStubPageBody =  "$pageBodyIntro '''Guide Stub''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$guideStubPages\n|}\n\n";
$guideWantedPageBody =  "$pageBodyIntro '''Guide Stub''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$guideWantedPages\n|}\n\n";


$redirectPageBody =  "$pageBodyIntro '''Redirect''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$redirectPages\n|}\n\n";
$unknownPageBody =  "$pageBodyIntro '''Unknown Pages''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$unknownPages\n|}\n\n";
$helpPageBody =  "$pageBodyIntro '''Help''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$helpPages\n|}\n\n";

$metaPageBody =  "$pageBodyIntro '''Help''' $pageBodyIntro2 \n\n\n\n{|style=\"background-color=#efefef\"\n|\n$metaPages\n|}\n\n";

# print "$helpPageBody $unknownPageBody $howtoPageBody $guidePageBody $redirectPageBody $objectPageBody"; 


###################################################
# Checking to see if  pages were parsed right
#

die "the count was inproper, stopped " if($numOfObjects==0||$numOfHowtos==0);



###############################################3
##  Login to the Server
##
print "\n\n######################\n# Loging onto Wikihowto.\n#\n";
$mw = CMS::MediaWiki->new(
        host  => 'howto.wikia.com',
        path  => '.' ,     #  Can be empty on 3rd-level domain Wikis
        debug => 0            #  0=no debug msgs, 1=some msgs, 2=more msgs
);
#$rc = $mw->login( user => "$username", pass => "$password" );

if ($mw->login(user => "$username", pass => "$password")) {
     print STDERR "Could not login, $username\n";
     exit;
}
else {
      print "Logged in. Doing stuff ...\n";
}








######################
# connect to timeserver
#

#print "# Connecting to time server....\n\n";
#
#$ntp_msg = get_ntp_time;
#interpret_ntp_data($ntp_msg);
#if (($LocalTime0H . $LocalTime0FH) ne ($OriginateTimeH . $OriginateTimeFH)) {
#    print "*** The received reply seems to be faulty and NOT the reply to our request packet:\n";
#    print "*** The OriginateTime stamp $OriginateTimeH.$OriginateTimeFH of the received packet does not \n";
#    print "***  show our Transmit Time $LocalTime0H.$LocalTime0FH.\n";
#    exit;
#}
#calculate_time_data;
#print "$ntp_msg, $LocalTime0H . $LocalTime0FH, $OriginateTimeH . $OriginateTimeFH\n";
#



@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
@weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = gmtime();
$year = 1900 + $yearOffset;
$theGMTime = "$hour:$minute, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
$currentTime = $theGMTime;
print "$currentTime\n";







#################################################
#################################################
####  Update Pages
####
####



# Writing the page lists 
if($writePages){
  print "## Posting Page Listing and Counts.\n#\n\n";
  
  print"#Posting pages\n";
  
  print "guides...\n";
  &updatePage($guidePage,$guidePageBody);
  print "Wanted guides...\n";
  &updatePage($guideWantedPage,$guideWantedPageBody);
  print "guide stubs...\n";
  &updatePage($guideStubPage,$guideStubPageBody);

  print "howto...\n";
  &updatePage($howtoPage,$howtoPageBody);
  print "Wanted howto...\n";
  &updatePage($howtoWantedPage,$howtoWantedPageBody);
  print "howto stubs...\n";
  &updatePage($howtoStubPage,$howtoStubPageBody);

  print "objects...\n";
  &updatePage($objectPage,$objectPageBody);
  print "empty objects...\n";
  &updatePage($objectEmptyPage,$objectEmptyPageBody);
  print "wanted objects...\n";

  &updatePage($metaPage,$metaPageBody);
  print "meta page...\n";

  &updatePage($objectWantedPage,$objectWantedPageBody);
  
  print "unknowns...\n";
  &updatePage($unknownPage,$unknownPageBody);
  print "helps...\n";
  &updatePage($helpPage,$helpPageBody);
  print "redirects...\n";
  &updatePage($redirectPage,$redirectPageBody);

  print "#posting page counts\n";
  # writing the pages counts
  # to the server
  print "howto count...\n";
  &updatePage($tmpHowto,$numOfHowtos);
  print "howto wanted count...\n";
  &updatePage($tmpWantedHowto,$numOfWantedHowtos);
  print "howto stub count...\n";
  &updatePage($tmpStubHowto,$numOfHowtoStubs);
  
  
  print "guide count...\n";
  &updatePage($tmpGuide,$numOfGuides);
  print "wanted guide count...\n";
  &updatePage($tmpWantedGuide,$numOfWantedGuides);
  print "guide stub count...\n";
  &updatePage($tmpStubGuide,$numOfGuideStubs);
  
  
  print "object count...\n";
  &updatePage($tmpObject,$numOfObjects);
  print "wanted object count...\n";
  &updatePage($tmpWantedObject,$numOfWantedObjects);
  print "empty object count...\n";
  &updatePage($tmpEmptyObject,$numOfEmptyObjects);
  
  
  print "unknown count...\n";
  &updatePage($tmpUnknown,$numOfUnknownPages);
  print "help count...\n";
  &updatePage($tmpHelp,$numOfHelpPages);
  print "redirect count...\n";
  &updatePage($tmpRedir,$numOfRedirects);
  
   print "meta count...\n";
  &updatePage($tmpMeta,$numOfMetas);
 
  # Write time of update
  print "#Updating time stamp\n";
  &updatePage("Template:NumUpdateDate",$currentTime);
}



print "# ALL DONE. \n";
  
  
  
  
  
  
  






######################################################################
#######################################################################
#####################################################################
# DO NOT EDIT the code below, unless you want to
# Its for extracting time, in an excesive and unessesarally
# precice way
######################################################################
####################################################################
# Begining of rediculus method for geting the time
# 
sub bin2frac { # convert a binary string to fraction
    my @bin = split '', shift;
    my $frac = 0;
    while (@bin) {
      $frac = ($frac + pop @bin)/2;
    }
    $frac;
  } # end sub bin2frac
  sub frac2bin { # convert a fraction to binary string (B32)
    my $frac = shift;
    my $bin ="";
    while (length($bin) < 32) {
      $bin = $bin . int($frac*2);
      $frac = $frac*2 - int($frac*2);
    }
    $bin;
  } # end sub frac2bin
sub get_ntp_time {
  # open the connection to the ntp server,
  # prepare the ntp request packet
  # send and receive
  # take local timestamps before and after

    my ($remote);
    my ($rin, $rout, $eout) ="";
    my $ntp_msg;

    # open the connection to the ntp server
    $remote = IO::Socket::INET -> new(Proto => "udp", PeerAddr => $server,
                                      PeerPort => 123,
                                      Timeout => $timeout)
                                  or die "Can't connect to \"$server\"\n";
    # measure local time BEFORE timeserver query
    $LocalTime1 = time();
    # convert fm unix epoch time to NTP timestamp
    $LocalTime0 = $LocalTime1 + 2208988800;

    # prepare local timestamp for transmission in our request packet
    $LocalTime0F = $LocalTime0 - int($LocalTime0);
    $LocalTime0FB = frac2bin($LocalTime0F);
    $LocalTime0H = unpack("H8",(pack("N", int($LocalTime0))));
    $LocalTime0FH = unpack("H8",(pack("B32", $LocalTime0FB)));

    $ntp_msg = pack("B8 C3 N10 B32", '00011011', (0)x12, int($LocalTime0), $LocalTime0FB);
                   # LI=0, VN=3, Mode=3 (client), remainder msg is 12 nulls
                   # and the local TxTimestamp derived from $LocalTime1
    # send the ntp-request to the server
    $remote -> send($ntp_msg) or return undef;
    vec($rin, fileno($remote), 1) = 1;
    select($rout=$rin, undef, $eout=$rin, $timeout)
      or do {print "No answer from $server\n"; exit};

    # receive the ntp-message from the server
    $remote -> recv($ntp_msg, length($ntp_msg))
               or do {print "Receive error from $server ($!)\n"; exit};

    # measure local time AFTER timeserver query
    $LocalTime2 = time();
    $ntp_msg;
  } # end sub get_ntp_time------------------------------ 
  sub interpret_ntp_data {
  # do some interpretations of the data
    my $ntp_msg = shift;
    # unpack the received ntp-message into long integer and binary values
    ( $Byte1, $Stratum, $Poll, $Precision,
      $RootDelay, $RootDelayFB, $RootDisp, $RootDispFB, $ReferenceIdent,
      $ReferenceTime, $ReferenceTimeFB, $OriginateTime, $OriginateTimeFB,
      $ReceiveTime, $ReceiveTimeFB, $TransmitTime, $TransmitTimeFB) =
      unpack ("a C3   n B16 n B16 H8   N B32 N B32   N B32 N B32", $ntp_msg);

    # again unpack the received ntp-message into hex and ASCII values
    ( $dummy, $dummy, $dummy, $dummy,
      $RootDelayH, $RootDelayFH, $RootDispH, $RootDispFH, $ReferenceIdentT,
      $ReferenceTimeH, $ReferenceTimeFH, $OriginateTimeH, $OriginateTimeFH,
      $ReceiveTimeH, $ReceiveTimeFH, $TransmitTimeH, $TransmitTimeFH) =
      unpack ("a C3   H4 H4 H4 H4 a4   H8 H8 H8 H8   H8 H8 H8 H8", $ntp_msg);

    $LI = unpack("C", $Byte1 & "\xC0") >> 6;
    $VN = unpack("C", $Byte1 & "\x38") >> 3;
    $Mode = unpack("C", $Byte1 & "\x07");
    if ($Stratum < 2) {$sc = $Stratum;}
    else {
      if ($Stratum > 1) {
        if ($Stratum < 16) {$sc = 2;} else {$sc = 16;}
      }
    }
    $PollT = 2**($Poll);
    if ($Precision > 127) {$Precision = $Precision - 255;}
    $PrecisionV = sprintf("%1.4e",2**$Precision);
    $RootDelay += bin2frac($RootDelayFB);
    $RootDelay = sprintf("%.4f", $RootDelay);
    $RootDisp += bin2frac($RootDispFB);
    $RootDisp = sprintf("%.4f", $RootDisp);
    $ReferenceT = "";
    if ($Stratum eq 1) {$ReferenceT = "[$ReferenceIdentT]";}
    else {
      if ($Stratum eq 2) {
        if ($VN eq 3) {
          $ReferenceIPv4 = sprintf("%d.%d.%d.%d",unpack("C4",$ReferenceIdentT));
          $ReferenceT = "[32bit IPv4 address $ReferenceIPv4 of the ref src]";
        }
        else {
          if ($VN eq 4) {$ReferenceT = "[low 32bits of latest TX timestamp of reference src]";}
        }
      }
    }

    $ReferenceTime += bin2frac($ReferenceTimeFB);
    $OriginateTime += bin2frac($OriginateTimeFB);
    $ReceiveTime += bin2frac($ReceiveTimeFB);
    $TransmitTime += bin2frac($TransmitTimeFB);

  } # end sub interpret_ntp_data ----------------------------------
  sub calculate_time_data {
  # convert time stamps to unix epoch and do some calculations on the time data

    my ($sec, $min, $hr, $dy, $mo, $yr);

    $ReferenceTime -= 2208988800; # convert to unix epoch time stamp
    $OriginateTime -= 2208988800; 
    $ReceiveTime -= 2208988800; 
    $TransmitTime -= 2208988800; 

    $NetTime = scalar(gmtime $TransmitTime);
    $Netfraction = sprintf("%03.f",1000*sprintf("%.3f", $TransmitTime - int($TransmitTime)));
    ($sec, $min, $hr, $dy, $mo, $yr) = gmtime($TransmitTime);
    $NetTime2 = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $yr+1900, $mo+1, $dy, $hr, $min, $sec);

    # calculate delay and difference
    $netround = sprintf("%+.4f",($LocalTime1 - $LocalTime2));
    $netdelay = sprintf("%+.4f",(($LocalTime1 - $LocalTime2)/2) - ($TransmitTime - $ReceiveTime));
    $off = sprintf("%+.4f",(($ReceiveTime - $LocalTime1) + ($TransmitTime - $LocalTime2))/2);

    $LocalTime = ($LocalTime1 + $LocalTime2) /2;
    $LocalTimeF = sprintf("%03.f",1000*sprintf("%.3f", $LocalTime - int($LocalTime)));
    ($sec, $min, $hr, $dy, $mo, $yr) = gmtime($LocalTime);
    $LocalTimeT = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $yr+1900, $mo+1, $dy, $hr, $min, $sec);

  } # end sub calculate_time_data--------------------------------
  ########################End of Funtions############################


#################

