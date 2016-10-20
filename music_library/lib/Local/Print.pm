package Local::Print;

use strict;
use warnings;
use feature 'say';

sub isEnd {
	my ($current_pos, $last_index) = @_;
	if ($current_pos == $last_index) {
		return 1;
	}
	else
	{
		return 0;
	}
}

sub print {
	my ($lib, $space) = @_;
	my $lib_len = scalar(@$lib);
	
	if ($lib_len == 0 || scalar(@$space) == 0) {
		return 0;
	}

	my $head_line = '/' . (join '', (map {'-'x($_ + 3)} @$space));
	chop ($head_line);
	$head_line .= '\\';

	my $skip_line = "\n|" . (join '+', (map {'-'x($_ + 2)} @$space)) . "|\n";

	say $head_line;

	for my $line_iter (0..$lib_len-1) {
		
		my @arr = @{$lib->[$line_iter]};
		
		print '|';
		for my $iter (0..$#arr) {
			print map {' '} ( 0..($space->[$iter] - length $arr[$iter]) );
			print $arr[$iter];
			print ' |';
		}
		if (isEnd($line_iter, $lib_len - 1)) {
			print "\n";
		} else {
			print $skip_line;
		}
	}

	my $bottom_line = '\\' . (join '', (map {'-'x($_ + 3)} @$space));
	chop($bottom_line);
	$bottom_line .= '/';

	say $bottom_line;
}

1;