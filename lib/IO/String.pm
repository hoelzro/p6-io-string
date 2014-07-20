class IO::String {
    has @.contents;

    method print($what) {
        @.contents.push: ~$what;
    }

    method Str { @.contents.join('') }
}
