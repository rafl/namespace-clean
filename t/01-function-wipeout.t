#!/usr/bin/env perl
use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More tests => 5;

use_ok('FunctionWipeout');
ok( !FunctionWipeout->can('foo'),
    'imported function removed' );
ok( !FunctionWipeout->can('bar'),
    'previously declared function removed' );
ok( FunctionWipeout->can('baz'),
    'later declared function still exists' );
is( FunctionWipeout->baz, 23,
    'removed functions still bound' );

