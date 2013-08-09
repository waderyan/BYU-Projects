;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname HIgherOrderFun) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; 3.5 Higher-order Functions
;; Wade Anderson

;; Problem #1
;; Contract: check-temps1 : (listof number?) -> boolean?
;; Purpose: Consumes a list of temperature measures 
;; and checks whether all measurements are between 5
;; and 95 degrees celsius

(define (between low high input)
  (and (>= high input) (<= low input)))
  
(check-expect (between 5 10 8) true)
(check-expect (between 5 10 11) false)
(check-expect (between 5 10 5) true)

;; tests

(define (check-temps1 temps)
  (andmap (lambda (x) (between 5 95 x)) temps))

(check-expect (check-temps1 empty) true)
(check-expect (check-temps1 (cons 50 empty)) true)
(check-expect (check-temps1 (cons 96 empty)) false)
(check-expect (check-temps1 
               (cons 41 
                     (cons 94 
                           (cons 44 (cons 75 (cons 6 empty)))))) true)
(check-expect (check-temps1 
               (cons 41 (cons 94 (cons 44 (cons 75 (cons 96 empty)))))) false)


;; Problem #2
;; Contract: (listof number?) number number -> boolean
;; Purpose: consumes a list of temperature measures and
;; checks whether they are between low and high

(define (check-temps temps low high)
  (andmap (lambda (x) (between low high x)) temps))

;; tests

(check-expect (check-temps (cons 50 empty) 40 60) true)
(check-expect (check-temps (cons 1000 empty) 9000 11000) false)
(check-expect (check-temps 
               (cons 41 (cons 94 (cons 44 
                                       (cons 75 (cons 6 empty))))) 4 95) true)
(check-expect (check-temps 
               (cons 41 
                     (cons 94 
                           (cons 44 
                                 (cons 75 (cons 96 empty))))) 45 100) false)


;; Problem #3
;; Contract: (listof number) -> number
;; Purpose: consumes a list of numbers and produces the 
;; corresponding number. The first digit is the least sign.

(define (convert digits)
  (foldr (lambda (x r) (+ x (* 10 r))) 0 digits))

;; tests

(check-expect (convert empty) 0)
(check-expect (convert (cons 1 empty)) 1)
(check-expect (convert (cons 1 (cons 2 empty))) 21)
(check-expect (convert (list 1 2 3)) 321)


;; Problem #4
;; Contract: (listof number) -> number
;; Purpose: Consumes a list of toy prices and computes
;; the average price of a toy
(define (average-price prices) 
  (if
   (empty? prices) 0
   (/ 
    (foldl + 0 prices) 
    (list-sizeof prices)
    )
   )
  )

(define (list-sizeof list)
  (if
   (empty? list) 0
   (+ 1 (list-sizeof (rest list)))))

(check-expect (list-sizeof (list 1 2 3)) 3)
(check-expect (list-sizeof empty) 0)
(check-expect (list-sizeof (list 1 2 3 4 5 6 7 8 9)) 9)

;; tests

(check-expect (average-price (list 1 2)) 1.5)
(check-expect (average-price (list 1 1)) 1)
(check-expect (average-price (list 1 3)) 2)
(check-expect (average-price (list 1 1 1 1)) 1)
(check-within (average-price (list 10 20 70)) 33.33 .01)
(check-expect (average-price (list 5 10 15 20 25)) 15)
(check-within (average-price (list 1.5 2.5 3.5 5.2)) 3.175 .001)

;; Problem #5
;; Contract: (listof number) -> (listof number)
;; Purpose: Converts a lsit of Fahrenheigh measurmeents 
;; to a list of Celcius measurements
(define (convertFC temps)
  (map convertF->C temps))

(define (convertF->C temp)
 (/ (* (- temp 32) 5) 9))

(check-expect (convertF->C 32) 0)
(check-expect (convertF->C 68) 20)
(check-expect (convertF->C 50) 10)
(check-expect (convertF->C 14) -10)

;; tests

(check-expect (convertFC empty) empty)
(check-expect (convertFC (list 32)) (list 0))
(check-expect (convertFC (list 68 50)) (list 20 10))
(check-expect (convertFC (list 14)) (list -10))

;; Problem #6
;; Contract: number (listof number) -> (listof number)
;; Purpose: eliminate from lotp all toys whose price is 
;; greater than ua
(define (eliminate-exp ua lotp) 
  (filter (lambda (x) (<= x ua)) lotp))
  
          
;; tests
(check-expect (eliminate-exp 10 empty) empty)
(check-expect (eliminate-exp 10 (list 5 6 7 11)) (list 5 6 7))
(check-expect (eliminate-exp 100 (list 90)) (list 90))
(check-expect (eliminate-exp 5 (list 6 7 8)) empty)
(check-expect (eliminate-exp 50 (list 40 50 60)) (list 40 50))


;; Problem # 7
;; Contract: compose-func
;; after before -> (alpha . -> . gamma)
;; after : (beta . -> . gamma)
;; before : (alpha . -> . beta)
;; Purpose: Returns the composition of before and after
(define (compose-func after before)
  (lambda (x) (after (before x))))
  
(define (divide2 x)
  (/ x 2))

(define (sub5 x)
  (- x 5))

(define (multByZero x)
  (* x 0))

(define (add5 x)
  (+ x 5))

;; tests
(check-expect ((compose-func divide2 sub5) 10) 2.5)
(check-expect ((compose-func sub5 divide2) 10) 0)
(check-expect ((compose-func add5 multByZero) 10) 5)
(check-expect ((compose-func multByZero add5) 10) 0)
(check-expect ((compose-func divide2 add5) 10) 7.5)

;; Problem # 8
;; contract: flatten 
;; listof (listof number?) -> (listof number?)
;; purpose: produces a list of all the numbers in the list of lists
;; Note: Don't use foldr
(define (flatten list)
  (if
   (empty? list) empty
   (append (first list) (flatten (rest list)))))


;; tests
(check-expect (flatten (list (list 1 2) (list 3 4 5) (list 6))) 
              (list 1 2 3 4 5 6))
(check-expect (flatten (list (list 1))) (list 1))
(check-expect (flatten (list empty)) empty)
(check-expect (flatten (list (list 1) (list 2))) (list 1 2))

;; Problem #9
;; Contract: flatten-foldr
;; (listof (listof number?) -> (listof number?)
;; Purpose: Returns a list of all the number sof lolon
;; Note: use foldr
(define (flatten-foldr list)
  (foldr append empty list))


;; tests
(check-expect (flatten-foldr (list (list 1 2) (list 3 4 5) (list 6))) 
              (list 1 2 3 4 5 6))
(check-expect (flatten-foldr (list (list 1))) (list 1))
(check-expect (flatten-foldr (list empty)) empty)
(check-expect (flatten-foldr (list (list 1) (list 2))) (list 1 2))


;; Problem #10
;; Contract: bucket
;; (listof number?) -> (listof (listof number?))
;; Purpose: returns a list of sublists of adjacent equal numbers
;; Note: use foldr
(define (bucket lst)
  (foldr 
   ;anonymous function
   (lambda (x rst)
     (cond
      [;if
       (empty? (first rst))
       (cons (cons x empty) (rest rst))
       ]
      [;elseif
       (= x (first (first rst)))
       (cons (cons x (first rst)) (rest rst))
       ]
      [
       else
       (cons (cons x empty) rst)
       ]
      )
     )
   ;base case
   (list empty)
    ;list
    lst
   )
  )
  
;; tests
(check-expect (bucket (list 1 1 2 2)) (list (list 1 1) (list 2 2)))
(check-expect (bucket (list empty)) (list (list empty)))
(check-expect (bucket (list 1 5 5 1)) (list (list 1)(list 5 5) (list 1)))
(check-expect (bucket 
               (list 1 1 2 2 2 3 1 1 1 2 3 3)) 
              (list (list 1 1) (list 2 2 2) 
                    (list 3) (list 1 1 1) (list 2) (list 3 3)))
(check-expect (bucket empty) (list empty))

;; Contract: struct unknown
;; Purpose: represents an unknown ancestor

(define-struct unknown ())

;; Contract: struct person (name birthyear eyecolor father mother)
;; Purpose: represents a person

(define-struct person (name birthyear eyecolor father mother))

;; List of people for testing purposes

(define stan (make-person "stan" 1920 'brown (make-unknown) (make-unknown)))
(define larae (make-person "larae" 1920 'blue (make-unknown) (make-unknown)))
(define christie 
  (make-person "christie" 1930 'brown (make-unknown) (make-unknown)))
(define ken (make-person "ken" 1930 'brown (make-unknown) (make-unknown)))
(define karl (make-person "karl" 1960 'brown (make-unknown) (make-unknown)))
(define vida (make-person "vida" 1960 'brown (make-unknown) (make-unknown)))
(define bob (make-person "bob" 1900 'yellow (make-unknown) (make-unknown)))
(define randy (make-person "randy" 1960 'brown stan larae))
(define tami (make-person "tami" 1962 'blue christie ken))
(define wade (make-person "wade" 1990 'blue randy tami))
(define cassie (make-person "cassie" 1989 'brown karl vida))
(define jake (make-person "jake" 1992 'blue randy tami))

;; Problem #11
;; Contract tree-map
;; (string .. -> ... -> string?) 
;; (or/c unknown? person?) -> (or/c unknown? person?)
;; purpose: returns a tree where f has 
;; been applied to every person's name in tree
(define (tree-map f tree)
  (if
   (unknown? tree) (make-unknown)
   (make-person 
    (f (person-name tree)) 
    (person-birthyear tree) 
    (person-eyecolor tree)
    (tree-map f (person-father tree))
    (tree-map f (person-mother tree)))))

(define (addBlah word)
  (string-append word "blah"))

;; tests
(check-expect (tree-map addBlah (make-unknown)) (make-unknown))
(check-expect (person-name (tree-map addBlah bob)) "bobblah")
(check-expect (person-name 
               (person-mother (tree-map addBlah cassie))) "vidablah")


;; Problem #12
;; Contract: add-last-name
;; tree : (or/c unknown? person?), lname : string? -> (or/c unknown? person?)
;; returns a tree where lname has been appeneded to every person's name
;; Note must use tree-map and string-append
(define (add-last-name tree lname)
  (tree-map (lambda (x) (string-append x " " lname)) tree))

;; tests
(check-expect (add-last-name (make-unknown) "blah") (make-unknown))
(check-expect (person-name (add-last-name wade "anderson")) "wade anderson")
(check-expect (person-name (person-father 
                            (add-last-name cassie "cannon"))) "karl cannon")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                      ;;
;;   TTTTTTTT  EEEEEEEE  SSSSSSSS  TTTTTTTT  SSSSSSSS   ;;
;;      TT     EE        SS           TT     SS         ;;
;;      TT     EEEEEE    SSSSSSSS     TT     SSSSSSSS   ;;
;;      TT     EE              SS     TT           SS   ;;
;;      TT     EEEEEEEE  SSSSSSSS     TT     SSSSSSSS   ;;
;;                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; TEST CASES FOR check-temps1
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define temp-list1 (list 6 30 51 93 41))
(define temp-list2 (list 2 5 7 23 68 23))
(define temp-list3 (list 45 67 89 93 102))
(define temp-list4 (list 5 95 6 59))

(check-expect (check-temps1 temp-list1) true)
(check-expect (check-temps1 temp-list2) false)
(check-expect (check-temps1 temp-list3) false)
(check-expect (check-temps1 temp-list4) true)
(check-expect (check-temps1 empty) true)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TEST CASES FOR check-temps
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (check-temps temp-list1 20 40) false)
(check-expect (check-temps temp-list2 2 80) true)
(check-expect (check-temps temp-list3 40 111) true)
(check-expect (check-temps temp-list4 50 90) false)
(check-expect (check-temps empty 40 50) true)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TEST CASES FOR convert
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (convert (list 1 2 3)) 321)
(check-expect (convert (list 4 2 6 8 9)) 98624)
(check-expect (convert empty) 0)
(check-expect (convert (list 3 4 6 9 0 3 4)) 4309643)
(check-expect (convert (list 1 2 3 9 8 7)) 789321)
(check-expect (convert (list 5)) 5)
(check-expect (convert (list 5 0)) 5)





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TEST CASES FOR average-price
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (average-price (list 1 2 3)) 2)
(check-expect (average-price (list 2 4 6 8 10)) 6)
(check-expect (average-price temp-list1) 44.2)
(check-within (average-price temp-list2) 21.3 .1)
(check-expect (average-price temp-list3) 79.2)
(check-expect (average-price temp-list4) 41.25)
(check-expect (average-price empty) 0)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TEST CASES FOR convertFC
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (convertFC (list 32 -40)) (list 0 -40))
(check-expect (convertFC empty) empty)
(check-expect (convertFC (list -40 32 32)) (list -40 0 0))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TEST CASES FOR eliminate-exp
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect 
  (eliminate-exp 3 (list 1 5 3 0 2 89 2 8))
  (cons 1 (cons 3 (cons 0 (cons 2 (cons 2 empty)))))
)
(check-expect 
  (eliminate-exp 5 (list 9 3 8 4 1 100))
  (cons 3 (cons 4 (cons 1 empty)))
)
(check-expect 
  (eliminate-exp 409 empty)
  empty
)
(check-expect 
  (eliminate-exp 32 (list 439 23 495 23 39 40 329 23))
  (cons 23 (cons 23 (cons 23 empty)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TEST CASES FOR person
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define arnold 
  (make-person "Arnold" 1930 'brown (make-unknown) (make-unknown)))
(define ellen 
  (make-person "Ellen" 1933 'blue (make-unknown) (make-unknown)))
(define kameron 
  (make-person "Kameron" 1965 'green arnold ellen))
(define grandpa 
  (make-person "grandpa" 1936 'brown (make-unknown) (make-unknown)))
(define midge 
  (make-person "Midge" 1940 'blue (make-unknown) (make-unknown)))
(define robyn 
  (make-person "Robyn" 1965 'green grandpa midge))
(define ryan 
  (make-person "Ryan" 1990 'blue kameron robyn))
(define imag 
  (make-person "Imaginary" 2015 'invisible ryan (make-unknown)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  TEST CASES FOR compose-func
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect ((compose-func sqr sqr) 3)
81)
(check-expect ((compose-func sqr sqr) 6)
1296)
(check-expect ((compose-func sqrt sqr) 6)
6)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST CASES FOR flatten
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (flatten (list '(2 3 4) '(3 0 3 2 0) '(2) '(9))) 
(list 2 3 4 3 0 3 2 0 2 9))
(check-expect (flatten (list '() '() '(2) '(9))) 
(list 2 9))
(check-expect (flatten (list '())) 
empty)
(check-expect (flatten (list '(3) '(4 2 3))) 
(list 3 4 2 3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST CASES FOR flatten-foldr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (flatten-foldr (list '(2 3 4) '(3 0 3 2 0) '(2) '(9))) 
(list 2 3 4 3 0 3 2 0 2 9))
(check-expect (flatten-foldr (list '() '() '(2) '(9))) 
(list 2 9))
(check-expect (flatten-foldr (list '())) 
empty)
(check-expect (flatten-foldr (list '(3) '(4 2 3))) 
(list 3 4 2 3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST CASES FOR bucket
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (bucket '(4 4 4 4 3 3 3 2 2 1))
(list (list 4 4 4 4) (list 3 3 3) (list 2 2) (list 1)))
(check-expect (bucket '(1 2 3 4 5 5 4 3 2 1))
(list
 (list 1)
 (list 2)
 (list 3)
 (list 4)
 (list 5 5)
 (list 4)
 (list 3)
 (list 2)
 (list 1)))
(check-expect (bucket '())
(list empty))
(check-expect (bucket '(1))
(list (list 1)))
(check-expect (bucket '(1 3 3 3 2 2))
(list (list 1) (list 3 3 3) (list 2 2)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST CASES FOR tree-map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (tree-map (lambda (n) (string-append n " yes")) (make-unknown))
(make-unknown))
(check-expect (tree-map (lambda (n) (string-append n " yes")) ryan)
(make-person
 "Ryan yes"
 1990
 'blue
 (make-person
  "Kameron yes"
  1965
  'green
  (make-person "Arnold yes" 1930 'brown (make-unknown) (make-unknown))
  (make-person "Ellen yes" 1933 'blue (make-unknown) (make-unknown)))
 (make-person
  "Robyn yes"
  1965
  'green
  (make-person "grandpa yes" 1936 'brown (make-unknown) (make-unknown))
  (make-person "Midge yes" 1940 'blue (make-unknown) (make-unknown)))))
(check-expect (tree-map (lambda (n) (string-append n " yes")) kameron)
(make-person
 "Kameron yes"
 1965
 'green
 (make-person "Arnold yes" 1930 'brown (make-unknown) (make-unknown))
 (make-person "Ellen yes" 1933 'blue (make-unknown) (make-unknown))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST CASES FOR add-last-name 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (add-last-name (make-unknown) "Jones")
(make-unknown))
(check-expect (add-last-name arnold "Jones")
(make-person "Arnold Jones" 1930 'brown (make-unknown) (make-unknown)))
(check-expect (add-last-name ellen "Jones")
(make-person "Ellen Jones" 1933 'blue (make-unknown) (make-unknown)))
(check-expect (add-last-name grandpa "Jones")
(make-person "grandpa Jones" 1936 'brown (make-unknown) (make-unknown)))
(check-expect (add-last-name midge "Jones")
(make-person "Midge Jones" 1940 'blue (make-unknown) (make-unknown)))
(check-expect (add-last-name kameron "Jones")
(make-person
 "Kameron Jones"
 1965
 'green
 (make-person "Arnold Jones" 1930 'brown (make-unknown) (make-unknown))
 (make-person "Ellen Jones" 1933 'blue (make-unknown) (make-unknown))))
(check-expect (add-last-name robyn "Jones")
(make-person
 "Robyn Jones"
 1965
 'green
 (make-person "grandpa Jones" 1936 'brown (make-unknown) (make-unknown))
 (make-person "Midge Jones" 1940 'blue (make-unknown) (make-unknown))))
(check-expect (add-last-name ryan "Jones")
(make-person
 "Ryan Jones"
 1990
 'blue
 (make-person
  "Kameron Jones"
  1965
  'green
  (make-person "Arnold Jones" 1930 'brown (make-unknown) (make-unknown))
  (make-person "Ellen Jones" 1933 'blue (make-unknown) (make-unknown)))
 (make-person
  "Robyn Jones"
  1965
  'green
  (make-person "grandpa Jones" 1936 'brown (make-unknown) (make-unknown))
  (make-person "Midge Jones" 1940 'blue (make-unknown) (make-unknown)))))
(check-expect (add-last-name imag "Jones")
(make-person
 "Imaginary Jones"
 2015
 'invisible
 (make-person
  "Ryan Jones"
  1990
  'blue
  (make-person
   "Kameron Jones"
   1965
   'green
   (make-person "Arnold Jones" 1930 'brown (make-unknown) (make-unknown))
   (make-person "Ellen Jones" 1933 'blue (make-unknown) (make-unknown)))
  (make-person
   "Robyn Jones"
   1965
   'green
   (make-person "grandpa Jones" 1936 'brown (make-unknown) (make-unknown))
   (make-person "Midge Jones" 1940 'blue (make-unknown) (make-unknown))))
 (make-unknown)))