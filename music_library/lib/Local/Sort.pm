package Local::Sort;
use strict;
use warnings FATAL => 'all';
use Exporter 'import';
our @EXPORT = ('sorting');
use lib '/home/kirill/Perl/music_library/lib/';
sub sorting {
    my %list = %{shift()};
    my @order = @{shift()};
    my $sortFromKey = shift();
    if ($sortFromKey eq "year") {
        @order = sort{(0 + $list{$a}{"$sortFromKey"}) <=> (0 + $list{$b}{"$sortFromKey"})} @order;
    } else {
        @order = sort{$list{$a}{"$sortFromKey"} cmp $list{$b}{"$sortFromKey"}} @order;
    }
    return \@order;
}
1;
