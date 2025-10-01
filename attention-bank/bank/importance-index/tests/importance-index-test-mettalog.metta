!(register-module! ../../../../../metta-attention)
!(register-module! ../../../../attention-bank)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self attention-bank:utilities:helper-functions)
!(import! &self attention-bank:utilities:recentVal)
!(import! &self attention-bank:bank:importance-index/importance-index)
!(import! &self attention-bank:attention-value:getter-and-setter)
!(import! &self attention-bank:bank:attentional-focus/attentional-focus)
!(import! &self attention-bank:bank:attention-bank)

;###################### Prep: adding atoms to the atom bin #####################
!(setAv a (2.0 2.0 2.0))
!(setAv d (4.0 2.0 2.0))
!(setAv c (3.0 2.0 2.0))
!(setAv x (200.0 200.0 0.0))
!(setAv (EvaluationLink a b) (20 20 0))
!(setAv another (25 25 0))
!(setAv Animals (30 30 1))
!(setAv (Hebbianlink (Hebbianlink Human Cat) Animal) (40 40 1))
!(setAv something (80 80 1))

;########################### Testing ###########################################

; Test case 01: Testing importanceBin with different number values
!(assertEqual (importanceBin -5.0) 0.0)    ; Should return 0
!(assertEqual (importanceBin 10.0) 10.0)   ; Should return 10 (direct assignment)
!(assertEqual (importanceBin 20.0) 20.0)   ; Should calculate based on group logic
!(assertEqual (importanceBin 50.0) 29.0)   ; Should calculate based on group logic

; Test case 02: Testing getHandleSet, getContent, and filterContents functions
!(assertEqual (getHandleSet 20 40) ((EvaluationLink a b) another Animals (Hebbianlink (Hebbianlink Human Cat) Animal)))
!(assertEqual (filterContents ((EvaluationLink a b) another Animals) 10 25) (() another (EvaluationLink a b)))
!(assertEqual (getHandleSet 11 26) ((EvaluationLink a b) another))
!(assertEqual (getContent 20 30) ((EvaluationLink a b) another Animals (Hebbianlink (Hebbianlink Human Cat) Animal)))

; Test case 03: Testing update function
!(assertEqual (update &atombin) ("Updated"))
!(assertEqual (getMaxSTI) 200)
!(assertEqual (getMinSTI) 2)

; Test case 04: Testing stimulate function
!(assertEqual (stimulate x 1.5) ("Updated"))

; Test case 05: Testing getNormalisedZeroToOneSTI with different average and clip values
!(assertEqual (getNormalisedZeroToOneSTI a True True) 0.0)
!(assertEqual (getNormalisedZeroToOneSTI d True False) 0.008771929824561403)
!(assertEqual (getNormalisedZeroToOneSTI c False False) 0.0043859649122807015)

; Test case 06: Testing getNormalisedSTI (single argument)
!(assertEqual (getNormalisedSTI a) 1.0)
!(assertEqual (getNormalisedSTI x) 115.0)

; Test case 07: Testing getNormalisedSTI with different average and clip values
!(assertEqual (getNormalisedSTI a True True) -1.0)
!(assertEqual (getNormalisedSTI d True False) -1.0263157894736843)
