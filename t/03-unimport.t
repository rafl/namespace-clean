#!/usr/bin/env perl
use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More tests => 6;

use_ok('Unimport');

ok( !Unimport->can('foo'),
    'first function correctly removed' );
ok( Unimport->can('bar'),
    'excluded method still in package' );
ok( !Unimport->can('baz'),
    'second function correctly removed' );
ok( Unimport->can('qux'),
    'last method still in package' );
is( Unimport->qux, 23,
    'all functions are still bound' );

