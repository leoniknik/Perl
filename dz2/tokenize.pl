=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

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

sub tokenize {
	
    chomp( my $expr = shift );
	my @split = split m{(\s+|[*()/^]|(?<!e)[+-])}x, $expr;
	my @temp= grep ( !m/^(\s*|)$/, @split );
    my @res = ();
    my $skobka = 0;
    my $operators = 0;
    my $numbers = 0;
    my $prev = "";
    my $prev_type = "";
    for (@temp) {
        if ( $_ =~ m/^[-+]$/ and $prev =~ m/^((\(|\s|)|([\+\-\/\*\^\(]))$/ )
		{
            $prev_type = "unary";
			if ($_ eq "+") {
                 push(@res, "U+");
            }
            if ($_ eq "-") {
                 push(@res, "U-");
            }
        }
        elsif ( $_ =~ m/^\d+$/ ) {
            $numbers += 1;
            $prev_type = "num";
            push( @res, $_ )
        }
        elsif ( $_ =~ m/^\d*\.?\d+((e?[-+]?\d+)|(\d*))$/ ) {
            $numbers += 1;
            $prev_type = "num";
            push( @res,  0+$_ );
        }
        else {
			if (( $_ =~ m/^([\+\-\*\/\^])$/)) {
                $prev_type = "operator";
				$operators += 1;
            }
			else
			{
				$prev_type = "skobka";
				if ($_ =~ m/^\($/) {
                    $skobka += 1;
                }
				elsif($_ =~ m/^\)$/)
				{
					$skobka -= 1;
				}
                
			}
            push( @res, $_ );
        }
        $prev = $_;
    }

    if ( !$numbers ) {
        die "Ошибка, это не число";
    }

    if ( $skobka ) {
        die "Неверное число ()";
    }

    if (!($numbers == $operators + 1)) {
        die "Неверное число операторов и чисел"
    };

    return \@res;
}

1;

