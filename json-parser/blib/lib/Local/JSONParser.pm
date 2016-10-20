package Local::JSONParser;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );
no warnings 'experimental';

sub parse_json {
    my $source = shift;
    my ($res) = parse($source);

    return $res;
}

sub parse {
    my $pattern_num = qr/\-?(?:[1-9]\d*|0)(?:\.\d+)?(?:[eE][\+-]?\d+)?/;
    my $pattern_str = qr/\"(?:[^"\\]|\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4}))*\"/;
    my $source = shift;
    my %patterns = (
        number => \{pattern => $pattern_num, parser => \&num},
        string => \{pattern => $pattern_str, parser => \&str}
    );
    for (values %patterns) {
        if ($source =~ /^(${$$_}{pattern})(.*)/sg) {
            return wantarray ? (${$$_}{parser}($1), $2) : ${$$_}{parser}($1);
        }
    }
    if ($source =~ /\G\s*\{\s*(.*)/sgc) {
        my %h;
        $source = $1;

        die "Not a JSON" if ($source =~ /^\s*$/);

        while ($source =~ /[\w\{\[,]/sg){
            my $key; my $val;

            die "Not a JSON" if !(defined ($source));

            ($key, $source) = parse($source);
            $source =~ s/\s*:\s*//;

            die "Not a JSON" if !(defined ($source));

            ($val, $source) = parse($source);

            die "Not a JSON" if !(defined ($source));

            $h{$key} = $val;

            die "Not a JSON" if ($source =~ /^\s*$/);

            $source =~ s/^\s*,\s*//;
            last if ($source =~ s/^\s*\}//);
        }
        return wantarray ? (\%h, $source) : \%h;
    }
    if ($source =~ /\G\s*\[\s*(.*)/sgc) {
        my @arr;
        $source = $1;

        die "Not a JSON" if ($source =~ /^\s*$/);
        while ($source =~ /[\w\{\[,]/sg) {
            my $val;

            ($val, $source) = parse($source);

            die "Not a JSON" if !(defined ($source));

            push @arr, $val;

            die "Not a JSON" if ($source =~ /^\s*$/);

            $source =~ s/^\s*,\s*//;
            last if ($source =~ s/^\s*\]//);
        }
        return wantarray ? (\@arr, $source) : \@arr;
    }
    return {};
}

sub str {
    $_ = shift;
    s/"$//;
    s/^"//;
    s/\\n/\n/g;
    s/\\t/\t/g;
    s/\\b/\b/g;
    s/\\f/\f/g;
    s/\\r/\r/g;
    s/\\"/"/g;
    s/\\u([0-9a-fA-F]{4})/chr(hex($1))/ge;
    return $_;
}

sub num {
    $_ = shift;
    return (0+$_);
}

#parse_json('{ "key1":"string \u0451 \n value","key2":-3.1415,"key3": ["nested array"],"key4":{"nested":"object"}}');

1;