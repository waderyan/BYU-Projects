	
#lang plai

; Wade Anderson
;; 3.8.2 CFWAE
;; use eager application semantics
;; use deferred substitution
; CFWAE	 	=	 	number
; 	 	|	 	(+ CFWAE CFWAE)
; 	 	|	 	(- CFWAE CFWAE)
; 	 	|	 	(* CFWAE CFWAE)
; 	 	|	 	(/ CFWAE CFWAE)
; 	 	|	 	id
; 	 	|	 	(if0 CFWAE CFWAE CFWAE)
; 	 	|	 	(with ([id CFWAE] ...) CFWAE)
; 	 	|	 	(fun (id ...) CFWAE)
; 	 	|	 	(CFWAE CFWAE ...)
; number == racket.number
;; id != +,-,*,/,with,if0,fun
;; abstract syntax
(define-type CFWAE
  [num (n number?)]
  [binop (op procedure?) (lhs CFWAE?) (rhs CFWAE?)]
  [with (lob (listof Binding?)) (body CFWAE?)]
  [id (name symbol?)]
  [if0 (c CFWAE?) (t CFWAE?) (e CFWAE?)]
  [fun (args (listof symbol?)) (body CFWAE?)]
  [app (fun-expr CFWAE?) (args (listof CFWAE?))]) 

;; internal representation of with binding

(define-type Binding
  [binding (name symbol?) (named-expr CFWAE?)])
;; internal representation of possible return values
(define-type CFWAE-Value
  [numV (n number?)]
  [closureV (param (listof symbol?)) 
            (body CFWAE?)
            (env Env?)])

;; (listof (list/c symbol? (number? number? .. -> .. number?))
;; datat structure contains a mappnig from operator symbol to their 
;; definitions
(define op-table
  (list 
   (list '+ +)
   (list '- -)
   (list '* *)
   (list '/ /)))

;; lookup-op op -> or/c prodedure? false/c
;; op : symbol?
;; extracts definiton of an operator or false if not in op-table
(define (lookup-op op)
   (if (pair? (assoc op op-table))
    (second (assoc op op-table)) #f))
;; TESTS
(test (lookup-op '+) +)
(test (lookup-op '-) -)
(test (lookup-op '^) #f)
(test (lookup-op '/) /)
(test (lookup-op '*) *)
(test (lookup-op '%) #f)
;; lookup : symbol Env -> CFWAE-Value
;; looks up an identifier in an environment and returns the value
;; bound to it (or reports error if not found)
(define (lookup name env)
  (type-case Env env
    [mtEnv () (error 'lookup "no binding for identifier")]
    [anEnv (bound-name bound-value rest-env)
           (if (symbol=? bound-name name)
               bound-value
               (lookup name rest-env))]))
;; Tests to see if there are a list of pairs
(define (validPairs? sexp)
  (andmap pair? sexp))
;; tests
(test (validPairs? '(x 5)) #f)
(test (validPairs? '((x 5) (y 7))) #t)
(test (validPairs? '((x 5) (x 4))) #t)
(test(validPairs? '(with ((x) (y 2)) (+ x y))) #f)

;; validBindings
;; lob : listOf? bindings
;; determines if a list of bindings is valid -- meaning that there 
;; are not multiple bindings with the same name
(define (validBindings? sexp)
  (if (validPairs? sexp)
      (if (= (length sexp) 
             (length (remove-duplicates 
                      (map (lambda (id) (car id)) sexp))))
          #t
          #f
          )
      #f))

;; tests 
(test (validBindings? '(x 5)) #f)
(test (validBindings? '((x 5) (y 7))) #t)
(test (validBindings? '((x 5) (x 4))) #f)
(test (validBindings? '(with ((x) (y 2)) (+ x y))) #f)

;; tests to see if we are dividing by zero
(define (dividingByZero? sexp)
 (and (symbol=? (first sexp) '/) (= (third sexp) 0)))

;; tests
(test (dividingByZero? '(/ 0 1)) #f)
(test (dividingByZero? '(/ 1 0)) #t)
(test (dividingByZero? '(* 1 0)) #f)
(define nonID (list '+ '- '* '/ 'with 'if0 'fun '()))
(define (validID? sexp)
  (not (member sexp nonID)))
(define (validFunArgs? sexp)
  (and (andmap symbol? sexp) 
       (if (= (length sexp) 
             (length (remove-duplicates sexp)))
          #t
          #f
          )
       (andmap validID? sexp)))

(test (validFunArgs? '(x y z t)) #t)
(test (validFunArgs? '(x x)) #f)

(define (validIfArgs? sexp)
  (= (length sexp) 4))
(test (validIfArgs? '(x y z t)) #t)
(test (validIfArgs? '(x x)) #f)
(test (validID? '+) #f)
(test (validID? '-) #f)
(test (validID? '*) #f)
(test (validID? '/) #f)
(test (validID? 'with) #f)
(test (validID? 'if0) #f)
(test (validID? 'fun) #f)
(test (validID? 'hello) #t)

(define (makeListOfSymbols sexp)
  sexp)

(test (makeListOfSymbols '(x y z)) (list 'x 'y 'z))

;; parse : sexp −> CFWAE
;; to convert s-expressions into CFWAEs
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(symbol? sexp)
     (if (validID? sexp)
         (id sexp)
         (error "Illegal syntax"))]
    [(empty? sexp) (error "Illegal syntax")]
    [(list? sexp)
     (cond
       [(lookup-op (first sexp)) 
        (if (= (length sexp) 3)
           (if (dividingByZero? sexp)
                    (error "Division by zero")
                    (binop (lookup-op (first sexp))
                           (parse (second sexp))
                           (parse (third sexp))))
         (error "Illegal syntax"))] 
       [(and (symbol? (first sexp)) (symbol=? 'with (first sexp)))
        (if (= (length sexp) 3)
            (if (validBindings? (second sexp))
                (with
                 (map (lambda (x) 
                        (binding (if 
                                  (symbol? (first x))
                                               (first x)
                                               (error "Illegal syntax"))
                                           (if (= (length x) 2)
                                               (parse (second x))
                                               (error "Illegal syntax"))))
                      (second sexp))
                 (parse (third sexp)))
            (error "Illegal syntax [with]"))
            (error "Illegal syntax [with]"))]       
       [(and (symbol? (first sexp))(symbol=? 'fun (first sexp)))
        (if (= (length sexp) 3)
            (if (validFunArgs? (second sexp))
                (fun 
                 (makeListOfSymbols (second sexp))
                 (parse (third sexp)))
                (error "Illegal syntax [fun]"))
            (error "Illegal syntax [fun]"))]
       [(and (symbol? (first sexp))(symbol=? 'if0 (first sexp)))
            (if (validIfArgs? sexp)
                (if0 (parse (second sexp))
                     (parse (third sexp))
                     (parse (fourth sexp)))
                (error "Illegal syntax [if0]"))
        ]
       [else
        (if (validID? (first sexp))
            (app (parse (first sexp))
                 (if (> (length sexp) 1)
                 (makeListOfCFWAE (rest sexp))
                 null))
            (error "Illegal syntax [app]"))] 
       )]
     [else (error "Illegal syntax")]
     )
  )

;; mekes a list of CFWAE expressions
;; listOf symbols -> listOf CFWAE
(define (makeListOfCFWAE args)
  (map parse args))

(test (makeListOfCFWAE (rest '(id 1 2 3))) (list (num 1) (num 2) (num 3)))
(test (makeListOfCFWAE (rest '(id 5))) (list (num 5)))
