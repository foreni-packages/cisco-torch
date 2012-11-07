#Telnet user leak check

sub telnet_leak_user
{
	my	$ret = 0;

	log_print( "Checking for telnet without a username \n", "h" );
	log_print( "----------------\n", "h" );
	my $sock = new IO::Socket::INET(
									 PeerAddr => $target,
									 PeerPort => 23,
									 Proto    => 'tcp',
									 Timeout  => '5'
	);
	if ( !$sock )
	{
		log_print( "No telnet\n\n", "i" );
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
		if ( $buff =~ /Password:/ )
		{
			log_print( "Found password only telnet login ", "c" );
			$ret = 1;
		}
		close($sock);
		last;
	}

	return $ret;
}


sub pwdbforce
{
open(PASSFILE, "<$passfile") || die " Cannot open the password file $passfile: $!\n";
        chomp(@password = <PASSFILE>);
close(PASSFILE);

	foreach $pass (@password)
	{
                my $sock = new IO::Socket::INET(
                                                                                 PeerAddr => $target,
                                                                                 PeerPort => 23,
                                                                                 Proto    => 'tcp',
                                                                                 Timeout  => '5'
                  );
                if ( !$sock )
                {
                        log_print( "No telnet\n", "i" );
                        return;
                }
               
                while ($sock)
                {
                        sleep(3);
                        sysread( $sock, $buff, 1000 ) || last;
			if (! ( $buff =~ /Password:/ ) )
			{
				log_print( "Unexpected prompt\n", "c" );
				close ($sock);
				last;
			}
			syswrite( $sock, $pass."\n" ) || last;
			sysread( $sock, $buff, 1000 ) || last;
			close ($sock);
			if ( $buff =~ /[#>]/ )
			{
                                log_print("*** Found valid password : $pass\n", "c");
                                return;
			}
		}
	}
}


# SSH/Telnet default passwd check 

sub bruteforce
{
my $use_ssh = shift;
my $user, $pass, @users, @password;

open(PASSFILE, "<$passfile") || die " Cannot open the password file $passfile: $!\n";
        chomp(@password = <PASSFILE>);
close(PASSFILE);
open(USERSFILE, "<$usersfile") || die " Cannot open the password file $passfile: $!\n";
        chomp(@users = <USERSFILE>);
close(PASSFILE);

	foreach $user (@users) 
	{
		foreach $pass (@password)
		{
			print "Tryng $user:$pass\n";
			my $conn =  $use_ssh ? Net::SSH::Perl->new($host) 
					     : Net::Telnet->new("Host" => $host, "Timeout" => 5, "Prompt" => "/[#>]/" );
               		
			eval {
			 $conn->login($user, $pass);
        		 $conn->cmd("cmd");
        		};
			$conn->close() unless $use_ssh;
			if (!$@)
			{
                                log_print("*** Found valid login/password pair : $user / $pass\n", "c");
                                return;
			}
		}
	}



}


 1;