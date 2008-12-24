use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'RAWeb' }
BEGIN { use_ok 'RAWeb::Controller::Messages' }

ok( request('/messages')->is_success, 'Request should succeed' );


