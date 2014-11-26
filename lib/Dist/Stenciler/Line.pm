package Dist::Stenciler::Line {

    use Moose;
    use Types::Standard -types;

    has row => (
        is => 'ro',
        isa => Int,
        required => 1,
    );

    has text => (
        is => 'ro',
        isa => Str,
        required => 1,
    );

}

1;
