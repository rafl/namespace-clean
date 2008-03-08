#!/usr/bin/env perl
use warnings;
use strict;

use inc::Module::Install;

name            q{namespace-clean};
license         q{perl};
author          q{Robert 'phaylon' Sedlacek <rs@474.at>};
all_from        q{lib/namespace/clean.pm};

build_requires  q{Test::More},                  '0.62';
build_requires  q{FindBin},                     0;

requires        q{Scope::Guard},                '0.02';
requires        q{Symbol},                      0;

auto_provides;
auto_install;

if (-e 'MANIFEST.SKIP') {

    print "Creating README file\n";
    system 'pod2text lib/namespace/clean.pm > README';

    print "Adding author tests to 'make test' run\n";
    tests 't/*.t t_author/*.t';
}

WriteAll;
