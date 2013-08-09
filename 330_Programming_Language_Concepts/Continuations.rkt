#lang racket

(require racket/trace)

;; filter: (x-> bool) (listof x) -> (listof x)
(define (filter f l)
 (cond
  [(empty? l) empty]
  [else (cond
          [(f (first l)) (cons (first l)
                               (filter f (rest l)))]
          [else (filter f (rest l))])]))

;; filter/k: (x-> bool) (listof x) -> (listof x) receiver -> doesn't
(define (filter/k f l k)
  0)


(define (less-than-three x)
  (< x 3))

(trace filter)

(filter less-than-three
        (cons 1 (cons 4 empty)))