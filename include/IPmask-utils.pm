sub check_ip
{
	my $ipaddr = shift;
	if ( $ipaddr !~ /^[0-9\.]+$/ ) { return 0 }
	if ( $ipaddr !~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/ ) { return 0 }
	for ( $1, $2, $3, $4 ) { return 0 if ( $_ > 255 ) }
	return 1;
}



sub GetRange
{
	($start, $end) = @ARGV;

	if ( $start =~ /\*/ )
	{
		$end = $start;
		$start =~ s/\*+/0/g;
		$end =~ s/\*+/255/g;
	}

	( $ippart, $bit ) = split( /\//, $start );

	#CIDR
	if ( $bit ne "" )
	{
		die "Error: CIDR Mask '$bit' is invalid.\n" if $bit >= 31;

		$netip = str2ip($ippart) or die "Invalid CIDR : $start";
		$net = (2 ** (32 - $bit)) - 1;
		$mask = 0xFFFFFFFF - $net;
		$start = GetIP( $netip & $mask );
		$end = GetIP( $netip | $net );
	}

	$end = $start if ( $start ne "" && $end eq "" );

	die "need [starting IP] [ending IP]" if ( $start eq "" || $end eq "" );

	$IPstart = str2ip($start) or die "Bad starting IP";
	$IPend = str2ip($end) or die "Bad ending IP";

	if ( $IPend < $IPstart ) { die "Can't scan backwards"; }

	$IPend++;
}

sub GetIP
{
	# converts "long" (undotted) IPs into "short" (dotted) IPs
	my ($ip) = @_;

	$Class[0] = ($ip / 0x1000000 ) % 0x100;
	$Class[1] = ($ip / 0x10000 ) % 0x100;
	$Class[2] = ($ip / 0x100 ) % 0x100;
	$Class[3] = $ip % 0x100;

	join ".", @Class;
}

sub str2ip
{
	my ($str) = @_;

	return 0 unless check_ip($str);
	my @IP = split /\./, $str;

	(($IP[0] * 256 + $IP[1] ) * 256 + $IP[2]) * 256  + $IP[3]; 
}
 1;