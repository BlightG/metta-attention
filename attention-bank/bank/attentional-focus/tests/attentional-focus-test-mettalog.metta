!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention-bank:bank/attention-bank)
!(import! &self metta-attention:attention-bank:attention-value/get-min-max)
!(import! &self metta-attention:attention-bank:bank/attentional-focus/attentional-focus)
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)
!(import! &self metta-attention:attention-bank:utilities/recentVal)

; ##################### Prep: inserting Atoms in attentional focus ####################
; Test attentional focus
!(setAv a (1.0 0.0 0.0))
!(setAv d (7.0 4.0 0.0))
!(setAv c (0.0 0.0 0.0))
!(setAv A (100.0 200.0 300.0))
!(setAv B (50.0 150.0 250.0))
!(setAv C (200.0 300.0 400.0))
!(setAv D (25.0 125.0 225.0))
!(setAv F (70.0 100.0 200.0))
!(getAttentionParam MAX_AF_SIZE)
; The test cases included AVs for links as well
!(setAv (EvaluationLink a b) (100.0 100.0 100.0))
!(setAv (Hebbianlink (Hebbianlink Cat Human) Animal) (200.0 250.0 280.0))
!(updateAttentionParam MAX_AF_SIZE 8)

; ################### Testing #################################

; Test case 01: incoming-set search restricted to AF atoms
!(assertEqual (getIncomingSetByType Animal Hebbianlink) ((Hebbianlink (Hebbianlink Cat Human) Animal)))

; Test case 02: isAtomInAf returns True for an atom that is in AF
!(assertEqual (isAtomInAf C) True)

; Test case 02b: links also considered in AF via getAfAtoms
!(assertEqual (isAtomInAf (EvaluationLink a b)) True)
!(assertEqual (isAtomInAf (Hebbianlink (Hebbianlink Cat Human) Animal)) True)

; Test case 03: isAtomInAf returns False for an atom not in AF
!(assertEqual (isAtomInAf Z) False)

; Test case 04: adding a high-importance atom makes it appear in AF
!(setAv G (300.0 400.0 500.0))
!(assertEqual (isAtomInAf G) True)

; Verify that the AF set contains the expected atoms (order not guaranteed; subtract to check membership)
!(let $x 
    (getAfAtoms)
    (assertEqual 
        (subtraction 
            (superpose $x) 
            (superpose (D B F (EvaluationLink a b) A (Hebbianlink (Hebbianlink Cat Human) Animal) C G))
        ) 
        (empty)
    )
)

; Test case 06: change G to a low STI and ensure AF membership reflects update
!(setAv G (15.0 25.0 35.0))

!(let $x 
    (getAfAtoms) 
    (assertEqual 
        (subtraction 
            (superpose $x) 
            (superpose (G D B F (EvaluationLink a b) A (Hebbianlink (Hebbianlink Cat Human) Animal) C))
        ) 
        (empty)
    )
)

; Test case 07: getRandomAtomNotInAF should return an atom that is not in AF
!(let $a (collapse (getRandomAtomNotInAF)) (assertEqual (isAtomInAf $a) False))

; Test case 08: get maximum STI among AF atoms
!(let $x (getAfAtoms) (assertEqual (getAllMaxSTI $x) 200))
