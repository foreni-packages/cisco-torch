sub sshfprint
{
	my	$ret = 0;

	log_print( "Checking for SSH\n", "h" );
	log_print( "----------------\n", "h" );
	my $sock = new IO::Socket::INET(
									 PeerAddr => $target,
									 PeerPort => 22,
									 Proto    => 'tcp',
									 Timeout  => '5'
	);
	if ( !$sock )
	{
		log_print( "No SSH\n\n", "i" );
	}
	while ($sock)
	{
		sleep(5);
		$cnt = sysread( $sock, $buff, 10000 );
		if ( !$cnt )
		{
			log_print( "I died\n\n", "i" );
			last;
		}
		if ( $buff =~ /Cisco/ )
		{
			log_print( "Cisco found by SSH banner $buff\n", "c" );
			return 1;
		}
		close($sock);
		last;
	}


}
 1;