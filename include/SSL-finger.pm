#*********************************************************************************

sub ssl_finger 
{
  
$Net::SSLeay::trace = 0;

# Net::SSLeay  timeot bug
my $timeout =1;

eval {
local $SIG{'ALRM'} = sub { die "Timeout Alarm" };
alarm ($timeout); 

($page, $response, @headers)
         = get_https($target, 443, '/',                   
                make_headers(User-Agent => 'Cisco-torch/0.2b',
                             Referer    => 'https://www.arhont.com'
                ));
    if ($EVAL_ERROR and ($EVAL_ERROR eq 'Timeout Alarm')) {
        print "**** Time Out\n";
        return 0;
    }
   
 
   
          if ($page, $response, @headers) {

	if ($lines = grep m/PIX/, @headers) 
	
		{
			log_print ("Cisco PIX firewall by SSL WWW found\n\n", "c");
			for ($i = 0; $i < $#headers; $i+=2) {
          log_print ("$headers[$i] = " . $headers[$i+1] . "\n" , "c");
          
          
			}
		 return (1);	
     }
    if ($lines = grep m/Cisco-IOS/, @headers) 
    
     {
			log_print ("Cisco OS by SSL WWW found\n\n", "c");
			for ($i = 0; $i < $#headers; $i+=2) {
          log_print ("$headers[$i] = " . $headers[$i+1] . "\n" ,"c");
             
			
			}
			 return (1);
		
     }

}  
alarm 0;

}
 
		
}
 1;