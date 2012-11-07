sub telnetfprint
{
	if ( $telnet ne "0" )
	{
		log_print( "Trying simple Telnet fingerprint\n", "h" );
		log_print( "--------------------------------\n", "h" );
		if ( !-e $fingerprintdb )
		{
			log_print( "HUH db not found, it should be in $fingerprintdb\n", "c" );
			log_print( "Skipping Telnet fingerprint\n", "c" );
			return 0;
		}
		my $sock = new IO::Socket::INET(
										 PeerAddr => $target,
										 PeerPort => 23,
										 Proto    => 'tcp',
										 Timeout  => '5'
		  );
		undef($fingerprint);
		undef($description);
		undef($return);
		undef($submitter);
		undef($hit);
		undef($buff);
		if ( !$sock )
		{
			log_print( "No telnet\n", "i" );
			return 0;
		}
		while ($sock)
		{
			sleep(3);
			$cnt = sysread( $sock, $buff, 14 );
			if ( !$cnt )
			{
				log_print( "Hmmm, probably TCP wrappers\n", "i" );
				last;
			}
			@rets = split( //, $buff );
			foreach $currentret (@rets) { $fingerprint .= ord($currentret); }
			close($sock);
			log_print( "Possible OS's\n\n", "h" );
			log_print( "Fingerprint:\t\t\t$fingerprint\n", "c" );
			last;
		}
		if ($fingerprint)
		{
			open FINGERPRINTDB, "<$fingerprintdb" || last; 
			while (<FINGERPRINTDB>)
			{
				( $description, $return, $submitter ) = split( /\!/, $_ );
				if ( "$fingerprint" eq "$return" )
				{
					 $hit = 1;
					 log_print( "Description:\t\t\t$description\n", "c" );
					 log_print( "Fingerprinting Successful\n\n", "c" );
					 last;
				}
			}
			close FINGERPRINTDB;
			$hit || log_print( "Fingerprint not found in database. If you know what it is please\nsubmit it to info\@arhont.com\n", "c" )
		}
		return $buff =~ /Password:/ ? 2 : ($fingerprint ? 1 : 0);
	}
}
 1;