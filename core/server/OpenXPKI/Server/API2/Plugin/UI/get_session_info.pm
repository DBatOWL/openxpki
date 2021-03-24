package OpenXPKI::Server::API2::Plugin::UI::get_session_info;
use OpenXPKI::Server::API2::EasyPlugin;

=head1 NAME

OpenXPKI::Server::API2::Plugin::UI::get_session_info

=cut

# Project modules
use OpenXPKI::Server::Context qw( CTX );
use OpenXPKI::Server::API2::Types;



=head1 COMMANDS

=head2 get_session_info

Returns information about the current user session:

    {
        name => STR,            # user name
        realname => STR,        # user name - descriptive label
        role => STR,            # role
        role_label => STR,      # role - descriptive label
        pki_realm => STR,       # PKI realm
        pki_realm_label => STR, # PKI realm - descriptive label
        checksum => STR,        # config checksum
        sid => STR,             # session ID
        userinfo => {           # additional user info, depending on authentication backend
            realname => STR,    # optional
            email => STR,       # optional
            ...
        },
        authinfo => {           # optional, params for authentication handlers
            logout => STR,      # redirect target for logout (used by UI)
            ....
        }
    }

=cut
command "get_session_info" => {
} => sub {
    my ($self, $params) = @_;

    my $session = CTX('session');

    my $realname = $session->data->user;
    if (ref $session->data->userinfo eq 'HASH' &&
        $session->data->userinfo->{realname}) {
        $realname = $session->data->userinfo->{realname};
    }

    my $role_label = CTX('config')->get([ 'auth', 'roles', $session->data->role, 'label' ]) || $session->data->role;
    my $pki_realm_label = CTX('config')->get([ 'system', 'realms', $session->data->pki_realm, 'label' ]) || $session->data->pki_realm;

    return {
        name            => $session->data->user,
        role            => $session->data->role,
        realname        => $realname,
        role_label      => $role_label,
        pki_realm       => $session->data->pki_realm,
        pki_realm_label => $pki_realm_label,
        checksum        => substr(CTX('config')->checksum(),0,8),
        sid             => substr($session->id,0,4),
        userinfo        => $session->data->userinfo || {},
        authinfo        => $session->data->authinfo || {},
    }
};

__PACKAGE__->meta->make_immutable;
