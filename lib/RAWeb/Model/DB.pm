package RAWeb::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'RAWeb::Schema',
    connect_info => [
        'dbi:mysql:raweb',
        'root',
        'lairdo',
        
    ],
);

=head1 NAME

RAWeb::Model::DB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<RAWeb>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<RAWeb::Schema>

=head1 AUTHOR

Devin,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
