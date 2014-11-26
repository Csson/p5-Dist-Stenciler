use Moops;

class Dist::Stenciler::Stencil using Moose {

    use MooseX::AttributeShortcuts;
    use Types::Standard -types;
    use Type::Tiny::Enum;
    use experimental 'postderef';

    has skip => (
        is => 'rw',
        isa => Bool,
        default => 0,
    );
    has is_example => (
        is => 'rw',
        isa => Bool,
        default => 0,
    );
    has name => (
        is => 'rw',
        isa => Str,
    );
    has number => (
        is => 'rw',
        isa => Int,
        default => 0,
    );
    has start_line => (
        is => 'rw',
        isa => Int,
        default => 0,
    );

    foreach my $attr (qw/
            lines_before_input
            lines_input
            lines_after_input
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
                        output
                        after_output
                   /]),

        default => 'head',
    );

    method handle_stencil_start($line, $stencil_count, $basename, $skip, $is_example) {
        ++$stencil_count;
        $self->number($stencil_count);
        $self->is_example($is_example);
        $self->skip($skip);
        $self->start_line($line->row);
        $self->name(sprintf '%s_%s' => $basename, $stencil_count);

        return $self;
    }

    around add_lines_before_input($orig: $self, @args) {
        return $self->_cleanup_lines_to_add($orig, $self->has_lines_before_input, @args);
    }
    around add_lines_input($orig: $self, @args) {
        return $self->_cleanup_lines_to_add($orig, $self->has_lines_input, @args);
    }
    around add_lines_after_input($orig: $self, @args) {
        return $self->_cleanup_lines_to_add($orig, $self->has_lines_after_input, @args);
    }
    around add_lines_output($orig: $self, @args) {
        return $self->_cleanup_lines_to_add($orig, $self->has_lines_output, @args);
    }
    around add_lines_after_output($orig: $self, @args) {
        return $self->_cleanup_lines_to_add($orig, $self->has_lines_after_output, @args);
    }
    method _cleanup_lines_to_add($orig, $already_have, @args) {
        if(!$already_have) {
            ARG:
            foreach my $arg (shift @args) {
                unshift @args => $arg && last if $arg !~ m{^\s*$};
            }
        }

        $self->$orig(@args) if scalar @args;
        return $self;
    }


    around all_lines_before_input($orig: $self, $joiner = undef) {
        return $self->_all_lines($orig, $joiner);
    }
    around all_lines_input($orig: $self, $joiner = undef) {
        return $self->_all_lines($orig, $joiner);
    }
    around all_lines_after_input($orig: $self, $joiner = undef) {
        return $self->_all_lines($orig, $joiner);
    }
    around all_lines_output($orig: $self, $joiner = undef) {
        return $self->_all_lines($orig, $joiner);
    }
    around all_lines_after_output($orig: $self, $joiner = undef) {
        return $self->_all_lines($orig, $joiner);
    }
    method _all_lines($orig, $joiner) {
        return $self->$orig if !defined $joiner;
        return join $joiner => $self->$orig;
    }

    method set_env($new_env) {
        $self->env($new_env);
        return $self;
    }

}

1;
