;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname Lists) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; 3.4 Lists and Trees
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


(define (check-temps1 temps)
  (cond
    [(empty? temps) true]
    [else 
     (and 
      (between 5 95 (first temps))
      (check-temps1 (rest temps)))]))
 
;; tests

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
  (cond
    [(empty? temps) true]
    [else
     (and 
      (between low high (first temps))
      (check-temps (rest temps) low high))]))

;; tests

(check-expect (check-temps empty 0 1) true)
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
  (cond
    [(empty? digits) 0]
    [else
     (+ (* 10 (convert (rest digits)))(first digits))]))

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
   (/ (sum prices) (list-sizeof prices))))

(define (sum list)
  (if
   (empty? list) 0
   (+ (first list) (sum (rest list)))))
  
(check-expect (sum (list 1 2)) 3)
(check-expect (sum (list 0 1 9)) 10)

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
  (if
   (empty? temps) empty
   (cons (convertF->C (first temps)) (convertFC (rest temps)))))

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
  (cond
    [(empty? lotp) empty]
    [else
     (if 
      ;test expr
      (>= ua (first lotp)) 
      ;then expr
      (cons (first lotp) (eliminate-exp ua (rest lotp)))
      ;else
      (eliminate-exp ua (rest lotp)))]))
          
;; tests
(check-expect (eliminate-exp 10 empty) empty)
(check-expect (eliminate-exp 10 (list 5 6 7 11)) (list 5 6 7))
(check-expect (eliminate-exp 100 (list 90)) (list 90))
(check-expect (eliminate-exp 5 (list 6 7 8)) empty)
(check-expect (eliminate-exp 50 (list 40 50 60)) (list 40 50))

;; Problem #7
;; Contract: suffixes
;; (suffixes l) -> (listof list?)
;; Purpose: Produces a list of suffixes of l
(define (suffixes l)
  (if
    (empty? l) (cons empty empty)
    (cons l (suffixes (rest l)))))
    
;; tests
(check-expect 
 (suffixes (list 'a 'b 'c 'd)) 
              (list (list 'a 'b 'c 'd) 
                    (list 'b 'c 'd) 
                    (list 'c 'd) 
                    (list 'd) 
                    empty))
(check-expect (suffixes empty) (cons empty empty))
(check-expect (suffixes (list 'a)) (list (list 'a) empty))
(check-expect (suffixes (list 'a 'b)) (list (list 'a 'b) (list 'b) empty))

;; Problem #8

;; Contract: struct unknown
;; Purpose: represents an unknown ancestor

(define-struct unknown ())

;; Problem #9

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

;; Problem #10

;; Contract: count-persons
;; (count-persons ftrees -> number?)
;; ftree : (or/c unknown? person?)

;; Purpose: returns the number of people in a family tree

(define (count-persons ftree)
  (cond
   [(unknown? ftree) 0]
   [else 
    (+ 
     1 
     (count-persons 
      (person-father ftree)) 
     (count-persons
      (person-mother ftree)))]))

;; test

(check-expect (count-persons cassie) 3)
(check-expect (count-persons bob) 1)
(check-expect (count-persons  (make-unknown)) 0)
(check-expect (count-persons wade) 7)
 

;; Problem #11

;; Contract: average-age 
;; (average-age ftree) -> number?
;; ftree : (or/c unknown? person?)

;; Purpose: Returns the average age of all the people in the family tree

(define (average-age ftree)
  (if
   (unknown? ftree) 
   ;then
   0
   ;else
   (/ 
   (sum-ages ftree)
   (count-persons ftree)
   )
  )
 )
     
    
;; tests
(check-within (average-age wade) 68.43 .01)
(check-within (average-age cassie) 43.33 .01)
(check-expect (average-age stan) 93)
(check-expect (average-age bob) 113)
(check-expect (average-age (make-unknown)) 0)

;; helper functions
(define (sum-ages ftree)
  (cond
   [(unknown? ftree) 0]
   [else
    (+ 
     (calcAge ftree) 
     (sum-ages (person-mother ftree)) 
     (sum-ages (person-father ftree)))
    ]
   )
  )

(check-expect (sum-ages cassie) 130)
(check-expect (sum-ages bob) 113)
(check-expect (sum-ages (make-unknown)) 0)
(check-expect (sum-ages wade) 479)


(define (calcAge person)
  (- 2013 (person-birthyear person)))

(check-expect (calcAge wade) 23)


;; Problem #12

;; Contract: eye-colors
;; (eye-colors ftrees) -> (listof symbol?)
;; ftree : (or/c unknown? person?)

;; Purpose: Produce a list of all eye colors in a family tree

;; Definition
(define (eye-colors ftree)
  (cond
    [;if
     (unknown? ftree) 
     ;then
     empty
     ]
    [;else
     else
     (cons
      (person-eyecolor ftree)
      (append
       (eye-colors 
        (person-mother ftree))
       (eye-colors 
        (person-father ftree))
       )
      )
     ]
    )
  )
     

;; Tests
(check-expect (eye-colors cassie) (list 'brown 'brown 'brown))
(check-expect (eye-colors bob) (list 'yellow))
(check-expect (eye-colors randy) (list 'brown 'blue 'brown))
(check-expect (eye-colors (make-unknown)) empty)


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
;;  TEST CASES FOR sum
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (sum (list 4 5 6)) 15)
(check-expect (sum (list 3 2 9 0 5)) 19)
(check-expect (sum empty) 0)
(check-expect (sum (list 0 1 2 3 4 5 6 8 9)) 38)
(check-expect (sum (list 1 1 1)) 3)
(check-expect (sum (list 4 5 2 0 -5 -7)) -1)



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
;;  TEST CASES FOR suffixes
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect 
  (suffixes (list 'a 'b 'c 'd))
  (list (list 'a 'b 'c 'd) (list 'b 'c 'd) (list 'c 'd) (list 'd) empty)
)
(check-expect 
  (suffixes empty)
  (list empty)
)
(check-expect 
  (suffixes (list (list 4 2) 3 9))
  (list (list (list 4 2) 3 9) (list 3 9) (list 9) empty)
)
(check-expect 
  (list "a" 1 'sym)
  (list "a" 1 'sym)
)
(check-expect 
  (suffixes (list "a" 1 'sym))
  (list (list "a" 1 'sym) (list 1 'sym) (list 'sym) empty)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TEST CASES FOR person
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define arnold 
  (make-person "Arnold" 1930 "brown" (make-unknown) (make-unknown)))
(define ellen 
  (make-person "Ellen" 1933 "blue" (make-unknown) (make-unknown)))
(define kameron 
  (make-person "Kameron" 1965 "green" arnold ellen))
(define grandpa 
  (make-person "grandpa" 1936 "brown" (make-unknown) (make-unknown)))
(define midge 
  (make-person "Midge" 1940 "blue" (make-unknown) (make-unknown)))
(define robyn 
  (make-person "Robyn" 1965 "green" grandpa midge))
(define ryan 
  (make-person "Ryan" 1990 "blue" kameron robyn))
(define imag 
  (make-person "Imaginary" 2015 "invisible" ryan (make-unknown)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TEST CASES FOR count-persons
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (count-persons arnold) 1)
(check-expect (count-persons ellen) 1)
(check-expect (count-persons kameron) 3)
(check-expect (count-persons grandpa) 1)
(check-expect (count-persons midge) 1)
(check-expect (count-persons robyn) 3)
(check-expect (count-persons ryan) 7)
(check-expect (count-persons imag) 8)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  TEST CASES FOR average-age
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-expect (average-age ryan) (/ 432 7))
(check-expect (average-age kameron) (/ 211 3))
(check-expect (average-age robyn) 66)
(check-expect (average-age arnold) 83)
(check-expect (average-age ellen) 80)
(check-expect (average-age midge) 73)
(check-expect (average-age grandpa) 77)
(check-expect (average-age imag) 53.75)
(check-expect (average-age (make-unknown)) 0)


