#lang plai

; abstract syntax for WAE
(define-type WAE
  [num (n number?)]
  [add (lhs WAE?) (rhs WAE?)]
  [sub (lhs WAE?) (rhs WAE?)]
  [with (name symbol?) (named-expr WAE?) (body WAE?)] ; new
  [id (name symbol?)]) ; new

;; parse : sexp −> WAE
;; to convert s-expressions into WAEs
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(symbol? sexp) (id sexp)] ; new
    [(list? sexp)
     (case (first sexp)
       [(+) (add (parse (second sexp))
                 (parse (third sexp)))]
       [(-) (sub (parse (second sexp))
                 (parse (third sexp)))]
       ; new from here
       [(with) (with (first (second sexp))
                     (parse (second (second sexp)))
                     (parse (third sexp)))])]))

;; calc : WAE -> number
;; evaluates WAE expressions by reducing them to numbers
(define (calc expr)
  (type-case WAE expr
    [num (n) n]
    [add (l r) (+ (calc l) (calc r))]
    [sub (l r) (- (calc l) (calc r))]
    ; new from here
    [with (bound-id named-expr bound-body)
          (calc (subst bound-body
                       bound-id
                       (num (calc named-expr))))]
    [id (v) (error 'calc "free identifier")]))

; subst : WAE symbol number -> WAE
(define (subst expr sub-id val)
  (type-case WAE expr
    [num (n) expr]
    [id (v) (if (symbol=? v sub-id) val expr)]
    [add (l r) (add (subst l sub-id val)
                    (subst r sub-id val))]
    [sub (l r) (sub (subst l sub-id val)
                    (subst r sub-id val))]
    [with (bound-id named-expr bound-body)
          (if (symbol=? bound-id sub-id)
              (with bound-id
                    (subst named-expr sub-id val)
                    bound-body)
              (with bound-id
                    (subst named-expr sub-id val)
                    (subst bound-body sub-id val)))]))

; run-time helper
(define (run x)
  (calc (parse x)))

; examples

(run '{with {x 5} 
            {+ x x}})

(run '{with {x 5} 
            {with {y 6} 
                  {+ x y}}})

(run '{with {x 5} 
            {with {y {+ x 1}} 
                  {- y x}}})

(run '{with {x 5}
            {with {x 6}
                  x}})
