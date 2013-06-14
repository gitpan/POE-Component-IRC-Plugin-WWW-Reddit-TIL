package POE::Component::IRC::Plugin::WWW::Reddit::TIL;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.04';

use POE::Component::IRC::Plugin qw( :ALL );
use Mojo::UserAgent;
use WWW::Shorten::Simple;

sub new {
    my $package = shift;
    return bless {}, $package;
}

sub PCI_register {
    my ($self, $irc) = splice @_, 0, 2;

    $irc->plugin_register($self, 'SERVER', qw(public));
    return 1;
}

# This is method is mandatory but we don't actually have anything to do.
sub PCI_unregister {
    return 1;
}

sub S_public {
    my ($self, $irc) = splice @_, 0, 2;

    # Parameters are passed as scalar-refs including arrayrefs.
    my $nick    = (split /!/, ${$_[0]})[0];
    my $channel = ${$_[1]}->[0];
    my $msg     = ${$_[2]};

    my $reply = $msg =~ /^!til\b/i && $self->_get_TIL;

    if ($reply) {
        $irc->yield(privmsg => $channel => "$nick: $reply");
        return PCI_EAT_PLUGIN;
    }

    # Default action is to allow other plugins to process it.
    return PCI_EAT_NONE;
}

sub _get_TIL {
    my $ua = Mojo::UserAgent->new;
    my %posts;
    foreach my $post (
        @{$ua->get('http://www.reddit.com/r/todayilearned.json')->res->json->{data}{children}})
    {
        my $title = $post->{data}{title};
        my $link  = $post->{data}{url};
        $posts{$title} = $link if $title && $link;
    }
    return unless %posts;

    my $title = (keys %posts)[rand keys %posts];
    my $short =
      WWW::Shorten::Simple->new('Bitly', 'aggrolite', 'R_418414782c81e2c4444348e367201706');
    my $link = $short->shorten($posts{$title});
    return "$title $link";
}

1;

__END__

=pod

=head1 NAME

POE::Component::IRC::Plugin::WWW::Reddit::TIL - IRC plugin that fetches random TIL headlines from reddit.com/r/TodayILearned

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use strict;
    use warnings;

    use POE qw(Component::IRC  Component::IRC::Plugin::WWW::Reddit::TIL);

    my $irc = POE::Component::IRC->spawn(
        nick    => 'nickname',
        server  => 'irc.freenode.net',
        port    => 6667,
        ircname => 'ircname',
    );

    POE::Session->create(package_states => [main => [qw(_start irc_001)]]);

    $poe_kernel->run;

    sub _start {
        $irc->yield(register => 'all');

        $irc->plugin_add('TIL' => POE::Component::IRC::Plugin::WWW::Reddit::TIL->new);

        $irc->yield(connect => {});
    }

    sub irc_001 {
        $irc->yield(join => '#channel');
    }

=head1 DESCRIPTION

type !til (casing does not matter) to get a random title and link from the first page of L<http://www.reddit.com/r/todayilearned>

=head1 AUTHOR

Curtis Brandt, C<< <curtis at cpan.org> >>

=head1 BUGS

Please report bugs on my Github: L<https://github.com/aggrolite/POE-Component-IRC-Plugin-WWW-Reddit-TIL>

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Curtis Brandt.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
