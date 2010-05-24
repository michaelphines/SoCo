#!/usr/bin/perl -w
# create an XML-compliant string

use DBI;

sub ConnectToDatabase()
{
	my $dbname = "soco_development";
	my $hostname = "localhost";
	my $username = "soco";
	my $password = "monkey";

	my $DataHandle = DBI->connect("DBI:mysql:database=$dbname;host=$hostname",
						"$username",
						"$password",
						{RaiseError => 1}
						) ||die "Unable to connect to $hostname because $DBI::errstr";

	return $DataHandle;
}

1;
