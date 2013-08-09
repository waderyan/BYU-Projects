#lang web-server/insta

(define (start initial-request)
  (local [(define a1 (getAnswer q1 opt1))
          (define a2 (if (string=? a1 (string-append q1 " Arcade Stick"))
                         (getAnswer q2 opt2)
                         ""))
          (define a3 (getAnswer q3 opt3))
          (define a4 (if (string=? a3 (string-append q3 " Horizontal"))
                         (getAnswer q4 opt4)
                         ""))
          (define a5 (if (string=? a3 (string-append q3 " Vertical"))
                         (getAnswer q5 opt5)
                         ""))
          (define a6 (if (and (string=? a3 (string-append q3 " Vertical"))
                              (string=? a5 (string-append q5 " Cave")))
                         (getAnswer q6 opt6)
                         ""))
          (define a7 (if (and (string=? a3 (string-append q3 " Vertical"))
                              (string=? a5 (string-append q5 " Treasure")))
                         (getAnswer q7 opt7)
                         ""))]
          (send/back (response/xexpr 
                      `(html (head (title "Results"))
                             (body
                             (h2 "Survey Results")
                             (ul
                             ,@(map render-result (list a1 a2 a3 a4 a5 a6 a7)))))))))

(define (render-result option)
  (if (string=? "" option)
      ""
      `(div ((class "result"))
            (li ,option)
            (br))))
      
(define (getAnswer prompt options)
  (local [(define req 
            (send/suspend 
             (lambda (k-url)
               (response/xexpr 
                `(html (head (title "Questions..."))
                       (body
                        (form ([action ,k-url])
                              ,prompt
                              (br)
                              (div
                              ,@(map render-option options))
                              (input ([type "submit"])))))))))
          (define bindings (request-bindings req))
          (define ans (if (string=? (extract-binding/single 'answer bindings) "Other")
                          (extract-binding/single 'customval bindings)
                          (extract-binding/single 'answer bindings)))]
    (string-append prompt " " ans)
    ))

(define (render-option option)
  (if (string=? option "Other")
      `(input ([type "radio"] 
              [name "answer"] 
              [value ,option])
              ,option
              (input ([type "text"] [name "customval"])))
      `(input ([type "radio"] [name "answer"] [value ,option]) ,option)))
      
  
 
(define q1 "What is the best controller for shooters?")
(define opt1 (list "Arcade Stick" "Gamepad" "Keyboard"))
(define q2 "What is the best gate?")
(define opt2 (list "Circle" "Octogonal" "Square"))
(define q3 "Do you prefer horizontal or vertical scrolling?")
(define opt3 (list "Horizontal" "Vertical"))
(define q4 "What is the best horizontal shooter?")
(define opt4 (list "Gradius V" "Sexy Parodius" "Border Down" "Deathsmiles" "Other"))
(define q5 "What is the better developer?")
(define opt5 (list "Cave" "Treasure"))
(define q6 "What is the Cave's best release?")
(define opt6 (list "Dodonpachi" "Ketsui kizuna" "jigoku tachi" "Mushihimesama Futari 1.5" "Other"))
(define q7 "What is the Treasure's best release?")
(define opt7 (list "Radiant Silvergun" "Sin and Punishment" "Ikaruga" "Sin and Punishment: Star Successor" "Other"))
