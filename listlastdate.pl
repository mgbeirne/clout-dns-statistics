#!/usr/bin/perl
# $Id: monthly.pl,v 1.3 2004/06/14 17:39:08 beirne Exp $
# I want to take a line in the BIND query log form:
# Nov 25 00:00:44 dns3 named[114]: XX /143.231.1.67/www.ci.chi.il.us/A/IN
# and print out a report listing each domain queried with a count
# of the number of times it was asked for and a second section listing
# all of the types of queries and the count for each too.

use Getopt::Std;
if ( getopts('m:') and "$opt_m" ne "" ) {
$thismonth = $opt_m;
} else {
@months=qw(january february march april may june july august september
october november december);
$thismonth = $months[((localtime)[4]-1)];
}
#print "$thismonth\n";

chdir("/home/beirne/stats") or die "Can't change to stats: $!\n"; 

use DB_File;
$domainfile=$thismonth."d.db";
if (! -e "$domainfile") { die "$thismonth doesn't exist $!\n";}
tie %domains, "DB_File", $domainfile or die "Can't open $domainfile: $!\n";
$queryfile=$thismonth."q.db";
tie %querytype, "DB_File", $queryfile or die "Can't open $queryfile: $!\n";
tie %lastdate, "DB_File", "lastdate.db" or die "Can't open lastdate: $!\n";
tie %totals, "DB_File", "totals.db" or die "Can't open totals: $!\n";
tie %chizone, "DB_File", "chizone.db" or die "Can't open chizone: $!\n";


if (exists $domains{"last_time_run"}) {
$t = localtime($domains{"last_time_run"});
print "statistics from: ", $t, "\n";
} else { die "No statistics to report: $!\n"
}

#print "\n  Count  Domain\n";
#foreach $key (sort { $domains{$b} <=> $domains{$a} } keys %domains) {
#  unless ($key eq "last_time_run"){
#	printf "%8d %s\n", $domains{$key}, $key;
#  }
#}

#print "\n Total Count  Query Type\n";
#foreach $key (sort { $totals{$b} <=> $totals{$a} } keys %totals) {
##  if ($totals{$key} > 9) {
#	printf "%9d %s\n", $totals{$key}, $key;
##  }
#}

#print "\n Monthly Count  Query type\n";
#foreach $key (sort { $querytype{$b} <=> $querytype{$a} } keys %querytype) {
##  if ($querytype{$key} > 9) {
#	printf "%8d \t%s\n", $querytype{$key}, $key;
##  }
#}

print "\n  Domain\tLast Query Date\n";
foreach $key (sort keys %chizone) {
	if (exists ($lastdate{$key})) {
	printf( "%s:\t%s\n", $key, $lastdate{$key});
	}else {
	printf( "%s:\t%s\n", $key, "No Queries Received");
	}
}

untie %domains;
untie %querytype;
untie %lastdate;
untie %totals;
