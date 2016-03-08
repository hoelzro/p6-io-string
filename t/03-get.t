use v6;
use Test;
use IO::String;

plan 12;

{
    my $s = IO::String.new(buffer => "hello,\nworld!\n");
    ok !$s.eof, "not yet eof";
    is $s.get, "hello,", "got first line";
    ok !$s.eof, "not yet eof";
    is $s.get, "world!", "got second line";
    ok !$s.get, "got nothing for third line";
    ok $s.eof, "we have eof";
}

{
    my $s = IO::String.new(buffer => "hello,\r\nworld!\r\n");
    ok !$s.eof, "not yet eof";
    is $s.get, "hello,", "got first line";
    ok !$s.eof, "not yet eof";
    is $s.get, "world!", "got second line";
    ok !$s.get, "got nothing for third line";
    ok $s.eof, "we have eof";
}
