requires 'perl',                        '5.010';
requires 'POE::Component::IRC::Plugin', '0';
requires 'Mojo::UserAgent',             '0';
requires 'WWW::Shorten::Simple',        '0.01';
requires 'WWW::Shorten::Bitly',         '1.17';

on test => sub {
    requires 'Test::More', '0.88';
};
