use strict;
use Test::More;
use Test::Deep;
use Data::Dump::Streamer 'Dumper';
use experimental 'postderef';
use DBIx::Class::MachinaX::SourceParser;

my $parser = DBIx::Class::MachinaX::SourceParser->new(path => 'corpus/01-test.mach');

is($parser->test_count, 2, "Correct number of tests");
is(join ("\n" => $parser->all_head_lines), all_head_lines(), 'Head lines');

my $test1 = $parser->get_test(0);
is($test1->all_lines_before_input("\n"), t1_before_input(), 'Test 1: Before input');
is($test1->all_lines_input("\n"), t1_input(), 'Test 1: Input');
is($test1->all_lines_after_input("\n"), t1_after_input(), 'Test 1: After input');

warn join "\n" => $parser->get_test(0)->all_lines_input;

done_testing;

sub all_head_lines {
    return
q{Some lines in the header
};
}

sub t1_before_input {
    return
q{Some lines before
the input};
}

sub t1_input {
    return
q{new table Books
on Books
add book_id primary_auto};
}

sub t1_after_input {
    return
q{Some lines in between};
}

