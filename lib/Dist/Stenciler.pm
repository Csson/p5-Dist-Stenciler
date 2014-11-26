package Dist::Stenciler {

    use Moose;
    with 'MooseX::Object::Pluggable';

    use Path::Tiny;
    use Types::Standard -types;
    use experimental qw/postderef signatures/;
    use namespace::sweep;
    use Eponymous::Hash 'eh';

    use Dist::Stenciler::Stencil;
    use Dist::Stenciler::Line;

    has path => (
        is => 'ro',
        isa => Str,
        required => 1,
    );
    has output => (
        is => 'ro',
        isa => ArrayRef,
        default => sub { [] },
    );
    has head_lines => (
        is => 'rw',
        isa => ArrayRef[Str],
        default => sub { [] },
        traits => ['Array'],
        handles => {
            add_head_line => 'push',
            all_head_lines => 'elements',
        },

    );
    has stencils => (
        is => 'rw',
        isa => ArrayRef[InstanceOf['Dist::Stenciler::Stencil']],
        default => sub { [] },
        traits => ['Array'],
        handles => {
            get_stencil => 'get',
            add_stencil => 'push',
            all_stencils => 'elements',
            stencil_count => 'count',
        }
    );

    sub BUILD($self, @rest) {
        $self->parse;

        foreach my $plugin ($self->output->@*) {
            $self->load_plugin("To::$plugin")
        }
    }

    sub parse($self) {
        my $basename = $self->get_basename;

        my @lines = split /\n/ => Path::Tiny::path($self->path)->slurp;

        # matches ==test== ==no test== ==test example==
        my $start_sep = qr/==(?:(NO) )?TEST( EXAMPLE)?==/i;
        my $input_sep  = '--input--';
        my $output_sep = '--output--';

        my $stencil = Dist::Stenciler::Stencil->new;
        my $row = 0;

        LINE:
        foreach my $text (@lines) {
            my $line = Dist::Stenciler::Line->new(eh $text, ++$row);
            $stencil = $stencil->env eq 'head' && $text =~ $start_sep           ? do {
                                                                                      $stencil->handle_stencil_start($line, $self->stencil_count, $self->get_basename, defined $1, defined $2);
                                                                                      $stencil->set_env('before_input');
                                                                                  }
                     : $stencil->env eq 'head'                                  ? $self->add_head_line($text) && $stencil
                     : $stencil->env eq 'before_input' && $text eq $input_sep   ? $stencil->set_env('input')
                     : $stencil->env eq 'before_input'                          ? $stencil->add_lines_before_input($text)
                     : $stencil->env eq 'input' && $text eq $input_sep          ? $stencil->set_env('after_input')
                     : $stencil->env eq 'input'                                 ? $stencil->add_lines_input($text)
                     : $stencil->env eq 'after_input' && $text eq $output_sep   ? $stencil->set_env('output')
                     : $stencil->env eq 'after_input'                           ? $stencil->add_lines_after_input($text)
                     : $stencil->env eq 'output' && $text eq $output_sep        ? $stencil->set_env('after_output')
                     : $stencil->env eq 'output'                                ? $stencil->add_lines_output($text)
                     : $stencil->env eq 'after_output' && $text =~ $start_sep   ? do {
                                                                                   $self->complete_stencil($stencil);
                                                                                   $stencil->handle_stencil_start($line, $self->stencil_count, $self->get_basename, defined $1, defined $2);
                                                                               }
                     : $stencil->env eq 'after_output'                          ? $stencil->add_lines_after_output($text)
                     :                                                         ()
                     ;

        }
        $self->complete_stencil($stencil);

    }

    sub complete_stencil($self, $stencil) {
        my $new_stencil = Dist::Stenciler::Stencil->new(env => 'before_input');
        return $new_stencil if $stencil->skip;
        return $new_stencil if !$stencil->has_lines_input;

        $self->add_stencil($stencil);
        return $new_stencil;
    }

    sub get_filename($self) {
        return Path::Tiny::path($self->path)->basename;
    }
    sub get_basename($self) {
        my $filename = $self->get_filename;
        (my $basename = $filename) =~ s{^([^\.]+)\..*}{$1}; # remove suffix
        $basename =~ s{-}{_};
        return $basename;
    }

}

1;

__END__

=encoding utf-8

=head1 NAME

DBIx::Class::MachinaX::SourceParser - Blah blah blah

=head1 SYNOPSIS

  use DBIx::Class::MachinaX::SourceParser;

=head1 DESCRIPTION

DBIx::Class::MachinaX::SourceParser is

=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2014- Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
