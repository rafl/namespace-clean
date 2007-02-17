package ExporterTest;
use warnings;
use strict;

use base 'Exporter';
use vars qw( @EXPORT_OK );

@EXPORT_OK = qw( foo bar );

sub foo { 23 }
sub bar { 12 }

1;
