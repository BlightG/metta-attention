!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)

; Test attentional focus
!(add-atom &atombin (1 (a)))
!(add-atom &atombin (2 (d)))
!(add-atom &atombin (17 (s c)))
!(add-atom &atombin (18 (g)))
!(add-atom &atombin (37 (f h j k)))
!(getAfMaxSTI)
!(setAv a (0.0 0.0 0.0))
!(setAv d (7.0 4.0 0.0))
!(setAv c (0.0 0.0 0.0))
!(setAv A (100.0 200.0 300.0))
!(setAv B (50.0 150.0 250.0))
!(setAv C (200.0 300.0 400.0))
!(setAv D (25.0 125.0 225.0))
!(setAv F (70.0 100.0 200.0))
!(addAtomToAF a)
!(addAtomToAF A)
!(addAtomToAF B)
!(addAtomToAF C)
!(addAtomToAF D)
!(addAtomToAF F)
!(assertEqual(attentionalFocusSize) 6)
!(assertEqual(atomIsInAF C) True)
!(assertEqual (sortAtomsBySti  (getAtomList)) (a D B F A C))
!(assertEqual (getLowestStiAtomInAF) a)
!(setAv G (300.0 400.0 500.0))
!(updateAttentionalFocus G) 
!(assertEqual (getAtomList) (a A B C D F G))
!(setAv H (15.0 25.0 35.0))
!(updateAttentionalFocus H) 
!(assertEqual (getAtomList) (a A B C D F G H))

!(setAv I (500.0 600.0 700.0))
!(updateAttentionalFocus I) 
!(setAv A (600.0 200.0 300.0))
!(updateAttentionalFocus A)

!(assertEqual (updateAttentionalFocus L) ("Atom is not valid"))
!(assertEqual (getAtomList) (a A B C D F G H I))
!(assertEqual (sortAtomsBySti  (getAtomList)) (a H D B F C G I A))
!(let $res (collapse (getRandomAtomNotInAF)) (assertEqual (size $res) 1))

!(assertEqual(getAfMaxSTI) 600.0)
!(assertEqual(sortAtomsByStiDescending  (getAtomList)) (A I G C F B D H a))
;This should be removed temporary Population for test
 (habbianlink abebe kebede) 
!(add-atom &attentionalFocus (habbianlink challa abebe))
!(add-atom &attentionalFocus (PlusLink abebe kebede))

! (assertEqual (getIncomingSet abebe habbianlink) ((habbianlink challa abebe)))
! (assertEqual (nodeMatch (ConceptNode abebe) (ConceptNode abebe)) False) ;False snce (ConceptNode abebe) is not in the attentional focus


