package Local::Parse;

use strict;
use warnings;
use Getopt::Long;

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

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

sub getOptions {

	my %keys = (
		band => undef,
		year => undef,
		album => undef,
		track => undef,
		format => undef,
		sort => undef,
		columns => undef);

	GetOptions(	"band=s" => \$keys{band},
				"year=s" => \$keys{year},
				"album=s" => \$keys{album},
				"track=s" => \$keys{track},
				"format=s" => \$keys{format},
				"sort=s" => \$keys{sort},
				"columns=s" => \$keys{columns});

	if (defined ($keys{columns})) {
		$keys{columns} = [split /,/, $keys{columns}];
	} else {
		$keys{columns} = ['band','year','album','track','format'];
	}
	return \%keys;
}

sub parse {
	my @lib;
	while (my $val = <>) {
		chomp $val;
		my @str = split m[\/], $val;
		my $band = $str[1];
		my ($year, $album) = split m[\-], $str[2];
		my ($track, $format) = split m[\.], $str[3];
		$album =~ s/\s//;
		chop($year);
		my %item = (band => $band,
		            year => $year, 
		            album => $album, 
		            track => $track, 
		            format => $format
		            );
		push (@lib, \%item);
	}
	return \@lib;
}
1;