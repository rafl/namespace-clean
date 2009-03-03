#!/usr/bin/env perl
use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More tests => 19;

use_ok('CleaneeTarget');

ok  CleaneeTarget->can('IGNORED'),  'symbol in exception list still there';
ok  CleaneeTarget->can('NOTAWAY'),  'symbol after import call still there';
ok !CleaneeTarget->can('AWAY'),     'normal symbol has disappeared';

ok !CleaneeTarget->can('x_foo'),    'explicitely removed disappeared (1/2)';
ok  CleaneeTarget->can('x_bar'),    'not in explicit removal and still there';
ok !CleaneeTarget->can('x_baz'),    'explicitely removed disappeared (2/2)';

ok !CleaneeTarget->can('d_foo'),    'directly removed disappeared (1/2)';
ok  CleaneeTarget->can('d_bar'),    'not in direct removal and still there';
ok !CleaneeTarget->can('d_baz'),    'directly removed disappeared (2/2)';

my @values = qw( 23 27 17 XFOO XBAR XBAZ 7 8 9 );
is(CleaneeTarget->summary->[ $_ ], $values[ $_ ], sprintf('testing sub in cleanee (%d/%d)', $_ + 1, scalar @values))
    for 0 .. $#values;
