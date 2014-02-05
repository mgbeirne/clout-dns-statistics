#!/usr/bin/perl -w
# $Id: create3hash.pl,v 1.1 2014/02/05 01:56:47 beirne Exp beirne $
# I want to take a line in the BIND 9 query log form:
# Feb  4 20:01:20 LSD named[54670]: client 68.87.69.149#36202: query: nationalcycle.com IN A -ED (204.248.57.218)
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
# remove stats file for this run if it exists.
if (-e "thisrund.db") { unlink "thisrund.db" };
if (-e "thisrunq.db") { unlink "thisrunq.db" };
tie %thisrund, "DB_File", "thisrund.db" or die "Can't open thisrund.db: $!\n";
tie %thisrunq, "DB_File", "thisrunq.db" or die "Can't open thisrunq.db: $!\n";
tie %querytype, "DB_File", $queryfile or die "Can't open $queryfile: $!\n";
tie %lastdate, "DB_File", "lastdate.db" or die "Can't open lastdate: $!\n";
tie %totals, "DB_File", "totals.db" or die "Can't open totals: $!\n";

#eval '$'.$1.'$2;' while $ARGV[0] =~ /^([A-Za-z_0-9]+=)(.*)/ && shift;
			# process any FOO=bar switches

#$[ = 1;			# set array base to 1
$, = ' ';		# set output field separator
$\ = "\n";		# set output record separator

#if (exists $domains{"last_time_run"}) {
#  if ( ( time() - $domains{"last_time_run"}) < (24*60*60)) {
#  $domains("last_time_run"=>time());
#  }
#  else { die "Please do not run more than once a day\n"; }
#}
#else {
$domains{"last_time_run"}=time();
#}

#@dstyear=( $dst[$isdst], $year);

NEXTLINE: while (<>) {
    chomp;	# strip record separator
    @Fld = split;
#	print $#Fld;
    if ($#Fld == 12 ) {
	$querytype{(lc$Fld[10])}++;
	$thisrunq{(lc$Fld[10])}++;
	$totals{(lc$Fld[10])}++;
# if the queried domain is in one of the domains we support,
# keep track of how many times it is queried for.
#	if ($Fld[9] is right anchored substing of a key of the
# chizone.db file keep stats on it otherwise ignore it.
#	foreach $key (keys %chizone) {
# the above works, but is way too slow and this is not much better.
	foreach $key (@chinames) {
	  if ($Fld[8] =~ m/.*\.$key\z|^$key\z/) {
	    $domains{$key}++;
	    $thisrund{$key}++;
	    if (lc$Fld[0] eq "dec") {
		if ($thismonth eq "january"){
		$queryyear = $year - 1;
		}
		else {
		$queryyear = $year;
		}
	      }
	    else {$queryyear =$year;};
	    $querydate=join(' ', $Fld[0], $Fld[1]);
	    $aqueryyear=sprintf "%d", $queryyear;
	    $nnquerydate=join(' ', $querydate, $aqueryyear);
	    $lastdate{$key} = $nnquerydate;
	    next NEXTLINE;
	  }
	}
      }
}

# Print out query counts for today for each supported domain.
print "\n  Count  Domain\n";
foreach $key (sort { $thisrund{$b} <=> $thisrund{$a} } keys %thisrund) {
	printf "%8d %s\n", $thisrund{$key}, $key;
}

# Print out counts of query types for this run.
print "\n  Count  Query type\n";
foreach $key (sort { $thisrunq{$b} <=> $thisrunq{$a} } keys %thisrunq) {
#  if ($thisrunq{$key} > 9) {
	printf "%8d %s\n", $thisrunq{$key}, $key;
#  }
}

untie %thisrund;
untie %thisrunq;
untie %domains;
untie %querytype;
untie %lastdate;
untie %totals;
