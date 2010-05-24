#!env perl -w

use Compress::Zlib;
use Getopt::Long;

$create = '';

GetOptions(
	'create' => \$create
	);

$ENV{PATH} = $ENV{PATH} . ';c:\Program Files\mySQL\MySQL Server 5.0\bin';

if ($create) {
	print "Enter MySQL password for user 'root': ";
	$password = <STDIN>;

	print "[*    ] Creating Database and User\n";
	system("mysql -f -u root -p$password < CREATE.SQL") and die "Can't create database and user\n";
}

chdir("../..");

print "[**   ] Running migrations to create tables\n";
	system("rake db:migrate") and die "Migration failed\n";

print "[***  ] Clearing existing CIS course data\n";
	system("mysql -usoco -pmonkey soco_development < \"db/data/development/TRUNCATE CIS Data.sql\"") and die "Truncate failed\n";

print "[**** ] Importing CIS course data\n";

	my $gz = gzopen("db/data/development/CIS Data.sql.gz", "rb") or die "Data import failed\n";

	open(MYSQL, "| mysql -usoco -pmonkey soco_development") or die "Data import failed\n";

	print MYSQL $buffer while ($gz->gzread($buffer) > 0);

	die "Error reading from db/data/development/CIS Data.sql.gz: $gzerrno " . ($gzerrno+0) . "\n" 
		if $gzerrno != Z_STREAM_END ;

	$gz->gzclose();

	close(MYSQL);

print "[*****] Creating testing tables\n";
	system("rake db:test:clone_structure") and die "Testing table creation failed\n";

print "Finished!\n";

