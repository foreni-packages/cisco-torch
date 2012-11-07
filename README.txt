  #############################################################
  # Cisco Torch Mass Cisco Vulnerability Scanner version 0.4b #
  #############################################################

  ________________________________________________________________
  Born by Arhont Team, 2005.  Special thanks to Boris Chernov, for
  http://www.arhont.com       checking the code and suggestions 
  ----------------------------------------------------------------

Basically, in the process of writing "Hacking Exposed Cisco Networks" we got dissatisfied 
with the Cisco scanners currently available and decided to do our own. Some code
(telnet fingerprint scan and several entries in the telnet fingerprinting database) 
are borrowed from Hackbot - thank you guys for writing an exellent tool! The main 
feature that makes cisco-torch different from similar tools is the extensive use of forking 
to launch multiple scanning processes on the background for maximum scanning efficiency. 
Also, it uses several methods of application layer fingerprinting simultaneoulsy, if needed.
We wanted something fast to discover remote Cisco hosts running Telnet, SSH, Web, NTP, TFTP 
and SNMP services and launch dicitionary attacks against the services discovered, including 
SNMP community attack (you would like the community.txt list :-) and TFTP servers (configuration
file name bruteforcing with following config leeching). The tool can also get device configuration
files automatically if SNMP RW community is found.

It should be fast enough to crunch through a large company or a small country (like UK :-) 
In addition, the tool finds classical, but still relevant Cisco IOS HTTP Auth and Cisco 
Catalyst 3500 XL Remote Arbitrary Command Execution Vulnerabilities. We could 
(and we will) add more vulnerabilities to check for, but mind it we are not interested in 
DoS, only enable :-)

By the way, this seems to be the only tool that does Cisco fingerprinting via NTP, spare for
the NTP Nessus plugin :-) Application layer fingerprinting performed against several services
on the host is fast and reliable. And if none of these services are running, it is unlikely
that you will manage to get into that Cisco box anyway, at least when you aren't on the same
LAN. 

As to the dictionary/bruteforcing attacks, we could've done them faster, but we didn't parallel 
the attacks to get maximum efficiency when attacking large networks (kind of paralleling it by IP's, 
rather than processes). 



DISCLAIMER
+++++++++++

Cisco Torch is written for legitimate penetration testing, network hardening and educational
purposes. The authors are not responsible for any possible misuse of the tool. 



INSTALLATION AND USE
++++++++++++++++++++

1. Make sure that you have the following Perl modules installed:

 Net::hostent;
 Net::Telnet;
 Net::SSH::Perl;
 Net::SNMP;
 Net::SSLeay;

If in Windows without Perl set up, download and install Active Perl binary from http://www.activestate.com/
Then you can install necessary modules listed above with commands like ppm install Net::Telnet, ppm Net::SSH::Perl  
and so on. Or, even better, use Cygwin. The Windows package of the tool is in making, anyways.

2. Modify the variables in the configuration file (torch.conf) to suit your personal taste:

$max_processes=20;
$hosts_per_process=10;
$passfile= "password.txt";
$communityfile="community.txt";
$usersfile="users.txt";
$fingerprintdb = "fingerprint.db";
$tmplogprefix="/tmp/tmplog";
$logfile="scan.log";
$llevel="c";

3. perl cisco-torch.pl and see the options available. You should get an output similar to

 # perl cisco-torch.pl -A 192.168.XXX.XXX

###############################################################
#   Cisco Torch Mass Scanner 0.4b                             #
#   Because we need it...                                     #
#   http://www.arhont.com/tools/cisco-torch.html              #
###############################################################

List of targets contains 1 host(s)
8711:   Checking 192.168.66.202 ...
Fingerprint:                    2552511255251325525324255253311310
Description:                    Cisco IOS host (tested on 2611,2950 and Aironet 1200 AP)
Fingerprinting Successful

Cisco found by SSH banner SSH-1.5-Cisco-1.25

HTTP/1.1 401 Unauthorized
Date: Tue, 25 Jan 2005 00:02:18 GMT
Server: cisco-IOS
Accept-Ranges: none
WWW-Authenticate: Basic realm="level_15_access"

401 Unauthorized

--->
- All scans done. Cisco Torch Mass Scanner 0.4b -
---> Exiting.

It is nicely stored in the scan.log file or whatever you name it. Mention, that if you see a host, 
fingerprinted as Cisco box via Telnet or/and SSH, but not showing up as an IOS-running host 
on a webserver check, it is likely to be a Catalyst. For example, this is Cisco Catalyst 2950:

List of targets contains 1 host(s)
9467:   Checking 192.168.77.254 ...
Fingerprint:                    2552511255251325525324255253311310
Description:                    Cisco IOS host (tested on 2611, 2950 and Aironet 1200 AP)
Fingerprinting Successful

HTTP/1.0 501 Not Implemented
Date: Tue, 25 Jan 2005 03:28:04 0
Content-type: text/html
Expires: Thu, 16 Feb 1989 00:00:00 GMT

<H1>501 Not Implemented</H1>

Keep in mind, that PIX firewalls usually employ HTTPS, not HTTP by default.
Also keep in mind, that on a PIX without aaa authentication the default username for 
the SSH login is "pix". 

By the way, running -A against vast networks is rather slow and is not recommended, so, scanning
/8 with -A may not be a good idea, unless you are a RAM maniac. 



BUGS
++++

It is a beta release and there are probably bugs lurking. 
Please send bug reports and comments to ciscotorch@arhont.com



FINGERPRINTS
++++++++++++

Collecting and adding Telnetd fingerprints of Cisco devices using the tool is very easy. 
For now, the fingerprint.db coming with the tool is limited, containing signatures from Hackbot,
TESO Team telnetftp and our testing lab. Please send Cisco-relevant Telnetd fingerprints 
you may discover to us at ciscotorch@arhont.com so that we can verify and include them in the future
releases. Also, please add additional devices and comments to what is already in the database. 
We have tested what we have at hand and supplied the signatures with names of the devices tested. 
Of course, this is not precise and there could be more Cisco (or even other vendor) hosts that 
possess mentioned signatures and are not listed. Please take this into account when scanning.  



LICENCE
+++++++

Cisco Torch is released under GNU Lesser General Public License. You should recieve a copy of this license 
together with the tool.
