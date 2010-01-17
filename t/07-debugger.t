#!/usr/bin/perl -d

use Test::More;

BEGIN {
    # apparently we can't just skip_all with -d, because the debugger breaks at
    # Test::Testers END block
    if ($] <= 5.008008) {
        pass;
        done_testing;
    }
    else {
        push @DB::typeahead, "c";
    }

    push @DB::typeahead, "q";

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

ok( !Foo->can("foo"), "foo cleaned up" );
ok( !Foo->can("baz"), "baz cleaned up" );

Foo->bar();

done_testing;
