#!/usr/bin/perl

##########################
#   Author: Tom Christiansen
#   Gotten from www.perldoc.com


use Net::hostent;
 use Socket;

 @ARGV = ('null') unless @ARGV;

 for $host ( @ARGV ) {

    unless ($h = gethost($host)) {
	warn "$0: no such host: $host\n";
	next;
    }

    printf "\n%s is %s%s\n", 
	    $host, 
	    lc($h->name) eq lc($host) ? "" : "*really* ",
	    $h->name;

    print "\taliases are ", join(", ", @{$h->aliases}), "\n"
		if @{$h->aliases};     

    if ( @{$h->addr_list} > 1 ) { 
	my $i;
	for $addr ( @{$h->addr_list} ) {
	    printf "\taddr #%d is [%s]\n", $i++, inet_ntoa($addr);
	} 
    } else {
	printf "\taddress is [%s]\n", inet_ntoa($h->addr);
    } 

    if ($h = gethostbyaddr($h->addr)) {
	if (lc($h->name) ne lc($host)) {
	    printf "\tThat addr reverses to host %s!\n", $h->name;
	    $host = $h->name;
	    redo;
	} 
    }
 }  

