#********************************************************************************
#TFTP bruteforce 
#********************************************************************************
sub tftp
              {
              
              	if (tftp_installed()) {
              		tftp_finger(1);
              		tftp_brute(1) if $opt_b; 
                          	    		
                 
                 
              	}
              }
              
              

	
sub tftp_brute {      
 
 
my $port = 69;
 my $retries=2;
 my $timeout=2;
 my $file;
 my $MAXLEN=2;
 my $op=01;
 my $mode = "netascii";

 
  open( BRUTEFILE,  "<$brutefile") || die " Cannot open the  community file : $communityfile ! \n";
        chomp(@brutefile = <BRUTEFILE>);
close(BRUTEFILE);

	foreach $file (@brutefile)
	{
		my $count=$retries;
		my $pkt  = pack("n a* c a* c", $op, $file, 0, $mode, 0);
       if ( $count != 0 && $treturn !="03") {
             my $sock = IO::Socket::INET->new(Proto => 'udp');
             send($sock,$pkt,0,pack_sockaddr_in($port,inet_aton($target)));
             undef($treturn);
		     undef($rpkt);
        eval {
    local $SIG{ALRM} = \&timed_out;
    alarm $timeout;
    $sock->recv($rpkt, $MAXLEN);
    close $sock;
    alarm 0;
    
}  ;
    $count--;
@rets = split( //, $rpkt );
foreach $currentret (@rets) { $treturn .= ord($currentret); }
         
                 if ($treturn =="03") 
                 {
                     
                                                          
       log_print("*** Found  TFTP server remote filename : $file \n", "c");    
 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                           if (opt_g) {
 log_print("*** Fetch  TFTP remote file : $file \n", "c"); 
                	
                 	$tftp = Net::TFTP->new($target, retries	=> 2, 
                        Mode => "octet",Timeout=>2, BlockSize => 1024);               
                        $download = $tftp-> get( $file, $target.$file) ;
                        $err = $tftp->error;
                        print "$err";
                         if ($download==1) 
                 {
            log_print("***Local file :$target.$file  download comlpete\n", "c"); 
              
                 }
                 if (defined $error) {
            log_print("*** Remote file : $file download Error $err\n", "c"); 
                 }
                           }
 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                 return 1;
                 } 
                
       }
     $count=$retries; 
	}
	
	return 0;
 
}   
	                        


sub tftp_installed {
my $port = 69;
 my $retries=2;
 my $timeout=2;
 my $file="Rand0mSTRING";
 my $MAXLEN=2;
 my $op=01;
 my $mode = "netascii";
 my $pkt  = pack("n a* c a* c", $op, $file, 0, $mode, 0);
 while ( $retries != 0) {
             my $sock = IO::Socket::INET->new(Proto => 'udp');
       
     	undef($treturn);
		undef ($rpkt);
             send($sock,$pkt,0,pack_sockaddr_in($port,inet_aton($target)));
        eval {
    local $SIG{ALRM} = \&timed_out;
    alarm $timeout;
    $sock->recv($rpkt, $MAXLEN);
    close $sock;
    alarm 0;
    
}  ;
    $retries--;
    
@rets = split( //, $rpkt );
foreach $currentret (@rets) { $treturn .= ord($currentret); }

      if ($treturn == "05" )

                 {
                                                               
                log_print("*** Found  TFTP server  \n", "c");    
                return (1);
                 
            }
 }                       
}
            

sub tftp_finger
    {
my $tdata;
my $rdata;
my $timeout = 3;
		log_print( "Trying simple tftp fingerprint\n", "h" );
		log_print( "--------------------------------\n", "h" );
		if ( !-e $tfingerprintdb )
		{
			log_print( "HUH db not found, it should be in $tfingerprintdb\n", "c" );
			log_print( "Skipping tftp fingerprint\n", "c" );
			return 0;
		}

    	
$tdata = "olja-lja";
$remote = IO::Socket::INET -> new(Proto => "udp", PeerAddr => $target,
                                      PeerPort => 69
                                   );
                                      
        undef($tfingerprint);
     	undef($tdescription);
		undef($rdata);
		undef($tsubmitter);
		undef($thit);
		undef($tbuff);
                                 
                                      
                    if ($remote)
                    {
                    	
# send the udp-request to the server
$remote -> send($tdata);

# receive the message from the server
$SIG{ALRM} = \&timed_out;
  alarm ($timeout);
 eval { 
 
recv($remote, $rdata, 4096, 0 );
 
              close $remote;
              alarm (0);
              } 
             
             }
         if ($rdata)
		  { 
		  
		    @rets = split( //, $rdata );
			foreach $currentret (@rets) { $tfingerprint .= ord($currentret); }
			log_print ("\n Response: $tfingerprint\n\n", "c");
		
        if ($tfingerprint)
		{
			open FINGERPRINTDB, "<$tfingerprintdb" || last; 
			while (<FINGERPRINTDB>)
			{
				( $tdescription, $treturn, $tsubmitter ) = split( /\!/, $_ );
				if ( "$tfingerprint" eq "$treturn" )
				{
					 $thit = 1;
					 log_print( "Description:\t$tdescription\n", "c" );
					 log_print( "Fingerprinting Successful\n\n", "c" );
					 last;
				}
			}
			close FINGERPRINTDB;
			$thit || log_print( "Fingerprint: $tfingerprint\n Not found in database. If you know what it is please\nsubmit it to info\@arhont.com\n", "c" );
			
		}           
    
}
return (0);

	
}
 1;