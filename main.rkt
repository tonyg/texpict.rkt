#lang at-exp slideshow
;;
;; Because this invokes external programs, namely TeX, you have to run this with
;;   slideshow --trust main.rkt
;;

(require "texpict.rkt")

(tex-append-preamble! @string-append{\usepackage{amsthm}
                                     \usepackage{amsmath}
                                     \usepackage{amssymb}
                                     \usepackage{wasysym}
                                     \usepackage{stmaryrd}
                                     \usepackage{bussproofs}
                                     \usepackage{mathtools}})
(tex-scale 2)
(tex-dpi 300)
(tex-supersample 8)

(slide (text "texpict.rkt demo" 'default 72))

(slide
 #:title (text "texpict.rkt demo (inline)" 'default 36)
 @${e^{i\pi} + 1 = 0})

(slide
 #:title (text "texpict.rkt demo (inline)" 'default 36)
 @${x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}})

(slide
 #:title (text "texpict.rkt demo (display)" 'default 36)
 @$${x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}})
