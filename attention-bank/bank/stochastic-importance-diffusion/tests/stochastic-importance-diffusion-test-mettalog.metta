!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention:AttentionParam)

!(import! &self metta-attention:attention-bank:bank/atom-bins/atombins)
!(import! &self metta-attention:attention-bank:bank/atom-bins/get-min-max-content)

!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention-bank:bank/stochastic-importance-diffusion/stochastic-importance-diffusion)

;###################### Prep: adding atoms to the atom bin #####################
!(add-atom &atombin (1 (a b)))

; Set the STI of 'a' to 1, giving it bin index 1
!(setAv a (1.0 1.0 1.0))

!(getSti a)
!(calcElapsedTime (getSti a))

; Update bins multiple times to simulate elapsed updates
!(updateBin a)
!(match &atomBinInfo (1 $a) $a)
!((py-atom time.sleep) 1.0)

!(updateBin a)
!(match &atomBinInfo (1 $b) $b)
!((py-atom time.sleep) 3.0)

!(updateBin a)
!(match &atomBinInfo (1 $c) $c)

!(updateBin a)
!(match &atomBinInfo (1 $d) $d)

!(updateBin a)
!(match &atomBinInfo (1 $e) $e)

!(updateBin a)
!(match &atomBinInfo (1 $f) $f)

!(importanceBin (getSti a))
!(calcElapsedTime (importanceBin (getSti a)))

; Testing diffusedValue
!(assertEqual (> (diffusedValue a 0.5) 0.5) True)
!(assertEqual (diffusedValue a 1) 0) ; after one round the STI decays by 1, output becomes 0

!(elapsedTime a)
