#lang plai/collector

;; Variable points to the location of the beginning
;; of the free list
(define free-ptr 0)
 
;; Debugging helper function.
;; Prints out the given string and the given number
;; separated by a space. Ending with a new line
(define (debug str num) 
  (begin
    (display str)
    (display " ")
    (display num)
    (display "\n")))

;; Initializes the heap allocation by calling
;; sweep starting at the zero location.
;; Equivalent to:
;; (sweep 0)
(define (init-allocator)
  (sweep 0))

;; Marks the location as in use
;; mark -> void?
;; loc -> location?
(define (mark loc)
 (cond 
    [(gc:flat? loc) 
       (if (procedure? (heap-ref (+ loc 1)))
           (begin
             (markAll (procedure-roots (heap-ref (+ loc 1))))
             (heap-set! loc 'mark-prim))
           (heap-set! loc 'mark-prim))]
    [(gc:cons? loc) 
     (begin
       (heap-set! loc 'mark-cons)
       (mark (heap-ref (+ loc 1)))
       (mark (heap-ref (+ loc 2))))]
    [(marked-flat? loc) #t]
    [(marked-cons? loc) #t]
    [else 
     (debug "free-ptr: " free-ptr)
     (debug "loc: " loc)
     (error "error in mark!")]))

;; Determines if it is a marked flat
;; marked-flat? loc -> boolean?
;; loc -> location?
(define (marked-flat? loc)
  (eq? (heap-ref loc) 'mark-prim))

;; Determines if it is a marked cons
;; marked-cons? loc -> boolean?
;; loc -> location?
(define (marked-cons? loc)
  (eq? (heap-ref loc) 'mark-cons))

;; Sweeps memory space allocating free blocks for 
;; any unmarked flat or cons
;; sweep loc -> void?
;; loc -> location?
(define (sweep loc)
  (if (not (> (+ loc 3) (heap-size)))
      (cond 
        [(marked-flat? loc) 
         (begin
           (heap-set! loc 'prim)
           (sweep (+ loc 3)))] 
        [(marked-cons? loc) 
         (begin
           (heap-set! loc 'cons)
           (sweep (+ loc 3)))] 
        [else
          (begin
            (heap-set! loc 'free)
            (heap-set! (+ loc 1) 'noUse)
            (if (= loc free-ptr)
                (heap-set! (+ loc 2) -1)
                (heap-set! (+ loc 2) free-ptr))
            (set! free-ptr loc)
            (sweep (+ loc 3)))])
      (begin
        (if (not (>= loc (heap-size)))
            (heap-set! loc #f)
            'doNothing)
        (if (not (>= (+ loc 1) (heap-size)))
            (heap-set! (+ 1 loc) #f)
            'doNothing)
        (if (not (>= (+ loc 2) (heap-size)))
            (heap-set! (+ 2 loc) #f)
            'doNothing)
        )))

;; Marks all the heap values reachable by the root set
;; Equivalent to calling for each on each root in rootSet
;; markAll rootSet -> void?
;; rootSet -> list?
(define (markAll rootSet)
  (for-each (lambda (root) (mark (read-root root))) rootSet))

;; Performs garbage collection on the given root set
;; Equivalent to marking all references reachable by root set
;; then sweeping beginning at the 0 location.
;; collect rootSet -> void?
;; rootSet -> list?
(define (collect rootSet)
  (begin
    (markAll rootSet)
    (sweep 0)))

;; Determines if the heap is out of space. This flag
;; is read by the free pointer being set to -1.
;; outOfSpace? -> boolean?
(define (outOfSpace?)
  (= free-ptr -1))

;; Allocates space for a flat value (number, boolean, function)
;; Returns the location of the allocated flat value.
;; gc:alloc-flat p -> location?
;; p -> heap-value?
(define (gc:alloc-flat p)
 (begin
   (when (outOfSpace?)
     (collect (get-root-set)))
   (when (outOfSpace?)
     (error 'gc:alloc-flat "out of memory"))
   (define newLoc free-ptr)
   (set! free-ptr (heap-ref (+ 2 free-ptr)))
   (heap-set! newLoc 'prim)
   (heap-set! (+ 1 newLoc) p)
   (heap-set! (+ 2 newLoc) 'NoUse)
   newLoc))
 
;; Allocates space for a cons value given the first
;; and the rest address.
;; Returns the location of the allocated cons value.
;; gc:cons f r -> location?
;; f -> location?
;; r -> location?
(define (gc:cons f r)
 (begin
   (when (outOfSpace?)
     (collect (get-root-set f r)))
   (when (outOfSpace?)
     (error 'gc:cons "out of memory"))
   (define newLoc free-ptr)
   (set! free-ptr (heap-ref (+ 2 free-ptr)))
   (heap-set! newLoc 'cons)
   (heap-set! (+ 1 newLoc) f)
   (heap-set! (+ 2 newLoc) r)
   newLoc))
 
;; Determins if the loction is a cons value.
;; gc:cons? a -> boolean?
;; a -> location?
(define (gc:cons? a)
 (eq? (heap-ref a) 'cons))
 
;; Gets the first value of the cons value.
;; gc:first a -> heap-value?
;; a -> location?
(define (gc:first a)
 (heap-ref (+ 1 a)))
 
;; Gets the rest value of the cons value.
;; gc:rest a -> heap-value?
;; a -> location?
(define (gc:rest a)
 (heap-ref (+ 2 a)))
 
;; Sets the first value of the cons value. 
;; gc:set-first! a f -> void?
;; a -> location?
;; f -> heap-value?
(define (gc:set-first! a f)
 (if (gc:cons? a)
     (heap-set! (+ 1 a) f)
     (error 'set-first! "expects address of cons")))
 
;; Sets the rest value of the cons value. 
;; gc:set-rest! a r -> void?
;; a -> location?
;; r -> heap-value?
(define (gc:set-rest! a r)
 (heap-set! (+ 2 a) r))
 
;; Determins if the loction is a flat value.
;; gc:flat? a -> boolean?
;; a -> location?
(define (gc:flat? a)
 (eq? (heap-ref a) 'prim))
 
;; Gets the dereferenced value of the given location
;; gc:deref a -> heap-value?
;; a -> location?
(define (gc:deref a)
 (heap-ref (+ 1 a)))