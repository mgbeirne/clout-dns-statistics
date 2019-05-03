#!/usr/local/bin/perl -w
# $Id: report.pl,v 1.1 2004/02/03 09:05:16 beirne Exp beirne $
# I want to take a line in the BIND query log form:
# Nov 25 00:00:44 dns3 named[114]: XX /143.231.1.67/www.ci.chi.il.us/A/IN
# and print out a report listing each domain queried with a count
# of the number of times it was asked for and a second section listing
# all of the types of queries and the count for each too.

use DB_File;
#@months=qw(january february march april may june july august september october november december);
#$thismonth = $months[(localtime)[4]];

$daily = "thisrun";
$dailyq = $daily."q.db";
$dailyd = $daily."d.db";
tie %dailyquery, "DB_File", $dailyq or die "Can't open $dailyq: $!\n";
tie %dailydom, "DB_File", $dailyd or die "Can't open $dailyd: $!\n";

print "\n Daily Count  Domain\n";
foreach $key (sort { $dailydom{$b} <=> $dailydom{$a} } keys %dailydom) {
#  if ($dailydom{$key} > 9) {
	printf "%8d %s\n", $dailydom{$key}, $key;
#  }
}

print "\n Daily Count  Query type\n";
foreach $key (sort { $dailyquery{$b} <=> $dailyquery{$a} } keys %dailyquery) {
#  if ($dailyquery{$key} > 9) {
	printf "%8d %s\n", $dailyquery{$key}, $key;
#  }
}

untie %dailyquery;
untie %dailydom;
