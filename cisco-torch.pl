#!/usr/bin/perl

eval ("use IO::Socket;");die "[error] IO::Socket perl module is not installed \n" if $@;
eval ("use sigtrap;");die "[error] sigtrap perl  is not suported \n" if $@;
eval ("use Net::hostent;");die "[error] Net::hostent  perl module is not installed \n" if $@;
eval ("use Getopt::Std;");die "[error] Getopt::Std perl module is not installed \n" if $@;
eval ("use Net::Telnet;");die "[error] Net::Telnet perl module is not installed \n" if $@;
eval ("use Net::SSH2;");die "[error] Net::SSH::Perl perl module is not installed \n" if $@;
eval ("use Net::SSLeay qw(get_https post_https sslcat make_headers make_form);");die "[error] Net::SSLeay perl module is not installed \n" if $@;
eval ("use MIME::Base64 qw(encode_base64);");die "[error] MIME::Base64 perl module is not installed \n" if $@;
eval ("use Net::SNMP;");die "[error] Net::SNMP perl module is not installed \n" if $@;
eval ("use POSIX;");die "[error] POSIX perl  is not suported \n" if $@;


eval{require "/etc/cisco-torch/torch.conf"};

if($@) {
   print "Failed to load config file:torch.conf\n";
}

print "Using config file torch.conf...\n";


# Plugins
print "Loading include and plugin ...\n";
opendir(DIR, "/usr/share/cisco-torch/include");
while($in=readdir(DIR)) {
    next if ($in=~/^[.]{1,2}/);
    next if !($in=~/\.pm$/);
    require "/usr/share/cisco-torch/include/$in";
}
closedir(DIR);



my $version = "0.4b";

#SNMP staff
$ENV{'MIBS'}="ALL";  #Load all available MIBs

&getopts('AtsdunbcjzwVl:XF:O:g');
use vars qw(
  $opt_A
  $opt_t
  $opt_s
  $opt_d
  $opt_c
  $opt_u
  $opt_n
  $opt_V
  $opt_l
  $opt_w
  $opt_z
  $opt_a
  $opt_X
  $opt_F
  $opt_O
  $opt_b
  $opt_j
  $opt_g
);

if ( !$opt_F ) { $host = $ARGV[0]; }
else { chomp $opt_F; $targetfile = $opt_F }

if ($opt_V)
{
	print(" Version $version\n");
	exit(0);
}
if (
	    ( !$host && !$opt_F )
	 || ( $host && $opt_F )
	 || (        !$opt_A
		  && !$opt_t
		  && !$opt_s
		  && !$opt_w
		  && !$opt_z
		  && !$opt_X
		  && !$opt_F
		  && !$opt_u
		  && !$opt_n
		  && !$opt_b
		  && !$opt_c
		  && !$opt_j
		  && !$opt_g
		  && !$ARGV[1] )
  )
{
	&usage;
	exit(0);
}

if ( $opt_g && !($opt_u ||  $opt_j ) )
{
	print (" -g should only be used with either -u  or -j with -b option\n");
	exit(0);
}
if ( $opt_g && ($opt_u ) )
{
	print (" You must be root or administrator to start the TFTP server!! \n Required for config download by SNMP\n");
}


if ( $opt_b && !($opt_t || $opt_s || $opt_u || $opt_c || $opt_w || $opt_j ) )
{
	print (" -b should only be used with either -t , -s, -c , -j , -w or -u option\n");
	exit(0);
}

$logfile = $opt_O if $opt_O;

print("\n");
&banner;

if ($opt_l)
{

	if ( ( $opt_l !~ /^[cdv]+$/ ) )
	{
		print "Unknown loglevel defenition: " . $opt_l . "\n";
		exit(0);
	}
	$llevel = $opt_l;
}

if ($opt_F)
{
	$date = `date`;
	open( TARGETLIST, "$targetfile" )
	  || die "$0:     Could not read from $targetfile! ($!)";
	while (<TARGETLIST>) { chomp; push( @targetlist, $_ ); }
} else
{
	if ( $host =~ /[A-z]/ )
	{
		@targetlist=($host);
	} else
	{
		&GetRange;
	}
}

$tgt_cnt = defined $IPstart ? $IPend-$IPstart : $#targetlist + 1;

log_print( "List of targets contains $tgt_cnt host(s)\n", "c" );

# Determine how many scanner processes is required ------------------------------------------------------

$proc_cnt = $tgt_cnt / $hosts_per_process > $max_processes ? $max_processes : floor($tgt_cnt / $hosts_per_process);
$proc_tgt_cnt = ceil( $tgt_cnt / ($proc_cnt + 1) );
log_print( "Will fork $proc_cnt additional scaner processes\n", "c" ) if $proc_cnt;

# Fork scanner processes --------------------------------------------------------------------------------

@children = ();
for ($bi = 0, $pid = -1 ; $bi < $tgt_cnt - $proc_tgt_cnt; $bi += $proc_tgt_cnt)
{
	last if !($pid = fork());
	push(@children, $pid);
}

# Determine scan range for each process -----------------------------------------------------------------

$ei = $bi + $proc_tgt_cnt <= $tgt_cnt ? $bi + $proc_tgt_cnt - 1 : $tgt_cnt - 1;	
if (defined $IPstart)
{
	$start = GetIP($IPstart + $bi);
	$end = GetIP($IPstart + $ei);
}
else
{
	$start = $targetlist[$bi];
	$end = $targetlist[$ei];
	@targetlist = @targetlist[$bi..$ei];
}



# Perform the scan --------------------------------------------------------------------------------------

log_print( "Range Scan from $start to $end\n", "c" ) unless ( "$start" eq "$end" );
for ($c = $bi; $c <= $ei; $c++)
{
	$host = defined $IPstart ? GetIP($IPstart + $c) : $targetlist[$c - $bi];
	log_print( "$$:\tChecking $host ...\n", "c" );
	log_start();
	&scanit;
	log_write("Host: $host *****************************************************\n");
}

if ($pid)	# Master process
{
	{} until wait() == -1;	# Wait for clildren to terminate
	&endbanner;

	push (@children, $$);	
	foreach $cpid (@children)
	{
		`cat $tmplogprefix.$cpid >>$logfile && rm -f $tmplogprefix.$cpid` if (stat("$tmplogprefix.$cpid"))
	}
}

# end core
#############################
###############
# Subroutines #
###############
sub scanit
{
	if ( !&check_ip($host) )
	{
		log_print( " trying to resolve hostname $host\n\n", "c" );
		my $handler = gethost($host);
		if ( !$handler )
		{
			log_print( "$host does not resolve, I died\n\n", "c" );
			exit(0);
		}
		$target = inet_ntoa( @{ $handler->addr_list }[0] );
		log_print( "resolved host to: $target\n\n", "i" );
		$host_resolves = 1;
	} else
	{
		$target        = $host;
		$host_resolves = 0;
	}
	if ($opt_A)
	{
		$opt_u = "1";
		$opt_n =  "1";
		$opt_t = "1";
		$opt_w = "1";
		$opt_s = "1";
		$opt_c = "1";
		$opt_j = "1";
		
	}
	if ($opt_t)
	{
		if (telnetfprint())
		{
			 telnet_leak_user() ? pwdbforce() : bruteforce(0) if $opt_b;
		}
	}
	if ($opt_s)
	{
		if (sshfprint())
		{
			bruteforce(1) if $opt_b;
		}
	}
	if ($opt_u)
	{
	               if ( snmp_ping()) 
	                {
	                      snmp_bruteforce(1) if $opt_b;    
	               }
	}
	
	if ($opt_n)
	{
	&ntp
	}
	if ($opt_j)
	{
	&tftp
	}	
	if ($opt_z)
	{
	
     &cisco_auth_http 
	}
	if ($opt_w)
	{
		
		if (checkweb())
		{
			 
	brute_www(1) if $opt_b;
	}
	}
	if ($opt_c)
	{
	  if (ssl_finger())
	  { 
	  
	  	brute_ssl(1) if $opt_b;
	  }
	}
	
}



 
