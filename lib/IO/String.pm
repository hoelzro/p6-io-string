use v6;

=head1 TITLE
IO::String
=head1 SYNOPSIS
=begin code
    use IO::String;

    my $buffer = IO::String.new;
    {
        my $*OUT = $buffer;
        say "hello";
    }
    say ~$buffer; # T<hello>

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

=item Input as well as output
=item Handle encodings
=end head1


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
