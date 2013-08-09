#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/dispatch
         web-server/page)

(define (first-ask-for-the-first-number req)
  (send/back
   (response/xexpr
    `(html (head (title "First Page"))
           (body
            (form ([action "/p2"])
                  "First number: " 
                  (input ([type "text"] [name "num1"]))
                  (input ([type "submit"]))))))))

(define (then-ask-for-second-number req)
  (define num1 (get-binding "num1" req))
  (send/back
   (response/xexpr
    `(html (head (title "Second Page"))
           (body
            (form ([action "/p3"])
                  "Second number: " 
                  (input ([type "text"] [name "num2"]))
                  (input ([type "hidden"] [name "num1"] [value ,num1]))
                  (input ([type "submit"]))))))))

(define (then-return-the-answer req)
  (define num1 (string->number (get-binding "num1" req)))
  (define num2 (string->number (get-binding "num2" req)))
  (send/back
   (response/xexpr
    `(html (head (title "Result"))
           (body
            "The result is "
            ,(number->string (+ num1 num2)))))))

;; url -> calls the appropriate function
(define-values
  (dispatch function->url)
  (dispatch-rules
   [("p3") then-return-the-answer]
   [("p2") then-ask-for-second-number]
   [else first-ask-for-the-first-number]))

(serve/servlet dispatch
               #:port 9000
               #:servlet-regexp #rx"")