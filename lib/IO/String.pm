class IO::String is IO::Handle {
    has @.contents;

    method print($what) {
        @.contents.push: ~$what;
    }

    method Str { @.contents.join('') }
}
