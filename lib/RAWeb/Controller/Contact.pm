package RAWeb::Controller::Contact;

use strict;
use warnings;
use parent 'Catalyst::Controller::HTML::FormFu';
use MIME::Lite;

=head1 NAME

BoyosPlace::Controller::Contact - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index :Path :Args(0) FormConfig('contact/index.yml'){
    my ( $self, $c ) = @_;

    my $form = $c->stash->{form};
    $c->stash->{template} = "contact/index.tt2";
    
    if ( $form->submitted_and_valid ) {

        my $msg = MIME::Lite->new(
                  To      => $form->param('email'),
                  From    => RAWeb->config->{email}{from},
                                Subject => 'Thanks emailing us!',
                                Data    => "Thank you for your feedback!\n Campus Village"
        );

        $msg->send or die "MIME::Lite Error: $!";
        
        my $msg2 = MIME::Lite->new(
                  To      => $form->param('to'),
                  From    => RAWeb->config->{email}{from},
                                Subject => 'Thanks emailing us!',
                                Data    => $c->view('TT')->render($c, 'contact/body.tt2' , 
                             { 
                               comments => $form->param('comments'),
                               name     => $form->param('user') 
                             })
        );
        $msg2->send or die "MIME::Lite Error: $!";
    	
    	$c->stash->{status_msg} = "Thanks for your comments!";
    	$c->detach;
    	
    } 
}


=head1 AUTHOR

Devin Austin
devin.austin@gmail.com
http://www.onthebeachatnight.com
http://www.codedright.net

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
