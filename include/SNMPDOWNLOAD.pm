#------------------------------------------------------------------------------- 
# Based Pancho (www.pancho.org)  
# patched for cisco-torch by Arhont Team 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$opts ="download";
%types = (
              cisco   => 'Cisco Systems',
            );
$name = "cisco";



sub fetch_conf {
#Initial setup 
my $target =shift;
my $community = shift;
my $port = 161;
my $filename = "$target.conf";           


open(FILEHANDLE, "> $tftprootdir/$filename") || die("cannot open file:". $!);

close(FILEHANDLE);

## resolve fqdn/hostname for tftpserver
if ($tftpserver =~ /[a-zA-Z]/) {
  my $i = gethostbyname($tftpserver);
  $tftpserver = inet_ntoa($i);
}

%args = ( Hostname => $target, Community => $community, Port => $port,
 src => "run", dst => "tftp", tftp => $tftpserver, file => $filename );
 
discover_vendor ($args);
}

sub create_snmp {
my $args = shift;



## initiate session with v1/2c values
$new_session = Net::SNMP->session(Hostname => $args{Hostname}, Community => $args{Community}, 
Port => $args{Port});
$new_session->timeout(2);
$new_session->retries(1);
return $new_session;
}

sub discover_vendor {
  my $args = shift;

#*********************************************************************************	






  ## sysdescr OID
  my %oid = ( version => ".1.3.6.1.2.1.1.1.0" );
  
  ## set up initial parameters for this nodes snmp session(s)
  $s = create_snmp($args);

  ## test for successful presence of a net::snmp session
  if (!$s) {
    $args->{err} = "SNMP session failed to be created for $args{host}!";
    print "SNMP session failed to be created for $args{host}!";    
    return 1;
  }
    ## grab the ios major revision number
  my $vendor_description = $s->get_request($oid{version});

  ## grab an error if it exists
  $args->{err} = $s->error;

  ## close the snmp session
  $s->close;
 
  ## if the ios is undeterminable log it to screen and skip
  if ($args->{err}) {
    ## if the remote device is not able to be queried
         print " remote device is not able to be queried $args{err}!";
    ## after logging the error, skip to next host
    return 1;
  }
       ## place sysDescr return into $args value
       $args->{desc} = $vendor_description->{$oid{version}};
        
 
     ## place our vendor into our dialogue hash
    $args->{vndr} = device_description($args->{desc});

     process_device($args);
     ## run post commands

 
}



#------------------------------------------------------------------------------- 
# device_description
# IN : scalar containing sysdescr
# OUT: returns scalar containing description or 'Unknown' if it doesn't exist
#------------------------------------------------------------------------------- 
sub device_description {
   my $name = shift || return 0;
   my $sn = '';
   
   if ($sn = (grep { $name =~ m/$_/gi } keys %types)[0]) {

     return $types{$sn};
    
   } else {
      return 'Unknown';

   }
}

#------------------------------------------------------------------------------- 
# process_device - figures out what device type we have and tries to
# operate on it based on args given
# IN : args - hash ref containing various program args
#      opts - hash ref of options passed into program
#------------------------------------------------------------------------------- 
sub process_device {
$args = shift;
 
  if ($opts =="download") {
     
    ## test to see which os is on remote node
    if ($args->{desc} =~ /Version 1(?:1|0)/) {

      ## place our vendor into our dialogue hash
      $args->{vndr} = 'Cisco (IOS 10.x/11.x)';

      ## run for 10.x and 11.x
      &cisco_transfer_deprecated($args);

      ## detect Catalyst 2950/3550 with 12.1(12) or higher
    } elsif ($args->{desc} =~ /C(?:35|29)50.*Version 12.[1-9]\(1[2-9]/) {

      ## place our vendor into our dialogue hash
      $args->{vndr} = 'Cisco IOS 12.1(12+) C3550|C2950';

      &cisco_transfer_cccopy($args);

      ## detect Catalyst 2900XL/3500XL
    } elsif ($args->{desc} =~ / C(?:(?:800)|35(?:(?:50)|(?:00XL))) /) {
                                                                                
      ## place our vendor into our dialogue hash
      $args->{vndr} = 'Cisco C3500XL/C2950/C3550/C800';
         
      &cisco_transfer_deprecated($args);

    } elsif ($args->{desc} =~ /Version 12/) {

      ## place our vendor into our dialogue hash
      $args->{vndr} = 'Cisco (IOS 12.x)';

      ## run for 12.x
      &cisco_transfer_cccopy($args);

    } elsif ($args->{desc} =~ /(?:Catalyst)|(?:WS-)/i) {

      ## place our vendor into our dialogue hash
      $args->{vndr} = 'Cisco CatalystOS';

      ## run for Catalysts
      &cisco_transfer_catalyst($args);

    } else {
      ## create error showing that cisco device is not supported
   
       log_print ("The hardware for target is not currently supported. \n" ,"c");
      ## log the error
    

    }
       log_print ("The target vendor $args->{vndr}. \n" ,"c");
  }



  &cisco_commit($args) if ($opts->{commit});

  &cisco_reload($args) if ($opts->{reload});

}

sub cisco_transfer_catalyst { 
  my $args = shift;

print "Start  $args->{vndr}. transfer \n";
  ## set up oid to be used in this routine
  my %oid = (

                ## catalyst switch mibs
                cat_ipaddress   => '.1.3.6.1.4.1.9.5.1.5.1.0',
                cat_filename    => '.1.3.6.1.4.1.9.5.1.5.2.0',
                cat_module      => '.1.3.6.1.4.1.9.5.1.5.3.0',
                cat_action      => '.1.3.6.1.4.1.9.5.1.5.4.0',
                cat_result      => '.1.3.6.1.4.1.9.5.1.5.5.0',
                cat_mod2stdbystatus => '.1.3.6.1.4.1.9.5.1.3.1.1.21.2',

            );
  # interface cards will report other (1) as standby status
  # other possible values are active (2), standby (3), error (4) 

  my %tftpResult =        ( 1     => 'inProgress',
                            2     => 'success',
                            3     => 'No Response',
                            4     => 'Too Many Retries',
                            5     => 'No Buffers',
                            6     => 'No Processes',
                            7     => 'Bad Checksum',
                            8     => 'Bad Length',
                            9     => 'Bad Flash',
                            10    => 'Server Error',
                            11    => 'User Canceled',
                            12    => 'Wrong Code',
                            13    => 'File Not Found',
                            14    => 'Invalid Tftp Host',
                            15    => 'Invalid Tftp Module',
                            16    => 'Access Violation',
                            17    => 'Unknown Status : Check TFTP Server',
                            18    => 'Invalid Storage Device',
                            19    => 'Insufficient Space On Storage Device',
                            20    => 'Insufficient Dram Size',
                            21    => 'Incompatible Image',
                          );

  if (($args->{src} eq 'start') or ($args->{dst} eq 'start')) {
    print "\nCopying configurations to and from startup-config\nis not possible using the CatOS.\n\n";

  } else {

    my $tftpmod = 1;

    ## determine the mib value for where the file will be sent
    my $i;
    if ($args->{src} eq 'tftp') { $i = '2'; } else { $i = '3'; }

    ## create the session
    my $s = create_snmp($args);

    ## check to see if sup in slot 2 is active
    my $mod_standby_state = $s->get_request($oid{cat_mod2stdbystatus});
    if (!$s->error) {
       if ($mod_standby_state->{$oid{cat_mod2stdbystatus}} eq '2') {
          $tftpmod = 2;
       }
    }

    ## set up the request
    $s->set_request	( ## set the tftp server value
			  $oid{cat_ipaddress}, OCTET_STRING, $args{tftp},

		     	  ## set up the config file name
			  $oid{cat_filename}, OCTET_STRING, "$args{file}",
 
		     	  ## prep the module to go
			  $oid{cat_module}, INTEGER, $tftpmod,

		     	  ## send config
			  $oid{cat_action}, INTEGER, $i,		
		   	);

    ## put error into hash
    $args->{err} = $s->error;
    print "$args->{err} \n";
    if (!$args->{err}) {

      ## set default status as "running"
      my $result = '1';

      ## check for the results status
      while (defined($result) && $result == '1') {

        ## get the current status of the tftp server's action
        my $current_state = $s->get_request ($oid{cat_result});

        $result = $current_state->{$oid{cat_result}};

      ## end while
      }


      ## failure!
      if (!defined($result)) {
        $args->{err} = 'SNMP Session failed during transfer';
        log_print ("Error:  $args->{err} \n", "c");
      } elsif ($result != '2') {

        ## add error message into $args hash
        $args->{err} = $tftpResult{$result};
           log_print ("Error:  $args->{err} \n", "c");
      ## endif
      }

    ## endif
    }

    ## close snmp session
    $s->close;

    ## log output to screen and possibly external file
     log_print ("$args->{log} \n", "c" );
      
  }

}



sub cisco_transfer_deprecated {
  my $args = shift;
 

  ## build oid list for subroutine
  my %oid = (	## deprecated lsystem mibs
                wrnet           => '.1.3.6.1.4.1.9.2.1.55.',
                confnet         => '.1.3.6.1.4.1.9.2.1.53.',
            );


  if (($args->{src} eq 'start') or ($args->{dst} eq 'start')) {
    print "\nCopying configurations to and from startup-config\nis not possible using deprecated mibs.\n\n";    
 
  } else {
    my $mib;

    ## set up proper value for $mib
    if ($args->{src} eq 'tftp') {
      $mib = $oid{confnet};
    } else {
      $mib = $oid{wrnet};
    }

    $mib = "$mib$args->{tftp}"; 

    my $s = create_snmp($args);

    ## set up the request
    $s->set_request($mib, OCTET_STRING, "$args->{file}");

    ## put error into hash
    $args->{err} = $s->error;

    ## close snmp session
    $s->close;

    ## log output to screen and possibly external file
    $args->{log}->log_action($args);

  }
}

sub cisco_transfer_cccopy {
  my $args = shift;

 
  ##
  ## NOTES TO SELF ON INCLUDING SCP TRANSPORT PROTOCOL
  ## 	ccCopyUserName AND ccCopyUserPassword
  ##


  ## set up oid to be used in this routine
  my %oid = (
                ## 
                method          => '.1.3.6.1.4.1.9.9.96.1.1.1.1.2',

		##
                source          => '.1.3.6.1.4.1.9.9.96.1.1.1.1.3',

		##
                destination     => '.1.3.6.1.4.1.9.9.96.1.1.1.1.4',

		##
                ipaddress       => '.1.3.6.1.4.1.9.9.96.1.1.1.1.5',

		##
                filename        => '.1.3.6.1.4.1.9.9.96.1.1.1.1.6',

		##
                rowstatus       => '.1.3.6.1.4.1.9.9.96.1.1.1.1.14',

		##
                state           => '.1.3.6.1.4.1.9.9.96.1.1.1.1.10',

		##
                cause           => '.1.3.6.1.4.1.9.9.96.1.1.1.1.13',
             );

  my %filelocation =      ( tftp          => '1',
                            start         => '3',
                            run           => '4',
                          );

  my %state =             ( waiting       => '1',
                            running       => '2',
                            success       => '3',
                            failed        => '4',
                          );

  my %cause =             ( 1     => 'Unknown Copy Failure',
                            2     => 'Bad File Name',
                            3     => 'Network timeout',
                            4     => 'Not Enough Memory',
                            5     => 'Source Configuration doesnt exist.',
                          );


  ## generate random number used for mib instances
  srand(time | $$);
  my $rand = int(rand(900))+10;

  ## start snmp session
  my $s = create_snmp($args);

  ## copy files across network
  $s->set_request   (  ## select method of transfer
                       "$oid{method}.$rand", INTEGER, 1,

                       ## select source file location
                       "$oid{source}.$rand", INTEGER, $filelocation{$args{src}},

                       ## select destination file location
                       "$oid{destination}.$rand", INTEGER, $filelocation{$args{dst}},

                       ## set tftpserver ip address
                       "$oid{ipaddress}.$rand", IPADDRESS, $args{tftp},

                       ## set the filename being written
                       "$oid{filename}.$rand", OCTET_STRING, "/$args->{file}",

                       ## set the session status
                       "$oid{rowstatus}.$rand", INTEGER, 4,
                    );

  ## add error message into $args hash
  $args->{err} = $s->error;
   print "$args->{err}\n";
  ## if no error...
  if (!$args->{err}) {

    ## set default status as "running"
    my $result = '1';

    ## check for the results status
    while( 
           ( defined($result) ) 
             && 
           (
             ($result == "$state{running}") 
               || 
             ($result == "$state{waiting}")
           ) 
         ) {

      ## get the current status of the tftp server's action
      my $current_state = $s->get_request ("$oid{state}.$rand");

      $result = $current_state->{"$oid{state}.$rand"};

    ## end while
    }

    ## failure!
    if (!defined($result)) {
      $args->{err} = 'SNMP Session failed during transfer';

    } elsif ($result != '3') {
 
      ## send snmp reqest to find cause of problem
      my $cause_req = $s->get_request ("$oid{cause}.$rand");

      ## assign result to the value returned from the query
      $result = $cause_req->{"$oid{cause}.$rand"};

      ## add error message into $args hash
      $args->{err} = $cause{$result};

    ## endif
    }

    ## clear the rowstatus for the remote device
    $s->set_request ("$oid{rowstatus}.$rand", INTEGER, 6);
    
  ## endif
  }

  ## close the snmp session
  $s->close;

  ## log output to screen and possibly external file
   log_print ("$args->{log} \n", "c"); 

}




# this must be here or else it won't return true
1;
