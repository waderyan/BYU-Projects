#lang plai


;; Class Notes Friday 2/4

;; internal represenation of pre-define dfunctions
(define-type FunDef
  [fundef (fun-name symbol?)
          (arg-name symbol?)
          (body FlWAE?)
          ]
  )

;; some functions to work with (add as desired)
(define fun-defs
  (list 
   (fundef 'double
           'n
           (add (id 'n) (id 'n)))
   (fundef 'inc
           'n
           (add (id 'n) (num 1)))
   (fundef 'dec
           'n
           (sub (id 'n) (num 1)))
   ))

;; lookup-fundef : symbol listof(FunDef) -> FunDef
(define (lookup-fundef fun-name fundefs)
  (cond
    [(empty? fundefs) (error fun-name "function not found")]
    [else (if (symbol=? fun-name (fundef-fun-name (first fundefs)))
              (first fundefs)
              (lookup-fundef fun-name (rest fundefs)))]))

;; parse : sexp -> F1WAE
;; to convert s-expression into F1WAEs
(define (parse1 sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(list? sexp)
     (case (first sexp)
       [(+) (add (parse1 (second sexp))
                 (parse1 (third sexp)))]
       [(-) (sub (parse1 (second sexp))
                 (parse1 (third sexp)))]
       [(with) (with (first (second sexp)) ; id
                     (parse (second (second sexp))) ; named-expr
                     (parse (third sexp)))] ;body
       )
     ; need to handle app here
     [else (app (first sexp)
                (parse (second sexp)))]
     ]
    )
  )


;; interpr
(define (interp expr fundefs)
  (type-case WAE expr
    (num (n) n)
    (add (l r) (+ (interp l fundefs) (interp r fundefs)))
    (sub (l r) (- (interp l fundefs) (calc r fundefs)))
    (with (id named-expr body) 
          (interp
           (subst body id 
                  (num (interp named-expr fundefs)))
              fundefs))
    (id (v) (error "unbound identifier"))
    [app (fun-name fun-args)
    )
  )




;; Class Notes Wednesday 1/30

;; abstract syntax for AE

;; one to one coorespondance between non terminals and pieces of abstract syntax
;; step one extend concrete syntax
;; step two extend abstract context
;; step trhee extend parser


(define-type WAE
  [num (n number?)]
  [add (lhs WAE?) 
       (rhs WAE?)]
  [sub (lhs WAE?) 
       (rhs WAE?)]
  [with (name id?)
        (named-expr WAE?)
        (body WAE?)]
  [id (name symbol?)]
 )

;; parse : sexp -> AE
;; to coonvert s-expression into AEs
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(list? sexp)
     (case (first sexp)
       [(+) (add (parse (second sexp))
                 (parse (third sexp)))]
       [(-) (sub (parse (second sexp))
                 (parse (third sexp)))]
       [(with) (with (first (second sexp)) ; id
                     (parse (second (second sexp))) ; named-expr
                     (parse (third sexp)))] ;body
       )
     ]
    )
  )


;; calc : AE -> number
;; evaluates an AE and returns the result
(define (calc expr)
  (type-case WAE expr
    (num (n) n)
    (add (l r) (+ (calc l) (calc r)))
    (sub (l r) (- (calc l) (calc r)))
    (with (id named-expr body) 
          (calc 
           (subst body id 
                  (calc named-expr))
           )
          )
    (id (v) (error "unbound identifier"))
    )
  )

(test (calc (parse '(+ 3 4))) 6)
(test (calc (parse '(+ 3 4))) 7)

;; Substitutes WAE symbol number -> WAE
(define (subst expr sub-id val)
  (type-case WAE expr
    [num (n) expr]
    [id (v) (if 
             (eq? v sub-id) val
              expr)]  
    [add (l r) (add (subst l sub-id val)
                    (subst r sub-id val)
                    )]
    [sub (l r) (sub (subst l sub-id val)
                    (subst r sub-id val)
                    )]
    [with (with-id with-named-expr with-body)
          (if (eq? with-id sub-id)
              expr ; shadowing -- no substituion
              (with ; no shadowing - OK to substitute
               with-id
               (subst with-named-expr sub-id val)
               (subst with-body sub-id val)
               )
              )
          ]
  )
)

;; run : s-exp -> number
;; run-time helper (not in book but useful)

(define (run x) 
  (calc parse x)
  )

;; Class Notes Monday 1/28

; local functions

(define (check-temps low high lst)
  (local [
          (define (helloWorld) 42)
          (define (check-temp x) true)
          
          ]
    (map check-temp lst)
   )
 )


;; just focusing on correct behavior
;; BNF - Bocus Nauer form (grammar for grammar)
;; <Arithmetic expression> ::= <number> | {+<AE><AE>} | {-<AE><AE>}

;; What do you write a compiler in? What was the C compiler written in? 
;; A subset was written in assembly and then the rest was written in that
;; subset

;; Target & implementation
;; sytax -> syntax
;; variable -> data structures to keep track of variables



;; case is like a switch statement

       
;; parser - go from concrete syntax to abstract syntax tree

;; concrete syntax -> parser -> abstract syntax -> translator 
;; -> abstract syntax -> unparser (code generator - generates bits) -> concerete ouput

;; Class Notes Friday 1/25

(define-type family-tree
  [unknown ]
  [person (name string?)
           (birthyear number?)
           (eyecolor symbol?)
           (mother family-tree?)
           (father family-tree?)])

;; What do we look for in languages? 
;; 1) grammar - where do you put semicolons to make the compiler 
;; stop complaining. the form
;; 2) semantics - the meaning
;; operational semantics - implement an interpreter and whatever the
;; interpreter does that is the meaning of the language


