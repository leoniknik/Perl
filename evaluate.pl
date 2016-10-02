=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub evaluate {
my @stack = ();
	my $str = shift;
	my @token = split /\s/, $str;
	my $res;
	for (@token)
	{
		if ($_ eq "U-") {
			my $x = pop(@stack);
			push(@stack, -$x);
        }
		elsif ($_ eq "U+") {
			my $x = pop(@stack);
			if ($x<0) {
			push(@stack, -$x);
			}
			else{
				push(@stack, $x);
			}
        }
		elsif ($_ =~ /[\+\-\*\/\^]/)
		{
			if (scalar(@stack) < 2)
				{
					print "ошибка";
				}
			my $x = pop(@stack);
			my $y = pop(@stack);
			if ($_ eq '*')
			{
				$res = $y*$x;
			}
			elsif($_ eq '/')
			{
				$res = $y/$x;
			}
			elsif($_ eq '+')
			{
				$res = $y+$x;
			}
			elsif($_ eq '-')
			{
				$res = $y-$x;
			}
			elsif($_ eq '^')
			{
				$res = $y**$x;
			}
			push(@stack, $res);
		} elsif ($_ =~ /[0-9]/)
		{
			push(@stack, $_);
		} else
		{
			print "недопустимый символ";
		}

	}
	if (scalar(@stack) > 1)
	{
		print("Количество операторов не соответствует количеству операндов");
	}
	print (pop(@stack));
	return 0;
}

1;
