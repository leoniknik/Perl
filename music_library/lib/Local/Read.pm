package Local::Read;
use strict;
use warnings FATAL => 'all';
use Exporter 'import';
our @EXPORT = qw(readMusic get_SORT get_COLUMNS);
use lib '/home/kirill/Perl/music_library/lib/';
use Getopt::Long;
my @strings = (
    "./Dreams Of Sanity/1999 - Masquerade/The Phantom of the Opera.mp3\n",
    "./Dreams Of Sanity/1999 - Masquerade/Masquerade Act 1.mp3\n",
    "./Dreams Of Sanity/1999 - Masquerade/Opera.mp3\n",
    "./Dreams Of Sanity/1999 - Masquerade/The Maiden and the River.mp3\n",
    "./Dreams Of Sanity/1999 - Masquerade/Lost Paradise '99.mp3\n",
    "./Dreams Of Sanity/1999 - Masquerade/Masquerade Act 4.mp3\n",
    "./Dreams Of Sanity/1999 - Masquerade/Masquerade Act 2.mp3\n",
    "./Dreams Of Sanity/1999 - Masquerade/Masquerade - Interlude.mp3\n",
    "./Dreams Of Sanity/1999 - Masquerade/Within (The Dragon).mp3\n",
    "./Dreams Of Sanity/1999 - Masquerade/Masquerade Act 3.mp3\n",
    "./Midas Fall/2015 - The Menagerie Inside/Low.ogg\n",
    "./Midas Fall/2015 - The Menagerie Inside/Holes.ogg\n",
    "./Midas Fall/2015 - The Menagerie Inside/Push.ogg\n",
    "./Midas Fall/2015 - The Menagerie Inside/The Morning Asked and I Said 'No'.ogg\n",
    "./Midas Fall/2011 - The Menagerie Inside/Afterthought...mp3\n",
    "./Midas Fall/2012 - The Menagerie Inside/Half a Mile Outside.mp3\n",
    "./Midas Fall/2013 - The Menagerie Inside/Tramadol Baby.mp3\n",
    "./Midas Fall/2015 - The Menagerie Inside/A Song Built From Scraps of Paper.ogg\n",
    "./Midas Fall/2015 - The Menagerie Inside/Counting Colours.ogg\n",
    "./Midas Fall/2015 - The Menagerie Inside/Circus Performer.ogg\n");
my %keys = (
    band => '',
    year => 0,
    album => '',
    track => '',
    format => '',
);

sub get_SORT {
    return $keys{"sort"};
}
sub get_COLUMNS {
    return $keys{"columns"};
}

GetOptions("band=s" => \$keys{"band"}, "year=s" => \$keys{"year"}, "album=s" => \$keys{"album"},
    "track=s" => \$keys{"track"}, "format=s" => \$keys{"format"},
    "sort=s" => \$keys{"sort"}, "columns=s" => \$keys{"columns"});

sub readMusic {
    my $string;
    my %dict = ();
    my $count = 0;
    if ($keys{"year"}) {
        $keys{"year"} = int($keys{"year"});
    }
    while ($string = <>) {
        chomp($string);
        my ($band, $year, $album, $track, $format) = ($string =~/^\.\/(.+)\/(\d+)\s\-\s(.+)\/(.+)\.+(.+)$/);
        $year = int($year);
        my %table = (
            "band"   => $band,
            "year"   => $year,
            "album"  => $album,
            "track"  => $track,
            "format" => $format,
        );
        my $value = 1;
        foreach my $i (keys %table) {
            if ($keys{"$i"}) {
                if ($i ne "year") {
                    if ($table{$i} ne $keys{$i}) {
                        $value = 0;
                        last;
                    }
                } else {
                    if ($table{$i} != $keys{$i}) {
                        $value = 0;
                        last;
                    }
                }
            }
        }
        if ($value) {
            $dict{$count} = \%table;
            $count++;
        }
    }
    return \%dict;
}


1;