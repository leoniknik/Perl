package Local::Format;

use strict;
use warnings;

sub makeList {
	my ($lib, $columns) = @_;
	my @ready_lib;

	for my $line (@$lib) {
		my @node;
		for my $column (@$columns) {
			push @node, $line->{$column};
		}
		push @ready_lib, \@node;
	}

	return \@ready_lib;
}

sub format {
	my ($lib, $count) = @_;	
	my @max_space = map { 0 * $_ } (0..$count-1);

	for my $line (@$lib) {
		my @arr = @$line;
		for my $iter (0..$#arr) {
			if (length $arr[$iter] > $max_space[$iter]) {
				$max_space[$iter] = length $arr[$iter];
			}
		}
	}

	return \@max_space;
}

1;