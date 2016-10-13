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
    my @source = grep ( !m/^(\s*|)$/, split m{
            (
                (?<!e) [+-]
                |
                [*()/^]
                |
                \s+
            )
        }x, $expr );
    my @result;

    my $parenthes = 0;
    my $operators = 0;
    my $numbers = 0;
    my $previous = "";
    my $previous_type = "";

    for (@source) {
        if ( $_ =~ m/^[-+]$/ and $previous =~ m/^((\(|\s|)|([\+\-\/\*\^\(]))$/ ) {
            $previous_type = "unary";
            push( @result, "U" . $_ );
        }
        elsif ( $_ =~ m/^\d+$/ ) {
            $numbers += 1;
            $previous_type = "num";
            push( @result, "" . $_ )
        }
        elsif ( $_ =~ m/^\d*\.?\d+((e?[-+]?\d+)|(\d*))$/ ) {
            $numbers += 1;
            $previous_type = "num";
            push( @result,  sprintf("%g", $_) );
        }
        else {
            $previous_type = ( $_ =~ m/^([\+\-\*\/\^])$/ ? "operator" : "skobka" );
            $operators += ( $_ =~ m/^([\+\-\*\/\^])$/ ? 1 : 0 );
            $parenthes += ( $_ =~ m/^\($/ ? 1 : ( $_ =~ m/^\)$/ ? -1 : 0 ) );
            push( @result, $_ );
        }
        $previous = $_;
    }

    if ( !$numbers ) {
        die "There's no number!";
    }

    if ( $parenthes ) {
        die "Mismatch number of parentheses!";
    }

    if (!($numbers == $operators + 1)) {
        die "Mismatch numbers and operators!"
    };

    return \@result;
}

1;
