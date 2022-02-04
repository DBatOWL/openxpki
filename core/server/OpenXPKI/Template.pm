package OpenXPKI::Template;

use strict;
use warnings;
use utf8;

use base qw( Template );

use OpenXPKI::Debug;
use OpenXPKI::FileUtils;
use OpenXPKI::Exception;
use OpenXPKI::Serialization::Simple;
#use OpenXPKI::Server::Context qw( CTX );

sub new {
    my ($class, $args) = @_;

    $args->{PLUGIN_BASE} = 'OpenXPKI::Template::Plugin';
    $args->{ENCODING} //= 'UTF-8';

    $Template::Stash::PRIVATE = undef;

    my $self = $class->SUPER::new($args);
    $self->{trim_whitespaces} = $args->{trim_whitespaces} // 1;

    return $self;
}


=head2 render

This wraps around the process method of the original Template class. It expects
the parameter string as first argument (scalar, not reference!) and a hashref
with the params for template. The class tries to auto-deserialize parameters
from the params array by evaluating the template string for sequences like
I<context.upper.lower> (this is yet done for the context prefix only). The
result is returned as a string, if processing fails, an OpenXPKI::Exception is
thrown.

=cut

sub render {
    my ($self, $template, $tt_param) = @_;

    ##! 16: 'template: ' . $template
    ##! 32: 'input params: ' . Dumper $tt_param
    # Try to detect access to non-scalar values and check if those are deserialized
    # Works only for stuff below the key context
    my @non_scalar_refs = ($template =~ m{ context\.([^\s\.]+)\.\S+ }xsg);
    foreach my $refkey (@non_scalar_refs) {
        ##! 16: 'auto deserialize for ' . $refkey
        if (!ref $tt_param->{'context'}->{$refkey}) {
            if (defined $tt_param->{'context'}->{$refkey} &&
                OpenXPKI::Serialization::Simple::is_serialized( $tt_param->{'context'}->{$refkey} )) {
                my $ser  = OpenXPKI::Serialization::Simple->new();
                $tt_param->{'context'}->{$refkey} = $ser->deserialize( $tt_param->{'context'}->{$refkey} );
                ##! 32: 'deserialized value ' . Dumper $tt_param->{$refkey}
            }
        }
    }

    my $out;
    if (!$self->process( \$template, $tt_param, \$out )) {
         OpenXPKI::Exception->throw (
            message => 'I18N_OPENXPKI_TEMPLATE_ERROR_PARSING_TEMPLATE_FOR_PARAM',
            params => {
                'TEMPLATE' => $template,
                'ERROR' => $self->error()
            }
        );
    }

    # trim spaces and newlines
    if ($self->{trim_whitespaces}) {
        $out =~ s{ \A [\s\n]+ }{}xms;
        $out =~ s{ [\s\n]+ \z }{}xms;
    }

    ##! 32: 'output: #' . $out . '#'

    return $out;

}

=head2 render_from_file

Expects a filename instead of a template string as first argument and uses the
content of this file as template string. The second parameter is passed
unmodified to render as template arguments.

Return undef if the file can not be read or is empty.

=cut

sub render_from_file {

    ##! 4: 'start'
    my $self = shift;
    my $filename = shift;
    my $tt_param = shift;

    ##! 16: 'Load template: ' . $filename
    if (! -e $filename || ! -r $filename ) {
        CTX('log')->system()->warn("Template file $filename does not exist");
        return undef;
    }

    my $template = OpenXPKI::FileUtils->read_file( $filename, 'utf8' );

    if (!defined $template || $template eq "") {
        CTX('log')->system()->warn("Template file $filename is empty");
        return undef;
    }

    return $self->render($template, $tt_param);

}


1;
