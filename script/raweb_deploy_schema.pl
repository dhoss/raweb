#!/usr/bin/perl
use FindBin;
use lib "$FindBin::Bin/../lib";
use RAWeb::Schema;
my $schema = RAWeb::Schema->connect("dbi:mysql:raweb", "root", "lairdo");
$schema->deploy( { add_drop_tables => 1 } );
