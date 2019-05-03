Clout DNS statistics for daily and monthly reports.

Written in Perl sometime in 2003

Depends upon named having a logging stanza to send debug level statistics to syslogd, which has been configured to put those statistics to a file rotated at midnight, and a nightly cron job to import the previous days statistics

------- /etc/namedb/named.conf
logging {
        channel mychannel {
          syslog local0;        # send to syslog's local0 facility
          severity debug;       # only send priority info and higher
        };
}

-------- /etc/syslog.conf
local0.*                                        /var/log/dnsqueries.log

------- /etc/newsyslog.conf
/var/log/dnsqueries.log                 640  10    *    @T00  Z

------- cron job
30 3 * * * /home/beirne/statsrun |mail -s "lsd daily stats" beirne
