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
	chomp(my $expr = shift);
	my @temp = split//, $expr;
	my @res;
	my $str_temp = "";
	my $flag = 0;
	my $flag_e = 0;
	for (@temp){
		if ($_ eq " ") {
			if ($flag) {
				push(@res,$str_temp);
				$str_temp = "";
            }
			$flag = 0;
			$flag_e = 0;
        }
		elsif($_ =~ /[0-9\.e]/){
			if ($_ eq "e") {
                $flag_e = 1;
            }
			$flag = 1;
			$str_temp.=$_;
		}
		elsif($_ =~ /[\+\-\*\/\^\(\)]/){
			if ($flag_e&&$_ eq "+") {
                $str_temp.=$_;
				$flag_e = 0;
            }
			else{
				if ($flag) {
				push(@res,$str_temp);
				$str_temp = "";
				$flag = 0;
				}
				push(@res,$_);
				
			}
		}
	}
   	for(@res){
        	if ($_ =~ /[\.e]/){
			$_ = 0+$_;  
        	}
    	}
	return \@res;
}

1;
