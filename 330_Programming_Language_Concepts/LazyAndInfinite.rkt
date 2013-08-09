#lang lazy

(define (take-n l n)
  (if (and (> n 0) (not (empty? l)))
    (cons (first l) (take-n (rest l) (- n 1)))
    empty
  )
)

;; TESTING FACILITY

(define print-only-errors #t)
(define (test l r)
  (if (equal? l r)
    (if print-only-errors
      ()
      (printf "Test Passed~n"))
    (printf "Test Failed.~nActual:   ~S ~nExpected: ~S~n" l r)))


;; plus1
(define (plus1 x)
   (+ x 1))

;; plus2
(define (plus2 x y)
  (+ x y 2))

;; 3.9.2 UTILITY FUNCTIONS

;; take-while
;; Contract: 
;; p (any/c . -> . boolean?) l (listof any/c) --> listof any/c
;; Purpose: 
;; Returns the prefix of l such that for all elements of f returns true
(define (take-while f l)
  (if (empty? l)
    empty
    (if (f (first l))
      (cons (first l) (take-while f (rest l)))
      empty
    )
  )
)


;; TESTS
; Correct 
(test (take-while (lambda (n) (< n 5)) (list 1 2 3 4 5 6 7))
      (list 1 2 3 4))

; Empty Result 
(test (take-while (lambda (n) (< n 5)) (list 6 7))
      ())

; Empty Param 
(test (take-while (lambda (n) (< n 5)) ()) ())
(test (take-while (lambda (n) (< n 5)) empty) ())

; Non prefix satisfying boolean expression
(test (take-while (lambda (n) (< n 5)) (list 7 6 5 4 3 2 1))
      ())
(test (take-while (lambda (n) (< n 5)) (list 1 2 5 6 1 2))
      (list 1 2))
(test (take-while (lambda (n) (< n 5)) (list 5 1 1 1 1 1))
      ())

; Non number list
(test (take-while number? (list "one" "two" "three")) 
      ())
(test (take-while string? (list "one" "two" "three")) 
      (list "one" "two" "three"))

; Mixed
(test (take-while string? (list 1 "one" "two"))
      ())
(test (take-while string? (list "one" 1 1))
      (list "one"))
(test (take-while string? (list 1 1 1))
      ())


; Non Boolean Function
(test (take-while (lambda (n) (+ n 1)) (list 1 2 3))
      (list 1 2 3))
(test (take-while + (list 1 2 3))
      (list 1 2 3))
(test (take-while / (list 1 1 1))
      (list 1 1 1))

;; Infinite list tests after build-infinite-list

;; build-infinite-list
;; Contract:
;; f (exact-nonnegative-integer? . -> . any/c) --> listof any/c
;; Purpose:
;; Lazily constructs the inifinite list such that 
;; (list-ref (build-infinite-list f) i) returns (f i)

(define (build-infinite-list f)
  (letrec 
    ([list-start-at 
      (λ (x) 
        (cons (f x) (list-start-at (+ x 1)))
      )
    ])
    (list-start-at 0)
  )
)

;; TESTS
;; Correct
(test (list-ref (build-infinite-list (lambda (x) 1)) 0) 1)
(test (list-ref (build-infinite-list (lambda (x) 1)) 5000) 1)
(test (list-ref (build-infinite-list (lambda (x) (+ x 2))) 0) 2)
(test (list-ref (build-infinite-list (lambda (x) (+ x 2))) 1) 3)
(test (list-ref (build-infinite-list (lambda (x) (+ x 2))) 5000) 5002)
(test (list-ref (build-infinite-list (lambda (x) (* x x))) 0) 0)
(test (list-ref (build-infinite-list (lambda (x) (* x x))) 1) 1)
(test (list-ref (build-infinite-list (lambda (x) (* x x))) 5) 25)
(test (list-ref (build-infinite-list (lambda (x) (+ x x x))) 2) 6)
(test (list-ref (build-infinite-list (lambda (x) (* x x x))) 2) 8)
(test (list-ref (build-infinite-list (lambda (x) (* x x x))) 5) 125)
(test (list-ref (build-infinite-list (lambda (x) (+ x x x x x))) 2) 10)
(test (list-ref (build-infinite-list plus1) 0) 1)
(test (list-ref (build-infinite-list plus1) 1) 2)
(test (list-ref (build-infinite-list plus1) 5000) 5001)
(test (list-ref (build-infinite-list (lambda (x) (- x 2))) 0) -2)
(test (list-ref (build-infinite-list (lambda (x) (- x 2))) 1) -1)
(test (list-ref (build-infinite-list (lambda (x) (- x 2))) 5000) 4998)
(test (list-ref (build-infinite-list (lambda (x) (< x 10))) 10) #f)
(test (list-ref (build-infinite-list (lambda (x) (< x 10))) 1) #t)
(test (list-ref (build-infinite-list (lambda (x) (number->string x))) 1) "1")
(test (list-ref (build-infinite-list (lambda (x) (number->string x))) 100) "100")
(test (list-ref (build-infinite-list (lambda (x) (number->string x))) 5000) "5000")
(test (list-ref (build-infinite-list (lambda (x) (number->string x))) 747) "747")

;; Infinite List
(test (take-while number? (build-infinite-list (lambda(x) (< x 7))))
      ())
(test (take-while string? (build-infinite-list (lambda(x) 1)))
      ())
(test (take-while number? (build-infinite-list (lambda(x) (= x 1))))
      ())
;(test (take-while (lambda(x) (= x 1)) (build-infinite-list (lambda(x) 1)))
     ; (#<promise> . #<promise>)

     
;; 3.9.3 PRIMES

;; prime?
;; Contract:
;; n (exact-positive-integer?) --> boolean?
;; Purpose:
;; Returns true if n is prime

(define prime?-Error "Invalid: Non Positive Integer")

(define (prime? x)
  (if (and (number? x) (> x 0) (integer? x))
    (and 
      (andmap (λ (y) 
        (not (= 0 (modulo x y)))) 
        (take-while (λ (z) (<= z (sqrt x))) 
          (build-infinite-list (λ (x) (+ x 2)))
        )
      )
      (not (= 1 x))
    )
    prime?-Error
  )
)

;; TESTS____________________________________

;; ILLEGAL
(test (prime? 0) prime?-Error)
(test (prime? -1) prime?-Error)
(test (prime? true) prime?-Error)
(test (prime? "Hello") prime?-Error)
(test (prime? 'x) prime?-Error)

;; TRUE RESULTS
(test (prime? 2) #t)
(test (prime? 3) #t)
(test (prime? 11) #t)
(test (prime? 17) #t)

;; FALSE RESULTS
(test (prime? 1) #f)
(test (prime? 4) #f)
(test (prime? 21) #f)
(test (prime? 33) #f)

;; primes
;; Contract:
;; (listof exact-positive-integer?)
;; Purpose:
;; list of all primes

(define primes 
  (filter prime? (build-infinite-list (λ (x) (+ x 2))))
)

;; TESTS____________________________________
(test (list-ref primes 0) 2)
(test (list-ref primes 1) 3)
(test (list-ref primes 2) 5)
(test (list-ref primes 3) 7)
(test (list-ref primes 4) 11)
(test (list-ref primes 5) 13)
(test (list-ref primes 6) 17)
(test (list-ref primes 7) 19)
(test (list-ref primes 8) 23)
(test (list-ref primes 9) 29)
(test (list-ref primes 10) 31)
(test (list-ref primes 11) 37)
(test (list-ref primes 12) 41)
(test (list-ref primes 13) 43)
(test (list-ref primes 14) 47)
(test (list-ref primes 15) 53)
(test (list-ref primes 16) 59)
(test (list-ref primes 17) 61)
(test (list-ref primes 18) 67)
(test (list-ref primes 19) 71)
(test (list-ref primes 20) 73)
(test (list-ref primes 100) 547)
(test (list-ref primes 101) 557)
(test (list-ref primes 999) 7919)
(test (list-ref primes 1000) 7927)

(test (take-while (lambda (n) (not (prime? n))) primes)
      ())

;; prime/fast
;; Contract:
;; (listof exact-positive-integer?)
;; Purpose:
;; list of all primes constructed with prime?/fast

(define primes/fast
  (filter prime?/fast (build-infinite-list (λ (x) (+ x 2))))
)



;; prime?/fast
;; Contract:
;; n (exact-positive-integer?) --> boolean
;; Purpose:
;; Returns true if n is prime, but tests only
;; prime factors from prime/fast

(define (prime?/fast x)
  (if (and (number? x) (> x 0) (integer? x))
    (if (= x 2)
      #t
      (and 
        (andmap (λ (y) 
          (not (= 0 (modulo x y)))) 
          (take-while (λ (z) (<= z (sqrt x))) 
            primes/fast
          )
        )
        (not (= 1 x))
      )
    )
    prime?-Error
  )
)

;; TESTS for prime?/fast
;; ILLEGAL
(test (prime?/fast 0) prime?-Error)
(test (prime?/fast -1) prime?-Error)
(test (prime?/fast true) prime?-Error)
(test (prime?/fast "Hello") prime?-Error)
(test (prime?/fast 'x) prime?-Error)

;; TRUE RESULTS
(test (prime?/fast 2) #t)
(test (prime?/fast 3) #t)
(test (prime?/fast 11) #t)
(test (prime?/fast 17) #t)
(test (prime?/fast 7703) #t)
(test (prime?/fast 8599) #t)
(test (prime?/fast 523) #t)

;; FALSE RESULTS
(test (prime?/fast 1) #f)
(test (prime?/fast 4) #f)
(test (prime?/fast 21) #f)
(test (prime?/fast 33) #f)
(test (prime?/fast 524) #f)
(test (prime?/fast 1022) #f)

;; TESTS for primes/fast
(test (list-ref primes/fast 0) 2)
(test (list-ref primes/fast 1) 3)
(test (list-ref primes/fast 2) 5)
(test (list-ref primes/fast 3) 7)
(test (list-ref primes/fast 4) 11)
(test (list-ref primes/fast 5) 13)
(test (list-ref primes/fast 6) 17)
(test (list-ref primes/fast 7) 19)
(test (list-ref primes/fast 8) 23)
(test (list-ref primes/fast 9) 29)
(test (list-ref primes/fast 10) 31)
(test (list-ref primes/fast 11) 37)
(test (list-ref primes/fast 12) 41)
(test (list-ref primes/fast 13) 43)
(test (list-ref primes/fast 14) 47)
(test (list-ref primes/fast 15) 53)
(test (list-ref primes/fast 16) 59)
(test (list-ref primes/fast 17) 61)
(test (list-ref primes/fast 18) 67)
(test (list-ref primes/fast 19) 71)
(test (list-ref primes/fast 20) 73)
(test (list-ref primes/fast 100) 547)
(test (list-ref primes/fast 101) 557)
(test (list-ref primes/fast 999) 7919)
(test (list-ref primes/fast 1000) 7927)

(test (take-while (lambda (n) (not (prime? n))) primes/fast)
      ())

;; 3.9.4 LONGEST COMMON SUBSEQUENCE

;; HELPER FUNCTIONS
;; build-vectors 
;; Contract:
;; 
;; Purpose:
;; 

(define (build-vector num f)
  (apply vector (build-list num f)))

;; TESTS____________________________________
(test (vector-ref (build-vector 1 (lambda (x) x)) 0) 0)
(test (vector-ref (build-vector 5 (lambda (x) x)) 4) 4)
(test (vector-ref (build-vector 2 (lambda (x) (* x x))) 1) 1)
(test (vector-ref (build-vector 5 (lambda (x) (* x x))) 4) 16)
(test (vector-ref (build-vector 2 (lambda (x) (+ x x x x x))) 1) 5)
(test (vector-ref (build-vector 5 (lambda (x) (* x x x x))) 4) (* 4 4 4 4))
(test (vector-ref (build-vector 2 (lambda (x) (* x 5))) 1) 5)
(test (vector-ref (build-vector 5 (lambda (x) (/ x 2))) 4) 2)


;; build-table
;; Contract:
;; rows cols f -> vectorof (vectorof any/c?)
;; (exact-positive-integer?) (exact-positive-integer?) -->
;; (exact-nonnegative-integer? exact-nonnegative-integer? .-> . any/c
;; Purpose:
;; Lazily constructs a vector such that 
;; (vector-ref (vector-ref (build-table rows cols f) i) j) 
;; equals (f i j), when (< i rows) (< j cols).

(define (build-table rows cols f)
  (letrec ([map-vector (λ (x) (build-vector cols (λ (y) (f x y))))])
    (build-vector rows map-vector)
  )
)

;; TESTS____________________________________
(test (vector-ref (vector-ref (build-table 5 5 (lambda (x y) (+ x y))) 4) 4) 8)
(test (vector-ref (vector-ref (build-table 1 1 (lambda (x y) (+ x y))) 0) 0) 0)
(test (vector-ref (vector-ref (build-table 1 5 (lambda (x y) (+ x y))) 0) 4) 4)
(test (vector-ref (vector-ref (build-table 5 1 (lambda (x y) (+ x y))) 4) 0) 4)
(test (vector-ref (vector-ref (build-table 5 5 (lambda (x y) (* x y))) 4) 4) 16)
(test (vector-ref (vector-ref (build-table 1 1 (lambda (x y) (* x y))) 0) 0) 0)
(test (vector-ref (vector-ref (build-table 1 5 (lambda (x y) (* x y))) 0) 4) 0)
(test (vector-ref (vector-ref (build-table 5 1 (lambda (x y) (* x y))) 4) 0) 0)
(test (vector-ref (vector-ref (build-table 5 5 (lambda (x y) (+ x y x y))) 4) 4) 16)
(test (vector-ref (vector-ref (build-table 1 1 (lambda (x y) (+ x y x y))) 0) 0) 0)
(test (vector-ref (vector-ref (build-table 1 5 (lambda (x y) (+ x y x y))) 0) 4) 8)
(test (vector-ref (vector-ref (build-table 5 1 (lambda (x y) (+ x y x y))) 4) 0) 8)
(test (vector-ref (vector-ref (build-table 5 5 (lambda (x y) (+ x x))) 4) 4) 8)
(test (vector-ref (vector-ref (build-table 1 1 (lambda (x y) (+ x x))) 0) 0) 0)
(test (vector-ref (vector-ref (build-table 1 5 (lambda (x y) (+ x x))) 0) 4) 0)
(test (vector-ref (vector-ref (build-table 5 1 (lambda (x y) (+ x x))) 4) 0) 8)
(test (vector-ref (vector-ref (build-table 5 5 (lambda (x y) (- x y))) 4) 4) 0)
(test (vector-ref (vector-ref (build-table 1 1 (lambda (x y) (- x y))) 0) 0) 0)
(test (vector-ref (vector-ref (build-table 1 5 (lambda (x y) (- x y))) 0) 4) -4)
(test (vector-ref (vector-ref (build-table 5 1 (lambda (x y) (- x y))) 4) 0) 4)
(test (vector-ref (vector-ref (build-table 5 5 (lambda (x y) (- x y))) 4) 2) 2)
(test (vector-ref (vector-ref (build-table 5 5 (lambda (x y) (- x y))) 2) 4) -2)
(test (vector-ref (vector-ref (build-table 5 5 plus2) 4) 4) 10)
(test (vector-ref (vector-ref (build-table 1 1 plus2) 0) 0) 2)
(test (vector-ref (vector-ref (build-table 1 5 plus2) 0) 4) 6)
(test (vector-ref (vector-ref (build-table 5 1 plus2) 4) 0) 6)

;; lcs-length
;; Contract:
;; string? string? --> exact-nonnegative-integer?
;; Purpose:
;; Computes the length of the longest common
;; subsequence of two strings

(define (lcs-length string-a string-b)
  (letrec ([common-sequence (build-table (+ 1 (string-length string-a)) (+ 1 (string-length string-b))
    (λ (x y)
      (if (or (= 0 x) (= 0 y))
        0
        (if (char=? (string-ref string-a (- x 1)) (string-ref string-b (- y 1)))
          (+ (vector-ref (vector-ref common-sequence (- x 1)) (- y 1)) 1)
          (max
            (vector-ref (vector-ref common-sequence x) (- y 1))
            (vector-ref (vector-ref common-sequence (- x 1)) y)
          )
        )
      )
    )
  )])
;  common-sequence
   (vector-ref (vector-ref common-sequence (string-length string-a)) (string-length string-b))
  )
)

;; TESTS____________________________________
(test (lcs-length "Artist" 
                  "Artsy") 4)
(test (lcs-length "Hello" 
                  "Ho") 2)
(test (lcs-length "abcdefghijklmnopqrstuvwxyz" 
                  "abc") 3)
(test (lcs-length "abcdefghijklmnopqrstuvwxyz" 
                  "abcefg") 6)
(test (lcs-length "abcdefghijklmnopqrstuvwxyz" 
                  "azbcde") 5)
(test (lcs-length "abcdefghijklmnopqrstuvwxyz" 
                  "bzacde") 4)
(test (lcs-length "abcdefghijklmnopqrstuvwxyz" 
                  "zyxwvutsrqponmlkjihgfedcba") 1)
(test (lcs-length "abcdefghijklmnopqrstuvwxyz" 
                  "zyxwvutsrqponmlkjihgfedcbabc") 3)
(test (lcs-length "abcdefghijklmnopqrstuvwxyz" 
                  "") 0)
(test (lcs-length "" 
                  "zyxwvutsrqponmlkjihgfedcba") 0)
(test (lcs-length "" "") 0)
(test (lcs-length "a" "a") 1)
(test (lcs-length "a" "z") 0)
(test (lcs-length "a" "1") 0)
(test (lcs-length "-" "a") 0)
(test (lcs-length "true" "a") 0)
(test (lcs-length "true" "te") 2)
(test (lcs-length "abcdefghijklmnopqrstuvwxyz" 
                  "abcdefghijklmnopqrstuvwxyz") 26)

