package RAWeb::Controller::Users;

use strict;
use warnings;
use parent 'Catalyst::Controller::HTML::FormFu';
use MIME::Lite;
use DateTime;
use Digest::SHA1 qw/sha1_hex/;

=head1 NAME

BoyosPlace::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = "users/index.tt2";
}


=head2 create
 
 create a user.
 display a form if no form parameters have been submitted
 otherwise, create the user object and save it to the db.

=cut

sub create : Path("/signup") : FormConfig {
	my ( $self, $c ) = @_;

	my $form = $c->stash->{form};
	$c->stash->{template} = "users/create.tt2";

	## let's make sure we have a valid form
	if ( $form->submitted_and_valid ) {

		## trap errors
		eval {
			## insert the object into the database
			my $user = $c->model('DB::Users')->create(
				{
					email    => $form->param('email'),
					name     => $form->param('name'),
					password => $form->param('password')

				}
			);

			## need to fix this since roleid 2 isn't
			## probably always going to be "user"
			$user->add_to_user_roles( { roleid => 1 }  ) or die "Error: $!";

			## send an email to the user with their registration key
                        
                        my $msg = MIME::Lite->new(
                                To      => $form->param('email'),
                                From    => RAWeb->config->{email}{from},
                                Subject => 'Thanks for signing up!',
                                Data    => "Thank you for signing up. Go here to confirm your account:" .
                                            $c->uri_for('users', 'confirm')
                                          . $user->confirm_key
                        );

                        $msg->send or die "MIME::Lite Error: $!";

			# Set a status message for the user
			$c->stash->{status_msg} =
                         "Thank you for registering! A confirmation email has been sent to "
			  . $form->param('email');

		};

		## something went awry
		if ($@) {

			$c->stash->{error_msg} =
			  "Oops! Something went wrong! Error message: $@";
			$c->detach;

		}

	}

}

=head2 confirm

  Check by confirmation key if a user
  has confirmed their account or not. 

=cut

sub confirm : Local {
	my ( $self, $c, $key ) = @_;

	$c->stash->{template} = "users/confirm.tt2";
	my $user;
	eval { $user = $c->model('DB::Users')->find( { confirm_key => $key } ); };

	if ( $user == undef ) {

		$c->stash->{error_msg} = "No such user to confirm";
		$c->detach;

	}

	unless ($key) {

		$c->stash->{error_msg} = "No key provided.";
		$c->detach;

	}

	if ( $user->confirmed ) {

		$c->stash->{error_msg} = "This account has already been confirmed";
		$c->detach;

	}
	else {

		if ( $user->confirm_key eq $key ) {

			$user->activate;
			$c->stash->{confirmed} = 1;
			$c->stash->{user}      = $user;

			$c->stash->{status_msg} = "Sucessfully confirmed!";
			$c->detach;

		}
		else {

			$c->stash->{error_msg} = "Confirmation key doesn't match!";
			$c->detach;

		}

	}

}

=head2 get_profile

  base action for profiles
  puts the user object into stash

=cut

sub get_profile : Chained('/') PathPart('user') CaptureArgs(1) {
	my ( $self, $c, $user ) = @_;

	my $user_info = $c->model('DB::Users')->find($user);

	## if the resultset isn't empty,
	## store the user object in the stash.
	## otherwise set an error message

	if ( $user_info != undef ) {

		$c->stash( user => $user_info );

	}
	else {

		$c->stash->{error_msg} = "No such user!";

	}

}

=head2 user_owns_profile

  gets the profile from the user's standpoint
  basically the user's "control panel" for their profile
  needs to check to see if the user is:
  1. logged in
  2. owns this profile

=cut

sub user_owns_profile : Chained('get_profile') PathPart('profile') Args(0) {
	my ( $self, $c ) = @_;
	my $user_info = $c->stash->{user};
   # $c->log->debug("check user roles: " . $c->user->roles());
	## see if our find failed
	if ( $c->stash->{error_msg} eq "No such user!" ) {

		$c->res->redirect('/');

	}

	$c->stash->{template} = "users/profile.tt2";

	if ( $c->user_exists ) {

		if ( !( $user_info->belongs_to_user( $c->user->email ) ) ) {

			$c->flash->{error_msg} = "This profile doesn't belong to you.";
			$c->res->redirect('/');

		}

	}
	else {

		## redirect them to their own profile
		$c->res->redirect(
			$c->uri_for( "/user/" . $user_info->userid . "/view" ) );

	}

}

=head2 edit_profile

  allows the user to edit their profile
  needs to check to see if the user is:
  1. logged in
  2. owns this profile

=cut

sub edit_profile : Chained('get_profile') PathPart('edit') Args(0)
  FormConfig('users/edit.yml') {
	my ( $self, $c ) = @_;
	my $user_info = $c->stash->{user};
	my $form      = $c->stash->{form};
	$c->stash->{template} = "users/edit.tt2";

	if ( $c->user_exists ) {

		if ( !( $user_info->belongs_to_user( $c->user->email ) ) ) {

			$c->flash->{error_msg} = "This profile doesn't belong to you.";
			$c->res->redirect('/');

		}

	}
	else {

		$c->flash->{error_msg} = "You must log in to perform this action.";
		$c->res->redirect('/login');

	}

	$form->default_values(
		{
			name  => $user_info->name,
			email => $user_info->email,
			about => $user_info->about,
		}
	);

	$form->process;

	if ( $form->submitted_and_valid ) {
		if ( $form->param('password') ) {
			if ( sha1_hex( $form->param('password') ) eq $user_info->password
				&& $form->param('newpassword') )
			{

				$user_info->update(
					{ password => $form->param('newpassword') } );

			}
			else {

				$c->stash->{error_msg} = "Oops, password incorrect.";
				$c->detach;

			}
		}

		$user_info->update(
			{
				name  => $form->param('name'),
				email => $form->param('email'),
				about => $form->param('about'),
			}
		);

		$c->stash->{status_msg} = "Profile updated!";
		$c->detach;

	}

}

=head2 view

  this is what the "rest of the world" sees when they 
  visit this profile. Does no checking (yet).

=cut

sub view : Chained('get_profile') PathPart('view') Args(0) {
	my ( $self, $c, $user ) = @_;
	my $user_info = $c->stash->{user};

	## see if our find failed
	if ( $c->stash->{error_msg} eq "No such user!" ) {

		$c->res->redirect('/');

	}

	$c->stash->{template} = 'users/view.tt2';

}

=head2 reset_password

  reset a user's password
  if the email given doesn't exist, no email is sent.

=cut

sub reset_password : Path('/reset_password') {
	my ( $self, $c ) = @_;
	my $email = $c->req->param('email');
	$c->stash->{template} = 'users/reset.tt2';

	if ($email) {

		my $user = $c->model('DB::Users')->find( { email => $email } );
		unless ( $user == undef ) {

			my $new_password = $user->reset_password;
			my $msg          = MIME::Lite->new(
				To      => $c->req->param('email'),
				From    => RAWeb->config->{email}{from},
				Subject => 'Password reset',
				Data =>
"Someone requested a password reset for you. Here it is: $new_password"
			);

			$msg->send;

			$c->stash->{status_msg} =
"If this user's email address exists, an email has been sent to them containing their new password.";
		}

	}

}

=head1 AUTHOR

Devin Austin
http://www.onthebeachatnight.com
devin@onthebeachatnight.com

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
