package FunctionWipeout;
use warnings;
use strict;

use ExporterTest qw(foo);

sub bar { foo() }

use namespace::clean;

sub baz { bar() }

1;
