sub checkweb
{

	log_print( "\n",                                     "h" );
	log_print( "Checking for webserver on port $port\n", "h" );
	log_print( "-----------------------------------\n",  "h" );
	my $sock = new IO::Socket::INET(
									 PeerAddr => $target,
									 PeerPort => '80',
									 Proto    => 'tcp',
									 Timeout  => '5'
	);
	if ($sock)
	{
		
		
			$sock->autoflush(1);
		
$sock->print("GET / HTTP/1.0\r\n");
$sock->print("User-Agent: Cisco-torch $version\r\n");
$sock->print("Host: $target\r\n");
$sock->print("Authorization: Basic $auth\r\n\r\n");	


		
		sleep(2);
		sysread( $sock, $httpversion, 4096 );
	
	}
		close ($sock);
	
	
		
			if ( $httpversion =~ /cisco-IOS/ )
			{
				log_print( "Cisco-IOS Webserver found\n $httpversion \n\n", "c" );
			}
			if ( $httpversion =~ /WWW-Authenticate\: Basic realm=\"level_15_access\"/ )
			{
				log_print( " Cisco WWW-Authenticate webserver found\n $httpversion\n\n", "c" );
			}
			
	
		
	
}

 1;