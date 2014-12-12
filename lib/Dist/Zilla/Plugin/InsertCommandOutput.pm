package Dist::Zilla::Plugin::InsertCommandOutput;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Proc::ChildError qw(explain_child_error);

use Moose;
with (
    'Dist::Zilla::Role::FileMunger',
    'Dist::Zilla::Role::FileFinderUser' => {
        default_finders => [':InstallModules', ':ExecFiles'],
    },
);

use namespace::autoclean;

sub munge_files {
    my $self = shift;

    $self->munge_file($_) for @{ $self->found_files };
}

sub munge_file {
    my ($self, $file) = @_;
    my $content = $file->content;
    if ($content =~ s{^#\s*COMMAND:\s*(.*)\s*$}{$self->_command_output($1)."\n"}egm) {
        $self->log(["inserting output of command '%s' in %s", $1, $file->name]);
        $file->content($content);
    }
}

sub _command_output {
    my($self, $cmd) = @_;

    my $res = `$cmd`;

    if ($?) {
        die "Command '$cmd' failed: " . explain_child_error();
    }

    $res =~ s/^/ /gm;
    $res;
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Insert the output of command into your POD

=for Pod::Coverage .+

=head1 SYNOPSIS

In dist.ini:

 [InsertCommandOutput]

In your POD:

 # COMMAND: netstat -anp


=head1 DESCRIPTION

This module finds C<# COMMAND: ...> directives in your POD, pass it to the
Perl's backtick operator, and insert the result into your POD as a verbatim
paragraph. If command fails (C<$?> is non-zero), build will be aborted.


=head1 SEE ALSO

L<Dist::Zilla::Plugin::InsertCodeResult>, which can also be used to accomplish
the same thing, e.g. with C<# CODE: my $res = `netstat -anp`; die if $?; $res>
except the DZP::InstallCommandResult plugin is shorter.

L<Dist::Zilla::Plugin::InsertCodeOutput>, which can also be used to accomplish
the same thing, e.g. with C<# CODE: system "netstat -anp"; die if $?>.

L<Dist::Zilla::Plugin::InsertExample>
