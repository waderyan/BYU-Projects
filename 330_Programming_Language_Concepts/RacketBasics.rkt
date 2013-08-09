;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname RacketBasics) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; Wade Anderson Basic Racket -- Date 1/15/13

;; Contract: number number number number -> number
;; Purpose: calculate the sum of coins in units of pennies

(define (sum-coins p n d q)
  (+ p (n-conv n) (d-conv d) (q-conv q)))

;; Contract: number -> number
;; Purpose: converts nickels to pennies
(define (n-conv nickels)
  (* 5 nickels))

;; Contract: nubmer-> number
;; Purpose: converts dimes to pennies
(define (d-conv dimes)
  (* 10 dimes))

;; Contract: number-> number
;; Purpose: converts quarters to pennies
(define (q-conv quarters)
  (* 25 quarters))

;; tests -- treating negatives like liabilities
(check-expect (sum-coins 1 1 1 1) 41)
(check-expect (sum-coins 1 0 0 0) 1)
(check-expect (sum-coins 0 1 0 0) 5)
(check-expect (sum-coins 0 0 1 0) 10)
(check-expect (sum-coins 0 0 0 1) 25)
(check-expect (sum-coins 0 0 0 0) 0)
(check-expect (sum-coins -1 0 0 0) -1)
(check-expect (sum-coins -1 -1 -1 -1) -41)


;;------------area cylinder -- ------------------
;; Contract: number number -> number
;; Purpose: compute the area of a cylinder
;; == 2 pi r^2 + 2 pi r h
(define (area-cylinder r h)
    (if (and (not (negative? r)) (not (negative? h)))
        (+ (area-circle r) (height-cylinder r h)) 0))

;; Contract: number->number
;; Purpose: computes the area of a circle
(define (area-circle r) 
  (if (positive? r) (* 2 pi (if (positive? r) (sqred r) 0)) 0))

;; Contract: number-> number
;; Purpose: squares a number
(define (sqred r)
  (* r r))

;; Contract: number, number -> number
;; Purpose: computes height of cylinder
(define (height-cylinder r h)
  (if (and (positive? r) (positive? h)) (* 2 pi r h) 0))

;; tests 
(check-within (area-cylinder 1 1) 12.56 .1)
(check-within (area-cylinder 0 1) 0 .1)
(check-within (area-cylinder 1 0) 6.28 .1)
(check-within (area-cylinder 5 5) #i314.15 .1)
(check-within (area-cylinder 100 100) #i125663.70 .1)
(check-within (area-cylinder -1 1) 0 .1)
(check-within (area-cylinder 1 -1) 0 .1)

;;------------------tax --------
;; Contract: number-> number
;; Purpose: computes the tax rate
(define (tax gross-pay)
  (if (negative? gross-pay) 0
      (cond 
        [(<= gross-pay 240) 0]
        [(and (> gross-pay 240) (<= gross-pay 480)) (* .15 gross-pay)]
        [(> gross-pay 480) (* .28 gross-pay)])))

;; tests
(check-expect (tax 239) 0)
(check-expect (tax 241) 36.15)
(check-expect (tax 481) 134.68)
(check-expect (tax 6000) 1680)
(check-expect (tax -1) 0)


;; -------------- netpay ------
;; Contract: number -> number
;; Purpose: calculates the net pay
(define (netpay hours-worked)
  (if (negative? hours-worked) 0
  (- (gross-pay hours-worked) (tax (gross-pay hours-worked)))))

;; Contract: number-> number
;; Purpose: computes gross-pay
(define (gross-pay hours-worked)
  (* 12 hours-worked))

;; tests
(check-expect (netpay 1) 12)
(check-expect (netpay 20) 240)
(check-expect (netpay 50) 432)
(check-expect (netpay -1) 0)


;; ----------- what-kind of quadratic function 
;; Contract: number, number, number -> 'word
;; Purpose: determines what type of a quadratic function it is
(define (what-kind a b c)
  (cond
    [(= a 0) 'degenerate]
    [(test-one a b c) 'one]
    [(test-none a b c) 'none]
    [else 'two]))
   
;; Contract: number, number, number -> 'word
;; Purpose: determines if there is 'one solution
;; if b^2 - 4ac == 0
(define (test-one a b c)
  (= (- (sqred b) (* 4 a c)) 0))

;; Contract: number, number, number -> 'none
;; Purpose: determines if there are no solutions
(define (test-none a b c)
  (> (* 4 a c) (sqred b)))

;; tests
(check-expect (what-kind 1 1 1) 'none)
(check-expect (what-kind 1 6 9) 'one)
(check-expect (what-kind 1 2 1) 'one)
(check-expect (what-kind 0 1 1) 'degenerate)
(check-expect (what-kind 1 5 6) 'two)
(check-expect (what-kind -1 1 1) 'two)
(check-expect (what-kind 1 -1 1) 'none)
(check-expect (what-kind 1 1 -1) 'two)

;; --------- struct time ---------
;; Structure: time in -> hours: minutes: seconds
;; Purpose: represents time

(define-struct time (hours minutes seconds))

;; tests
(check-expect (time-hours (make-time 1 0 0)) 1)
(check-expect (time-minutes (make-time 0 1 0)) 1)
(check-expect (time-seconds (make-time 0 0 1)) 1)

;; ---------- time-diff
;; Contract: time, time -> number
;; Purpose: time since midnight

(define (time-diff t1 t2)
  (- (time->seconds t2) (time->seconds t1)))

;; Contract: time -> number
;; Purpose: convert time object to number of seconds
(define (time->seconds t)
  (+ (time-seconds t) (* 60 (time-minutes t)) (* 60 60 (time-hours t))))
 
;; tests
(check-expect (time->seconds (make-time 0 0 0)) 0)
(check-expect (time->seconds (make-time 1 3 2)) 3782)

(check-expect (time-diff (make-time 1 1 1) (make-time 1 1 0)) -1)
(check-expect (time-diff (make-time 1 1 0) (make-time 1 1 1)) 1)
(check-expect (time-diff (make-time 0 0 100) (make-time 0 0 0)) -100)

;; ---------- struct position
;; Structure: represents two dimensional points
;; Purpose: Represents a 2D point
(define-struct position (x y))

;; tests
(check-expect (position-x (make-position 1 0)) 1)
(check-expect (position-y (make-position 1 0)) 0)

;; ----------- struct circ ----
;; Structure: represents circles
;; Purpose: represents circle
(define-struct circle (center radius))

;; tests
(check-expect (circle-center (make-circle (make-position 1 1) 0)) 
              (make-position 1 1))
(check-expect (circle-radius (make-circle (make-position 1 1) 1)) 1)

;; ----------- struct square
;; Structure: reprsents squares
;; Purpose; represents squares
(define-struct square (upper-left length))

;;tests
(check-expect (square-upper-left (make-square (make-position 1 0) 1)) 
              (make-position 1 0))
(check-expect (square-length (make-square 0 1)) 1)

;; ----------- struct rectangle
;; Purpose: represents rectangles
(define-struct rect (upper-left width height))

;; tests
(check-expect (rect-upper-left (make-rect (make-position 1 0) 2 3)) 
              (make-position 1 0))
(check-expect (rect-width (make-rect (make-position 1 0) 2 3)) 2)
(check-expect (rect-height (make-rect (make-position 1 0) 2 3)) 3)

;; ---------- area shape
;; Contract: shape -> number
;; Purpose: computes the area of the shape
(define (area shape)
  (cond 
    [(rect? shape) (areaRect shape)]
    [(square? shape) (areaSquare shape)]
    [(circle? shape) (areaCircle shape)]))

;; Contract: rect -> number
;; Purpose: calculate area of rectangle
(define (areaRect rect)
  (* (rect-width rect) (rect-height rect)))

;; test
(check-expect (areaRect (make-rect 0 1 2)) 2)

;; Contract: square -> number
;; Purpose: calculate area of square
(define (areaSquare s)
  (* (square-length s) (square-length s)))

;; test
(check-expect (areaSquare (make-square 1 2)) 4)

;; Contract: circle -> number
;; Purpose: calculate area of circle
(define (areaCircle c)
  (* (sqred (circle-radius c)) pi))

;; test
(check-within (areaCircle (make-circle 0 1)) 3.14 .1)

;; tests
(check-expect (area (make-rect 0 1 2)) 2)
(check-expect (area (make-square 1 2)) 4)
(check-within (area (make-circle 0 1)) 3.14 .1)


;; ---------- translate-shape 
;; Contract: shape, number -> shape
;; Purpose: produces a shape whose key position is 
;; moved by delta pixels in the x direction
(define (translate-shape shape delta)
  (cond
    [(rect? shape) (transRect shape delta)]
    [(square? shape) (transSquare shape delta)]
    [(circle? shape) (transCircle shape delta)]))

;; Contract: rectangle, number -> rectangle
;; Purpose: translate a rectangle
(define (transRect rect delta)
  (make-rect (make-position 
              (+ (position-x (rect-upper-left rect)) delta) 
                (position-y (rect-upper-left rect))) 
                  (rect-width rect) (rect-height rect)))

;; test
(check-expect (transRect (make-rect (make-position 1 0) 1 1) 1) 
              (make-rect (make-position 2 0) 1 1))

;; Contract: square, number -> square
;; Purpose: translate a square
(define (transSquare s delta) 
  (make-square (make-position 
                (+ (position-x (square-upper-left s)) delta) 
                    (position-y (square-upper-left s))) (square-length s)))

;; test
(check-expect (transSquare (make-square (make-position 1 0) 2) 1) 
              (make-square (make-position 2 0) 2))

;; Contract: circle, number -> circle
;; Purpose: translate a circle
(define (transCircle c delta)
  (make-circle (make-position 
                (+ (position-x (circle-center c)) delta) 
                              (position-y (circle-center c))) 
                                                (circle-radius c)))

;; test
(check-expect (transCircle (make-circle (make-position 1 0) 1) 1) 
              (make-circle (make-position 2 0) 1))

;; tests
(check-expect (translate-shape (make-rect (make-position 1 0) 1 1) 1) 
              (make-rect (make-position 2 0) 1 1))
(check-expect (translate-shape (make-rect (make-position 1 0) 1 1) -1) 
              (make-rect (make-position 0 0) 1 1))
(check-expect (translate-shape (make-square (make-position 1 0) 2) 1) 
              (make-square (make-position 2 0) 2))
(check-expect (translate-shape (make-square (make-position 1 0) 2) -1) 
              (make-square (make-position 0 0) 2))
(check-expect (translate-shape (make-circle (make-position 1 0) 1) 1) 
              (make-circle (make-position 2 0) 1))

;;---------- in-shape?
;; Contract: shape, point -> boolean
;; Purpose: returns true if p is within the shape, false otherwise

(define (in-shape? shape p)
  (cond
    [(rect? shape) (in-rect? shape p)]
    [(square? shape) (in-square? shape p)]
    [(circle? shape) (in-circle? shape p)]))


;; tests
(check-expect (in-shape? (make-rect (make-position 0 0) 2 2) 
                         (make-position 1 1)) true)
(check-expect (in-shape? (make-rect (make-position 1 1) 2 4) 
                         (make-position 3 8)) false)
(check-expect (in-shape? (make-rect (make-position 0 0) 2 2) 
                         (make-position 3 1)) false)
(check-expect (in-shape? (make-square (make-position 0 0) 2) 
                         (make-position 1 3)) false)
(check-expect (in-shape? (make-square (make-position 0 0) 2) 
                         (make-position 3 1)) false)
(check-expect (in-shape? (make-square (make-position 1 1) 2) 
                         (make-position 1 2)) false)
(check-expect (in-shape? (make-square (make-position 1 1) 2) 
                         (make-position 3 1)) false)
(check-expect (in-shape? (make-square (make-position 0 0) 2) 
                         (make-position 1 2)) false)
(check-expect (in-shape? (make-circle (make-position 0 0) 2) 
                         (make-position 1 3)) false)
(check-expect (in-shape? (make-circle (make-position 0 0) 2) 
                         (make-position 3 1)) false)
(check-expect (in-shape? (make-circle (make-position 1 1) 2) 
                         (make-position 1 3)) false)
(check-expect (in-shape? (make-circle (make-position 1 1) 2) 
                         (make-position 3 1)) false)
(check-expect (in-shape? (make-circle (make-position 1 1) 2) 
                         (make-position 1 1)) true)
(check-expect (in-shape? (make-circle (make-position -1 -1) 2) 
                         (make-position 3 1)) false)
(check-expect (in-shape? (make-circle (make-position 0 0) 2) 
                         (make-position -1 -1)) true)

;; Contract: rectangle, point -> boolean
;; Purpose: determines if a point is in a rectangle
(define (in-rect? rect p)
  (and 
   (< (position-x p) (+ (position-x (rect-upper-left rect)) 
                        (rect-width rect)))
   (> (position-x p) (position-x (rect-upper-left rect)))
   (< (position-y p) (+ (position-y (rect-upper-left rect)) 
                        (rect-height rect)))
   (> (position-y p) (position-y (rect-upper-left rect)))))

;; tests
(check-expect (in-rect? (make-rect (make-position 0 0) 2 2) 
                        (make-position 1 1)) true)
(check-expect (in-rect? (make-rect (make-position 0 0) 2 2) 
                        (make-position 3 3)) false)
(check-expect (in-rect? (make-rect (make-position 0 0) 2 2) 
                        (make-position 1 3)) false)
(check-expect (in-rect? (make-rect (make-position 0 0) 2 2) 
                        (make-position 3 1)) false)
(check-expect (in-rect? (make-rect (make-position 1 1) 2 4) 
                        (make-position 1 4)) false)
(check-expect (in-rect? (make-rect (make-position 1 1) 2 4) 
                        (make-position 3 8)) false)
(check-expect (in-rect? (make-rect (make-position 1 1) 2 4) 
                        (make-position 1 5)) false)

;; Contract: square, point -> boolean
;; Purpose: determines if a point is in a square
(define (in-square? square p)
  (and 
   (< (position-x p) 
      (+ (position-x (square-upper-left square)) 
                        (square-length square)))
   (> (position-x p) 
      (position-x (square-upper-left square)))
   (< (position-y p) 
      (+ (position-y (square-upper-left square)) 
                        (square-length square)))
  (> (position-x p) 
     (position-x (square-upper-left square)))))

;; tests
(check-expect (in-square? (make-square (make-position 0 0) 2) 
                          (make-position 1 1)) true)
(check-expect (in-square? (make-square (make-position 0 0) 2) 
                          (make-position 3 3)) false)
(check-expect (in-square? (make-square (make-position 0 0) 2) 
                          (make-position 1 3)) false)
(check-expect (in-square? (make-square (make-position 0 0) 2) 
                          (make-position 3 1)) false)
(check-expect (in-square? (make-square (make-position 1 1) 2) 
                          (make-position 1 2)) false)
(check-expect (in-square? (make-square (make-position 1 1) 2) 
                          (make-position 3 1)) false)
(check-expect (in-square? (make-square (make-position 0 0) 2) 
                          (make-position 1 2)) false)
(check-expect (in-square? (make-square (make-position 0 0) 2) 
                          (make-position 2 1)) false)

;; Contract: circle, point -> boolean
;; Purpose: determines if a point is in a circle
(define (in-circle? circle p)
  (< 
   (+ (sqred (- (position-x p) (position-x (circle-center circle)))) 
                (sqred (- (position-y p) (position-y (circle-center circle)))))
   (sqred (circle-radius circle))))

;; tests
(check-expect (in-circle? (make-circle (make-position 0 0) 2) 
                          (make-position 1 1)) true)
(check-expect (in-circle? (make-circle (make-position 0 0) 2) 
                          (make-position 3 3)) false)
(check-expect (in-circle? (make-circle (make-position 0 0) 2) 
                          (make-position 1 3)) false)
(check-expect (in-circle? (make-circle (make-position 0 0) 2) 
                          (make-position 3 1)) false)

;; on the edge
(check-expect (in-circle? (make-circle (make-position 1 1) 2) 
                          (make-position 1 3)) false)
(check-expect (in-circle? (make-circle (make-position 1 1) 2) 
                          (make-position 3 1)) false)
(check-expect (in-circle? (make-circle (make-position 1 1) 2) 
                          (make-position 1 1)) true)
(check-expect (in-circle? (make-circle (make-position 1 1) 3) 
                          (make-position -1 1)) true)


(define p3 (make-position 2 2))
(define p1 (make-position 0 0))
(define p2 (make-position 4 4))
(define c1 (make-circle p1 5))
(define c2 (make-circle p2 3))
(define sq1 (make-square p1 7))
(define sq2 (make-square p2 10))
(define r1 (make-rect p1 4 5))
(define r2 (make-rect p2 9 2))
(define p4 (make-position 5 0))
(define p5 (make-position 9 4))
(define p6 (make-position 7 2))
(define t1 (make-time 0 0 0))
(define t2 (make-time 4 15 0))
(define t3 (make-time 8 20 16))
(define t4 (make-time 12 45 7))
(define t5 (make-time 16 0 37))
(define t6 (make-time 20 30 41))
(define t7 (make-time 22 17 52))

(check-expect (sum-coins 3 4 5 6) 223)
(check-expect (sum-coins 0 0 0 3) 75)
(check-expect (sum-coins 0 0 3 0) 30)
(check-expect (sum-coins 0 3 0 0) 15)
(check-expect (sum-coins 3 0 0 0) 3)
(check-expect (sum-coins 43 54 23 56) 1943)
(check-expect (sum-coins 3435 343 23 544) 18980)

(check-expect (tax 40) 0)
(check-expect (tax 0) 0)
(check-expect (tax 240) 0)
(check-expect (tax 241) 36.15)
(check-expect (tax 300) 45)
(check-expect (tax 480) 72)
(check-expect (tax 481) 134.68)
(check-expect (tax 1000) 280)
(check-expect (netpay 1) 12)
(check-expect (netpay 5) 60)
(check-expect (netpay 20) 240)
(check-expect (netpay 21) 214.2)
(check-expect (netpay 40) 408)
(check-expect (netpay 45) 388.8)
(check-expect (netpay 60) 518.4)
(check-expect (netpay 100) 864)
(check-expect (what-kind 4 4 4) 'none)
(check-expect (what-kind 0 4 3) 'degenerate)
(check-expect (what-kind 1 5 6) 'two)
(check-expect (what-kind 1 0 4) 'none)
(check-expect (what-kind 1 0 -4) 'two)
(check-expect (what-kind 1 2 1) 'one)
(check-expect (what-kind 4 9 0) 'two)


(check-expect (time-diff t1 t2) 15300)
(check-expect (time-diff t1 t3) 30016)
(check-expect (time-diff t1 t4) 45907)
(check-expect (time-diff t2 t1) -15300)
(check-expect (time-diff t4 t6) 27934)
(check-expect (time-diff t5 t5) 0)
(check-expect (time-diff t5 t6) 16204)
(check-expect 49 (area sq1))
(check-expect 100 (area sq2))
(check-within (* pi 5 5) (area c1) .0001)
(check-within (* pi 3 3) (area c2) .0001)
(check-expect 20 (area r1))
(check-expect 18 (area r2))
(check-expect (translate-shape c1 5) (make-circle p4 5))
(check-expect (translate-shape c2 5) (make-circle p5 3))
(check-expect (translate-shape sq1 5) (make-square p4 7))
(check-expect (translate-shape sq2 5) (make-square p5 10))
(check-expect (translate-shape r1 5) (make-rect p4 4 5))
(check-expect (translate-shape r2 5) (make-rect p5 9 2))
(check-expect (in-shape? r1 p3) true)
(check-expect (in-shape? r2 p3) false)
(check-expect (in-shape? sq1 p3) true)
(check-expect (in-shape? sq2 p3) false)
(check-expect (in-shape? c1 p3) true)
(check-expect (in-shape? c2 p3) true)
