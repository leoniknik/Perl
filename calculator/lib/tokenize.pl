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
    my @temp = grep ( !m/^(\s*|)$/, split m{
            (
                (?<!e) [+-]
                |
                [*()/^]
                |
                \s+
            )
        }x, $expr );
    my @res;

    my $skobka = 0;
    my $operators = 0;
    my $numbers = 0;
    my $prev = "";
    my $prev_type = "";

    for (@temp) {
        if ( $_ =~ m/^[-+]$/ and $prev =~ m/^((\(|\s|)|([\+\-\/\*\^\(]))$/ ) {
            $prev_type = "unary";
            push( @res, "U" . $_ );
        }
        elsif ( $_ =~ m/^\d+$/ ) {
            $numbers += 1;
            $prev_type = "num";
            push( @res, "" . $_ )
        }
        elsif ( $_ =~ m/^\d*\.?\d+((e?[-+]?\d+)|(\d*))$/ ) {
            $numbers += 1;
            $prev_type = "num";
            push( @res,  0+$_ );
        }
        else {
            $prev_type = ( $_ =~ m/^([\+\-\*\/\^])$/ ? "operator" : "skobka" );
            $operators += ( $_ =~ m/^([\+\-\*\/\^])$/ ? 1 : 0 );
            $skobka += ( $_ =~ m/^\($/ ? 1 : ( $_ =~ m/^\)$/ ? -1 : 0 ) );
            push( @res, $_ );
        }
        $prev = $_;
    }

    if ( !$numbers ) {
        die "Не число";
    }

    if ( $skobka ) {
        die "Неверное количество скобок";
    }

    if (!($numbers == $operators + 1)) {
        die "Неверное количество операторов!"
    };

    return \@res;
}

1;
