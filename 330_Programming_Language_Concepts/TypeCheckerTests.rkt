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
(test/exn (run '(+ hi bob)) "type-of: binop")
(test/exn (run '(+ hi 1)) "type-of: binop")
(test/exn (run '(+ 1 hi)) "type-of: binop")
(test/exn (run '(+ 1 true)) "type-of: binop")
(test/exn (run '(+ nempty bob)) "type-of: binop")
(test (run '(+ (- 1 2) (+ 5 4))) (t-num))
(test/exn (run '(+ (- 1 hi) (+ 5 4))) "type-of: binop")
(test/exn (run '(+ (- 1 2) (+ hi 4))) "type-of: binop")

;; -
(test (run '(- 1 2)) (t-num))
(test (run '(- (nfirst nempty) 2)) (t-num))
(test (run '(- (nfirst nempty) (nfirst nempty))) (t-num))
(test/exn (run '(- hi bob)) "type-of: binop")
(test/exn (run '(- hi 1)) "type-of: binop")
(test/exn (run '(- 1 hi)) "type-of: binop")
(test/exn (run '(- 1 true)) "type-of: binop")
(test/exn (run '(- nempty 1)) "type-of: binop")
(test (run '(+ (- 1 2) (+ 5 4))) (t-num))
(test/exn (run '(- (- 1 hi) (+ 5 4))) "type-of: binop")
(test/exn (run '(- (- 1 2) (+ hi 4))) "type-of: binop")

;; *
(test (run '(* 1 2)) (t-num))
(test (run '(* (nfirst nempty) 2)) (t-num))
(test (run '(* (nfirst nempty) (nfirst nempty))) (t-num))
(test/exn (run '(* hi bob)) "type-of: binop")
(test/exn (run '(* hi 1)) "type-of: binop")
(test/exn (run '(* 1 hi)) "type-of: binop")
(test/exn (run '(* 1 true)) "type-of: binop")
(test/exn (run '(* 1 nempty)) "type-of: binop")
(test (run '(* (* 1 2) (+ 5 4))) (t-num))
(test/exn (run '(* (- 1 hi) (+ 5 4))) "type-of: binop")
(test/exn (run '(* (- 1 2) (+ hi 4))) "type-of: binop")

;; iszero
(test (run '(iszero 0)) (t-bool))
(test (run '(iszero 100)) (t-bool))
(test (run '(iszero (+ 2 (- 1 2)))) (t-bool))
(test (run '(iszero (- 0 (+ 1 0)))) (t-bool))
(test/exn (run '(iszero true)) "type-of: iszero")
(test/exn (run '(iszero (bif true true true))) "type-of: iszero")
(test/exn (run '(iszero hi)) "type-of: iszero")
(test/exn (run '(iszero (ncons 1 nempty))) "type-of: iszero")

;; bif 
(test/exn (run '(bif 1 2 3)) "type-of: bif")
(test/exn (run '(bif 1 true true)) "type-of: bif")
(test/exn (run '(bif true 1 true)) "type-of: bif")
(test/exn (run '(bif true true 1)) "type-of: bif")
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
           "type-of: bif")

;; nempty
(test (run 'nempty) (t-nlist))

;; ncons
(test/exn (run '(ncons 1 2)) "type-of: ncons")
(test/exn (run '(ncons bob joe)) "type-of: ncons")
(test/exn (run '(ncons nempty 1)) "type-of: ncons")
(test/exn (run '(ncons true true)) "type-of: ncons")
(test/exn (run '(ncons 1 true)) "type-of: ncons")
(test/exn (run '(ncons (+ 1 2) true)) "type-of: ncons")
(test/exn (run '(ncons true nempty)) "type-of: ncons")
(test (run '(ncons 1 nempty)) (t-nlist))
(test (run '(ncons (+ 1 2) nempty)) (t-nlist))
(test (run '(ncons 1 (nrest nempty))) (t-nlist))
(test (run '(ncons (+ 1 (* 9 0)) (nrest (ncons 1 nempty)))) 
      (t-nlist))


;; nempty?
(test (run '(nempty? nempty)) (t-bool))
(test (run '(nempty? (nrest nempty))) (t-bool))
(test/exn (run '(nempty? 1)) "type-of: nempty?")
(test/exn (run '(nempty? true)) "type-of: nempty?")
(test/exn (run '(nempty? (nempty? (nrest nempty)))) "type-of: nempty?")
(test/exn (run '(nempty? (+ 1 2))) "type-of: nempty?")
(test/exn (run '(nempty? bob)) "type-of: nempty?")
(test (run '(nempty? (ncons 1 nempty))) (t-bool))
(test (run '(nempty? (ncons (+ 1 2) nempty))) (t-bool))
(test (run '(nempty? (ncons (+ 1 2) (nrest nempty)))) (t-bool))
(test (run '(nempty? (ncons (+ 1 2) (nrest (ncons 1 nempty))))) (t-bool))
(test (run '(nempty? 
             (ncons (+ 1 2) 
                    (nrest (ncons 1 (nrest nempty)))))) 
      (t-bool))

;; nfirst
(test/exn (run '(nfirst 1)) "type-of: nfirst")
(test/exn (run '(nfirst true)) "type-of: nfirst")
(test/exn (run '(nfirst (+ 1 2))) "type-of: nfirst")
(test/exn (run '(nfirst (nfirst nempty))) "type-of: nfirst")
(test/exn (run '(nfirst (nfirst 1))) "type-of: nfirst")
(test (run '(nfirst nempty)) (t-num))
(test (run '(nfirst (nrest nempty))) (t-num))
(test (run '(+ 1 (nfirst (nrest nempty)))) (t-num))
(test/exn (run '(nfirst bob)) "type-of: nfirst")
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
(test/exn (run '(nrest 1)) "type-of: nrest")
(test/exn (run '(nrest bob)) "type-of: nrest")
(test/exn (run '(nrest (nfirst nempty))) "type-of: nrest")
(test/exn (run '(nrest true)) "type-of: nrest")
(test/exn (run '(nrest (nempty? nempty))) "type-of: nrest")
(test (run '(nrest (ncons 1 nempty))) (t-nlist))
(test
 (run '(nrest (ncons (+ 1 2)
                     (ncons (* (+ 1 2) 3)
                            (nrest (ncons 1 nempty))))))
 (t-nlist))


;; id

;; with

;; fun

;; app


