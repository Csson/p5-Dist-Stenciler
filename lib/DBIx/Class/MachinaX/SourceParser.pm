package DBIx::Class::MachinaX::SourceParser {

    use Moose;
    with 'MooseX::Object::Pluggable';

    use Path::Tiny;
    use Types::Standard -types;
    use experimental qw/postderef signatures/;
    use namespace::sweep;

    use DBIx::Class::MachinaX::SourceParser::Test;
    use DBIx::Class::MachinaX::SourceParser::Line;

    has path => (
        is => 'ro',
        isa => Str,
        required => 1,
    );
    has test_index => (
        is => 'rw',
        isa => HashRef,
        default => sub { { } },
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
    has tests => (
        is => 'rw',
        isa => ArrayRef[InstanceOf['DBIx::Class::MachinaX::SourceParser::Test']],
        default => sub { [] },
        traits => ['Array'],
        handles => {
            add_test => 'push',
            all_tests => 'elements',
            test_count => 'count',
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
        my $totest_sep = '--test--';
        my $output_sep = '--output--';

        my $environment = 'head';

        my $info = {
            indexed    => {},
        };
        my $test = DBIx::Class::MachinaX::SourceParser::Test->new;
        my $row = 0;

        LINE:
        foreach my $text (@lines) {
            my $line = DBIx::Class::MachinaX::SourceParser::Line->new(eh $text, ++$row);

              $test->env eq 'head' && $line =~ $start_sep           ? $test->handle_test_start($test, $line, $1 // 0, $2 // 0)
            : $test->env eq 'head'                                  ? $self->add_head_line($text)
            : $test->env eq 'before_input' && $text eq $input_sep   ? $test->end_before_input
            : $test->env eq 'before_input'                          ? $test->add_lines_before_input($text)
            : $test->env eq 'input' && $text eq $input_sep          ? $test->end_input
            : $test->env eq 'input'                                 ? $test->add_lines_input($text)
            : $test->env eq 'after_input' && $text eq $totest_sep   ? $test->end_after_input
            : $test->env eq 'after_input'                           ? $test->add_lines_after_input($text)
            : $test->env eq 'totest' && $text eq $totest_sep        ? $test->end_totest
            : $test->env eq 'totest'                                ? $test->add_lines_totest($text)
            : $test->env eq 'before_output' && $text eq $output_sep ? $test->end_before_output
            : $test->env eq 'before_output'                         ? $test->add_lines_before_output($text)
            : $test->env eq 'output' && $text eq $output_sep        ? $test->end_output
            : $test->env eq 'output'                                ? $test->add_lines_output($text)
            : $test->env eq 'after_output' && $line =~ $start_sep   ? $test->complete
            : $test->env eq 'after_output'                          ? $test->add_lines_after_output($text)
            :                                                         ()
            ;

        }

    }

    sub handle_test_start($self, $test, $line, $skip = 0, $is_example = 0) {
        $test = DBIx::Class::MachinaX::SourceParser::Test->new(number => $self->tests->count + 1,
                                                               is_example => $is_example,
                                                               skip => $skip,
                                                               start_line => $line->row,
                                                               name => sprintf '%s_%s' => $self->basename, $self->tests->count + 1,
                                                            );
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
