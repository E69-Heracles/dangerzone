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
    
    # find if he has at least 1 sortie
    $sth = $dbh->prepare("SELECT missions FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($hlname);
    @row = $sth->fetchrow_array;
    
    if (! $row[0]){
	print  "Content-Type: text/html\n\n";
	print  "Pilot has no mission to plot\n";
	return (1); # no missions to plot
    }

    else {

	$sth = $dbh->prepare("SELECT state FROM $pilot_mis_tbl WHERE hlname=? order by misrep ASC");
	$sth->execute($hlname);
	
	print SORT "0 0\n"; 
	print BAIL "0 0\n"; 
	print DISC "0 0\n"; 
	my $mis=0;
	while ( @row = $sth->fetchrow_array ) {
	    $mis++; $mis_vivo++;
	    if ($mis_vivo>$max_mis) {$max_mis=$mis_vivo;}

	    if ($row[0] =~ m/ail/){
		print BAIL "$mis  $mis_vivo\n"; 
	    }
	    if ($row[0] =~ m/isco/){
		print DISC "$mis  $mis_vivo\n"; 
	    }

	    print SORT "$mis  $mis_vivo\n"; 
	    if ($row[0] =~ m/(Muerto|capturado|Kia|captured|Killed)/){
		$mis_vivo=0;
		print SORT "$mis.001  $mis_vivo\n"; 
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
my $sorties="sorties".int(rand(1000000)+1000000);
my $bail="bail".int(rand(1000000)+1000000);
my $disco="disco".int(rand(1000000)+1000000);
open (SORT,">$PD/$sorties") || die " $0 : ". scalar(localtime(time))." no se puede abrir $PD/$sorties \n";
open (BAIL,">$PD/$bail") || die " $0 : ". scalar(localtime(time))." no se puede abrir $PD/$bail \n";
open (DISC,">$PD/$disco") || die " $0 : ". scalar(localtime(time))." no se puede abrir $PD/$disco \n";

&ReadParse(%in); # Read data
$hlname=$in{'hlname'};
$hlname=~ s/^ *//g;
$hlname=~ s/ *$//g;
if ($hlname =~ m/ / || $hlname eq ""){ 
    print  "Content-Type: text/html\n\n";
    print  "incorrect name\n";
    exit(0);
}

$max_mis=0;
build_data();

if ($max_mis){
    
    print  "Content-Type: image/png\n\n";
    sleep 1;
    open(GP,"|$GNUPLOT_PROG");
    print GP "set terminal png small  xffffff x000000 x404040 x0000ff x008000 xdf0000 xd0d0d0\n";
    print GP "set grid 4\n";
    print GP "set time\n";
    print GP "set key left top\n";
    print GP "set yrange [0:".($max_mis+3)."]\n";
    print GP "set data style lines\n";
    print GP "set title \"$hlname - All missions\"\n";
#    print GP "test\n quit\n";
#    print GP "plot x**2, x**3;\n";
#    print GP "plot \"$PD/$sorties\" title \"Missions per live \"\n quit\n";
#    print GP "plot \"$PD/$bail\" title \"Bailed \"\n quit\n";
#    print GP "plot \"$PD/$disco\" title \"Disco \"\n quit\n";
    print GP "plot \"$PD/$sorties\" title \"Missions per live \",\"$PD/$bail\"  title \"Bailed \" w p pointtype 6 ps 1,\"$PD/$disco\" title \"Disco \" w p pointtype 6 ps 1\n quit\n";



    close(GP) || die " $0 : ". scalar(localtime(time))." No se pudo cerrar pipe!\n";
}
close (SORT);
close (BAIL);
close (DISC);
unlink "$PD/$sorties";
unlink "$PD/$bail";
unlink "$PD/$disco";
exit (0);



# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
$pilot_file_tbl=$pilot_file_tbl;
$pilot_mis_tbl=$pilot_mis_tbl;
$CGI_TEMP_UPLOAD_DIR=$CGI_TEMP_UPLOAD_DIR;
