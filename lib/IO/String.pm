use v6;

=head1 TITLE
IO::String
=head1 SYNOPSIS
=begin code
    use IO::String;

    # Using IO to write a Str
    my $buffer = IO::String.new;
    {
        my $*OUT = $buffer;
        say "hello";
    }
    say ~$buffer; # T<hello>

    # Using IO to read a Str
    my $sh = IO::String.new(:$buffer)
    for $sh.lines -> $line {
        say $line; # T<hello>
    }

=end code
=begin head1
DESCRIPTION

Sometimes you want to use code that deals with files (or other
file-like objects), but you don't want to mess around with creating
temporary files.  This includes uses like APIs that for some reason
don't accept strings as well as files as targets, mocking I/O,
or capturing output written to the terminal.  That's why this module
exists.  Loosely based on Perl 5's IO::String.

=end head1

=begin head1
TODO

=item Handle encodings
=end head1

=head1 METHODS
=begin head2
method new

    method new(
        Str :$buffer = '',
        Str :$pos = 0,
        Str :$chomp = True,
        Str :$nl-in = ["\x0a", "\r\n"],
        Str:D :$nl-out = "\n",
    ) returns IO::String:D

This creates a new IO::String handle. Every IO::String is also a L<IO::Handle> and can be used in place of a file handle. The C<$buffer> is the string to read from or write to. The C<$pos> is the current position to start the next read or write.

The C<$chomp>, C<$nl-in>, and C<$nl-out> options are from of IO::Handle. When reading line-by-line, C<$chomp> the chomp setting is used to determine whether the line endings should be chomped or left in place. The C<$nl-in> is an array of strings that will be used to end line records during reads and C<$nl-out> is the string that will be appended for new lines at the end of any output line record.
=end head2

=begin head2
method open

    multi method open(
        Str $buffer is rw,
        Bool :$bind,
    );
    multi method open(Str $buffer)

This tells the IO::String object to start working with a new string. Passing a variable and setting the C<:bind> option will result in that value being bound to the IO::String object. Any write to the handle will result in a change to the original string. For example,

    my $s;
    my $h = IO::String.new;
    $h.open($s, :bind);
    $h.say("hello");
    say $s; # T<hello> <-- the original string changed

With C<:bind> set to false or without being passed, the string will not be bound and changes to the handle will I<not> change the original.
=end head2

#| An L<IO::Handle> implementation that writes to memory.
class IO::String:ver<0.1.0>:auth<hoelzro> is IO::Handle {
    has Str $.buffer = '';
    has Int $.pos = 0;

    multi method open(IO::String:D: Str $buffer is rw, Bool :$bind) {
        if $bind {
            $!buffer := $buffer;
            $!pos = 0;
        }
        else {
            nextwith("$buffer");
        }
    }

    multi method open(IO::String:D: Str $buffer = '') {
        # In case of binding in previous open, bind a new one
        my Str $new-buffer = $buffer;
        $!buffer := $new-buffer;
        $!pos = 0;
    }

    method get(IO::String:D:) {
        return Nil if $.pos >= $.buffer.chars;

        my $start = $.pos;
        my $next-nl = $.nl-in.map({
            $_ => $^nl with $.buffer.index($^nl, $start)
        }).grep(*.key.defined).sort(&infix:<<=>>)[0];
        without $next-nl {
            $!pos = $.buffer.chars;
            return $.buffer.substr($start);
        }

        my $len = 1 + $next-nl.key - $start;
        $!pos += $len;
        $len -= $next-nl.value.chars if $.chomp;
        $.buffer.substr($start, $len);
    }

    method eof(IO::String:D:) { $.pos >= $.buffer.chars }

    method print(*@what) {
        $!buffer ~= @what.join('');
    }

    method print-nl {
        self.print($.nl-out);
    }

    #| Returns, as a string, everything that's been written to
    #| this object.
    method Str { $!buffer }
}
