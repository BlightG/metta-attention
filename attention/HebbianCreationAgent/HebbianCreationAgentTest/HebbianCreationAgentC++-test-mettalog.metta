!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention-bank:bank/attention-bank)
!(import! &self metta-attention:attention-bank:bank/attentional-focus/attentional-focus)
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)
!(import! &self metta-attention:attention-bank:utilities/recentVal)
!(import! &self metta-attention:attention:Neighbors)
!(import! &self metta-attention:attention:HebbianCreationAgent/HebbianCreationAgent)

!(updateAttentionParam MAX_AF_SIZE 4)
!(bind! conf90 900)

; Populate AtomSpace with atoms
!(setStv Kermit (0.001 conf90))
!(setStv Frog (0.01 conf90))
!(setStv Animal (0.1 conf90))
!(setStv alive (0.01 conf90))
!(setStv slimy (0.01 conf90))

; Create links
!(setStv (INHERITANCE_LINK Kermit Frog) (0.9 conf90))
!(setStv (INHERITANCE_LINK Frog Animal) (0.9 conf90))
!(setStv (EVALUATION_LINK Frog alive) (0.9 conf90))
!(setStv (EVALUATION_LINK Frog slimy) (0.9 conf90))
!(setStv (EVALUATION_LINK Animal slimy) (0.9 conf90))

; Dummy atoms
!(setStv Dummy1 (0.001 conf90))
!(setStv Dummy2 (0.001 conf90))
!(setStv Dummy3 (0.001 conf90))

; Dummy links
!(setStv (INHERITANCE_LINK Dummy1 Dummy2) (0.9 conf90))
!(setStv (INHERITANCE_LINK Dummy2 Dummy3) (0.9 conf90))

; Stimulate AF
!(stimulate Kermit 200)
!(stimulate Frog 200)
!(stimulate Animal 200)
!(stimulate alive 200)
!(stimulate (EVALUATION_LINK Animal slimy) 100)

; Run Hebbian Creation Agent
!(HebbianCreationAgent-Run (TypeSpace))

; Assert AF contains exactly 4 atoms
!(assertEqual (size-atom (collapse (getAfAtoms))) 4)

; Assert 12 asymmetric Hebbian links were formed
!(assertEqual
    (size-atom
        (collapse
            (match (TypeSpace)
                ((ASYMMETRIC_HEBBIAN_LINK $x $y) $value)
                (ASYMMETRIC_HEBBIAN_LINK $x $y)
            )
        )
    )
    12
)
