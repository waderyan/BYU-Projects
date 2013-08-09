#lang plai/mutator

(allocator-setup "gcMark.rkt" 80)

(define (fact x)
  (if (zero? x)
      1
      (* x (fact (sub1 x)))))

(define (fact-help x a)
  (if (zero? x)
      a
      (fact-help (sub1 x) (* x a))))

(define lst (cons 1 (cons 2 (cons 3 empty))))

(define (map-add n lst)
  (map (lambda (x) (+ n x)) lst))

(define (map f lst)
  (if (cons? lst)
      (cons (f (first lst)) (map f (rest lst)))
      empty))

(define (filter p lst)
  (if (cons? lst)
      (if (p (first lst))
          (cons (first lst) (filter p (rest lst)))
          (filter p (rest lst)))
      lst))

(define (append l1 l2)
  (if (cons? l1)
      (cons (first l1) (append (rest l1) l2))
      l2))

(define (length lst)
  (if (empty? lst)
      0
      (add1 (length (rest lst)))))

(define tail (cons 1 empty))
(define head (cons 4 (cons 3 (cons 2 tail))))
(set-rest! tail head)

(printf "res ~a~n" head)
(set! head empty)
(set! tail head)
(printf "res ~a~n" lst)
(printf "res ~a~n" (length '(hello goodbye)))
(printf "res ~a~n" (map sub1 lst))

(printf "(fact-help 15 1): ~a~n" (fact-help 15 1))
(printf "(fact 9): ~a~n" (fact 9))

(printf "(append lst lst): ~a~n" (append lst lst))

(printf "(map-add 5 lst): ~a~n" (map-add 5 lst))
(printf "(filter even? (map sub1 lst)): ~a~n"
        (filter even? (map sub1 lst)))
(printf "(length lst): ~a~n" (length lst))