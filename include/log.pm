sub log_start
{
	$log_tmp = "";
	$savelog = 1;
}

sub log_write
{
	$header = shift;

	if ($log_tmp)
	{
		open (LOGTMP, ">> $tmplogprefix.$$") || die "Can't open temporary log";
		print LOGTMP $header if $header;
		print LOGTMP $log_tmp; 
		close (LOGTMP);
	}
	$log_tmp = "";
	$savelog = 0;
}

sub log_print
{
	( my $logstring, $_ ) = @_;
	if (/[$llevel]/)
	{ 
		$log_tmp .= $logstring if $savelog;
		print $logstring;
	}
}

sub endbanner
{
	log_print( "--->\n",                                                  "c" );
	log_print( "- All scans done. Cisco Torch Mass Scanner $version -\n", "c" );
	log_print( "---> Exiting.\n",                                         "c" );
}


 1;