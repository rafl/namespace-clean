#!/usr/bin/perl -d

BEGIN {
    push @DB::typeahead, "c", "q";

    # try to shut it up at least a little bit
    open my $out, ">", \my $out_buf;
    $DB::OUT = $out;
    open my $in, "<", \my $in_buf;
    $DB::IN = $in;
}

{
    package Foo;

    BEGIN { *baz = sub { 42 } }
    sub foo { 22 }

    use namespace::clean;

    sub bar {
        ::is(baz(), 42);
        ::is(foo(), 22);
    }
}

use Test::More tests => 5;

ok( !Foo->can("foo"), "foo cleaned up" );
ok( !Foo->can("baz"), "baz cleaned up" );

Foo->bar();

pass();
