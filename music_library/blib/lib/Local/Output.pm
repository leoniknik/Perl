package Local::Output;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw(printResult);
use lib '/home/kirill/Perl/music_library/lib/';
sub max {
    my $x = shift();
    my $y = shift();
    if ($x > $y) {
        return $x;
    } else {
        return $y;
    }
}
sub printResult {
    #list
    my $columnsFromKey = shift();
    if (!$columnsFromKey) {
        $columnsFromKey = "band,year,album,track,format";
    }
    my @colNames = split(/,/, $columnsFromKey);
    my %list = %{shift()};
    if (scalar(keys %list) == 0) {
        return 0;
    }
    my %len = (
        "band" => 0,
        "year" => 0,
        "album" => 0,
        "track" => 0,
        "format" => 0,
    );
    foreach my $i (keys %list) {
        foreach my $j (keys %len) {
            $len{$j} = max($len{$j}, length $list{$i}{$j});
        }
    }
    my $strLen = 0;
    foreach my $i (@colNames) {
        $strLen += $len{$i} + 2;
    }
    $strLen += scalar(@colNames) - 1;
    print ("/");
    for (my $i = 0; $i < $strLen; $i++) {
        print ("-");
    }
    print ("\\"."\n");
    my @order = @{shift()};
    foreach my $i (@order) {
        foreach my $j (@colNames) {
            print "|";
            for (my $k = 1; $k <= $len{$j} - length($list{$i}{$j}) + 1; $k++) {
                print " ";
            }
            print $list{$i}{$j}." "
        }
        print "|";
        if ($i != $order[@order - 1]) {
            print "\n";
            print "|";
            foreach my $j (@colNames) {
                for (my $k = 0; $k < $len{$j} + 2; $k++) {
                    print "-";
                }
                if ($j ne $colNames[@colNames - 1]) {
                    print "+";
                } else {
                    print "|";
                }
            }
            print "\n";
        } else {
            print "\n";
            print "\\";
            for (my $i = 0; $i < $strLen; $i++) {
                print "-";
            }
            print "/"."\n";
        }
    }
}
1;