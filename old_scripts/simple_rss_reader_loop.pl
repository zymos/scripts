#!/usr/bin/perl


system('echo -e "-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n" > /tmp/rss.log');
system('echo -e "-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n-\n" > /tmp/rss2.log');

# system('echo -e '-\\n-\\n-\\n-\\n-\\n-\\n-\\n-\\n-\\n-\\n-\\n-\\n' > /tmp/rss2.log');

while (1){
	system("/usr/scripts/simple_rss_reader.pl http://twitter.com/statuses/user_timeline/37039456.rss > /tmp/rss.log");
	system("/usr/scripts/simple_rss_reader.pl > /tmp/rss2.log");
	sleep(1200);
}
