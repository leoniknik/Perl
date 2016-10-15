#!/usr/bin/perl
use utf8;
use JSON::XS;
use strict;
use Unicode::Escape 'unescape';
use Encode;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );
#test
sub encodeToText {
    my $string = shift();
    if ($string eq "") {
        return $string;
    }
    $string = unescape($string);
    $string =~ s/\\b/\b/g;
    $string =~ s/\\f/\f/g;
    $string =~ s/\\n/\n/g;
    $string =~ s/\\r/\r/g;
    $string =~ s/\\t/\t/g;
    $string =~ s/\\\//\//g;
    $string =~ s/\\"/"/g;
    $string =~ s/\\\\/\\/g;

    return decode('utf8', $string);
}

sub numBracket {
    my @num = ();
    my $count = 1;
    my $source = shift;
    my @arr = split(//, $source);
    foreach my $i (@arr) {
        if ($i eq '[' or $i eq '{') {
            $i = $count.$i;
            push(@num, $count++);
        } elsif ($i eq ']' or $i eq '}') {
            $i = $i.pop(@num);
        }
    }
    return join('', @arr);
}
my $idBracket = 0;
sub parse_json {
    my $source = shift;
    $source =~ s/\n//gm;
    if (!$idBracket) {
        $source = numBracket($source);
        $idBracket = 1;
    }
    my ($firstChar) = ($source =~ /([\[|\{])/);
    if ($firstChar eq '[') {
        #array

        $source =~ s/(\d+\[)//;
        $source =~ s/(.*)(\]\d+)/$1/;
        if (!$2) {
            die "Error";
        }
        my @result;
        my $copySource = $source;
        $copySource =~ s/\s*//gm;
        if (length($copySource) == 0) {
            return \@result;
        }
        $source .= ",";

        while ($source =~ s{
            (
                #Шаблон для объекта
                (?<object>(\d+)\{.*\}\3)\s*,
                |
                #Шаблон для массива
                (?<array>(\d+)\[.*\]\5)\s*,
                |
                #Шаблон для string
                (?<string>"(?:[^"\\]|\\(?:["\\\/bfnrt]|(?:u\d{4})))*")\s*,
                |
                #Шаблон для number
                (?<number>(?:\-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE](?:\+|\-)?\d+)?))\s*,
                )
            }{}xm) {
            my ($string, $number, $object, $array) = ($+{string}, $+{number}, $+{object}, $+{array});
            #ищем отдельные элементы массива, если они "элементарные", то сразу добавляем
            #иначе запускаемся рекурсивно дальше
            if ($string) {
                $string =~ s/^"//;
                $string =~ s/"$//;
                $string = encodeToText($string);
                push(@result, $string);
            } elsif ($object) {
                push(@result, parse_json($object));
            } elsif ($array) {
                push(@result, parse_json($array));
            } elsif ($number or $number == 0) {
                push(@result, $number);
            }
        }
        $source =~ s/\s*//g;
        if (length($source) != 0) {
            die "Error";
        }
        return \@result;
    } elsif ($firstChar eq '{') {
        #object

        $source =~ s/(\d+\{)//;
        $source =~ s/(.*)(\}\d+)/$1/;
        if (!$2) {
            die "Error";
        }
        my %result;
        my $copy = $source;
        $copy =~ s/\s*//gm;
        if (length($copy) == 0) {
            return \%result;
        }
        $source .= ",";
        while ($source =~ s{
            #Шаблон key
            (?<key>"(?:[^"\\]|\\(?:["\\\/bfnrt]|(?:u\d{4})))+")
                \s*\:\s*
                (
                (?:
                #Шаблон для объекта
                (?<object>(\d+)\{.*\}\4)\s*
                |
                #Шаблон для массива
                (?<array>(\d+)\[.*\]\6)\s*
                |
                #Шаблон для string
                (?<string>"(?:[^"\\]|\\(?:["\\\/bfnrt]|(?:u\d{4})))*")\s*
                |
                #Шаблон для number
                (?<number>(?:\-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE](?:\+|\-)?\d+)?))\s*
                )
                )\s*,
            }{}xm) {

            my ($key, $string, $number, $object, $array) = ($+{key}, $+{string}, $+{number}, $+{object}, $+{array});
            $key =~ s/^"//;
            $key =~ s/"$//;
            $key = encodeToText($key);
            if ($string) {
                $string =~ s/^"//;
                $string =~ s/"$//;
                $string = encodeToText($string);
                $result{$key} = $string;
            } elsif ($object) {
                $result{$key} = parse_json($object);
            } elsif ($array) {
                $result{$key} = parse_json($array);
            } elsif ($number or $number == 0) {
                $result{$key} = $number;
            }
        }
        $source =~ s/\s*//g;
        if (length($source) != 0) {
            #Аналогично с обработкой массива
            die "Error";
        }
        return \%result;
    } else {
        #Если изначально не было открывающей скобки, а на вход всегда должен подаваться либо [], либо {}
        #Выдаем ошибку
        die "Error";
    }
    #return JSON::XS->new->utf8->decode($source);
    return {};
}

parse_json('{ "key1":"string \u0451 \n value","key2":-3.1415,"key3": ["nested array"],"key4":{"nested":"object"}}');
