package RAWeb::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    INCLUDE_PATH => [
              RAWeb->path_to( 'root', 'site' ),  
    ],
    WRAPPER => "wrapper"
);

=head1 NAME

RAWeb::View::TT - TT View for RAWeb

=head1 DESCRIPTION

TT View for RAWeb. 

=head1 AUTHOR

=head1 SEE ALSO

L<RAWeb>

Devin,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
