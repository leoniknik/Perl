package Local::Sort;

use strict;
use warnings;
use List::Util;

sub num_comparator { my ($a, $b) = @_; return $a != $b; }
sub str_comparator { my ($a, $b) = @_; return $a ne $b; }
sub num_sorter { my ($a, $b, $k) = @_; return $a->{$k} <=> $b->{$k}; }
sub str_sorter { my ($a, $b, $k) = @_; return $a->{$k} cmp $b->{$k}; }

my $comparators = { year   => {compare => \&num_comparator, sort => \&num_sorter},
                    band   => {compare => \&str_comparator, sort => \&str_sorter},
                    album  => {compare => \&str_comparator, sort => \&str_sorter},
                    track  => {compare => \&str_omparator,  sort => \&str_sorter},
                    format => {compare => \&str_comparator, sort => \&str_sorter}
                    };

sub filter {
    my ($lib, $keys) = @_;

    my @necessary_keys = grep {defined($keys->{$_}) and $_ ne 'sort' and $_ ne 'columns'} keys %$keys;    
    my @filtered_lib;
    
    for my $node (@$lib) {
        
        my $flag = 1;
        for my $key (@necessary_keys) {
            $flag = 0 if $comparators->{$key}{compare} ($node->{$key}, $keys->{$key});
        }
        push @filtered_lib, $node if $flag;
    }

    return \@filtered_lib;
}

sub sort {
    my ($lib, $keys) = @_;

    my $sort_key = $keys->{sort};
    @$lib = sort {$comparators->{$sort_key}{sort}($a, $b, $sort_key)} @$lib;

    return $lib;
}

1;