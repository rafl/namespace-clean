package namespace::clean;

=head1 NAME

namespace::clean - Keep imports and functions out of your namespace

=cut

use warnings;
use strict;

use vars              qw( $VERSION $STORAGE_VAR );
use Symbol            qw( qualify_to_ref );
use Filter::EOF;

=head1 VERSION

0.04

=cut

$VERSION     = 0.04;
$STORAGE_VAR = '__NAMESPACE_CLEAN_STORAGE';

=head1 SYNOPSIS

  package Foo;
  use warnings;
  use strict;

  use Carp qw(croak);   # 'croak' will be removed

  sub bar { 23 }        # 'bar' will be removed

  # remove all previously defined functions
  use namespace::clean;

  sub baz { bar() }     # 'baz' still defined, 'bar' still bound

  # begin to collection function names from here again
  no namespace::clean;

  sub quux { baz() }    # 'quux' will be removed

  # remove all functions defined after the 'no' unimport
  use namespace::clean;

  # Will print: 'No', 'No', 'Yes' and 'No'
  print +(__PACKAGE__->can('croak') ? 'Yes' : 'No'), "\n";
  print +(__PACKAGE__->can('bar')   ? 'Yes' : 'No'), "\n";
  print +(__PACKAGE__->can('baz')   ? 'Yes' : 'No'), "\n";
  print +(__PACKAGE__->can('quux')  ? 'Yes' : 'No'), "\n";

  1;

=head1 DESCRIPTION

When you define a function, or import one, into a Perl package, it will
naturally also be available as a method. This does not per se cause
problems, but it can complicate subclassing and, for example, plugin
classes that are included via multiple inheritance by loading them as 
base classes.

The C<namespace::clean> pragma will remove all previously declared or
imported symbols at the end of the current package's compile cycle.
Functions called in the package itself will still be bound by their
name, but they won't show up as methods on your class or instances.

By unimporting via C<no> you can tell C<namespace::clean> to start
collecting functions for the next C<use namespace::clean;> specification.

You can use the C<-except> flag to tell C<namespace::clean> that you
don't want it to remove a certain function. A common use would be a 
module exporting an C<import> method along with some functions:

  use ModuleExportingImport;
  use namespace::clean -except => [qw( import )];

=head1 METHODS

You shouldn't need to call any of these. Just C<use> the package at the
appropriate place.

=cut

=head2 import

Makes a snapshot of the current defined functions and registers a 
L<Filter::EOF> cleanup routine to remove those symbols at the end 
of the compile-time.

=cut

sub import {
    my ($pragma, %args) = @_;

    # calling class, all current functions and our storage
    my $cleanee   = caller;
    my $functions = $pragma->get_functions($cleanee);
    my $store     = $pragma->get_class_store($cleanee);

    my %except    = map {( $_ => 1 )} @{ $args{ -except } || [] };

    # register symbols for removal, if they have a CODE entry
    for my $f (keys %$functions) {
        next if     $except{ $f };
        next unless    $functions->{ $f } 
                and *{ $functions->{ $f } }{CODE};
        $store->{remove}{ $f } = 1;
    }

    # register EOF handler on first call to import
    unless ($store->{handler_is_installed}) {
        Filter::EOF->on_eof_call(sub {
          SYMBOL:
            for my $f (keys %{ $store->{remove} }) {

                # ignore already removed symbols
                next SYMBOL if $store->{exclude}{ $f };
                no strict 'refs';

                # keep original value to restore non-code slots
                local *__tmp = *{ ${ "${cleanee}::" }{ $f } };
                delete ${ "${cleanee}::" }{ $f };

              SLOT:
                # restore non-code slots to symbol
                for my $t (qw( SCALAR ARRAY HASH IO FORMAT )) {
                    next SLOT unless defined *__tmp{ $t };
                    *{ "${cleanee}::$f" } = *__tmp{ $t };
                }
            }
        });
        $store->{handler_is_installed} = 1;
    }

    return 1;
}

=head2 unimport

This method will be called when you do a

  no namespace::clean;

It will start a new section of code that defines functions to clean up.

=cut

sub unimport {
    my ($pragma) = @_;

    # the calling class, the current functions and our storage
    my $cleanee   = caller;
    my $functions = $pragma->get_functions($cleanee);
    my $store     = $pragma->get_class_store($cleanee);

    # register all unknown previous functions as excluded
    for my $f (keys %$functions) {
        next if $store->{remove}{ $f }
             or $store->{exclude}{ $f };
        $store->{exclude}{ $f } = 1;
    }

    return 1;
}

=head2 get_class_store

This returns a reference to a hash in a passed package containing 
information about function names included and excluded from removal.

=cut

sub get_class_store {
    my ($pragma, $class) = @_;
    no strict 'refs';
    return \%{ "${class}::${STORAGE_VAR}" };
}

=head2 get_functions

Takes a class as argument and returns all currently defined functions
in it as a hash reference with the function name as key and a typeglob
reference to the symbol as value.

=cut

sub get_functions {
    my ($pragma, $class) = @_;

    return {
        map  { @$_ }                                        # key => value
        grep { *{ $_->[1] }{CODE} }                         # only functions
        map  { [$_, qualify_to_ref( $_, $class )] }         # get globref
        grep { $_ !~ /::$/ }                                # no packages
        do   { no strict 'refs'; keys %{ "${class}::" } }   # symbol entries
    };
}

=head1 IMPLEMENTATION DETAILS

This module works through the effect that a 

  delete $SomePackage::{foo};

will remove the C<foo> symbol from C<$SomePackage> for run time lookups
(e.g., method calls) but will leave the entry alive to be called by
already resolved names in the package itself.

A test file has been added to the perl core to ensure that this behaviour
will be stable in future releases.

Just for completeness sake, if you want to remove the symbol completely,
use C<undef> instead.

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
