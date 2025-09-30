!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention:ForgettingAgent/ForgettingAgent)
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention-bank:bank/attention-bank)
!(import! &self metta-attention:attention-bank:bank/attentional-focus/attentional-focus)
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)

!(updateAttentionParam FORGET_THRESHOLD 5)
; STImualte 0.25 translated toLTI5

!(STImulate a 1)
!(STImulate b 0.4)
!(STImulate c 0.2)
!(STImulate d 0.15)
!(STImulate e 0.41)
!(STImulate f 0.62)
!(STImulate g 0.13)
!(STImulate h 0.02)
!(STImulate i 0.43)
!(STImulate j 0.52)
!(STImulate k 0.13)
!(STImulate l 0.02)
!(STImulate A 1)
!(STImulate B 0.4)
!(STImulate C 0.2)
!(STImulate D 0.15)
!(STImulate E 0.41)
!(STImulate F 0.62)
!(STImulate G 0.13)
!(STImulate H 0.02)
!(STImulate I 0.43)
!(STImulate J 0.52)
!(STImulate K 0.13)
!(STImulate L 0.02)
!(STImulate M 0.1)
!(STImulate N 0.1)

!(STImulate O 0.1)
!(STImulate o 2.1)
!(setStv p (0.1 0.2))

; only stv, source > 5, target > 5
!(setStv (ASYMMETRIC_HEBBIAN_LINK a b) (0.5 0.45))

; only stv, source < 5, target < 5
!(setStv (ASYMMETRIC_HEBBIAN_LINK c d) (0.4 0.45))

; stv & av, lit > 5, source > 5, target > 5
!(STImulate (ASYMMETRIC_HEBBIAN_LINK e f) 2)

; stv &av, lit > 5, source < 5, target < 5
!(STImulate (ASYMMETRIC_HEBBIAN_LINK g h) 13)

; stv & av, lit < 5, source > 5, target > 5
!(STImulate (ASYMMETRIC_HEBBIAN_LINK i j) 0.2)

; stv &av, lit < 5, source < 5, target < 5
!(STImulate (ASYMMETRIC_HEBBIAN_LINK k l) 0.1)

; only stv, source > 5, target > 5
!(setStv (SYMMETRIC_HEBBIAN_LINK A B) (0.5 0.45))

; only stv, source < 5, target < 5
!(setStv (SYMMETRIC_HEBBIAN_LINK C D) (0.4 0.45))

; stv & av, lit > 5, source > 5, target > 5
!(STImulate (SYMMETRIC_HEBBIAN_LINK E F) 2)

; stv &av, lit > 5, source < 5, target < 5
!(STImulate (SYMMETRIC_HEBBIAN_LINK G H) 13)

; stv & av, lit < 5, source > 5, target > 5
!(STImulate (SYMMETRIC_HEBBIAN_LINK I J) 0.2)

; stv &av, lit < 5, source < 5, target < 5
!(STImulate (SYMMETRIC_HEBBIAN_LINK K L) 0.1)

; stv &av, lit < 5, source < 5, target < 5, linkLTIabove source & target lti
!(STImulate (SYMMETRIC_HEBBIAN_LINK M N) 0.2)

!(assertEqual (getAttentionParam FUNDS_STI) 99174.80000000002)


!(forgettingAgent-Run (TypeSpace))


!(let*
    (
        ($rmvspace (getAtomsInRemoveSpace))	
        ($typspace (getAtomsInTypeSpace)) 
        ($assertTypespace (assertEqual (intersection-atom $typspace $rmvspace) ()))
    )
    ()
) 

!(assertEqual (getAttentionParam FUNDS_STI) 99468.40000000002)

!(assertEqual (let $a (getAtomsInRemoveSpace) (size-atom $a)) 16)