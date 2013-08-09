#lang plai
(print-only-errors #t)

;; abstract syntax
(define-type FWAE
  [num (n number?)]
  [add (lhs FWAE?) (rhs FWAE?)]
  [with (name symbol?) (named-expr FWAE?) (body FWAE?)]
  [id (name symbol?)]
  [fun (param symbol?) (body FWAE?)]
  [app (fun-expr FWAE?) (arg-expr FWAE?)])

;; internal representation of possible return values
(define-type FWAE-Value
  [numV (n number?)]
  [closureV (param symbol?)
            (body FWAE?)
            (env Env?)])

;; internal representation of an environment
(define-type Env
  [mtEnv]
  [anEnv (name symbol?) (value FWAE-Value?) (env Env?)])

;; lookup : symbol Env -> FWAE-Value
;; looks up an identifier in an environment and returns the value
;; bound to it (or reports error if not found)
(define (lookup name env)
  (type-case Env env
    [mtEnv () (error 'lookup "no binding for identifier")]
    [anEnv (bound-name bound-value rest-env)
           (if (symbol=? bound-name name)
               bound-value
               (lookup name rest-env))]))

;; num+ : numV numV −> numV
;; adds two numV number representations
(define (num+ n1 n2)
  (numV (+ (numV-n n1) (numV-n n2))))

;; parse : sexp −> FWAE
;; to convert s-expressions into FWAEs
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(symbol? sexp) (id sexp)]
    [(list? sexp)
     (case (first sexp)
       [(+) (add (parse (second sexp))
                 (parse (third sexp)))]
       [(with) (with (first (second sexp))
                     (parse (second (second sexp)))
                     (parse (third sexp)))]
       [(fun) (fun (first (second sexp))
                   (parse (third sexp)))]
       [else (app (parse (first sexp))
                  (parse (second sexp)))])]))

;; interp : FWAE Env -> FWAE-Value
;; evaluates an expression with respect to the current environment
(define (interp expr env)
  (type-case FWAE expr
    [num (n) (numV n)]
    [add (l r) (num+ (interp l env) (interp r env))]
    [id (v) (lookup v env)]
    [with (bound-id named-expr bound-body)
          (interp bound-body
                  (anEnv bound-id
                         (interp named-expr
                                 env)
                         env))]
    [fun (bound-id bound-body)
         (closureV bound-id bound-body env)]
    [app (fun-expr arg-expr)
         (local ([define fun-val (interp fun-expr env)])
           (interp (closureV-body fun-val)
                   (anEnv (closureV-param fun-val)
                          (interp arg-expr env)
                          (closureV-env fun-val))))]))

;; run : s-expression -> numV
;; parses then evaluates an s-expression in the FWAE language
(define (run expr) 
  (interp 
   (parse expr)
   (mtEnv)))

;; -- some examples --

(run '{with {double {fun {x} {+ x x}}} {double 5}})

(run '{fun {x} x})

(run '{fun {x}
           {fun {y} 
                {+ x y}}})

(run '{
       {fun {x}
            {fun {y} 
                 {+ x y}}}
       3
       })

(run '{with {x 3}
            {fun {y}
                 {+ x y}}})

(run '{with {add3 {with {x 3}
                        {fun {y}
                             {+ x y}}}}
            {add3 5}})


;; Test - 1 param funct
(test (run '{fun {x} x}) (closureV 'x (id 'x) (mtEnv)))
(test (interp (fun 'x (id 'x)) (mtEnv)) (closureV 'x (id 'x) (mtEnv)))

;; Test - named funct
(test (parse '(with (double (fun (x) (+ x x))) (double 5))) (with 'double (fun 'x (add (id 'x) (id 'x))) (app (id 'double) (num 5))))
(test (interp (with 'double (fun 'x (add (id 'x) (id 'x))) (app (id 'double) (num 5))) (mtEnv)) (numV 10))
(test (run '{with {double {fun {x} {+ x x}}} {double 5}}) (numV 10))

;; Test - nested funct
(test (parse '(fun (x) (fun (y) (+ x y)))) (fun 'x (fun 'y (add (id 'x) (id 'y)))))
(test (interp (fun 'x (fun 'y (add (id 'x) (id 'y)))) (mtEnv))
      (closureV 'x (fun 'y (add (id 'x) (id 'y))) (mtEnv)))
(test (run '{fun {x}
           {fun {y} 
                {+ x y}}}) 
      (closureV 'x (fun 'y (add (id 'x) (id 'y))) (mtEnv)))

;; Test - nested function with env
(test (parse '{{fun {x}{fun {y} {+ x y}}} 3})
      (app (fun 'x (fun 'y (add (id 'x) (id 'y)))) (num 3)))
(test (interp (app (fun 'x (fun 'y (add (id 'x) (id 'y)))) (num 3)) (mtEnv))
(closureV 'y (add (id 'x) (id 'y)) (anEnv 'x (numV 3) (mtEnv))))

(test (run '{
       {fun {x}
            {fun {y} 
                 {+ x y}}}
       3
       })
 (closureV 'y (add (id 'x) (id 'y)) (anEnv 'x (numV 3) (mtEnv)))
 )

;; TEST - with binding function body
(test (parse '(with (x 3) (fun (y) (+ x y))))
      (with 'x (num 3) (fun 'y (add (id 'x) (id 'y)))))
(test (interp (with 'x (num 3) (fun 'y (add (id 'x) (id 'y)))) (mtEnv))
      (closureV 'y (add (id 'x) (id 'y)) (anEnv 'x (numV 3) (mtEnv))))
(test (run '{with {x 3}
            {fun {y}
                 {+ x y}}})
      (closureV 'y (add (id 'x) (id 'y)) (anEnv 'x (numV 3) (mtEnv)))
      )


;; TEST - with binding to a function
(test (parse '(with (add3 (with (x 3) (fun (y) (+ x y)))) (add3 5)))
      (with 'add3 (with 'x (num 3) (fun 'y (add (id 'x) (id 'y)))) (app (id 'add3) (num 5))))
(test (interp (with 'add3 (with 'x (num 3) (fun 'y (add (id 'x) (id 'y)))) (app (id 'add3) (num 5))) (mtEnv))
      (numV 8))
(test (run '{with {add3 {with {x 3}
                        {fun {y}
                             {+ x y}}}}
            {add3 5}})
      (numV 8))
