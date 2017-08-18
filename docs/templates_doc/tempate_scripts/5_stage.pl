# E69_Heracles@20110910
# Script para la finalización del imap.data
# Este script recoge el imap.data realizado automaticamente por GIMP
# con el fin de anadirle los nombres de sectores en el tag "title"
use IO::Handle;
$|=1;

$IMAPFILENAME = "BES41_imap.data";
$LETRAS = 34; # numero de letras en el mapa
$PRIMERALETRA = "AA";
$NUMEROS = 29; # numeros del mapa

@LETRAS_SEC=("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK","AL","AM","AN","AO","AP","AQ","AR","AS","AT","AU","AV","AW","AX","AY","AZ","BA","BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BO","BP","BQ","BR","BS","BT","BU","BV","BW","BX","BY","BZ");

if (!open (IMAPFILE, "<$IMAPFILENAME")) {
    print " ERROR: No puedo abrir $IMAPFILENAME \n";
    exit(0);
}
if (!open (TEMPIMAPFILE, ">temp_imap.data")) {
    print " ERROR: No puedo crear temp_imap.data \n";
    exit(0);
}

$primera = 0;
for (my $i = 0; $i < scalar(@LETRAS_SEC); $i++ ) {
    if ($LETRAS_SEC[$i] eq $PRIMERALETRA) {
        $primera = $i;
        last;
    }
}

print STDOUT "Letra $PRIMERALETRA en contrada en $primera\n";
for (my $j = $NUMEROS; $j > 0; $j--) {
    for (my $i = $primera; $i < ($primera + $LETRAS); $i++) {
        $n = $j;
        if ($n < 10) {
            $n = "0".$j;
        }
        print STDOUT "Para sector " . $LETRAS_SEC[$i] .  $n . "\n";
        while (<IMAPFILE>) {
            if ( $_ =~ m/area shape/) {
                print STDOUT $_;
                $line = $_;                
                $sector = "title=\"sector--" . $LETRAS_SEC[$i] . $n . "\" tooltip=\"" . $LETRAS_SEC[$i] . $n . "\" alt=\"sector--" . $LETRAS_SEC[$i] . $n . "\"";
                $line =~ s/(^<area shape="rect") ([^\s]+  [^\s]+ \/>)/$1 $sector $2/;
                print STDOUT $line;
                print TEMPIMAPFILE $line;                
                last;
            }
            else {
                print TEMPIMAPFILE;
            }
        }
    }
}

print TEMPIMAPFILE "</map>";
close IMAPFILE;
close TEMPIMAPFILE;
