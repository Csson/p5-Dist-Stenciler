use strict;
use Test::More;
use Test::Deep;
use Data::Dump::Streamer 'Dumper';
use DBIx::Class::MachinaX::SourceParser;

my $parser = DBIx::Class::MachinaX::SourceParser->new(path => 'corpus/test-1.mach');

done_testing;
