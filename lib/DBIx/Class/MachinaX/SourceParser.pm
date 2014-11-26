package DBIx::Class::MachinaX::SourceParser {

    use Moose;
    with 'MooseX::Object::Pluggable';

    use Path::Tiny;
    use Types::Standard -types;
    use experimental qw/postderef signatures/;

    use DBIx::Class::MachinaX::SourceParser::Test;
    use DBIx::Class::MachinaX::SourceParser::Line;

    has path => (
        is => 'ro',
        isa => Str,
        required => 1,
    );
    has test_index => (
        is => 'rw',
        isa => 'HashRef',
        default => sub { { } },
    );
    has output => (
        is => 'ro',
        isa => 'ArrayRef',
        default => sub { [] },
    );
    foreach my $attr (qw/head_lines  tests/) {
        has $attr => (
            is => 'rw',
            isa => 'ArrayRef',
            default => { [] },
            traits => ['Array'],
            handles => {
                "add_$attr" => 'push',
                "all_$attr" => 'elements',
            },

        );
    }
    has head_lines => (
        is => 'rw',
        isa => 'ArrayRef',
        default => { [] },
        traits => ['Array'],
        handles => {
            add => 'push',
            all => 'elements',
        },
    );

    sub BUILD($self) {
        $self->_parse;

        foreach my $plugin ($self->output->@*) {
            $self->load_plugin("To::$plugin")
        }
    }

    sub _parse($self) {
        my $basename = $self->_get_basename;

        my @lines = split /\n/ => Path::Tiny::path($self->path)->slurp;

        # matches ==test== ==no test== ==test loop(a thing or two)== ==test example ==test 1== ==test example 2==
        my $start_sep = qr/==(?:(NO) )?TEST( EXAMPLE)?(?: (?:\d+))?==/i;
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

              $test->env eq 'head' && $line =~ $start_sep           ? $test->handle_test_start($test, $line, defined $1)
            : $test->env eq 'head'                                  ? $self->head_lines->add($text)
            : $test->env eq 'before_input' && $text eq $input_sep   ? $test->end_before_input
            : $test->env eq 'before_input'                          ? $test->lines_before_input->add($text)
            : $test->env eq 'input' && $text eq $input_sep          ? $test->end_input
            : $test->env eq 'input'                                 ? $test->lines_input->add($text)
            : $test->env eq 'after_input' && $text eq $totest_sep   ? $test->end_after_input
            : $test->env eq 'after_input'                           ? $test->lines_after_input->add($text)
            : $test->env eq 'totest' && $text eq $totest_sep        ? $test->end_totest
            : $test->env eq 'totest'                                ? $test->lines_totest->add($text)
            : $test->env eq 'before_output' && $text eq $output_sep ? $test->end_before_output
            : $test->env eq 'before_output'                         ? $test->lines_before_output->add($text)
            : $test->env eq 'output' && $text eq $output_sep        ? $test->end_output
            : $test->env eq 'output'                                ? $test->lines_output->add($text)
            : $test->env eq 'after_output' && $line =~ $start_sep   ? $test->complete
            : $test->env eq 'after_output'                          ? $test->lines_after_output
            :                                                         ()
            ;

        }

    }

    sub _get_filename($self) {
        return Path::Tiny::path($self->path)->basename;
    }
    sub _get_basename($self) {
        my $filename = $self->_get_filename;
        (my $basename = $filename) =~ s{^([^\.]+)\..*}{$1}; # remove suffix
        $basename =~ s{-}{_};
        return $basename;
    }

}
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
