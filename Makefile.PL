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

requires        q{Filter::EOF},                 '0.02';
requires        q{Symbol},                      0;

WriteAll;
