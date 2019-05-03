#!/usr/local/bin/perl
# 
eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
	if $running_under_some_shell;

use DB_File;
$chizonelist="chizone.db";
tie %chizone, "DB_File", $chizonelist or die "Can't open $chizonelist: $!\n";

# The following section adds secondary domains
# it discards reverse zones, root ".", chi.il.us and chicago.il.us
open(SECZONES, "/etc/namedb/named.conf");
while ( $line = <SECZONES>) {
if ($line =~ /^zone/) {
    $_ = lc($line);
    chomp;
    s/^zone "(.*)".*/\1/;
    if ( $_ ne "chicago.il.us" && $_ ne "chi.il.us" && $_ ne "." && $_ !~ /example/ && $_ !~ /arpa/ && $_ !~ /invalid/ && $_ !~ /test/ && $_ !~ /ip6.int/ && $_ !~ /localhost/) {
    $chizone{"$_"} = "$_";
#    print $_;
    }
  }
}
close(SECZONES);

open(ZONE1, "/etc/namedb/master/chi.il.us");

while ( $line = <ZONE1>) {
if ($line =~ /^[a-zA-Z0-9\-]+/) {
    $_ = lc($line);
    s/[ 	].*//;
#    s/(.*)\..*/\1/;
    s/www\.//;
    s/ftp\.//;
    s/ns\d\.//;
    chomp();
    $chizonename=join('.', "$_" , "chi.il.us" );
    $chizone{$chizonename} = join('.', $_, "chi.il.us");
}
}

close(ZONE1);

open(ZONE2, "/etc/namedb/master/chicago.il.us");

while ( $line = <ZONE2>) {
if ($line =~ /^[a-zA-Z0-9\-]+/) {
    $_ = lc($line);
    s/[ 	].*//;
#    s/(.*)\..*/\1/;
    s/www\.//;
    s/ftp\.//;
    s/ns\d\.//;
    chomp();
    $chizonename=join('.', "$_" , "chicago.il.us" );
    $chizone{$chizonename} = join('.', $_, "chicago.il.us");
}
}
close(ZONE2);

#foreach $key (sort keys %chizone) {
#    print $key, $chizone{$key}, "\n";
#}
