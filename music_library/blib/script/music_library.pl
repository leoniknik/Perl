#!/usr/bin/env perl
use strict;
use warnings;
use lib '/home/kirill/Perl/music_library/lib/';
use Local::Read qw(readMusic get_SORT get_COLUMNS);
use Local::Sort qw(sorting);
use Local::Output qw(printResult);
my %dict = %{readMusic()};
my $sortFromKey = get_SORT();
my $columnsFromKey = get_COLUMNS();
my @order = (0..scalar(keys %dict) - 1);
if ($sortFromKey) {
    @order = @{sorting(\%dict, \@order, $sortFromKey)};
}
printResult($columnsFromKey, \%dict, \@order);