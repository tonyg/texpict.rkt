# texpict.rkt

This repository contains [`texpict.rkt`](texpict.rkt) along with a
small [demo](main.rkt). The file [`slides.pdf`](slides.pdf) contains
the output of a run of the demo.

The `texpict.rkt` library calls out to LaTeX (via `pdflatex`), using
the `standalone` LaTeX document class to render snippets of LaTeX to
high-resolution PNG for embedding in a Racket slideshow (or other
`pict`-based application).

Use of `#lang at-exp slideshow` gives a convenient syntax for
embedding LaTeX snippets. For example:

```racket
(slide
 #:title (text "texpict.rkt demo (inline)" 'default 36)
 @${e^{i\pi} + 1 = 0})
```

Because the library shells out to an external command, you will have
to use the `--trust` command-line argument to `slideshow`.

## Caching

The library chooses a temporary directory (by default, for me,
`/var/tmp/slideshow-texfiles/`) to write rendered PNG files into. The
files are named by a strong hash over

 1. the LaTeX source code being rendered;
 2. the current DPI setting (`tex-dpi` parameter);
 3. the current supersampling setting (`tex-supersample` parameter);
 4. the current TeX dependencies filenames (`tex-dependencies` parameter); and
 5. the current custom preamble text (`tex-custom-preamble` parameter).

This allows the library to avoid unnecessary re-rendering of LaTeX
snippets. Use `tex-remove-all-cached-files` to clean out the cache,
forcing a rerender.

Here is the current content of my temporary directory:

      -rw-r--r--  1 tonyg tonyg 32963 Jun 23 19:42 texfile2ddb34cb3cbc69c186cd31d51589eb759a172b27.png
      -rw-r--r--  1 tonyg tonyg 46303 Jun 23 19:47 texfile47f667809a0be3e0c768d8e9820988ca6f1eabc1.png
      -rw-r--r--  1 tonyg tonyg  7390 Jun 23 19:39 texfile64697ead276746f801a77c4ae9bb77036b16ff1d.png
      -rw-r--r--  1 tonyg tonyg 15672 Jun 23 19:39 texfile9700d7937e8a6e26acf7a6b782e4855c7cac989f.png
      -rw-r--r--  1 tonyg tonyg 34790 Jun 23 19:39 texfileba27136a451b29ec79eb35cad6a5436e6f371a99.png
      -rw-r--r--  1 tonyg tonyg 81835 Jun 23 19:42 texfilee0be0718e661b1294cf76f5ca15ae432ea5f48e9.png
      -rw-r--r--  1 tonyg tonyg 16995 Jun 23 19:48 texfilee2f73e44a5bfe99d3bfbbd903908e9ab1b89a0c1.png
      -rw-r--r--  1 tonyg tonyg 13268 Jun 23 19:42 texfileed5e097cdd94139d03bdc23fd27b1892960207cb.png
      -rw-r--r--  1 tonyg tonyg  3831 Jun 23 19:48 texpict-rkt-output

The `texpict-rkt-output` file contains output from the most recent run
of `pdflatex`, which can be helpful for debugging LaTeX problems.

## History

`texpict.rkt` is based on `main.rkt` from Stephen Chang's 2012 library
[`(planet stchang/slideshow-tex)`](https://planet.racket-lang.org/display.ss?package=slideshow-tex.plt&owner=stchang)
(also
[available on github](https://github.com/stchang/slideshow-tex)),
subsequently modified a reasonable amount by Tony Garnock-Jones over
the years up to around 2018.

## License

Both `texpict.rkt` and its ancestor, `main.rkt`, are
[CC0](https://creativecommons.org/publicdomain/zero/1.0/)-licensed.
That is to say: To the extent possible under law, Tony Garnock-Jones
and Stephen Chang have both waived all copyright and related or
neighboring rights to texpict.rkt. Please see also the
[LICENSE](LICENSE) file in this repository.
