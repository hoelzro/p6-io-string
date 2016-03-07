use v6;
use Test;
use IO::String;

plan 4;

my $s = IO::String.new(buffer => "hello,\nworld!\n");
is $s.get, "hello,", "got first line";
is $s.get, "world!", "got second line";
ok !$s.get, "got nothing for third line";
ok $s.eof, "we have eof";
