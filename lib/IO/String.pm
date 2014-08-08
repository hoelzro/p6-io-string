class IO::String:ver<0.1.0>:auth<hoelzro> is IO::Handle {
    has @.contents;

    method print($what) {
        @.contents.push: ~$what;
    }

    method Str { @.contents.join('') }
}
