#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;

require "$FindBin::Bin/../lib/Local/Parse.pm";
require "$FindBin::Bin/../lib/Local/Sort.pm";
require "$FindBin::Bin/../lib/Local/Print.pm";
require "$FindBin::Bin/../lib/Local/Format.pm";

my %keys = %{Local::Parse::getOptions()};

my @lib = @{Local::Parse::parse()};

my @filtered_lib = @{Local::Sort::filter(\@lib, \%keys)};

my @sorted_lib = defined $keys{sort} ? @{Local::Sort::sort(\@filtered_lib, \%keys)} : @filtered_lib;

my @ready_lib = @{Local::Format::makeList(\@sorted_lib, $keys{columns})};

my @required_space = @{Local::Format::format(\@ready_lib, scalar(@{$keys{columns}}))};

Local::Print::print(\@ready_lib, \@required_space);
