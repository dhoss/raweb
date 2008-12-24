package RAWeb::Controller::Logs;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

RAWeb::Controller::Logs - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched RAWeb::Controller::Logs in Logs.');
}


=head1 AUTHOR

Devin,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
