use strict;
my $expr = "- 16 + 2 * 0.3e+2 - .5 ^ ( 2 - 3 )";

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

sub rpn {
        my @stack=(); #объявляем массив стека
        my @out=(); #объявляем массив выходной строки
	
        my %prior = ( #задаем приоритет операторов, а также их ассоциативность
			"U-" => {"prior" => "5", "assoc" => "right"},
            "U+" => {"prior" => "5", "assoc" => "right"},
            "^"=> {"prior" => "4", "assoc" => "right"},
			"*"=> {"prior" => "3", "assoc" => "left"},
			"/"=> {"prior" => "3", "assoc" => "left"},
			"+"=> {"prior" => "2", "assoc" => "left"},
			"-"=> {"prior" => "2", "assoc" => "left"},
	);
	my $expr = shift;
	my @token = @{tokenize($expr)};
	my @rpn;

	#@$token =~ s/\s//g; #удалим все пробелы
	#$token=str_replace(",", ".", $token);#поменяем запятые на точки
	#my @token = split// ,$token;
	#проверим, не является ли первый символ знаком операции - тогда допишем 0 перед ним */
	
	#if (!($token[0] =~ /[\+\-\*\/\^]/)){unshift @token, "0";}
	my $endop;
    	my $curr_assoc;
    	my $curr_prior;
    	my $may_unary= 1;
    	my $lastnum = 0;
	#my $lastnum = 1;
	foreach (@token)
	{
        my $value = $_;
	
		if ($value =~ /[\+\-\*\/\^]/)#если встретили оператор
			{
                if ($may_unary&&$value eq "-") {
                    $value = "U-";
                }
                if ($may_unary&&$value eq "+") {
                    $value = "U+";
                }
				$endop = 0; #маркер конца цикла разбора операторов
				
				while ($endop != 1)
				{
					my $lastop = pop(@stack);
					if ($lastop eq "")
					{
                            push(@stack,$value); #если в стеке нет операторов - просто записываем текущий оператор в стек
                            $endop = 1; #укажем, что цикл разбора while закончилс
					}
					
					else #если в стеке есть операторы - то последний сейчас в переменной $lastop
					{
						# получим приоритет и ассоциативность текущего оператора и сравним его с $lastop 
						$curr_prior = $prior{$value}->{'prior'}; #приоритет текущиего оператора
						$curr_assoc = $prior{$value}->{'assoc'}; #ассоциативность текущиего оператора
						
						my $prev_prior = $prior{$lastop}->{'prior'}; #приоритет предыдущего оператора
		
						if ($curr_assoc eq "left")
                        {   #оператор - лево-ассоциативный
								
									if ($curr_prior > $prev_prior) #если приоритет текущего опертора больше предыдущего, то записываем в стек предыдущий, потом текйщий
                                    {
                                        push(@stack,$lastop);
                                    	push(@stack,$value);
                                        $endop = 1; #укажем, что цикл разбора операторов while закончился	
                                    }
									
									elsif($curr_prior <= $prev_prior)#если тек. приоритет меньше или равен пред. - выталкиваем пред. в строку out[]
									{
                                            push(@out,$lastop);
                                    }
						}
						elsif ($curr_assoc eq "right")#оператор - право-ассоциативный
						{	
									if ($curr_prior >= $prev_prior) #если приоритет текущего опертора больше или равен предыдущего, то записываем в стек предыдущий, потом текйщий
									{
                                            push(@stack,$lastop);
                                            push(@stack,$value);
                                            $endop = 1; #укажем, что цикл разбора операторов while закончился
                                    }
									
									elsif ($curr_prior < $prev_prior) #если тек. приоритет меньше пред. - выталкиваем пред. в строку out[]
									{
                                        push(@out,$lastop);
                                    }
						}		
								
                    }
						
					
				
                } #while ($endop != TRUE)
				$lastnum = 0; #укажем, что последний разобранный символ - не цифра
                $may_unary= 1;
		}
		elsif ($value =~ /[0-9\.]/) #встретили цифру или точку
			{
                
		#Мы встретили цифру или точку (дробное число). Надо понять, какой символ был разобран перед ней. 
		#За это отвечает переменная $lastnum - если она TRUE, то последней была цифра.
		#В этом случае надо дописать текущую цифру к последнему элменту массива выходной строки*/
				if ($lastnum == 1)  #разобранный символ - цифра
					{
						my $num = pop(@out); #извлечем содержимое последнего элемента массива строки
						push(@out,$num.$value);
					}
				
				else 
					{
						push(@out,$value); #если последним был знак операции - то открываем новый элемент массива строки
						$lastnum = 1; #и указываем, что последним была цифра
					}
                    $may_unary = 0;
			}
		 
		elsif ($value eq "(") #встреили скобку ОТкрывающую
			{
		#Мы встретили ОТкрывающую скобку - надо просто поместить ее в стек*/
						push(@stack,$value); 
						$lastnum = 0; # указываем, что последним была НЕ цифра
                $may_unary = 1;
            }
			
		elsif ($value eq ")") #встреили скобку ЗАкрывающую
			{
                
		#Мы встретили ЗАкрывающую скобку - теперь выталкиваем с вершины стека в строку все операторы, пока не встретим ОТкрывающую скобку*/
						my $skobka = 0; #маркер нахождения открывающей скобки
						while ($skobka != 1) #пока не найдем в стеке ОТкрывающую скобку
						{
							my $op = pop(@stack); #берем оператора с вершины стека
							
								if ($op eq "(") 
								{
									$skobka = 1; #если встретили открывающую - меняем маркер
								} 
								
								else
								{
									push(@out,$op); #если это не скобка - отправляем символ в строку
								}
							
								
						}
						
						$lastnum = 0; #указываем, что последним была НЕ цифра
                        $may_unary = 0;
			}	
	
	}
	#foreach закончился - мы разобрали все выражение
	#теперь вытолкнем все оставшиеся элементы стека в выходную строку, начиная с вершины стека*/

	#$stack1 = $stack; //временный массив, копия стека, на случай, если будет нужен сам стек для дебага
	@rpn = @out; #начинаем формировать итоговую строку
	
	while (my $stack_el = pop(@stack))
	{
		push(@rpn,$stack_el);
	}
	
	my $rpn_str;
    for(@rpn){
        $rpn_str.="$_ ";
    }
    #запишем итоговый массив в строку
    chop($rpn_str);
	@rpn = split/\s/,$rpn_str; #функция возвращает строку, в которой исходное выражение представлено в ОПЗ

	return \@rpn;
}

sub calc
{
	my @stack = ();
    my $temp = shift;
	my @token = @{$temp};
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
	return pop(@stack);
}
print calc(rpn($expr));
