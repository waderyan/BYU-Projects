#lang plai

(print-only-errors #f)

(define-type Type
  [t-num]
  [t-bool]
  [t-nlist]
  [t-fun (arg Type?) (result Type?)])

(define-type Expr
  [num (n number?)]
  [id (v symbol?)]
  [bool (b boolean?)]
  [bin-num-op (op procedure?) (lhs Expr?) (rhs Expr?)]
  [iszero (e Expr?)]
  [bif (test Expr?) (then Expr?) (else Expr?)]
  [with (bound-id symbol?) (bound-body Expr?) (body Expr?)]
  [fun (arg-id symbol?)
       (arg-type Type?) 
       (result-type Type?)
       (body Expr?)]
  [app (fun-expr Expr?) (arg-expr Expr?)]
  [nempty]
  [ncons (first Expr?) (rest Expr?)]
  [nfirst (e Expr?)]
  [nrest (e Expr?)]
  [isnempty (e Expr?)])

;; (listof (list/c symbol? (number? number? .. -> .. number?))
;; datat structure contains a mappnig from operator symbol to their 
;; definitions
(define op-table
  (list 
   (list '+ +)
   (list '- -)
   (list '* *)))

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
(test (lookup-op '*) *)
(test (lookup-op '%) #f)

; parseType : s-expression -> Type
(define (parseType sexp)
  (cond
    [(list? sexp) 
     (if (= (length sexp) 2)
         (t-fun (parseType (first sexp))
                (parseType (second sexp)))
         (error "ParseType: syntax t-fun"))]
    [(symbol=? 'number sexp) (t-num)]
    [(symbol=? 'boolean sexp) (t-bool)]
    [(symbol=? 'nlist sexp) (t-nlist)]
    [else
     (error "ParseType: syntax parseType")]))
    
;; Purpose: Test for being a valid identifier
;; Contract: (any?) -> boolean?
(define (valid-id? id)
  #t)

; Purpose: Parses the symbol expression according to the 
; abstract syntax tree
; Contract: parse : s-expression -> Expr
(define (parse sexp)
  (cond
    [(empty? sexp) (error "Parse: expected non empty sexpr")]
    [(number? sexp) (num sexp)]
    [(and (symbol? sexp) (symbol=? 'nempty sexp)) (nempty)]
    [(symbol? sexp) 
     (if (or (symbol=? sexp 'true) (symbol=? sexp 'false))
         (if (symbol=? sexp 'true)
             (bool #t)
             (bool #f))
         (if (valid-id? sexp)
             (id sexp)
             (error "Parse: invalid identifier")))]
    [(list? sexp)
     (cond
       [(lookup-op (first sexp))
        (if (= (length sexp) 3)
            (bin-num-op (lookup-op (first sexp))
                        (parse (second sexp))
                        (parse (third sexp)))
            (error "Parse: bin-num-op"))]
       [(and (symbol? (first sexp)) (symbol=? 'iszero (first sexp)))
        (if (= (length sexp) 2)
            (iszero (parse (second sexp)))
            (error "Parse: iszero"))]
       [(and (symbol? (first sexp)) (symbol=? 'bif (first sexp)))
        (if (= (length sexp) 4)
            (bif (parse (second sexp))
                 (parse (third sexp))
                 (parse (fourth sexp)))
            (error "Parse: bif"))]
        [(and (symbol? (first sexp)) (symbol=? 'with (first sexp)))
        (if (= (length sexp) 3)
            (with (first (second sexp))
                  (parse (second (second sexp)))
                  (parse (third sexp)))
            (error "Parse: with"))]
       [(and (symbol? (first sexp)) (symbol=? 'fun (first sexp)))
        (if (= (length sexp) 5) 
            (fun 
             (first (second sexp))
             (parseType (third (second sexp)))
             (parseType (fourth sexp))
             (parse (fifth sexp)))
            (error "Parse: fun"))]
       [(and (symbol? (first sexp)) (symbol=? 'ncons (first sexp)))
        (if (= (length sexp) 3)
            (ncons (parse (second sexp))
                   (parse (third sexp)))
            (error "Parse: ncons"))]
       [(and (symbol? (first sexp)) (symbol=? 'nfirst (first sexp)))
        (if (= (length sexp) 2)
            (nfirst (parse (second sexp)))
            (error "Parse: nfirst"))]
       [(and (symbol? (first sexp)) (symbol=? 'nrest (first sexp)))
        (if (= (length sexp) 2)
            (nrest (parse (second sexp)))
            (error "Parse: nrest"))]
       [(and (symbol? (first sexp)) (symbol=? 'nempty? (first sexp)))
        (if (= (length sexp) 2)
            (isnempty (parse (second sexp)))
            (error "Parse: nempty?"))]
       [else
        (if (= (length sexp) 2)
            (app (parse (first sexp))
                 (parse (second sexp)))
            (error "Parse: app"))]
     )]
     [else
      (if (boolean? sexp)
          (id sexp)
          (error "Parse: expected expr syntax"))]
    ))

;; PARSER TESTS

;; num
(test (parse '1) (num 1))
(test (parse '-1) (num -1))
(test (parse '100) (num 100))
(test (parse '1e11) (num 1e11))

;; true/false
(test (parse 'true) (bool true))
(test (parse 'false) (bool false))
(test (parse 'true) (bool #t))
(test (parse 'false) (bool #f))
;(test (parse '#f) (id '#f))
;(test (parse '#t) (id '#t))

;; binop-num-op
(test (parse '(+ 1 2)) (bin-num-op + (num 1) (num 2)))
(test/exn (parse '(+ 1)) "Parse: bin-num-op")
(test/exn (parse '(+ 1 2 3)) "Parse: bin-num-op")
(test (parse '(+ hi bob)) (bin-num-op + (id 'hi) (id 'bob)))
(test (parse '(- 1 2)) (bin-num-op - (num 1) (num 2)))
(test/exn (parse '(- 1)) "Parse: bin-num-op")
(test/exn (parse '(- 1 2 3)) "Parse: bin-num-op")
(test (parse '(- hi bob)) (bin-num-op - (id 'hi) (id 'bob)))
(test (parse '(* 1 2)) (bin-num-op * (num 1) (num 2)))
(test/exn (parse '(* 1)) "Parse: bin-num-op")
(test/exn (parse '(* 1 2 3)) "Parse: bin-num-op")
(test (parse '(* hi bob)) (bin-num-op * (id 'hi) (id 'bob)))

;; iszero
(test (parse '(iszero 5)) (iszero (num 5)))
(test (parse '(iszero hi)) (iszero (id 'hi)))
(test (parse '(iszero true)) (iszero (bool true)))

;; bif
(test (parse '(bif 1 1 1)) 
      (bif (num 1) (num 1) (num 1)))
(test (parse '(bif a b c))
      (bif (id 'a) (id 'b) (id 'c)))
(test (parse '(bif (bif a b c) b c))
      (bif (bif (id 'a) (id 'b) (id 'c)) (id 'b) (id 'c)))
(test (parse '(bif 1 (with (hello 5) hi) a))
      (bif (num 1) (with 'hello (num 5) (id 'hi)) (id 'a)))
;; id
(test (parse 'hi) (id 'hi))
(test (parse 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)
      (id 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa))

;; with
(test (parse '(with (hello 5) hi)) 
      (with 'hello (num 5) (id 'hi)))

;; fun
(test (parse '(fun (hi : number) : number 5)) 
      (fun 'hi (t-num) (t-num) (num 5)))

;; app
(test (parse '(5 5)) (app (num 5) (num 5)))

;; nempty
(test (parse 'nempty) (nempty))

;; ncons
(test (parse '(ncons 5 5)) (ncons (num 5) (num 5)))

;; nempty?
(test (parse '(nempty? 5)) (isnempty (num 5)))

;; nfirst 
(test (parse '(nfirst 5)) (nfirst (num 5)))

;; nrest
(test (parse '(nrest 5)) (nrest (num 5)))


;;Defines environment
(define-type Env
  [mtEnv]
  [anEnv (name symbol?) (value Type?) (env Env?)])

;;Purpose: Looks up an identifier in an environment and returns the bound
;;  value. Raises error if not found.
;;Contract: (symbol? Env?) -> CFWAE-Value?
(define (lookup name env)
  (type-case Env env
    [mtEnv () (error "type-of: no binding for identifier")]
    [anEnv (bound-name bound-value rest-env)
           (if (symbol=? bound-name name)
               bound-value
               (lookup name rest-env))]))
 

; type-of : Expr -> Type
(define (type-of e [env (mtEnv)])
  (type-case Expr e
    [num (n) (t-num)]
    [id (v) (lookup v env)]
    [bool (b) (t-bool)]
    [bin-num-op (op left right) 
                (if (and 
                     (equal? (type-of left env) (t-num)) 
                     (equal? (type-of right env) (t-num)))
                    (t-num)
                    (error "type-of: binop"))]
    [iszero (e) 
            (if (equal? (type-of e env) (t-num))
                (t-bool)
                (error "type-of: iszero"))]
    [bif (e1 e2 e3)
         (if (equal? (type-of e1 env) (t-bool))
              (local 
                ((define bif-type (type-of e2 env)))
              (if (equal? bif-type (type-of e3 env))
                bif-type
                (error "type-of: bif")))
             (error "type-of: bif"))]
    [with (bound-id bound-body body)
          (type-of body (anEnv bound-id (type-of bound-body env) env))]
    [fun (arg-id arg-type result-type body)
         (if (equal? result-type (type-of body (anEnv arg-id arg-type env)))
             (t-fun arg-type result-type)
             (error "type-of: fun"))]
    [app (fun-expr arg-expr)
       (local [(define t (type-of fun-expr env))]
         (cond
           [(not (t-fun? t))
                 (error "type-of: app - not a function")]
           [(not (equal? (t-fun-arg t) (type-of arg-expr env)))
                 (error "type-of: app - incorrect argument type")]
           [else (t-fun-result t)]))]
    [nempty () (t-nlist)]
    [ncons (e1 e2)
           (if (and
                (equal? (type-of e1 env) (t-num))
                (equal? (type-of e2 env) (t-nlist)))
               (t-nlist)
               (error "type-of: ncons"))]
    [isnempty (e1)
             (if (equal? (type-of e1 env) (t-nlist))
                 (t-bool)
                 (error "type-of: nempty?"))]
    [nfirst (e1)
            (if (equal? (type-of e1 env) (t-nlist))
                (t-num)
                (error "type-of: nfirst"))]
    [nrest (e1)
           (if (equal? (type-of e1 env) (t-nlist))
               (t-nlist)
               (error "type-of: nrest"))]))

(define (run sexp)
  (type-of (parse sexp)))

;; TYPE-OF TESTS
;; num
(test (run '0) (t-num))
(test (run '1) (t-num))
(test (run '100000000) (t-num))
(test (run '-1) (t-num))
(test (run '-100000000) (t-num))
(test (run '1e11) (t-num))

;; bool
(test (run 'true) (t-bool))
(test (run 'false) (t-bool))

;; bin-num-op
;; +
(test (run '(+ 1 2)) (t-num))
(test (run '(+ (nfirst nempty) 2)) (t-num))
(test (run '(+ (nfirst nempty) (nfirst nempty))) (t-num))
(test/exn (run '(+ hi bob)) "type-of")
(test/exn (run '(+ hi 1)) "type-of")
(test/exn (run '(+ 1 hi)) "type-of")
(test/exn (run '(+ 1 true)) "type-of")
(test/exn (run '(+ nempty bob)) "type-of")
(test (run '(+ (- 1 2) (+ 5 4))) (t-num))
(test/exn (run '(+ (- 1 hi) (+ 5 4))) "type-of")
(test/exn (run '(+ (- 1 2) (+ hi 4))) "type-of")

;; 
(test (run '(- 1 2)) (t-num))
(test (run '(- (nfirst nempty) 2)) (t-num))
(test (run '(- (nfirst nempty) (nfirst nempty))) (t-num))
(test/exn (run '(- hi bob)) "type-of")
(test/exn (run '(- hi 1)) "type-of")
(test/exn (run '(- 1 hi)) "type-of")
(test/exn (run '(- 1 true)) "type-of")
(test/exn (run '(- nempty 1)) "type-of")
(test (run '(+ (- 1 2) (+ 5 4))) (t-num))
(test/exn (run '(- (- 1 hi) (+ 5 4))) "type-of")
(test/exn (run '(- (- 1 2) (+ hi 4))) "type-of")

;; *
(test (run '(* 1 2)) (t-num))
(test (run '(* (nfirst nempty) 2)) (t-num))
(test (run '(* (nfirst nempty) (nfirst nempty))) (t-num))
(test/exn (run '(* hi bob)) "type-of")
(test/exn (run '(* hi 1)) "type-of")
(test/exn (run '(* 1 hi)) "type-of")
(test/exn (run '(* 1 true)) "type-of")
(test/exn (run '(* 1 nempty)) "type-of")
(test (run '(* (* 1 2) (+ 5 4))) (t-num))
(test/exn (run '(* (- 1 hi) (+ 5 4))) "type-of")
(test/exn (run '(* (- 1 2) (+ hi 4))) "type-of")

;; iszero
(test (run '(iszero 0)) (t-bool))
(test (run '(iszero 100)) (t-bool))
(test (run '(iszero (+ 2 (- 1 2)))) (t-bool))
(test (run '(iszero (- 0 (+ 1 0)))) (t-bool))
(test/exn (run '(iszero true)) "type-of")
(test/exn (run '(iszero (bif true true true))) "type-of")
(test/exn (run '(iszero hi)) "type-of")
(test/exn (run '(iszero (ncons 1 nempty))) "type-of")

;; bif 
(test/exn (run '(bif 1 2 3)) "type-of")
(test/exn (run '(bif 1 true true)) "type-of")
(test/exn (run '(bif true 1 true)) "type-of")
(test/exn (run '(bif true true 1)) "type-of")
(test (run '(bif false false false)) (t-bool))
(test (run '(bif true true true)) (t-bool))
(test (run '(bif true 1 2)) (t-num))
(test (run '(bif false 1 2)) (t-num))
(test (run '(bif (nempty? nempty) 1 2)) (t-num))
;(test (run '(bif true hi hi)) ??)
(test (run '(bif (nempty? (ncons 1 nempty))
                 (ncons 1 nempty)
                 (ncons 1 nempty)))
           (t-nlist))
(test (run '(bif (nempty? 
                  (ncons (nfirst nempty)
                         (nrest nempty)))
                 (ncons (* 9 (- 0 0)) nempty)
                 (ncons (nfirst nempty) nempty)))
           (t-nlist))
(test (run '(bif (nempty? 
                  (ncons 
                   (nfirst (nrest (ncons 1 nempty)))
                         (nrest nempty)))
                 (ncons (* 9 (- 0 0))
                        (nrest (ncons 1 nempty)))
                 (ncons (nfirst nempty) nempty)))
           (t-nlist))
(test/exn (run '(bif (nempty? 
                  (ncons 
                   (nfirst (nrest (ncons 1 nempty)))
                         (nrest nempty)))
                 (ncons (* 9 (- 0 0))
                        (nrest (ncons 1 nempty)))
                 1))
           "type-of")

;; nempty
(test (run 'nempty) (t-nlist))

;; ncons
(test/exn (run '(ncons 1 2)) "type-of")
(test/exn (run '(ncons bob joe)) "type-of")
(test/exn (run '(ncons nempty 1)) "type-of")
(test/exn (run '(ncons true true)) "type-of")
(test/exn (run '(ncons 1 true)) "type-of")
(test/exn (run '(ncons (+ 1 2) true)) "type-of")
(test/exn (run '(ncons true nempty)) "type-of")
(test (run '(ncons 1 nempty)) (t-nlist))
(test (run '(ncons (+ 1 2) nempty)) (t-nlist))
(test (run '(ncons 1 (nrest nempty))) (t-nlist))
(test (run '(ncons (+ 1 (* 9 0)) (nrest (ncons 1 nempty)))) 
      (t-nlist))


;; nempty?
(test (run '(nempty? nempty)) (t-bool))
(test (run '(nempty? (nrest nempty))) (t-bool))
(test/exn (run '(nempty? 1)) "type-of")
(test/exn (run '(nempty? true)) "type-of")
(test/exn (run '(nempty? (nempty? (nrest nempty)))) "type-of")
(test/exn (run '(nempty? (+ 1 2))) "type-of")
(test/exn (run '(nempty? bob)) "type-of")
(test (run '(nempty? (ncons 1 nempty))) (t-bool))
(test (run '(nempty? (ncons (+ 1 2) nempty))) (t-bool))
(test (run '(nempty? (ncons (+ 1 2) (nrest nempty)))) (t-bool))
(test (run '(nempty? (ncons (+ 1 2) (nrest (ncons 1 nempty))))) (t-bool))
(test (run '(nempty? 
             (ncons (+ 1 2) 
                    (nrest (ncons 1 (nrest nempty)))))) 
      (t-bool))

;; nfirst
(test/exn (run '(nfirst 1)) "type-of")
(test/exn (run '(nfirst true)) "type-of")
(test/exn (run '(nfirst (+ 1 2))) "type-of")
(test/exn (run '(nfirst (nfirst nempty))) "type-of")
(test/exn (run '(nfirst (nfirst 1))) "type-of")
(test (run '(nfirst nempty)) (t-num))
(test (run '(nfirst (nrest nempty))) (t-num))
(test (run '(+ 1 (nfirst (nrest nempty)))) (t-num))
(test/exn (run '(nfirst bob)) "type-of")
(test (run '(nfirst (nrest (ncons (nfirst nempty) nempty)))) (t-num))
(test 
 (run '(nfirst 
        (nrest 
         (ncons 
          (nfirst (ncons (+ 1 (* 0 9)) (nrest nempty))) nempty)))) 
 (t-num))

;; nrest
(test (run '(nrest nempty)) (t-nlist))
(test (run '(nrest (ncons 1 nempty))) (t-nlist))
(test/exn (run '(nrest 1)) "type-of")
(test/exn (run '(nrest bob)) "type-of")
(test/exn (run '(nrest (nfirst nempty))) "type-of")
(test/exn (run '(nrest true)) "type-of")
(test/exn (run '(nrest (nempty? nempty))) "type-of")
(test (run '(nrest (ncons 1 nempty))) (t-nlist))
(test
 (run '(nrest (ncons (+ 1 2)
                     (ncons (* (+ 1 2) 3)
                            (nrest (ncons 1 nempty))))))
 (t-nlist))

;; with
(test (run '(with (a 1) a)) (t-num))
(test/exn (run '(with (a 1) b)) "type-of")
(test (run '(with (a true) a)) (t-bool))
(test (run '(with (a (with (a 1) a)) a)) (t-num))
(test (run '(with (a 1) (with (a true) a))) (t-bool))
(test/exn (run '(with (a (with (b a) a)) 1)) "type-of")

;; fun

;; app

;; MORE...
;; bool
(test (run 'true) (t-bool))
(test (run 'false) (t-bool))
;; NUM
(test (run '1) (t-num))
(test (run '100) (t-num))
;; ID
(test/exn (run 'i) "type-of")

;; bin-num-op
(test (run '(+ 1 1)) (t-num))
(test (run '(* 1 1)) (t-num))
(test (run '(- 1 1)) (t-num))
(test/exn (run '(+ true 1)) "type-of")
(test/exn (run '(- 1 false)) "type-of")
(test/exn (run '(* true false)) "type-of")
(test/exn (run '(+ nempty nempty)) "type-of")

;; iszero
(test (run '(iszero 1)) (t-bool))
(test/exn (run '(iszero nempty)) "type-of")
(test/exn (run '(iszero true)) "type-of")
(test (run '(iszero ((fun (x : number) : number x) 1))) (t-bool))
(test/exn (run '(iszero ((fun (x : number) : boolean x) 1))) "type-of")

;; bif
(test (run '(bif true 1 1)) (t-num))
(test/exn (run '(bif true 1 true)) "type-of")
(test/exn (run '(bif true true 1)) "type-of")
(test/exn (run '(bif 1 1 1)) "type-of")
(test (run '(bif (bif true true false) 1 1)) (t-num))
(test (run '(bif true (bif true 1 1) 1)) (t-num))
(test (run '(bif true 1 (bif true 1 1))) (t-num))
(test (run '(bif true (+ 1 1) (+ 1 1))) (t-num))
(test (run '(bif true true true)) (t-bool))
(test (run '(bif true true true)) (t-bool))

;; nempty & ncons
(test (run '(ncons 1 nempty)) (t-nlist))
(test (run 'nempty) (t-nlist))
(test/exn (run '(ncons 1 1)) "type-of")
(test/exn (run '(ncons nempty 1)) "type-of")
(test/exn (run '(ncons true nempty)) "type-of")
(test/exn (run '(ncons 1 true)) "type-of")
(test (run '(ncons 1 (ncons 1 nempty))) (t-nlist))
(test/exn (run '(ncons (ncons 1 nempty) nempty)) "type-of")
(test (run '(ncons (+ 1 1) nempty)) (t-nlist))
(test (run '(ncons ((fun (x : number) : number x) 1) nempty)) (t-nlist))

;; nempty?
(test (run '(nempty? nempty)) (t-bool))
(test (run '(nempty? (ncons 1 nempty))) (t-bool))

;; nfirst & nrest
(test (run '(nfirst nempty)) (t-num))
(test (run '(nfirst (ncons 1 nempty))) (t-num))
(test/exn (run '(nfirst 1)) "type-of")
(test/exn (run '(nfirst true)) "type-of")
(test/exn (run '(nfirst false)) "type-of")
(test/exn (run '(nfirst (+ 1 1))) "type-of")
(test (run '(nrest nempty)) (t-nlist))
(test (run '(nrest (ncons 1 nempty))) (t-nlist))
(test/exn (run '(nrest 1)) "type-of")
(test/exn (run '(nrest true)) "type-of")
(test/exn (run '(nrest false)) "type-of")
(test/exn (run '(nrest (+ 1 1))) "type-of")

;; fun & app
(test/exn (run '(fun (x : number) : nlist x)) "type-of")
(test (run '(fun (y : nlist) : nlist y)) (t-fun (t-nlist) (t-nlist)))

(test/exn (run '(fun (x : nlist) : number (+ x 1))) "type-of")
(test/exn (run '(+ 1 ((fun (x : number) : boolean 1) 1))) "type-of")
(test/exn (run '((fun (x : nlist) : nlist nempty) 1)) "type-of")
(test/exn (run '((fun (x : boolean) : nlist nempty) 1)) "type-of")
(test (run '((fun (x : boolean) : nlist nempty) true)) (t-nlist))

;; with
(test (run '(with (x true) (bif x false x))) (t-bool))
(test (run '(with (x 1) (+ 1 x))) (t-num))
(test (run '(with (x (fun (y : number) : number (* y y))) (x 2))) (t-num))
(test (run '(with (x 1) (with (y 2) (+ x y)))) (t-num))
(test/exn (run '(with (x 1) (with (y true) (+ x y)))) "type-of")
(test/exn (run '(with (x true) (with (y 1) (+ x y)))) "type-of")
(test/exn (run '(with (x true) (with (y 1) (bif x y x)))) "type-of")
(test (run '(with (x true) (with (y 1) (bif x y (+ y 1))))) (t-num))