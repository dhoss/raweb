package RAWeb::Schema::Users;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(
  "InflateColumn::DateTime",
  "InflateColumn::FS",
  "PK::Auto",
  "Core",
);
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "confirmed",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
  "confirm_key",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "about",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => 65535,
  },
  "created",
  {
    data_type => "DATETIME",
    default_value => undef,
    is_nullable => 0,
    size => 19,
  },
  "email",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "last_here",
  {
    data_type => "DATETIME",
    default_value => undef,
    is_nullable => 0,
    size => 19,
  },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "password",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "profile_image",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "userid",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("userid");
__PACKAGE__->has_many(
  "user_roles",
  "RAWeb::Schema::UserRoles",
  { "foreign.userid" => "self.userid" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-11-25 13:06:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:yHec9OV+9ljSP3BcNedgmQ


=head2 user roles
 
  roles for users. 
  such as "Admin," "Moderator," etc.

=cut

#__PACKAGE__->has_many( 'map_user_role' => 'BoyosPlace::Schema::UserRoles', 'userid' );
__PACKAGE__->many_to_many( 'roles' => 'user_roles', 'roleid' );

=head2 yoinked

  The following methods have been stolen from rafl :-)

=cut
use Text::Password::Pronounceable;
=head2 activate

  activate a user

=cut

sub activate {
	my ($self) = @_;

	$self->result_source->schema->txn_do(
		sub {
			$self->update( { confirmed => 1, confirm_key => undef } );
		}
	);
}

=head2 hash_password

  hash a user's password using
  the SHA1 algorithm.

=cut

sub hash_password {
	my ($self) = @_;

	my $d = Digest->new('SHA-1');
	$d->add( $self->password );
	$self->password( $d->hexdigest );

	return;
}

=head2 insert

  hash the user's password
  update their created time
  add their 
  commit the user object to the database

=cut

sub insert {
	my ($self) = @_;

	die "User email exists!"
	  if $self->result_source->resultset->find( { email => $self->email } );
	my $key = Digest->new('SHA-1');
	$key->add( $self->email );
	$self->confirm_key( $key->hexdigest );
	$self->created( DateTime->now );
	$self->hash_password;

	return $self->next::method;
}

=head2 update

 overload update to hash password

=cut
sub update {
    my ($self, $col_data) = @_;
    $col_data ||= {};

    if ($col_data->{password}) {
    	## we have to update the password key
    	## delete it, so that the new one passed
    	## can be hashed
        $self->password( delete $col_data->{password} );
        $self->hash_password;
    }

    return $self->next::method($col_data);
}

=head2 reset_password

  reset a user's password
  by generating a random password
  with Text::Password::Pronounceable
  also, update their confirmed status to 0
  so the user has to manually confirm the password

=cut

sub reset_password {
	my ($self) = @_;

	my $pass = Text::Password::Pronounceable->new( 6, 10 )->generate;
	$self->update(
		{
			#confirmed => 0,
			password  => $pass,
		}
	);

	return $pass;
}

=head2 belongs_to_user

  checks to see if a given profile belongs to a user
  returns a 1 if it belongs to the user 
  returns a 0 if it does not belong to the user

=cut

sub belongs_to_user {
	my ( $self, $accessor ) = @_;

	return $self->result_source->resultset->search(
		{ userid => $self->userid, email => $accessor } )->count;

}
1;
