
sub usage
{
	print( " version $version\nusage: ./cisco-torch.pl <options> <IP,hostname,network>\n\n");
	print("or: ./cisco-torch.pl <options> -F <hostlist>\n\n");
	print("Available options:\n");
	print("-O <output file>\n");
	print("-A\t\tAll fingerprint scan types combined\n");
	print("-t\t\tCisco Telnetd scan\n");
	print("-s\t\tCisco SSHd scan\n");
	print("-u\t\tCisco SNMP scan\n");
	print("-g\t\tCisco config or tftp file download\n");
	print("-n\t\tNTP fingerprinting scan\n");
	print("-j\t\tTFTP fingerprinting scan\n");
	print("-l <type>\tloglevel\n");
	print("\t\tc  critical (default)\n");
	print("\t\tv  verbose\n");
	print("\t\td  debug\n");
	print("-w\t\tCisco Webserver scan\n");
	print("-z\t\tCisco IOS HTTP Authorization Vulnerability Scan\n");
	print("-c\t\tCisco Webserver with SSL support scan\n");
	print("-b\t\tPassword dictionary attack (use with -s, -u, -c, -w , -j or -t only)\n");
	print("-V\t\tPrint tool version and exit\n");
	print("examples:\t./cisco-torch.pl -A 10.10.0.0\/16\n");
	print("\t\t./cisco-torch.pl -s -b -F sshtocheck.txt\n");
        print("\t\t./cisco-torch.pl -w -z 10.10.0.0\/16\n");
	print("\t\t./cisco-torch.pl -j -b -g -F tftptocheck.txt\n");
}

sub banner
{
	log_print("###############################################################\n", "c" );
	log_print("#   Cisco Torch Mass Scanner  $version                 #\n", "c" );
        log_print("#   Becase we need it...                                      #\n", "c" );
	log_print("#   http://www.arhont.com/cisco-torch.pl                      #\n", "c" );
	log_print("###############################################################\n", "c" );
	log_print( "\n", "c" );
}

sub banner_end
{
	log_print("###############################################################\n", "c" );
	log_print("#   Cisco Torch Mass Scanner  $version                 #\n", "c" );
        log_print("#   ALL scan is done                                         #\n", "c" );
	log_print("#   http://www.arhont.com/cisco-torch.pl                      #\n", "c" );
	log_print("###############################################################\n", "c" );
	log_print( "\n", "c" );
}
 1;
