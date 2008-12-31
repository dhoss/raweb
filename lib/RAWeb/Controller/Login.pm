package RAWeb::Controller::Login;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use DateTime;    ## where should i put this?

=head1 NAME

BoyosPlace::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

    Login logic

=cut

sub index : Path : Args(0) {
	my ( $self, $c ) = @_;

	## let's see if they're logged in first
	## if so just direct them to their profile
	if ( $c->user_exists ) {

		$c->res->redirect(
			## need to fix this...
			$c->uri_for( "/user/" . $c->user->userid . "/profile" )
		);
		return;

	}

	# Get the username and password from form
	my $email    = $c->req->param('email')    || "";
	my $password = $c->req->param('password') || "";

	# If the username and password values were found in form
	if ( $email && $password ) {

		# Attempt to log the user in
		if (
			$c->authenticate(
				{
					email    => $email,
					password => $password
				}
			)
		  )
		{
			
			if ($c->req->param('remember') eq "checked") {
				
				## if they want to be remembered, 
				## make the cookie expire in a year
				$c->session->{cookie_expires} = 31536000;
				
			}

			# If successful, then let them use the application
			## update their last_here time
			$c->model('DB::Users')->find( { email => $email } )
			  ->update( { last_here => DateTime->now } );
			$c->res->redirect(
				## need to fix this...
				$c->uri_for( "/user/" . $c->user->userid . "/profile" )
			);
			return;
		}
		else {

			# Set an error message
			$c->stash->{error_msg} = "Bad username or password.";
		}
	}

	# If either of above don't work out, send to the login page
	$c->stash->{template} = 'login.tt2';
}

=head1 AUTHOR

Devin Austin 
devin@onthebeachatnight.com
http://www.onthebeachatnight.com

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
