#!/usr/bin/env perl
use strict;
use Data::Dumper;
my %table;
my @people;
no warnings 'experimental::smartmatch';
my @strings = ("Али Ольга\n","Ира\n");
my $suprug = 1;
my $drug = 1;
foreach my $x (@ARGV)
{
    #ключи на семинаре не доделал
}
for(<STDIN>)
{
    chomp;
    my @pair = split /\s+/,$_;
    if (scalar @pair > 1)
    {
        $table{$pair[0]} = [$pair[1],$pair[0]];
        $table{$pair[1]} = [$pair[0],$pair[1]];
        push(@people,$pair[0]);
        push(@people,$pair[1]);
    }
    else
    {
        $table{$pair[0]} = [$pair[0]];
        push(@people,$pair[0]);
    }

}
for my $value (keys %table)
{    
    
    my $val =  $table{$value};
    #print Dumper([$val,$value]);
    my $flag = 1;
    while ($flag)
    {
        my @numbers = ();
        my $ch = int(rand((scalar keys %table)));
        if (not($ch ~~ @numbers)) {
            push(@numbers, $ch);
        }
        if (not($people[$ch] ~~ @{$val})) {
            push(@{$val},$people[$ch]);
            $table{$value} = $val;
            $val = $table{$people[$ch]};
            push(@{$val},$value);
            $table{$people[$ch]} = $val;
            print ("$value->$people[$ch]\n");
            $flag = 0;
            
        }
        if (scalar @numbers == scalar @people) {
            $flag = 0;
            @numbers = ();
        }
    }
}


