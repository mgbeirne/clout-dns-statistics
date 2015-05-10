#!/usr/bin/perl -w
# $Id: create3hash.pl,v 1.1 2014/02/05 01:56:47 beirne Exp beirne $
# I want to take a line in the BIND 9 query log form:
# Feb  4 20:01:20 LSD named[54670]: client 68.87.69.149#36202: query: nationalcycle.com IN A -ED (204.248.57.218)
#Feb  1 13:03:54 LSD named[635]: client 165.254.102.79#43721 (margot2.us.mensa.org): query: margot2.us.mensa.org IN AAAA -EDC (204.248.57.218)
# and print out a report listing each domain queried with a count
# of the number of times it was asked for and a second section listing
# all of the types of queries and the count for each too.

use DB_File;
no strict;

$chizonelist="chizone.db";
tie %chizone, "DB_File", $chizonelist or die "Can't open $chizonelist: $!\n";
@chinames=keys(%chizone);


@months=qw(january february march april may june july august september
october november december);
$thismonth = $months[(localtime)[4]];
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

# process any FOO=bar switches

$, = ' ';		# set output field separator
$\ = "\n";		# set output record separator

$domains{"last_time_run"}=time();

NEXTLINE: while (<>) {
    chomp;	# strip record separator
    @Fld = split;
#	print $#Fld;
    if ($#Fld == 13 ) {
	$querytype{(lc$Fld[11])}++;
	$thisrunq{(lc$Fld[11])}++;
	$totals{(lc$Fld[11])}++;
# if the queried domain is in one of the domains we support,
# keep track of how many times it is queried for.
#	if ($Fld[9] is a right anchored substing of a key of the
# chizone.db file keep stats on it otherwise ignore it.
#	foreach $key (keys %chizone) {
# the above works, but is way too slow and this is not much better.
	foreach $key (@chinames) {
	  if ($Fld[9] =~ m/.*\.$key\z|^$key\z/) {
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
