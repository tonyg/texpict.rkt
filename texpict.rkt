#lang racket/base
;; main.rkt from (planet stchang/slideshow-tex) version 1.7
;; Lightly modified by tonyg over the course of years up to around 2018

(provide tex
         tex-scale
	 tex-dpi
	 tex-supersample
	 $
	 $$
	 tex-remove-all-cached-files
	 tex-custom-preamble
	 tex-document-transformer
	 tex-append-preamble!
         tex-add-dependency!)

(require openssl/sha1)
(require pict)
(require racket/file)
(require racket/match)
(require racket/set)
(require racket/system)

(define tex-scale (make-parameter 1))
(define tex-dpi (make-parameter 100))
(define tex-supersample (make-parameter 4))

(define tex-dir (string-append (path->string (find-system-path 'temp-dir))
                               "/slideshow-texfiles/"))
(log-info "texpict.rkt directory is ~v" tex-dir)

(define tex-cache (make-hash))

(define (tex-cache-lookup key thunk)
  (hash-ref tex-cache key (lambda ()
			    (define p (thunk))
			    (hash-set! tex-cache key p)
			    p)))

;; -> string
(define (get-filenames [str #f])
  (define preprefix "texfile")
  (define probe-str (format "~v" (list str (tex-dpi) (tex-supersample) (tex-dependency-hash))))
  (define probe (sha1 (open-input-string probe-str)))
  (define prefix
    (if str
        (string-append preprefix probe)
        (symbol->string (gensym preprefix))))
  (values prefix
          (string-append prefix ".tex")
          (string-append prefix ".pdf")
          (string-append prefix ".png")))

(define ($ . strs) (tex (string-append "$" (apply string-append strs) "$")))
(define ($$ . strs) (tex (string-append "$\\displaystyle " (apply string-append strs) " $")))

; customizable preamble (default value is for backwards compatibility)
(define tex-custom-preamble
  (make-parameter
   (string-append
    "\\usepackage{color}\n"
    "\\definecolor{grayed}{gray}{0.4}\n"
    "\\definecolor{lightgrayed}{gray}{0.8}\n"
    "\\definecolor{black}{gray}{0}\n"
    "\\definecolor{white}{gray}{1}\n"
    )))

(define tex-dependencies (make-parameter (set)))

(define (tex-add-dependency! filename)
  (tex-dependencies (set-add (tex-dependencies) filename)))

(define cached-tex-dependency-hash #f)

(define (compute-tex-dependency-hash!)
  (define blob (apply bytes-append
                      (string->bytes/utf-8 (tex-custom-preamble))
                      (sort (set->list (tex-dependencies)) string<?)))
  (define value (sha1 (open-input-bytes blob)))
  (set! cached-tex-dependency-hash (list (tex-custom-preamble) (tex-dependencies) value))
  value)

(define (tex-dependency-hash)
  (match cached-tex-dependency-hash
    [#f (compute-tex-dependency-hash!)]
    [(list preamble dependencies value)
     (if (and (eq? preamble (tex-custom-preamble))
              (eq? dependencies (tex-dependencies)))
         value
         (compute-tex-dependency-hash!))]))

(define tex-document-transformer (make-parameter values))

(define (tex-append-preamble! . strs)
  (tex-custom-preamble (apply string-append (tex-custom-preamble) strs)))

(define (tex . strs)
  (define str (apply string-append strs))
  (define-values (fileroot texfile pdffile pngfile) (get-filenames str))
  (define saved-cwd (current-directory))
  (define saved-texinputs (getenv "TEXINPUTS"))
  (tex-cache-lookup
   (string-append tex-dir pngfile)
   (lambda ()
     (define bm
       (if (file-exists? (string-append tex-dir pngfile))
	   (bitmap (string-append tex-dir pngfile))
	   (begin
	     (log-info "Compiling tex pict ~a" fileroot)
	     (unless (directory-exists? tex-dir) (make-directory tex-dir))
	     (current-directory tex-dir)
	     (putenv "TEXINPUTS"
		     (string-append ".:" (path->string saved-cwd)
				    (if saved-texinputs
					(string-append ":" saved-texinputs)
					"")
				    ":" ;; get standard value for TEXINPUTS auto-appended
				    ))
	     (let ([o (open-output-file texfile #:mode 'binary #:exists 'replace)])
	       (display (string-append
			 "\\documentclass[border=1pt,preview]{standalone}\n"
			 (tex-custom-preamble)
			 "\\begin{document}\n"
			 ((tex-document-transformer) str)
			 "\\end{document}\n")
			o)
	       (close-output-port o)
	       (system (string-append "pdflatex" " " texfile " >texpict-rkt-output 2>&1"))
	       (system (format (string-append "gs -q -dNOPAUSE -dBATCH -sDEVICE=pngalpha "
					      "-r~a "
					      "-dEPSCrop "
					      "-sOutputFile=~a ~a")
			       (* (tex-dpi) (tex-supersample)) pngfile pdffile))
	       (begin0
		   (bitmap pngfile)
		 (for-each delete-file
			   (list (string-append fileroot ".aux")
				 (string-append fileroot ".log")
				 pdffile
				 texfile))
		 (current-directory saved-cwd)
		 (if saved-texinputs
		     (putenv "TEXINPUTS" saved-texinputs)
		     (putenv "TEXINPUTS" ""))
		 )))))
     (scale (inset (scale bm (/ (tex-supersample))) 1) (tex-scale)))))

(define (tex-remove-all-cached-files)
  (system (string-append "rm -Rf " tex-dir)))
