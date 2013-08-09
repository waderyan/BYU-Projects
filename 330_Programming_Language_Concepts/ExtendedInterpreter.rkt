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


;; ===============PARSE TESTS ==========================================

;; ================= app 
; check for invalid ids
(test/exn (parse '(+ (5))) "Illegal syntax")
(test/exn (parse '(with (5))) "Illegal syntax")
; no list of args
(test (parse '(id 5)) (app (id 'id) (list (num 5))))
; basic case
(test (parse '(double 5)) (app (id 'double) (list (num 5))))
(test (parse '(double (5)))(app (id 'double) (list (app (num 5) '()))))
; nested in a with cases
(test (parse '(with ((double (fun (x) (+ x x)))) (double 5)))
      (with (list 
             (binding 'double 
                      (fun '(x) 
                           (binop + (id 'x) (id 'x))))) 
            (app (id 'double) (list (num 5)))))
(test (parse '(with ((add3 (with ((x 3)) (fun (y) (+ x y))))) (add3 (5))))
      (with (list (binding 'add3 
                           (with (list (binding 'x (num 3))) 
        (fun '(y) (binop + (id 'x) (id 'y)))))) 
            (app (id 'add3) (list (app (num 5) '())))))

;;=================== if0
; base cases
(test (parse '(if0 0 x y)) (if0 (num 0) (id 'x) (id 'y)))
(test (parse '(if0 1 x y)) (if0 (num 1) (id 'x) (id 'y)))
; not enough if0 args
(test/exn (parse '(if0 1 x)) "Illegal syntax [if0]")
(test/exn (parse '(if0 + x y)) "Illegal syntax")
(test/exn (parse '(if0))
          "Illegal syntax")
(test/exn (parse '(if0 x y))
          "Illegal syntax")
; too many args
(test/exn (parse '(if0 1 x y z)) "Illegal syntax [if0]")
(test/exn (parse '(if0 a b c d))
          "Illegal syntax")
; complex cases
(test (parse '(if0 (- 2 2) x y)) 
      (if0 (binop - (num 2) (num 2)) (id 'x) (id 'y)))
(test (parse '(if0 x y z)) (if0 (id 'x) (id 'y) (id 'z)))
(test (parse '(if0 (+ 1 -1) then else))
      (if0 (binop + (num 1) (num -1)) (id 'then) (id 'else)))


;; ================ fun ==================
; illegal
(test/exn (parse '(fun)) "Illegal syntax")
(test/exn (parse '(fun (x))) "Illegal syntax")
(test/exn (parse '(fun (+ x y))) "Illegal syntax")
(test/exn (parse '(fun (x) ())) "Illegal syntax")
(test/exn (parse '(fun (+ x y z) x)) "Illegal syntax")
; one arg
(test (parse '(fun (x) x)) (fun (list 'x) (id 'x)))
; two different args
(test (parse '(fun (x y) (* x y))) 
      (fun (list 'x 'y) (binop * (id 'x) (id 'y))))
; three diff args
(test (parse '(fun (x y z) (+ x x))) 
      (fun (list 'x 'y 'z) (binop + (id 'x) (id 'x))))
(test (parse '(fun (x y z) (+ x (+ z y)))) 
      (fun (list 'x 'y 'z) (binop + (id 'x) (binop + (id 'z) (id 'y)))))
; many args
(test (parse '(fun (a b c d e f g) h))
      (fun (list 'a 'b 'c 'd 'e 'f 'g) (id 'h)))
; args with the same name
(test/exn (parse '(fun (x x) 10)) "Illegal syntax [fun]") 
; no arguments
(test (parse '(fun () 10)) (fun '() (num 10))) 
(test (parse '(fun () 4))
      (fun '() (num 4)))

   
; ================== ids and number tests ======
(test/exn (parse '()) "Illegal syntax")
(test (parse 3) (num 3))
(test (parse -2) (num -2))
(test (parse 0) (num 0))
(test (parse 's) (id 's))
(test (parse 'x) (id 'x))
(test (parse 'parse) (id 'parse))
(test (parse 'interp) (id 'interp))
(test (parse 'id) (id 'id))
(test/exn (parse '+) "Illegal syntax")
(test/exn (parse '-) "Illegal syntax")
(test/exn (parse '*) "Illegal syntax")
(test/exn (parse '/) "Illegal syntax")
(test/exn (parse 'if0) "Illegal syntax")
(test/exn (parse 'fun) "Illegal syntax")
(test/exn (parse 'with) "Illegal syntax")
(test/exn (parse empty) "Illegal syntax")


; ================ binop =============
; numbers
(test (parse '5) (num 5))
(test (parse '4550) (num 4550))
(test (parse '-1) (num -1))

; subtraction
(test (parse '(- 1 2)) (binop - (num 1) (num 2)))
(test/exn (parse '(- 1)) "Illegal syntax")
(test/exn (parse '(- 1 2 3)) "Illegal syntax")
(test (parse '(- 1 1)) (binop - (num 1) (num 1)))
(test (parse '(- 8 p)) (binop - (num 8) (id 'p)))
(test (parse '(- s y)) (binop - (id 's) (id 'y)))
(test/exn (parse '(- 2)) "Illegal syntax")
(test/exn (parse '(- d)) "Illegal syntax")
(test/exn (parse '(- 2 s 1)) "Illegal syntax")

; addition
(test (parse '(+ 1 2)) (binop + (num 1) (num 2)))
(test/exn (parse '(+ 1 2 3)) "Illegal syntax")
(test/exn (parse '(+ 1)) "Illegal syntax")
(test (parse '(+ 3 3)) (binop + (num 3) (num 3)))
(test/exn (parse '(+ 3)) "Illegal syntax")
(test/exn (parse '(+ d)) "Illegal syntax")
(test/exn (parse '(+ 7 7 7)) "Illegal syntax")

; multiplication
(test (parse '(* 1 2)) (binop * (num 1) (num 2)))
(test/exn (parse '(* 1)) "Illegal syntax")
(test/exn (parse '(* 1 2 3)) "Illegal syntax")
(test (parse '(* 3 3)) (binop * (num 3) (num 3)))
(test (parse '(* t y)) (binop * (id 't) (id 'y)))
(test/exn (parse '(* 3 s 3)) "Illegal syntax")

; division
(test (parse '(/ 1 2)) (binop / (num 1) (num 2)))
(test/exn (parse '(/ 1)) "Illegal syntax")
(test/exn (parse '(/ 1 0)) "Division by zero")
(test/exn (parse '(/ 1 2 3)) "Illegal syntax")

; binops defined as apps
(test (parse '(^ 1 2)) (app (id '^) (list (num 1) (num 2))))
(test (parse '(^ 1)) (app (id '^) (list (num 1))))
(test (parse '(& 1 2)) (app (id '&) (list (num 1) (num 2))))

; invalid identifiers
(test/exn (parse true) "Illegal syntax")

; ================== with tests ============================
(test/exn (parse '(with [x 1] x)) "Illegal syntax")
(test/exn (parse '(with ([5 5]) x)) "Illegal syntax")
(test (parse '(with ([x 3]) x)) (with (list (binding 'x (num 3))) (id 'x)))
(test (parse '(with ([x (with ([x 1]) x)] [y 2]) (+ x y))) 
      (with (list (binding 'x (with (list (binding 'x (num 1))) (id 'x)))
                  (binding 'y (num 2))) (binop + (id 'x) (id 'y))))
 
(test/exn (parse '(with ([x] [y 2]) (+ x y))) "Illegal syntax")
(test/exn (parse '(with ([x 1] [x 2]) (+ x x)))
      "Illegal syntax")  

(test (parse '(with ([x 1] [y 2]) (+ x y)))
      (with (list (binding 'x (num 1))
                  (binding 'y (num 2)))
            (binop + (id 'x) (id 'y)))) 

(test (parse '(with ([x (with ([x 3]) x)]) x))
      (with (list (binding 'x 
                           (with (list (binding 'x (num 3))) 
                                 (id 'x)))) (id 'x)))

(test (parse '(with ((x 4)) x))
(with (list (binding 'x (num 4))) (id 'x) ))

(test (parse '(with ((x 4) (y 2)) (+ x y)))
(with (list (binding 'x (num 4)) (binding 'y (num 2))) 
      (binop + (id 'x) (id 'y))))

(test (parse '(with ((w z) (y 2)) (+ a x)))
(with (list (binding 'w (id 'z)) (binding 'y (num 2))) 
      (binop + (id 'a) (id 'x))))
(test/exn (parse '(with ((x 4) (y 2)))) "Illegal syntax")
(test/exn (parse '(with (+ x 3))) "Illegal syntax")
(test/exn (parse '(with)) "Illegal syntax")
(test/exn (parse '(with ((x 3) (y 4)) (+ x 3) (+ y 2))) 
          "Illegal syntax")
(test/exn (parse '(with ((x 3) (z 3) (s 4) (x y)) x)) 
          "Illegal syntax [with]")
(test/exn (parse '(with ((x y) (y x) (w z) ()) (+ x y))) 
          "Illegal syntax")


;; ==================== END PARSE TESTS ================================

;; internal representation of an environment
(define-type Env
  [mtEnv]
  [anEnv (name symbol?) (value CFWAE-Value?) (env Env?)])

;; Extends the enviornment
(define (extend-Env lob env)
  (foldl (lambda (bound curEnv)
           (anEnv (binding-name bound) 
                  (interp (binding-named-expr bound) curEnv) curEnv))
         env
         lob))



;; Determines if an expression is zero or not
;; Throws an error if there is any invalid semantic
(define (isZero? value)
  (if (numV? value)
      (local ([define var (numV-n value)])
        (if (number? var)
            (zero? var)
            (error "Illegal Semantic [if0]")))
      (error "Illegal Semantic [if0]")))

;tests 
(test/exn (isZero? (id 'x)) "Illegal Semantic [if0]")
(test (isZero? (numV 5)) #f)
(test (isZero? (numV 0)) #t)

;; interp : CFWAE Env -> CFWAE-Value
;; evaluates an expression with respect to the current environment
(define (interp expr env)
  (type-case CFWAE expr
    [num (n) (numV n)]
    [binop (op l r) 
           (numV 
            (op 
             (numV-n (interp l env)) 
             (numV-n (interp r env))))]
    [id (v) (lookup v env)]
    [with (lob body)
          (interp body (extend-Env lob env))]
    [fun (args body)
         (closureV args body env)]
    [if0 (cond then else)
         (if (isZero? (interp cond env))
             (interp then env)
             (interp else env))]
    [app (fun-expr args)
         (local ([define fun-val (interp fun-expr env)])
           (if (closureV? fun-val)
               (interp 
                (closureV-body fun-val)
                (extendParamEnv 
                 (map (lambda (x) (interp x env)) args)
                 (closureV-param fun-val) 
                 (closureV-env fun-val)))
               (error "Invalid semantic [app]")))]))

;; createEnv listof symbol? listof symbol? env -> env
;; maps arguments to paramaters and creates a new environment
(define (extendParamEnv args params env)
  (if (= (length args) (length params))
      (foldl 
       (lambda (param arg curEnv) 
         (anEnv param arg curEnv)) 
       env 
       params 
       args)
      (error "arguments/parameters mismatch"))
  )

; check length is the same
; make pairs list of params and args
; extend-env (slightly modified) no interp for either first or second

;; run : s-expression -> numV
;; parses then evaluates an s-expression in the CFWAE language
(define (run expr) 
  (interp 
   (parse expr)
   (mtEnv)))

;; test extend-Env
(test (extend-Env (list (binding 'x (num 4))) (anEnv 'y (numV 3) (mtEnv)))
       (anEnv 'x (numV 4) (anEnv 'y (numV 3) (mtEnv))))
(test (extend-Env (list (binding 'x (num 1)) (binding 'y (num 2)))
      (mtEnv))
      (anEnv 'y (numV 2) (anEnv 'x (numV 1) (mtEnv))))
(test (extend-Env (list) (mtEnv)) (mtEnv))
(test (extend-Env (list (binding 'x (num 1))) (mtEnv)) 
      (anEnv 'x (numV 1) (mtEnv)))
(test (extend-Env (list (binding 'x (num 1)) (binding 'y (num 2))) (mtEnv)) 
      (anEnv 'y (numV 2) (anEnv 'x (numV 1) (mtEnv))))


;; ===========INTERP TESTS ==============================================

; =========== app tests ======================
(test (run '(((fun (x) (fun (y) (+ x y))) 2) 4)) (numV 6))
(test (run '((fun () (+ 1 3)))) (numV 4))
(test (run '(with ((double (fun (x) (+ x x)))) (double 5))) (numV 10))
(test (run '{
       {fun {x}
            {fun {y} 
                 {+ x y}}}
       3
       })
 (closureV '(y) (binop + (id 'x) (id 'y)) (anEnv 'x (numV 3) (mtEnv)))
 )
(test (run '{with 
             ({add3 
                    {with ({x 3})
                        {fun {y}
                             {+ x y}}}})
            {add3 5}})
      (numV 8))
(test (run '((fun (x) x) 1))
      (numV 1))
(test (run '((fun (a b) (+ a b)) 4 5))
      (numV 9))
(test (run '(fun (x y) ((fun (x) (+ x y)) x)))
      (closureV '(x y) 
       (app (fun '(x) (binop + (id 'x) (id 'y))) (list (id 'x))) (mtEnv)))
(test (run '(((fun (x) (fun (y) (+ x y))) 2) 4))
      (numV 6))
(test/exn (run '((fun (x y) ((fun (x) (+ x y)))) 1 2))
          "arguments/parameters mismatch")
(test/exn (run '((fun (x) x)))
          "arguments/parameters mismatch")
(test/exn (run '((fun (x) X) 3))
          "lookup: no binding for identifier")
(test/exn (run '(1 1))
          "Invalid semantic [app]")
(test/exn (run '((fun (x) x) 1 2))
          "arguments/parameters mismatch")

; ============ if0 tests ======================
; non numeric evaluation
(test/exn (run '(if0 (double (5)) 1 2)) "lookup: no binding for identifier")
(test/exn (run '(if0 (fun (x) x) 1 2)) "Illegal Semantic [if0]")

; basic case
(test (run '(if0 0 1 2)) (numV 1))
; complex case
(test (run '(if0 (with ([x 3]) x) (+ 1 2) (- 1 2))) (numV -1))
; 0 case
(test (run '(if0 (with ([x 0]) x) 1 2)) (numV 1))
; 1 case
(test (run '(if0 (with ([x 1]) x) 1 2)) (numV 2))

(test (run '(if0 (with ([x 1]) x) 1 2)) (numV 2))
(test (run '(if0 ((fun () 0)) 1 2)) (numV 1))

(test (interp (if0 (num 0) (num 1) (num 2)) (mtEnv)) (numV 1))
(test (interp (if0 (id 'x) (num 1) (num 2)) 
              (anEnv 'x (numV 0) (mtEnv))) (numV 1))
(test (interp (if0 (id 'x) (id 'x) (id 'y)) 
              (anEnv 'x (numV 1) (anEnv 'y (numV 5) (mtEnv)))) (numV 5))

(test (run '(if0 0 1 2)) (numV 1))
(test (run '(if0 (with ([x 3]) x) (+ 1 2) (- 1 2))) (numV -1))
(test (run '(if0 (with ([x 0]) x) 1 2)) (numV 1))


; ============ fun tests =======================
; one arg
(test (run '(fun (x) x)) (closureV '(x) (id 'x) (mtEnv)))
; two args
(test (run '(fun (x y) (+ x y)))
      (closureV '(x y) (binop + (id 'x) (id 'y)) (mtEnv)))
; many args
(test (run '(fun (x y z u i d) (+ x y)))
      (closureV '(x y z u i d) (binop + (id 'x) (id 'y)) (mtEnv)))
; zero args
(test (run '(fun () 0)) (closureV '() (num 0) (mtEnv)))
(test (run '(fun () x))
      (closureV '() (id 'x) (mtEnv)))
(test (run '(fun () (+ x y)))
      (closureV '() (binop + (id 'x) (id 'y)) (mtEnv)))
; nested
(test (run '(fun (x) (fun (y) (+ x y))))
      (closureV '(x) (fun '(y) (binop + (id 'x) (id 'y))) (mtEnv)))
(test (run '(fun () x))
      (closureV '() (id 'x) (mtEnv)))
(test (run '(fun (x) (fun (y) (+ x y))))
      (closureV '(x) (fun '(y) (binop + (id 'x) (id 'y))) (mtEnv)))

; ============== with tests ============================
(test (run '(with ([x 3]) x)) (numV 3))
(test (run '(with ((x 5)) (+ x x)))(numV 10))
(test/exn (run '(with (x 5) x)) "Illegal syntax")
(test (run '(with ((x (with ((x 1)) x)) (y 2)) (+ x y))) (numV 3))

(test (interp (with (list (binding 'x (num 1))) 
                    (with (list (binding 'x (num 2))) 
                          (binop + (id 'x) (id 'x)))) (mtEnv)) (numV 4))
(test (interp (with (list (binding 'x (num 1))) 
                    (with (list (binding 'x (id 'x))) 
                          (binop + (id 'x) (id 'x)))) (mtEnv)) (numV 2))
(test (interp (with (list (binding 'x (num 1)))
                    (with (list (binding 'x (num 2))) 
                          (binop + (id 'x) (id 'x))))
              (anEnv 'x (numV 3) (mtEnv))) (numV 4))

; =============== binop tests =======================
(test (run '(+ 1 2)) (numV 3))
(test/exn (run '(+ 1)) "Illegal syntax")
(test/exn (run '(+ 1 2 3)) "Illegal syntax")
(test/exn (run '(/ 1 0)) "Division by zero")
(test (run '(+ 5 5)) (numV 10))
(test/exn (run '(/ 1 0)) "Division by zero")
(test/exn (run '((fun () (/ 1 0)))) "Division by zero")
(test/exn (run '(if0 (/ 1 0) 1 0)) "Division by zero")


;; ================ END INTERP TESTS =========================

;; RESULTS =======================================

(good (lookup-op '+) #<procedure:+> #<procedure:+> "at line 61")
(good (lookup-op '-) #<procedure:-> #<procedure:-> "at line 62")
(good (lookup-op '^) #f #f "at line 63")
(good (lookup-op '/) #<procedure:/> #<procedure:/> "at line 64")
(good (lookup-op '*) #<procedure:*> #<procedure:*> "at line 65")
(good (lookup-op '%) #f #f "at line 66")
(good (validPairs? '(x 5)) #f #f "at line 85")
(good (validPairs? '((x 5) (y 7))) #t #t "at line 86")
(good (validPairs? '((x 5) (x 4))) #t #t "at line 87")
(good (validPairs? '(with ((x) (y 2)) (+ x y))) #f #f "at line 88")
(good (validBindings? '(x 5)) #f #f "at line 105")
(good (validBindings? '((x 5) (y 7))) #t #t "at line 106")
(good (validBindings? '((x 5) (x 4))) #f #f "at line 107")
(good (validBindings? '(with ((x) (y 2)) (+ x y))) #f #f "at line 108")
(good (dividingByZero? '(/ 0 1)) #f #f "at line 115")
(good (dividingByZero? '(/ 1 0)) #t #t "at line 116")
(good (dividingByZero? '(* 1 0)) #f #f "at line 117")
(good (validFunArgs? '(x y z t)) #t #t "at line 133")
(good (validFunArgs? '(x x)) #f #f "at line 134")
(good (validIfArgs? '(x y z t)) #t #t "at line 139")
(good (validIfArgs? '(x x)) #f #f "at line 140")
(good (validID? '+) #f #f "at line 144")
(good (validID? '-) #f #f "at line 145")
(good (validID? '*) #f #f "at line 146")
(good (validID? '/) #f #f "at line 147")
(good (validID? 'with) #f #f "at line 148")
(good (validID? 'if0) #f #f "at line 149")
(good (validID? 'fun) #f #f "at line 150")
(good (validID? 'hello) #t #t "at line 151")
(good (makeListOfSymbols '(x y z)) '(x y z) '(x y z) "at line 156")
(good (makeListOfCFWAE 
       (rest '(id 1 2 3))) 
      (list (num 1) (num 2) (num 3)) 
      (list (num 1) (num 2) (num 3)) "at line 224")
(good (makeListOfCFWAE 
       (rest '(id 5))) 
      (list (num 5)) (list (num 5)) "at line 225")
(good (parse '(+ (5))) "Illegal syntax" 
      "Illegal syntax" "at line 232")
(good (parse '(with (5))) "Illegal syntax [with]" 
      "Illegal syntax" "at line 233")
(good (parse '(id 5)) (app (id 'id) (list (num 5))) 
      (app (id 'id) (list (num 5))) "at line 235")
(good (parse '(double 5)) (app (id 'double) (list (num 5)))
      (app (id 'double) (list (num 5))) "at line 237")
(good (parse '(double (5))) (app (id 'double) (list (app (num 5) '())))
      (app (id 'double) (list (app (num 5) '()))) "at line 238")
(good (parse '(with ((double (fun (x) (+ x x)))) (double 5))) 
      (with (list (binding 'double (fun '(x) 
                                        (binop + (id 'x) (id 'x)))))
            (app (id 'double) (list (num 5)))) 
      (with (list (binding 'double (fun '(x)
                                        (binop + (id 'x) (id 'x))))) 
            (app (id 'double) (list (num 5)))) "at line 240")
(good (parse '(with ((add3 (with ((x 3)) (fun (y) (+ x y)))))
                    (add3 (5)))) 
      (with (list (binding 'add3 
                           (with (list (binding 'x (num 3))) 
                                       (fun '(y) (binop + (id 'x)
                                                        (id 'y))))))
            (app (id 'add3) (list (app (num 5) '()))))
      (with (list (binding 'add3 (with (list (binding 'x (num 3)))
                                       (fun '(y) (binop + (id 'x) 
                                                        (id 'y))))))
            (app (id 'add3) (list (app (num 5) '())))) "at line 246")
(good (parse '(if0 0 x y)) (if0 (num 0) (id 'x) (id 'y)) 
      (if0 (num 0) (id 'x) (id 'y)) "at line 253")
(good (parse '(if0 1 x y)) (if0 (num 1) (id 'x) (id 'y))
      (if0 (num 1) (id 'x) (id 'y)) "at line 254")
(good (parse '(if0 1 x)) "Illegal syntax [if0]" 
      "Illegal syntax [if0]" "at line 256")
(good (parse '(if0 + x y)) "Illegal syntax" 
      "Illegal syntax" "at line 257")
(good (parse '(if0)) "Illegal syntax [if0]"
      "Illegal syntax" "at line 258")
(good (parse '(if0 x y)) "Illegal syntax [if0]" 
      "Illegal syntax" "at line 260")
(good (parse '(if0 1 x y z)) "Illegal syntax [if0]" 
      "Illegal syntax [if0]" "at line 263")
(good (parse '(if0 a b c d)) "Illegal syntax [if0]"
      "Illegal syntax" "at line 264")
(good (parse '(if0 (- 2 2) x y))
      (if0 (binop #<procedure:-> (num 2) (num 2)) (id 'x) (id 'y))
      (if0 (binop #<procedure:-> (num 2) (num 2)) (id 'x) (id 'y)) 
      "at line 267")
(good (parse '(if0 x y z)) 
      (if0 (id 'x) (id 'y) (id 'z)) 
      (if0 (id 'x) (id 'y) (id 'z)) "at line 269")
(good (parse '(if0 (+ 1 -1) then else))
      (if0 (binop #<procedure:+> (num 1) (num -1)) (id 'then)
           (id 'else)) 
      (if0 (binop #<procedure:+> (num 1) (num -1)) (id 'then) 
           (id 'else))
      "at line 270")
(good (parse '(fun)) "Illegal syntax [fun]"
      "Illegal syntax" "at line 276")
(good (parse '(fun (x))) "Illegal syntax [fun]" 
      "Illegal syntax" "at line 277")
(good (parse '(fun (+ x y))) "Illegal syntax [fun]"
      "Illegal syntax" "at line 278")
(good (parse '(fun (x) ())) "Illegal syntax"
      "Illegal syntax" "at line 279")
(good (parse '(fun (+ x y z) x)) "Illegal syntax [fun]" 
      "Illegal syntax" "at line 280")
(good (parse '(fun (x) x)) (fun '(x) (id 'x)) (fun '(x)
                                                   (id 'x)) 
      "at line 282")
(good (parse '(fun (x y) (* x y)))
      (fun '(x y) (binop #<procedure:*> (id 'x) (id 'y)))
      (fun '(x y) (binop #<procedure:*> (id 'x) (id 'y))) 
      "at line 284")
(good (parse '(fun (x y z) (+ x x))) 
      (fun '(x y z) (binop #<procedure:+> (id 'x) (id 'x)))
      (fun '(x y z) (binop #<procedure:+> (id 'x) (id 'x)))
      "at line 287")
(good (parse '(fun (x y z) (+ x (+ z y))))
      (fun '(x y z) (binop #<procedure:+> (id 'x) 
                           (binop #<procedure:+> (id 'z)
                                  (id 'y))))
      (fun '(x y z) (binop #<procedure:+> (id 'x) 
                           (binop #<procedure:+> (id 'z)
                                  (id 'y))))
      "at line 289")
(good (parse '(fun (a b c d e f g) h)) 
      (fun '(a b c d e f g) (id 'h)) (fun '(a b c d e f g)
                                          (id 'h))
      "at line 292")
(good (parse '(fun (x x) 10)) "Illegal syntax [fun]"
      "Illegal syntax [fun]" "at line 295")
(good (parse '(fun () 10)) (fun '() (num 10)) 
      (fun '() (num 10)) "at line 297")
(good (parse '(fun () 4)) (fun '() (num 4)) 
      (fun '() (num 4)) "at line 298")
(good (parse '()) "Illegal syntax" 
      "Illegal syntax" "at line 303")
(good (parse 3) (num 3) (num 3) "at line 304")
(good (parse -2) (num -2) (num -2) "at line 305")
(good (parse 0) (num 0) (num 0) "at line 306")
(good (parse 's) (id 's) (id 's) "at line 307")
(good (parse 'x) (id 'x) (id 'x) "at line 308")
(good (parse 'parse) (id 'parse) (id 'parse) "at line 309")
(good (parse 'interp) (id 'interp) (id 'interp) "at line 310")
(good (parse 'id) (id 'id) (id 'id) "at line 311")
(good (parse '+) "Illegal syntax" "Illegal syntax"
      "at line 312")
(good (parse '-) "Illegal syntax" "Illegal syntax" 
      "at line 313")
(good (parse '*) "Illegal syntax" "Illegal syntax"
      "at line 314")
(good (parse '/) "Illegal syntax" "Illegal syntax"
      "at line 315")
(good (parse 'if0) "Illegal syntax" "Illegal syntax"
      "at line 316")
(good (parse 'fun) "Illegal syntax" "Illegal syntax"
      "at line 317")
(good (parse 'with) "Illegal syntax" "Illegal syntax"
      "at line 318")
(good (parse empty) "Illegal syntax" "Illegal syntax" 
      "at line 319")
(good (parse '5) (num 5) (num 5) "at line 324")
(good (parse '4550) (num 4550) (num 4550) "at line 325")
(good (parse '-1) (num -1) (num -1) "at line 326")
(good (parse '(- 1 2)) (binop #<procedure:-> (num 1) (num 2))
      (binop #<procedure:-> (num 1) (num 2)) "at line 329")
(good (parse '(- 1)) "Illegal syntax" "Illegal syntax" 
      "at line 330")
(good (parse '(- 1 2 3)) "Illegal syntax" "Illegal syntax" 
      "at line 331")
(good (parse '(- 1 1)) (binop #<procedure:-> (num 1) (num 1))
      (binop #<procedure:-> (num 1) (num 1)) "at line 332")
(good (parse '(- 8 p)) (binop #<procedure:-> (num 8) (id 'p)) 
      (binop #<procedure:-> (num 8) (id 'p)) "at line 333")
(good (parse '(- s y)) (binop #<procedure:-> (id 's) (id 'y)) 
      (binop #<procedure:-> (id 's) (id 'y)) "at line 334")
(good (parse '(- 2)) "Illegal syntax" "Illegal syntax"
      "at line 335")
(good (parse '(- d)) "Illegal syntax" "Illegal syntax" 
      "at line 336")
(good (parse '(- 2 s 1)) "Illegal syntax" "Illegal syntax" 
      "at line 337")
(good (parse '(+ 1 2)) (binop #<procedure:+> (num 1) (num 2))
      (binop #<procedure:+> (num 1) (num 2)) "at line 340")
(good (parse '(+ 1 2 3)) "Illegal syntax" "Illegal syntax"
      "at line 341")
(good (parse '(+ 1)) "Illegal syntax" "Illegal syntax" 
      "at line 342")
(good (parse '(+ 3 3)) (binop #<procedure:+> (num 3) (num 3)) 
      (binop #<procedure:+> (num 3) (num 3)) "at line 343")
(good (parse '(+ 3)) "Illegal syntax" "Illegal syntax"
      "at line 344")
(good (parse '(+ d)) "Illegal syntax" "Illegal syntax"
      "at line 345")
(good (parse '(+ 7 7 7)) "Illegal syntax" "Illegal syntax" 
      "at line 346")
(good (parse '(* 1 2)) (binop #<procedure:*> (num 1) (num 2))
      (binop #<procedure:*> (num 1) (num 2)) "at line 349")
(good (parse '(* 1)) "Illegal syntax" "Illegal syntax" 
      "at line 350")
(good (parse '(* 1 2 3)) "Illegal syntax" "Illegal syntax" 
      "at line 351")
(good (parse '(* 3 3)) (binop #<procedure:*> (num 3) (num 3)) 
      (binop #<procedure:*> (num 3) (num 3)) "at line 352")
(good (parse '(* t y)) (binop #<procedure:*> (id 't) (id 'y)) 
      (binop #<procedure:*> (id 't) (id 'y)) "at line 353")
(good (parse '(* 3 s 3)) "Illegal syntax" "Illegal syntax"
      "at line 354")
(good (parse '(/ 1 2)) (binop #<procedure:/> (num 1) (num 2))
      (binop #<procedure:/> (num 1) (num 2)) "at line 357")
(good (parse '(/ 1)) "Illegal syntax" "Illegal syntax"
      "at line 358")
(good (parse '(/ 1 0)) "Division by zero" "Division by zero"
      "at line 359")
(good (parse '(/ 1 2 3)) "Illegal syntax" "Illegal syntax" 
      "at line 360")
(good (parse '(^ 1 2)) (app (id '^) (list (num 1) (num 2))) 
      (app (id '^) (list (num 1) (num 2))) "at line 363")
(good (parse '(^ 1)) (app (id '^) (list (num 1)))
      (app (id '^) (list (num 1))) "at line 364")
(good (parse '(& 1 2)) (app (id '&) (list (num 1) (num 2))) 
      (app (id '&) (list (num 1) (num 2))) "at line 365")
(good (parse true) "Illegal syntax" "Illegal syntax"
      "at line 368")
(good (parse '(with (x 1) x)) "Illegal syntax [with]"
      "Illegal syntax" "at line 371")
(good (parse '(with ((5 5)) x)) "Illegal syntax"
      "Illegal syntax" "at line 372")
(good (parse '(with ((x 3)) x)) 
      (with (list (binding 'x (num 3)))
                                      (id 'x)) 
      (with (list (binding 'x (num 3))) (id 'x)) 
      "at line 373")
(good (parse '(with ((x (with ((x 1)) x)) (y 2)) (+ x y)))
      (with (list (binding 'x (with (list (binding 'x (num 1)))
                                    (id 'x)))
                  (binding 'y (num 2))) 
            (binop #<procedure:+> (id 'x) (id 'y)))
      (with (list (binding 'x (with (list (binding 'x (num 1)))
                                    (id 'x)))
                  (binding 'y (num 2))) 
            (binop #<procedure:+> (id 'x) (id 'y))) "at line 374")
(good (parse '(with ((x) (y 2)) (+ x y))) "Illegal syntax" 
      "Illegal syntax" "at line 378")
(good (parse '(with ((x 1) (x 2)) (+ x x))) "Illegal syntax [with]"
      "Illegal syntax" "at line 379")
(good (parse '(with ((x 1) (y 2)) (+ x y))) 
      (with (list (binding 'x (num 1))(binding 'y (num 2)))
            (binop #<procedure:+> (id 'x) (id 'y))) 
      (with (list (binding 'x (num 1))(binding 'y (num 2))) 
            (binop #<procedure:+> (id 'x) (id 'y))) "at line 382")
(good (parse '(with ((x (with ((x 3)) x))) x)) 
      (with (list (binding 'x (with (list (binding 'x (num 3)))
                                    (id 'x)))) (id 'x))
      (with (list (binding 'x (with (list (binding 'x (num 3))) 
                                    (id 'x)))) (id 'x)) 
      "at line 387")
(good (parse '(with ((x 4)) x)) 
      (with (list (binding 'x (num 4))) (id 'x))
      (with (list (binding 'x (num 4))) (id 'x)) "at line 392")
(good (parse '(with ((x 4) (y 2)) (+ x y))) 
      (with (list (binding 'x (num 4)) (binding 'y (num 2)))
            (binop #<procedure:+> (id 'x) (id 'y))) 
      (with (list (binding 'x (num 4)) (binding 'y (num 2)))
            (binop #<procedure:+> (id 'x) (id 'y))) "at line 395")
(good (parse '(with ((w z) (y 2)) (+ a x)))
      (with (list (binding 'w (id 'z)) (binding 'y (num 2))) 
            (binop #<procedure:+> (id 'a) (id 'x)))
      (with (list (binding 'w (id 'z)) (binding 'y (num 2)))
            (binop #<procedure:+> (id 'a) (id 'x))) "at line 399")
(good (parse '(with ((x 4) (y 2)))) "Illegal syntax [with]" 
      "Illegal syntax" "at line 402")
(good (parse '(with (+ x 3))) "Illegal syntax [with]"
      "Illegal syntax" "at line 403")
(good (parse '(with)) "Illegal syntax [with]" 
      "Illegal syntax" "at line 404")
(good (parse '(with ((x 3) (y 4)) (+ x 3) (+ y 2)))
      "Illegal syntax [with]" 
      "Illegal syntax" "at line 405")
(good (parse '(with ((x 3) (z 3) (s 4) (x y)) x))
      "Illegal syntax [with]"
      "Illegal syntax [with]" "at line 406")
(good (parse '(with ((x y) (y x) (w z) ()) (+ x y))) 
      "Illegal syntax [with]"
      "Illegal syntax" "at line 407")
(good (isZero? (id 'x)) "Illegal Semantic [if0]"
      "Illegal Semantic [if0]" "at line 438")
(good (isZero? (numV 5)) #f #f "at line 439")
(good (isZero? (numV 0)) #t #t "at line 440")
(good (extend-Env (list (binding 'x (num 4))) 
                  (anEnv 'y (numV 3) (mtEnv)))
      (anEnv 'x (numV 4) (anEnv 'y (numV 3) (mtEnv)))                                     
      (anEnv 'x (numV 4) (anEnv 'y (numV 3) (mtEnv))) 
                                               "at line 497")
(good (extend-Env (list (binding 'x (num 1))
                        (binding 'y (num 2))) (mtEnv))
      (anEnv 'y (numV 2) (anEnv 'x (numV 1) (mtEnv))) 
      (anEnv 'y (numV 2) (anEnv 'x (numV 1) (mtEnv))) 
      "at line 499")
(good (extend-Env (list) (mtEnv)) (mtEnv) (mtEnv) "at line 502")
(good (extend-Env (list (binding 'x (num 1))) (mtEnv))
      (anEnv 'x (numV 1) (mtEnv)) 
      (anEnv 'x (numV 1) (mtEnv)) "at line 503")
(good (extend-Env (list (binding 'x (num 1)) 
                        (binding 'y (num 2))) (mtEnv))
      (anEnv 'y (numV 2) (anEnv 'x (numV 1) (mtEnv)))
      (anEnv 'y (numV 2) (anEnv 'x (numV 1) (mtEnv)))
      "at line 505")
(good (run '(((fun (x) (fun (y) (+ x y))) 2) 4))
      (numV 6) (numV 6) "at line 512")
(good (run '((fun () (+ 1 3)))) (numV 4) (numV 4) "at line 513")
(good (run '(with ((double (fun (x) (+ x x)))) (double 5)))
      (numV 10) (numV 10) "at line 514")
(good (run '((fun (x) (fun (y) (+ x y))) 3))
      (closureV '(y) (binop #<procedure:+> (id 'x) (id 'y)) 
                (anEnv 'x (numV 3) (mtEnv)))
      (closureV '(y) (binop #<procedure:+> (id 'x) (id 'y))
                (anEnv 'x (numV 3) (mtEnv))) 
      "at line 515")
(good (run '(with ((add3 (with ((x 3)) (fun (y) (+ x y))))) 
                  (add3 5))) (numV 8) (numV 8) "at line 523")
(good (run '((fun (x) x) 1)) (numV 1) (numV 1) "at line 530")
(good (run '((fun (a b) (+ a b)) 4 5)) (numV 9) (numV 9) "at line 532")
(good (run '(fun (x y) ((fun (x) (+ x y)) x))) 
      (closureV '(x y) (app (fun '(x)
                                 (binop #<procedure:+> 
                                        (id 'x) 
                                        (id 'y)))
                            (list (id 'x))) (mtEnv)) 
      (closureV '(x y) (app (fun '(x) (binop #<procedure:+>
                                             (id 'x) 
                                             (id 'y)))
                            (list (id 'x))) (mtEnv))
      "at line 534")
(good (run '(((fun (x) (fun (y) (+ x y))) 2) 4)) 
      (numV 6) (numV 6) "at line 537")
(good (run '((fun (x y) ((fun (x) (+ x y)))) 1 2))
      "arguments/parameters mismatch"
      "arguments/parameters mismatch" "at line 539")
(good (run '((fun (x) x))) "arguments/parameters mismatch" 
      "arguments/parameters mismatch" "at line 541")
(good (run '((fun (x) X) 3)) "lookup: no binding for identifier" 
      "lookup: no binding for identifier" "at line 543")
(good (run '(1 1)) "Invalid semantic [app]"
      "Invalid semantic [app]" "at line 545")
(good (run '((fun (x) x) 1 2)) "arguments/parameters mismatch" 
      "arguments/parameters mismatch" "at line 547")
(good (run '(if0 (double (5)) 1 2))
      "lookup: no binding for identifier" 
      "lookup: no binding for identifier" "at line 552")
(good (run '(if0 (fun (x) x) 1 2)) "Illegal Semantic [if0]"
      "Illegal Semantic [if0]" "at line 553")
(good (run '(if0 0 1 2)) (numV 1) (numV 1) "at line 556")
(good (run '(if0 (with ((x 3)) x) (+ 1 2) (- 1 2)))
      (numV -1) (numV -1) "at line 558")
(good (run '(if0 (with ((x 0)) x) 1 2)) (numV 1) (numV 1)
      "at line 560")
(good (run '(if0 (with ((x 1)) x) 1 2)) (numV 2) (numV 2)
      "at line 562")
(good (run '(if0 (with ((x 1)) x) 1 2)) (numV 2) (numV 2) 
      "at line 564")
(good (run '(if0 ((fun () 0)) 1 2)) (numV 1) (numV 1)
      "at line 565")
(good (interp (if0 (num 0) (num 1) (num 2))
              (mtEnv)) (numV 1) (numV 1) "at line 567")
(good (interp (if0 (id 'x) (num 1) (num 2)) 
              (anEnv 'x (numV 0) (mtEnv))) (numV 1) (numV 1)
                                           "at line 568")
(good (interp (if0 (id 'x) (id 'x) (id 'y))
              (anEnv 'x (numV 1) (anEnv 'y (numV 5) (mtEnv)))) 
      (numV 5) (numV 5) "at line 570")
(good (run '(if0 0 1 2)) (numV 1) (numV 1) "at line 573")
(good (run '(if0 (with ((x 3)) x) (+ 1 2) (- 1 2)))
      (numV -1) (numV -1) "at line 574")
(good (run '(if0 (with ((x 0)) x) 1 2))
      (numV 1) (numV 1) "at line 575")
(good (run '(fun (x) x))
      (closureV '(x) (id 'x) (mtEnv))
      (closureV '(x) (id 'x) (mtEnv)) "at line 580")
(good (run '(fun (x y) (+ x y)))
      (closureV '(x y) (binop #<procedure:+> (id 'x) (id 'y))
                (mtEnv))
      (closureV '(x y) (binop #<procedure:+> (id 'x) (id 'y)) 
                (mtEnv))
      "at line 582")
(good (run '(fun (x y z u i d) (+ x y)))
      (closureV '(x y z u i d) (binop #<procedure:+> (id 'x) (id 'y)) 
                (mtEnv)) 
      (closureV '(x y z u i d) (binop #<procedure:+> (id 'x) (id 'y))
                (mtEnv)) 
      "at line 585")
(good (run '(fun () 0)) 
      (closureV '() (num 0) (mtEnv)) (closureV '() (num 0) (mtEnv)) 
      "at line 588")
(good (run '(fun () x))
      (closureV '() (id 'x) (mtEnv)) (closureV '() (id 'x) (mtEnv)) 
      "at line 589")
(good (run '(fun () (+ x y))) 
      (closureV '() (binop #<procedure:+> (id 'x) (id 'y)) 
                (mtEnv))
      (closureV '() (binop #<procedure:+> (id 'x) (id 'y)) 
                (mtEnv)) 
      "at line 591")
(good (run '(fun (x) (fun (y) (+ x y)))) 
      (closureV '(x) (fun '(y) (binop #<procedure:+> (id 'x)
                                      (id 'y))) 
                (mtEnv)) 
      (closureV '(x) (fun '(y) (binop #<procedure:+> (id 'x)
                                      (id 'y))) 
                (mtEnv))
      "at line 594")
(good (run '(fun () x)) (closureV '() (id 'x) (mtEnv)) 
      (closureV '() (id 'x) (mtEnv)) "at line 596")
(good (run '(fun (x) (fun (y) (+ x y))))
      
      (closureV '(x) (fun '(y) (binop #<procedure:+> (id 'x)
                                      (id 'y)))
                (mtEnv))
      (closureV '(x) (fun '(y) (binop #<procedure:+> (id 'x)
                                      (id 'y)))
                (mtEnv))
      "at line 598")
(good (run '(with ((x 3)) x)) (numV 3) (numV 3)
      "at line 602")
(good (run '(with ((x 5)) (+ x x))) (numV 10) (numV 10) 
      "at line 603")
(good (run '(with (x 5) x)) "Illegal syntax [with]" 
      "Illegal syntax" "at line 604")
(good (run '(with ((x (with ((x 1)) x)) (y 2)) (+ x y))) 
      (numV 3) (numV 3) "at line 605")
(good (interp (with (list (binding 'x (num 1)))
                    (with (list (binding 'x (num 2)))
                          (binop + (id 'x) (id 'x))))
              (mtEnv)) (numV 4) (numV 4) "at line 607")
(good (interp (with (list (binding 'x (num 1))) 
                    (with (list (binding 'x (id 'x)))
                          (binop + (id 'x) (id 'x))))
              (mtEnv)) (numV 2) (numV 2) "at line 610")
(good (interp (with (list (binding 'x (num 1)))
                    (with (list (binding 'x (num 2)))
                          (binop + (id 'x) (id 'x))))
              (anEnv 'x (numV 3) (mtEnv))) (numV 4) (numV 4) 
                                           "at line 613")
(good (run '(+ 1 2)) (numV 3) (numV 3) "at line 619")
(good (run '(+ 1)) "Illegal syntax"
      "Illegal syntax" "at line 620")
(good (run '(+ 1 2 3)) "Illegal syntax" 
      "Illegal syntax" "at line 621")
(good (run '(/ 1 0)) "Division by zero"
      "Division by zero" "at line 622")
(good (run '(+ 5 5)) (numV 10) (numV 10) "at line 623")
(good (run '(/ 1 0)) "Division by zero"
      "Division by zero" "at line 624")
(good (run '((fun () (/ 1 0)))) "Division by zero" 
      "Division by zero" "at line 625")
(good (run '(if0 (/ 1 0) 1 0)) "Division by zero" 
      "Division by zero" "at line 626")
