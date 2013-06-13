requires 'perl',                        '5.008005';
requires 'POE::Component::IRC::Plugin', '0';
requires 'Mojo::JSON',                  '0';
requires 'LWP::Simple',                 '0';

on test => sub {
    requires 'Test::More', '0.88';
};
