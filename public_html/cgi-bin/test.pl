#!/usr/bin/perl

use strict;
use DBI();
require "cgi-lib.pl";
$|++; # hot output.

# header HTML
print &PrintHeader;
print &HtmlTop ("varios tests");
print "<br><br>";


print "<h2>Test de sleep y localtime: </h2><br>\n";
#--------------------------------------------------
for (my $i=1; $i<4; $i++){
    print $i . " " . scalar(localtime(time)) . "<br>\n";
    sleep 1;
}
print "<br><br>\n";



print "<h2>Versiones Perl Y OS:</h2><br>\n";
#--------------------------------------------------
print "Version Perl: $] <br>\n";
print "OS: $^O <br>\n";
print "<br><br>\n";


print "<h2>Test cjpeg: </h2><br>\n";
#--------------------------------------------------
my $CJPEG="";
if ( -e "/usr/local/bin/cjpeg" && -x "/usr/local/bin/cjpeg" ) { $CJPEG="/usr/local/bin/cjpeg";}
if ( -e "/usr/bin/cjpeg" && -x "/usr/bin/cjpeg" ) { $CJPEG="/usr/bin/cjpeg";}
if ( -e "./cjpeg" && -x "./cjpeg" ) { $CJPEG="./cjpeg";} 

if ($CJPEG eq  ""){
    print "No se encontro cjpeg <br>\n";
}
else {
    if (! system(`$CJPEG -progressive ../images/tux.bmp > ../images/tux.jpg`)) { 
	print "Fallo: No se pudo evaluar $CJPEG <br>\n";
	print "\$\@: $@ <br>\$!: $! <br>\$^E: $^E <br>\n";
    }
    else {
	print "Path: $CJPEG <br>\n";
	print "<br><img src=\"../images/tux.jpg\"><br>\n";
    }
}
print "<br><br>\n";




print "<h2>Test acceso a Mysql: </h2><br>\n";
#--------------------------------------------------

#conectar a la base de datos test
my $dbh = DBI->connect("DBI:mysql:database=ae000008_test;host=localhost","ae000008_www", "");

if (! $dbh) {
    print "No se pudo conectar a la base de datos test en localhost, como user fulano sin pwd.<br>\n";
}
else {
    print "- creando tabla \"tabla123\"<br>\n";
    $dbh->do("CREATE TABLE test123 (id INTEGER, nombre VARCHAR(30))");

    print "- insertando valor 1,Orka con quotes <br>\n";
    $dbh->do("INSERT INTO  test123 VALUES (1, " . $dbh->quote("Orka") . ")");

    print "- insertando valor 2,Meyer con place holes<br>\n";
    $dbh->do("INSERT INTO  test123 VALUES (?, ?)", undef, 2, "Meyer");

    print "- lectura de datos:<br>\n";
    my $sth = $dbh->prepare("SELECT * FROM test123");
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {
	print "id = $row->{'id'}, nombre = $row->{'nombre'} <br>\n";
    }
    $sth->finish();
    
    print "- eliminando la \"tabla123\"\n";
    $dbh->do("DROP TABLE test123");

    #desconectar
    $dbh->disconnect();
}

print "<br><br>\n";
print &HtmlBot;
