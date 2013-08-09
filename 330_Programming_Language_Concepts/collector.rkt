#lang plai/collector

(define free-ptr 0)

(define (init-allocator)
  (begin
    (gc:alloc-free 0 -1)))
 
(define (markAll rootSet)
  (for-each (lambda (root) (mark (read-root root))) rootSet))

(define (unMarkAll rootSet)
  (for-each (lambda (root) (unmark (read-root root))) rootSet))

(define (mark loc)
  (cond 
    [(gc:flat? loc) 
       (if (procedure? (+ loc 1))
           (begin
             (markAll (procedure-roots (+ loc 1)))
             (heap-set! loc 'mark-prim))
           (heap-set! loc 'mark-prim))]
    [(gc:cons? loc) 
     (begin
       (heap-set! loc 'mark-cons)
       (mark (+ loc 1))
       (mark (+ loc 2)))]
    [else (error "error in mark!")]))

(define (unmark loc)
  (cond 
    [(marked-flat? loc) 
      (if (procedure? (+ loc 1))
           (begin
             (markAll (procedure-roots (+ loc 1)))
             (heap-set! loc 'mark-prim))
           (heap-set! loc 'mark-prim))]
    [(marked-cons? loc) 
     (begin
       (heap-set! loc 'cons)
       (unmark (+ loc 1))
       (unmark (+ loc 2)))]
    [(eq? (heap-ref loc) 'free)
     (unmark (+ loc (heap-ref (+ loc 1))))]
    [else (error "error in unmark!")]))

(define (debug str num) 
  (begin
    (display str)
    (display " ")
    (display num)
    (display "\n")))

(define (sweep loc)
    (if (location? (+ 3 loc))
        (cond
          [(marked-flat? loc) (sweep (+ loc 2))]
          [(marked-cons? loc) (sweep (+ loc 2))]
          [else 
           (if (eq? loc (- (heap-size) 1))
               (begin (heap-set! loc 'end) loc)
               (begin (gc:alloc-free loc free-ptr) (sweep (+ loc 3))))]
          )
        loc)
  )

(define (collect rootSet) 
  (begin
    (markAll rootSet)
    (sweep 0)
    (unMarkAll rootSet)
    ))

(define (findSpace loc)
  (cond
    [(eq? loc 'end) #f]
    [(eq? 'free (heap-ref loc)) loc]
    [else findSpace (heap-ref loc)]))
      
(define (gc:alloc-flat p)
 (begin
   (when (findSpace free-ptr)
     (if (procedure? p)
         (collect (append (get-root-set) (procedure-roots p)))
         (collect (get-root-set))))
   (when (findSpace free-ptr)
       (error 'gc:alloc-flat "no more memory!"))
   (define newFree (+ free-ptr 3))
   (define oldFree (+ free-ptr 0))
   (heap-set! free-ptr 'prim)
   (heap-set! (+ 1 free-ptr) p)
   (heap-set! (+ 2 free-ptr) 'notUsed)
   (gc:alloc-free newFree oldFree)
   (debug "gc:alloc-flat set! free-ptr" free-ptr)
   oldFree))

(define (gc:alloc-free new-loc oldFree)
    (if (location? (+ new-loc 2))
        (begin
          (heap-set! new-loc 'free)
          (heap-set! (+ 1 new-loc) oldFree)
          (heap-set! (+ 2 new-loc) -1)
          (set! free-ptr new-loc))
        (set! free-ptr -1)
        ))
  
(define (gc:cons f r)
 (begin
   (when (> (+ free-ptr 3) (heap-size))
     (error 'gc:cons "out of memory"))
     ;(collect (get-root-set f r)))
   (heap-set! free-ptr 'cons)
   (heap-set! (+ 1 free-ptr) f)
   (heap-set! (+ 2 free-ptr) r)
   (set! free-ptr (+ 3 free-ptr))
   (- free-ptr 3)))
 
(define (marked-cons? a)
  (eq? (heap-ref a) 'mark-cons))

(define (gc:cons? a)
 (eq? (heap-ref a) 'cons))
 
(define (gc:first a)
 (heap-ref (+ 1 a)))
 
(define (gc:rest a)
 (heap-ref (+ 2 a)))
 
(define (gc:set-first! a f)
 (if (gc:cons? a)
     (heap-set! (+ 1 a) f)
     (error 'set-first! "expects address of cons")))
 
(define (gc:set-rest! a r)
 (heap-set! (+ 2 a) r))
 
(define (marked-flat? a)
  (eq? (heap-ref a) 'mark-prim))

(define (gc:flat? a)
 (eq? (heap-ref a) 'prim))
 
(define (gc:deref a)
 (heap-ref (+ 1 a)))
