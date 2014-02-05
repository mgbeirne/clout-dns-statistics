#!/usr/bin/perl
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
	if $running_under_some_shell;

chdir("/home/beirne/stats") or die "Can't change to stats: $!\n";

use DB_File;
$chizonelist="chizone.db";
tie %chizone, "DB_File", $chizonelist or die "Can't open $chizonelist: $!\n";

foreach $key (sort keys %chizone) {
    print "$key => $chizone{$key}\n";
}
