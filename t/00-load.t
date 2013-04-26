#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'POE::Component::IRC::Plugin::WWW::Reddit::TIL' ) || print "Bail out!\n";
}

diag( "Testing POE::Component::IRC::Plugin::WWW::Reddit::TIL $POE::Component::IRC::Plugin::WWW::Reddit::TIL::VERSION, Perl $], $^X" );
