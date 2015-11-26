#!perl

# see http://dev.mysql.com/downloads/dbi.html
# see http://dev.mysql.com/doc/refman/4.1/ja/perl-dbi-class.html
# see http://sql-info.de/mysql/examples/Perl-DBI-examples.html
# see http://www.easysoft.com/developer/languages/perl/dbi-debugging.html

#use strict;
#use warnings;

use DBI;

$username = 'root';
$password = '123456';
$dbname = 'test';

# connect MySQL
#$dbh = DBI->connect('DBI:mysql:databasename', 'username', 'password') || die "Could not connect to database: $DBI::errstr";
$dbh = DBI->connect("DBI:mysql:$dbname", $username, $password) || die "Could not connect to database: $DBI::errstr";
# (insert query examples here...)

# simple query (not select)
$dbh = DBI->connect("DBI:mysql:$dbname", $username, $password) || die "Could not connect to database: $DBI::errstr";
$dbh->do('CREATE TABLE exmpl_tbl (id INT, val VARCHAR(100))');
$dbh->do('INSERT INTO exmpl_tbl VALUES(1, ?)', undef, 'Hello');
$dbh->do('INSERT INTO exmpl_tbl VALUES(2, ?)', undef, 'World');

# typical query (select)
$sth = $dbh->prepare('SELECT val FROM exmpl_tbl WHERE id=1');
$sth->execute();
$result = $sth->fetchrow_hashref();
$sth->finish;
print "Value returned: $result->{val}\n";

# use placeholders in select query
$val = 'World';
$sth = $dbh->prepare('SELECT id FROM exmpl_tbl WHERE val=?');
$sth->execute($val);
@result = $sth->fetchrow_array();
$sth->finish;
print "ID of $val is $result[0]\n";

# read all records one time
$results = $dbh->selectall_hashref('SELECT * FROM exmpl_tbl', 'id');
foreach my $id (keys %$results) {
	print "Value of ID $id is $results->{$id}->{val}\n";
}

# simple query (not select)
$c = $dbh->do('DELETE FROM exmpl_tbl WHERE id=1');
print "Deleted $c rows\n";
$dbh->do('DROP TABLE exmpl_tbl');

# disconnect MySQL
$dbh->disconnect();





