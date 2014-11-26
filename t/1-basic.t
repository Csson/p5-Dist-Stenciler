use strict;
use Test::More;
use Test::Deep;
use Data::Dump::Streamer 'Dumper';
use experimental 'postderef';
use Dist::Stenciler;

my $parser = Dist::Stenciler->new(path => 'corpus/01-test.mach');

is($parser->test_count, 2, "Correct number of tests");
is(join ("\n" => $parser->all_head_lines), all_head_lines(), 'Head lines');

my $test1 = $parser->get_stencil(0);
my $test2 = $parser->get_stencil(1);
is($test1->all_lines_before_input("\n"), t1_before_input(), 'Test 1: Before input');
is($test1->all_lines_input("\n"), t1_input(), 'Test 1: Input');
is($test1->all_lines_after_input("\n"), t1_after_input(), 'Test 1: After input');
is($test1->all_lines_output("\n"), t1_output(), 'Test 1: Output');
is($test1->all_lines_after_output("\n"), t1_after_output(), 'Test 1: After output');

is($test2->all_lines_before_input("\n"), t2_before_input(), 'Test 2: Before input');
is($test2->all_lines_input("\n"), t2_input(), 'Test 2: Input');
is($test2->all_lines_after_input("\n"), t2_after_input(), 'Test 2: After input');
is($test2->all_lines_output("\n"), t2_output(), 'Test 2: Output');
is($test2->all_lines_after_output("\n"), t2_after_output(), 'Test 2: After output');

done_testing;

sub all_head_lines {
q{Some lines in the header
};
}

sub t1_before_input {
q{Some lines before
the input};
}

sub t1_input {
q{new table Books
on Books
add book_id primary_auto};
}

sub t1_after_input {
q{Some lines in between};
}

sub t1_output {
q{The expected output};
}

sub t1_after_output {
q{And some lines after
};
}


sub t2_before_input {
q{Some other lines
before another test};
}

sub t2_input {
q{new table Authors
on Authors
add author_id primary_auto};
}

sub t2_after_input {
q{Some different lines
in between};
}

sub t2_output {
q{The expected output
goes here
};
}

sub t2_after_output {
q{And some lines after
the output};
}
