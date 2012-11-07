# NTP fingerprinting
#####################################################################
sub ntp {
	
if (ntp_installed())
{
	
get_ntp();
}	

}

sub get_ntp {

my $timeout = 2;
my $ntp_msg; 
 # NTP message according to NTP/SNTP protocol specification
  # open the connection to the ntp server,
  # prepare the ntp request packet
  # send and receive

    my ($remote);
   

$ntp_msg = pack "C*", (0x16, 0x02, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00, 0x00); 

    # open the connection to the ntp server
    $remote = IO::Socket::INET -> new(Proto => "udp", PeerAddr => $target,
                                      PeerPort => 123,
                                      Timeout => $timeout);
                    
                    if ($remote)
                    {
# send the ntp-request to the server
    $remote -> send($ntp_msg);
                    
 # receive the ntp-message from the server
$SIG{ALRM} = \&timed_out;
alarm ($timeout);
 eval { recv($remote, $ntp_msg, 4096, 0) 
 	or die "recv: $!\n"; }       
                    }
                    
                               
      if ($ntp_msg =~/cisco/) {
       
log_print ("Found Cisco remote NTP host $target\n ","c" ) ;
        $ntp_msg =~ s/^\s+//;  
        $ntp_msg =~ s/\"//g ;               
 @fields = split(/,/, $ntp_msg);
 foreach (@fields) {
 	if ($_ =~/version/) {
 	$_ =~s/mversion=//i;
 	$_=~ s/^\s+//;

log_print ("**NTP daemon:$_ \n", "c");
 	}
 	if ($_ =~/processor/) {
    $_ =~s/processor=//i;
 	$_=~ s/^\s+//;
 log_print ("**Processor:$_ \n", "c") ;
 	}
 	if ($_ =~/system/) {
 	$_ =~s/system=//i;
 	$_=~ s/^\s+//;
 log_print ("**Operation system:$_ \n \n", "c");
 }
 }
 alarm (0);
 	}
 	return 1;
 	}
 
 
 
  
sub ntp_installed
    {
my $ndata;
my $timeout = 2;

    	
$ndata = pack "C*",(0xDB, 0x00, 0x04, 0xFA, 0x00, 0x01,
    	  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
		  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		  0x00, 0x00, 0xBE, 0x78, 0x2F, 0x1D, 0x19, 0xBA,
		  0x00, 0x00);
$remote = IO::Socket::INET -> new(Proto => "udp", PeerAddr => $target,
                                      PeerPort => 123,
                                      Timeout => $timeout);
                                 
                                      
                    if ($remote)
                    {
# send the ntp-request to the server
    $remote -> send($ndata);
        
     
# receive the ntp-message from the server
$SIG{ALRM} = \&timed_out;
  alarm ($timeout);
 eval { $remote -> recv($ndata, length(4096),0);
              close $remote;
              alarm (0);
              } 
             
             }
         if ($ndata)
		  { 
		   
	       return (1);
                   
        
}
return (0);
}

 1;