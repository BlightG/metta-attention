!(register-module! ../../../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities:helper-functions)
!(import! &self metta-attention:attention:agents:mettaAgents:AttentionParam)
!(import! &self metta-attention:attention-bank:bank:atom-bins:atombins)
!(import! &self metta-attention:attention-bank:bank:atom-bins:get-min-max-content)
!(import! &self metta-attention:attention-bank:bank:importance-index:importance-index)
!(import! &self metta-attention:attention-bank:bank:attention-bank)
!(import! &self metta-attention:attention-bank:attention-value:getter-and-setter)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:RentCollectionBaseAgent:RentCollectionBaseAgent)
!(import! &self metta-attention:attention-bank:bank:stochastic-importance-diffusion:stochastic-importance-diffusion)
!(import! &self metta-attention:attention-bank:bank:attentional-focus:attentional-focus)
!(import! &self metta-attention:attention:agents:mettaAgents:RentCollectionAgent:WARentCollectionAgent:WARentCollectionAgent)
;lower max AFsize for testing
!(updateAttentionParam MAX_AF_SIZE 4)
!(assertEqual (getAttentionParam MAX_AF_SIZE) 4)
!(stimulate b 3000.0)
!(stimulate c 1500.0)
!(stimulate d 290.0)
!(stimulate (Hebbianlink a b) 50.0)
!(stimulate (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) 5.0)
!(assertEqual  (getSTI b) 60000.0)
!(assertEqual (getSTI c)  30000.0)
!(assertEqual (getSTI d) 2900.0)
!(assertEqual (getSTI (Hebbianlink a b)) 355.0)
!(assertEqual  (getSTI (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725)
!(assertEqual (selectTargets) (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))
!((let $res (selectTargets)
(elapsedTime $res) ))
!(WARentCollectionAgent-Run)
; Sleep for the computed time to match C++ behavior
!((py-atom time.sleep) 0.5)
!(WARentCollectionAgent-Run)
!(assertEqual (< (getSTI (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725) True) ;must have lower sti
!(getSTI (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))
!(assertEqual  (getSTI b) 60000.0)
!(assertEqual (getSTI c)  30000.0)
!(assertEqual (getSTI d) 2900.0)
!(assertEqual (getSTI (Hebbianlink a b)) 355.0)








