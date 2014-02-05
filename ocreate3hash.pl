#!/usr/bin/perl -w
# $Id: create3hash.pl,v 1.2 2004/02/03 09:05:35 beirne Exp beirne $
# I want to take a line in the BIND 9 query log form:
# Jan  8 00:00:34 dns3 named[115]: client 63.104.224.10#56186: query: miami.gagme.chi.il.us IN A
# and print out a report listing each domain queried with a count
# of the number of times it was asked for and a second section listing
# all of the types of queries and the count for each too.

use DB_File;
use strict;
#use DNS::ZoneParse;

#my $chicagozone = DNS::ZoneParse->new("./chicago.il.us.zone");
#my $chizone = DNS::ZoneParse->new("./chi.il.us.zone");
#
#my %chirrs = $chizone->Dump;
#my %chicagorrs = $chicagozone->Dump;
#my $chinames = keys %chirrs;
#foreach my $record ($chinames) {
#                    print "$record\n";
#       };
no strict;

$chizonelist="chizone.db";
tie %chizone, "DB_File", $chizonelist or die "Can't open $chizonelist: $!\n";
@chinames=keys(%chizone);

#$querycount = 0;
#$legalqueries = 0;
#%domains = ();	# hash to hold the domains queried for
#%querytype = ();# hash to hold query types

#($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
@months=qw(january february march april may june july august september
october november december);
#@dst = qw( CST CDT );
$thismonth = $months[(localtime)[4]];
#$isdst=(localtime)[8];
$year = (localtime)[5] + 1900;

$domainfile=$thismonth."d.db";
tie %domains, "DB_File", $domainfile or die "Can't open $domainfile: $!\n";
$queryfile=$thismonth."q.db";
tie %querytype, "DB_File", $queryfile or die "Can't open $queryfile: $!\n";
tie %lastdate, "DB_File", "lastdate.db" or die "Can't open lastdate: $!\n";
tie %totals, "DB_File", "totals.db" or die "Can't open totals: $!\n";

#eval '$'.$1.'$2;' while $ARGV[0] =~ /^([A-Za-z_0-9]+=)(.*)/ && shift;
			# process any FOO=bar switches

$[ = 1;			# set array base to 1
$, = ' ';		# set output field separator
$\ = "\n";		# set output record separator

#if (exists $domains{"last_time_run"}) {
#  if ( ( time() - $domains{"last_time_run"}) = (24*60*60)) {
#  %domains=("last_time_run"=>time());
#  }
#  else { die "Please do not run more than once a day\n"; }
#}
#else {
#%domains("last_time_run"=>time());
$domains("last_time_run"=>time());
#}

#@dstyear=( $dst[$isdst], $year);

NEXTLINE: while (<>) {
    chomp;	# strip record separator
    @Fld = split;
    if ($#Fld == 11 ) {
	$querytype{(lc$Fld[11])}++;
	$totals{(lc$Fld[11])}++;
# if the queried domain is in one of the domains we support,
# keep track of how many times it is queried for.
#	if ($Fld[9] is right anchored substing of a key of the
# chizone.db file keep stats on it otherwise ignore it.
#	foreach $key (keys %chizone) {
# the above works, but is way too slow and this is not much better.
	foreach $key (@chinames) {
	  if ($Fld[9] =~ m/.*\.$key\z|^$key\z/) {
	    $domains{$key}++;
	    if (lc$Fld[1] eq "dec") {
		if ($thismonth eq "january"){
		$queryyear = $year - 1;
		}
		else {
		$queryyear = $year;
		}
	      }
	    else {$queryyear =$year;};
	    $querydate=join(' ', $Fld[1], $Fld[2]);
	    $aqueryyear=sprintf "%d", $queryyear;
	    $nnquerydate=join(' ', $querydate, $aqueryyear);
	    $lastdate{$key} = $nnquerydate;
	    next NEXTLINE;
	  }
	}
      }
}

# print "count of bogus logfile lines:", $querycount-$legalqueries;
print "\n  Count  Domain\n";
foreach $key (sort { $domains{$b} <=> $domains{$a} } keys %domains) {
  unless ($key eq "last_time_run"){
#  if ($domains{$key} > 9) {
	printf "%8d %s\n", $domains{$key}, $key;
#  }
  }
}

print "\n  Count  Query type\n";
foreach $key (sort { $querytype{$b} <=> $querytype{$a} } keys %querytype) {
#  if ($querytype{$key} > 9) {
	printf "%8d %s\n", $querytype{$key}, $key;
#  }
}

untie %domains;
untie %querytype;
untie %lastdate;
untie %totals;
