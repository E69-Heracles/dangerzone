#!/usr/bin/perl 

require "config.pl";
require "cgi-lib.pl";
require "ui.pl";
use DBI();

$|=1; # hot output

# db stuff
my @row;
my $dbh;
my $sth;

# data
my $del_hlname="";
my $del_pwd="";


my $sqd_id=0;
my $sqd_pref="";


sub update_data(){

    $del_hlname=$in{'hlname'};
    $del_pwd=$in{'pwd'};


    $del_hlname=~ s/^ *//g;
    $del_hlname=~ s/ *$//g;

    if ($del_hlname  =~ m/ / || $del_hlname eq "" ) {
	print "<font color=\"red\" size=\"+1\">ERROR:</font>  Null name. <br>\n";
	return(0);
    }
    if ($del_pwd eq "") {
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Null password.<br>\n";
	return(0);
    }

    # db connect
    $dbh = DBI->connect("DBI:mysql:database=$database;host=localhost","$db_user", "$db_upwd");

    if (! $dbh) { 
	print "Can't connect to DB\n";
	die "$0: Can't connect to DB\n";
    }

    #verify Password of  del_hlname
    $sth = $dbh->prepare("SELECT password FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($del_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    if ($row[0] ne $del_pwd) { #pwd no match
	print "<font color=\"red\" size=\"+1\">ERROR:</font> Your password is incorrect<br>\n";
	return(0);
    }

    # html special chars on $del_hlname
    $html_del_hlname=$del_hlname;
    $html_del_hlname =~ s/</&lt;/g;
    $html_del_hlname =~ s/>/&gt;/g;
    
    # get del_hlname sqadron
    $sth = $dbh->prepare("SELECT in_sqd_id,in_sqd_name,sqd_accepted FROM $pilot_file_tbl WHERE hlname=?");
    $sth->execute($del_hlname);
    @row = $sth->fetchrow_array;
    $sth->finish;
    $sqd_id=$row[0];
    $sqd_pref=$row[1];

    # html special chars on $sqd_pref
    $html_sqd_pref=$sqd_pref;
    $html_sqd_pref =~ s/</&lt;/g;
    $html_sqd_pref =~ s/>/&gt;/g;

    if ($row[2] == 1) { # It is  accepted in squadron.
	print "<font color=\"red\" size=\"+1\">ERROR:</font> The pilot $html_del_hlname is an active pilot of squadron $html_sqd_pref <br><br>\n";
	print "To delete pilot profile, you have to first leave the squadron $html_sqd_pref.<br> You can do that using <b>Leave squadron</b> form.<br>\n";
	return(0);
    }

    # if we are here: $sqd_id=1 and $sqd_prefix=NONE

    print "<h3>Deleting $html_del_hlname:</h3><br>\n";

    $dbh->do("DELETE from $pilot_file_tbl WHERE hlname=\"$del_hlname\"");
    $dbh->do("DELETE from $pilot_mis_tbl WHERE hlname=\"$del_hlname\"");
    $dbh->do("DELETE from $air_events_tbl WHERE hlkiller=\"$del_hlname\"");
    $dbh->do("DELETE from $ground_events_tbl WHERE hlkiller=\"$del_hlname\"");
    $dbh->do("DELETE from $rescue_tbl WHERE rescatador=\"$del_hlname\"");

    open (PILOT_LOG, ">>Pilot_log.txt") || die "$0 : " .scalar(localtime(time)) ." Can't open File Pilot_log.txt $!\n";
    print PILOT_LOG  "- ". scalar(localtime(time)) ." $del_hlname has been deleted from database\n";
    close (PILOT_LOG);

    print "+ $html_del_hlname deleted<br>\n";
    print "<br>Return to <a href=\"/mng_sqd.php\">register menu</a><br>\n";

}


# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------

print &PrintHeader;
print &print_start_html();

# Limit upload size to avoid overflws
$cgi_lib::maxdata = 512; 
$cgi_lib::maxdata = 512; 

&ReadParse(%in); # Read data
update_data();

print &print_end_html();
exit (0);

# useless lines to avoid used only once messages 
$database=$database;
$db_user=$db_user;
$db_upwd=$db_upwd;
$pilot_file_tbl=$pilot_file_tbl;
$pilot_mis_tbl=$pilot_mis_tbl;
$air_events_tbl=$air_events_tbl;
$ground_events_tbl=$ground_events_tbl;
$rescue_tbl=$rescue_tbl;
