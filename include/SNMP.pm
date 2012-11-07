
########################################################################
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SNMP finger ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub snmp_ping {

        my $community = public;
        my $port = 161;


        my ($session, $error) = Net::SNMP->session(
                        Hostname        => $target,
                        Community       => $community,
                        Port            => $port
                        );

        if (!defined($session))
        {
                return 0;
        }
        
        my $sysDescr = '1.3.6.1.2.1.1.1.0';
        $session->timeout(1);
        $session->retries(1);
        my $response=" ";

        if (!defined($response = $session->get_request($sysDescr)))
        {
                $session->close;
                return 0;
        }
        
        my $buff = ($response->{$sysDescr} ) ;
    
         if ( $buff =~ /Cisco/ )
		{
	   log_print( "* Cisco by SNMP found ***  \n*System Description: $buff \n\n", "c" );   
                 } 
        
  
        $session->close;
        
      
        return 1;
        
} 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SNMP brute~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sub snmp_bruteforce {      
 my $port = 161;
  open( COMMUNITYFILE,  "<$communityfile") || die " Cannot open the  community file : $communityfile ! \n";
        chomp(@community = <COMMUNITYFILE>);
close(COMMUNITYFILE);

	foreach $community (@community)
	{
       
        my ($session, $error) = Net::SNMP->session(
                        Hostname        => $target,
                        Community       => $community,
                        Port            => $port
                        );
      print "*** Check  $target community SNMP   : $community\n";    
        if (!defined($session))
        {
            
           return 0;
        }
        my $sysDescr = '1.3.6.1.2.1.1.1.0';
        $session->timeout(2);
        $session->retries(2);
        my $response=" ";

        if (defined($response = $session->get_request($sysDescr)))
        {
               
                       
             if  ( $community !~ "public" )
             {                              
                log_print("*** Found no public SNMP community : $community \n", "c"); 
                log_print("***System Description:$response->{$sysDescr}\n", "c" );
              $session->close; 
  
  # If defined config download 
  if ($opt_g) { fetch_conf($target,$community) ;} 
             
              return 0;
}
 
              }
              
     
              }
                        
        }
        
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1;
