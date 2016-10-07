=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";


sub rpn {
    my $value   = shift;
    my @temp = @{tokenize($value)};
	
    my @stack;
    my @rpn;

    my $value = "";

    my %operators = (
        "U-" => { "prior" => "5", "assoc" => "right" },
        "U+" => { "prior" => "5", "assoc" => "right" },
        "^"  => { "prior" => "4", "assoc" => "right" },
        "*"  => { "prior" => "3", "assoc" => "left" },
        "/"  => { "prior" => "3", "assoc" => "left" },
        "+"  => { "prior" => "2", "assoc" => "left" },
        "-"  => { "prior" => "2", "assoc" => "left" },
    );

    for (@temp) {
        given ($_)
		{
            when ($_ =~ m/\d+\.?\d*/)
			{
                push(@rpn, $_);
            }
            when ($_ =~ m/^[\(]$/)
			{
                push(@stack, $_);
            }
            when ($_ =~ m/^[\)]$/)
			{
                while ($stack[-1] !~ m/^[\(]$/)
				{
                    push(@rpn, pop(@stack));
                }
                pop(@stack);
            }
            when ($_ =~ m/^(U[\+\-]|[\+\-\*\/\^])$/)
			{
                while (((@stack)&&($stack[-1] =~ m/^(U[\+\-]|[\+\-\*\/\^])$/))&&
					   (
							(
                                ($operators{$_}->{"assoc"} eq "left") &&
                                ($operators{$_}->{"prior"} <= $operators{$stack[-1]}->{"prior"})
                            )
                            ||
                            (
                                ($operators{$_}->{"assoc"} eq "right") &&
                                ($operators{$_}->{"prior"} < $operators{$stack[-1]}->{"prior"})
                            )
                        )
                ) {
                    push(@rpn, pop(@stack));
                };
                push(@stack, $_);
            }
        }
    }
    while (@stack) {
        push(@rpn, pop(@stack));
    }

    return \@rpn;
}

1;
