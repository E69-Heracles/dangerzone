#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();

$|=1; # hot output

sub build_data (){

    my @row;
    my $dbh;
    my $sth;

    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");
    if (! $dbh) { 
	print  "Content-Type: text/html\n\n";
	print "Can't connect to DB\n";
	return (1); 
    }
    
    # buscar si el piloto esta registrado
    $sth = $dbh->prepare("SELECT count(*) FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($hlname);
    @row = $sth->fetchrow_array;

    if (! $row[0]){
	print  "Content-Type: text/html\n\n";
	print  "Pilot not found\n";
	return (1); # no se encontro $hlname
    }
    else {
	
	$sth = $dbh->prepare("SELECT state,gkills FROM $pilot_mis_tbl WHERE hlname=? order by misrep ASC");
	$sth->execute($hlname);
	
	print AKxLF "0 0\n"; 
	print AK "0 0\n"; 

	$mis=0;
	$steak=0;
	$akills=0;
	$max_ak=0;
	$scale=0;
	$max_scale=0;

	while ( @row = $sth->fetchrow_array ) {
	    $mis++; 
	    $akills+=$row[1];

	    $steak+=$row[1];
	    if ($steak>$max_ak) {$max_ak=$steak;}

	    if ($mis>10){
		$scale=$akills/$mis;
		if ($scale>$max_scale){$max_scale=$scale;}
	    }

	    print AKxLF "$mis  $steak\n"; 
	    print AK   "$mis  $akills\n"; 

	    if ($row[0] =~ m/(Muerto|capturado|Kia|captured|Killed)/){
		$steak=0;
		print AKxLF "$mis.001  $steak\n"; 
	    }
	}
	$sth->finish;
	return(0);
    }
}





# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------

if (! defined $GNUPLOT_PROG || $GNUPLOT_PROG eq "") {
    print  "Content-Type: text/html\n\n";
    print  "Plots not aviable\n";
    exit(0);
}

my $PD=$CGI_TEMP_UPLOAD_DIR; # PD : Print data Directory, just a temporary place

srand;
my $ak_x_life="ak_x_life$$".int(rand(1000)+1000);
open (AKxLF,">$PD/$ak_x_life") || die " $0 : ". scalar(localtime(time))."  no se puede abrir $PD/$ak_x_life \n";
my $derribos="derribos$$".int(rand(1000)+1000);
open (AK,">$PD/$derribos") || die " $0 : ". scalar(localtime(time))."  no se puede abrir $PD/$derribos \n";


&ReadParse(%in); # Read data
$hlname=$in{'hlname'};
$hlname=~ s/^ *//g;
$hlname=~ s/ *$//g;
if ($hlname =~ m/ / || $hlname eq ""){ 
    print  "Content-Type: text/html\n\n";
    print  "incorrect name\n";
    exit(0);
}

$mis=0;
$steak=0;
$akills=0;
$max_ak=0;
$scale=0;
$max_scale=0;


if (! build_data() ){
    
    print  "Content-Type: image/png\n\n";
    sleep 1;
    open(GP,"|$GNUPLOT_PROG");
    print GP "set terminal png small xffffff x000000 x404040 x0000ff xFF0000 xcccccc xbbbbbb xaaaaaa\n";
 #   print GP "set terminal png  medium xffffff x000000 x404040 x0000ff xdd7000 xcccccc xd0d0d0\n";
    print GP "set grid 4\n";
    print GP "set time\n";
#    print GP "set yrange [0:".($max_mis+3)."]\n";
    print GP "set data style lines\n";
    print GP "set title \"$hlname\"\n";
    print GP "set xlabel \"Misiones\"\n";
    print GP "set ylabel \"Nro. Obj. Terrestres\"\n";
    #print GP "plot x**3; quit\n";
#    print GP "plot \"$PD/$ak_x_life\" title \"Misiones por vida \", \"$PD/$derribos\" title \"Derribos por vida \", \"$PD/$objtierra\" title \"Obj. Terrestres por vida \"\nquit\n";

    print GP "set key left top\n";
    print GP "plot ";
    print GP "1*x t\"1 * mis\" w l lt 3,  ";
    if ($max_scale>1) {print GP " x*2  t\"2 * mis\"  w l lt 3 , ";}
    if ($max_scale>2) {print GP " x*4  t\"4 * mis\"  w l lt 4 , ";}
    if ($max_scale>6) {print GP " x*8  t\"8 * mis\"  w l lt 5 , ";}
    print GP " \"$PD/$ak_x_life\" title \"Ground kills per live (max $max_ak) \" w l lt 1,";
    print GP " \"$PD/$derribos\"  title \"Total ground kills ($akills)\" w l lt 2\n";

    print GP "quit\n";

    close(GP) || die " $0 : ". scalar(localtime(time))."  No se pudo cerrar pipe!\n";
}
close (AKxLF);
unlink "$PD/$ak_x_life";
close (AK);
unlink "$PD/$derribos";
exit (0);



# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
$pilot_file_tbl=$pilot_file_tbl;
$pilot_mis_tbl=$pilot_mis_tbl;
$CGI_TEMP_UPLOAD_DIR=$CGI_TEMP_UPLOAD_DIR;
