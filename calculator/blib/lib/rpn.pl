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
    my $expr = shift;
    my @temp = @{tokenize($expr)};
    my @stack;
    my @rpn;
    my $value = "";
    my %operators = (
        "U-" => { "prec" => "5", "assoc" => "right" },
        "U+" => { "prec" => "5", "assoc" => "right" },
        "^"  => { "prec" => "4", "assoc" => "right" },
        "*"  => { "prec" => "3", "assoc" => "left" },
        "/"  => { "prec" => "3", "assoc" => "left" },
        "+"  => { "prec" => "2", "assoc" => "left" },
        "-"  => { "prec" => "2", "assoc" => "left" },
    );

    for (@temp) {
        given ($_) {
            when ( $_ =~ m/\d+\.?\d*/ ) {
                push(@rpn, $_);
            }
            when ( $_ =~ m/^[\(]$/ ) {
                push(@stack, $_);
            }
            when ( $_ =~ m/^[\)]$/ ) {
                while ( $stack[-1] !~ m/^[\(]$/ ) {
                    push(@rpn, pop(@stack));
                }
                pop(@stack);
            }
            when ( $_ =~ m/^(U[\+\-]|[\+\-\*\/\^])$/ ) {
                while (
                        (
                            (
                                @stack
                            )
                            and
                            (
                                $stack[-1] =~ m/^(U[\+\-]|[\+\-\*\/\^])$/
                            )
                        )
                        and
                        (
                            (
                                ($operators{$_}->{"assoc"} eq "left") and
                                ($operators{$_}->{"prec"} <= $operators{$stack[-1]}->{"prec"})
                            )
                            or
                            (
                                ($operators{$_}->{"assoc"} eq "right") and
                                ($operators{$_}->{"prec"} < $operators{$stack[-1]}->{"prec"})
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
