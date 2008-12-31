package RAWeb::Controller::Logout;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

BoyosPlace::Controller::Logout - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

    Logout logic

=cut

sub index : Path : Args(0) {
	my ( $self, $c ) = @_;

	# Clear the user's state
	$c->logout;

	# Send the user to the starting point
	$c->flash->{status_msg} = "Logged out!";
	$c->response->redirect( $c->uri_for('/') );
}



=head1 AUTHOR

Devin Austin,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
