!(register-module! ../../../attention-bank)
!(import! &self attention-bank:utilities:helper-functions)
!(import! &self attention-bank:bank:importance-index/importance-index)

; ---------------------------
; filter tests
; ---------------------------
!(assertEqual 
    (filter ((c)(a)(f h j k)(s c)(g j)(d)()) notEmpty) 
    ((d) (g j) (s c) (f h j k) (a) (c))
)

!(assertEqual (filter (()()) notEmpty) ())

; ---------------------------
; removeDuplicates tests
; ---------------------------
!(assertEqual (removeDuplicates (a a d c)) (c d a))
!(assertEqual (removeDuplicates (a a)) (a))

; ---------------------------
; flatten tests
; ---------------------------
!(flatten ((s c) (G E) (a) (g) (f h j k) (d)))

; ---------------------------
; reverseExpr tests
; ---------------------------
!(assertEqual (reverseExpr (a b c d)) (d c b a))
!(assertEqual (reverseExpr ()) ())

; ---------------------------
; findGroup tests
; ---------------------------
!(assertEqual (findGroup 0 0 0) 0)
!(assertEqual (findGroup 1 0 0) 1)
!(assertEqual (findGroup 2 0 0) 2)
!(assertEqual (findGroup 3 0 0) 2)
!(assertEqual (findGroup 4 0 0) 3)
!(assertEqual (findGroup 50 0 0) 6)
!(assertEqual (findGroup 500 0 0) 9)
!(assertEqual (findGroup 5000 0 0) 12)
