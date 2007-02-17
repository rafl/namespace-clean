package namespace::clean;

=head1 NAME

namespace::clean - Keep imports out of your namespace

=cut

use warnings;
use strict;

use vars              qw( $VERSION );
use Symbol            qw( qualify_to_ref );
use Filter::EOF;

=head1 VERSION

0.01

=cut

$VERSION = 0.01;

=head1 SYNOPSIS

  package Foo;
  use warnings;
  use strict;

  use Carp qw(croak);   # will be removed

  sub bar { 23 }        # will be removed

  use namespace::clean;

  sub baz { bar() }     # still defined, 'bar' still bound

  ### Will print:
  #   No
  #   No
  #   Yes
  print +(__PACKAGE__->can('croak') ? 'Yes' : 'No'), "\n";
  print +(__PACKAGE__->can('bar')   ? 'Yes' : 'No'), "\n";
  print +(__PACKAGE__->can('baz')   ? 'Yes' : 'No'), "\n";

  1;

=head1 DESCRIPTION

When you define a function, or import one, into a Perl package, it will
naturally also be available as a method. This does not per se cause
problems, but it can complicate subclassing and, for example, plugin
classes that are included by loading them as base classes.

The C<namespace::clean> pragma will remove all previously declared or
imported symbols at the end of the current package's compile cycle.
This means that functions are already bound by their name, and calls to
them still work. But they will not be available as methods on your class
or instances.

=head1 METHODS

You shouldn't need to call any of these. Just C<use> the package at the
appropriate place.

=head2 import

Makes a snapshot of the current defined functions and registers a 
L<Filter::EOF> cleanup routine to remove those symbols from the package
at the end of the compile-time.

=cut

sub import {
    my ($pragma) = @_;

    my $cleanee   = caller;
    my $functions = $pragma->get_functions($cleanee);
    
    Filter::EOF->on_eof_call(sub {
        for my $f (keys %$functions) {
            next unless $functions->{ $f } 
                    and *{ $functions->{ $f } }{CODE};
            {   no strict 'refs';
                delete ${ "${cleanee}::" }{ $f };
            }
        }
    });
}

=head2 get_functions

Takes a class as argument and returns all currently defined functions
in it as a hash reference with the function name as key and a typeglob
reference to the symbol as value.

=cut

sub get_functions {
    my ($pragma, $class) = @_;

    return {
        map  { @$_ }
        grep { *{ $_->[1] }{CODE} }
        map  { [$_, qualify_to_ref( $_, $class )] }
        grep { $_ !~ /::$/ }
        do   { no strict 'refs'; keys %{ "${class}::" } }
    };
}

=head1 SEE ALSO

L<Filter::EOF>

=head1 AUTHOR AND COPYRIGHT

Robert 'phaylon' Sedlacek C<E<lt>rs@474.atE<gt>>, with many thanks to
Matt S Trout for the inspiration on the whole idea.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
