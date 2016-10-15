package Local::JSONParser;

use utf8;
use JSON::XS;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );
use Encode;
use Unicode::Escape 'unescape';
#test
my $numberOfStart = 0;
sub parse_json {
	my $source = shift;
	$source =~ s/\n//gm;
	if (!$numberOfStart) {
		$source = numerize($source);
		$$numberOfStart++;
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
				(?<object>(\d+)\{.*\}\3)\s*,						#Шаблон для объекта
				|
				(?<array>(\d+)\[.*\]\5)\s*,							#Шаблон для массива
				|
				(?<string>"(?:[^"\\]|\\(?:["\\\/bfnrt]|(?:u\d{4})))*")\s*,		#Шаблон для string
				|
				(?<number>(?:\-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE](?:\+|\-)?\d+)?))\s*,	#Шаблон для number
				)
			}{}xm) {
			my ($string, $number, $object, $array) = ($+{string}, $+{number}, $+{object}, $+{array});
			if ($string) {
				$string =~ s/^"//;
				$string =~ s/"$//;
				$string = toText($string);
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
			(?<key>"(?:[^"\\]|\\(?:["\\\/bfnrt]|(?:u\d{4})))+") #Шаблон key
				\s*\:\s*
				(
				(?:
				(?<object>(\d+)\{.*\}\4)\s* 				#Шаблон для объекта
				|
				(?<array>(\d+)\[.*\]\6)\s*					#Шаблон для массива
				|
				(?<string>"(?:[^"\\]|\\(?:["\\\/bfnrt]|(?:u\d{4})))*")\s*    #Шаблон для string
				|
				(?<number>(?:\-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE](?:\+|\-)?\d+)?))\s*		#Шаблон для number
				)
				)\s*,
			}{}xm) {

			my ($key, $string, $number, $object, $array) = ($+{key}, $+{string}, $+{number}, $+{object}, $+{array});
			$key =~ s/^"//;
			$key =~ s/"$//;
			$key = toText($key);
			if ($string) {
				$string =~ s/^"//;
				$string =~ s/"$//;
				$string = toText($string);
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
			die "Error";
		}
		return \%result;
	} else {
		die "Error";
	}
	#return JSON::XS->new->utf8->decode($source);
	return {};
}

sub toText {
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

sub numerize {
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

#parse_json('{ "key1":"string \u0451 \n value","key2":-3.1415,"key3": ["nested array"],"key4":{"nested":"object"}}');
1;