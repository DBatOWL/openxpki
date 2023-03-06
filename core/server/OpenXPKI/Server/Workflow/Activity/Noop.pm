package OpenXPKI::Server::Workflow::Activity::Noop;

use warnings;
use strict;
use base qw( OpenXPKI::Server::Workflow::Activity );

sub execute {
    my ($self) = @_;
    return undef;
}

1;

__END__

=head1 Name

OpenXPKI::Server::Workflow::Activity::Noop

=head1 Description

The OpenXPKI equivalent to Workflow::Action::Null.
