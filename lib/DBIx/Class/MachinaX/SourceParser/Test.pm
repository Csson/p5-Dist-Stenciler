package DBIx::Class::MachinaX::SourceParser::Test {

    use Moose;
    use MooseX::AttributeShortcuts;
    use Types::Standard -types;
    use Type::Tiny::Enum;

    has [qw/is_example  skip/] => (
        is => 'rw',
        isa => Bool,
        default => 0,
    );
    has name => (
        is => 'rw',
        isa => Str,
    );

    has [qw/number  start_lines/] => (
        is => 'rw',
        isa => Int,
        default => 0,
    );

    foreach my $attr (qw/
            lines_before_input
            lines_input
            lines_after_input
            lines_totest
            lines_before_output
            lines_output
            lines_after_output
        /) {

        has $attr => (
            traits => ['Array'],
            is => 'rw',
            isa => ArrayRef[Str],
            predicate => 1,
            default => sub { [] },
            handles => {
                "add_$attr" => 'push',
                "all_$attr" => 'elements',
            },
        );
    }

    has env => (
        is => 'rw',
        isa => Type::Tiny::Enum->new(values => [qw/
                        head
                        before_input
                        input
                        after_input
                        totest
                        before_output
                        output
                        after_output
                   /]),

        default => 'head',
    );

}

1;
