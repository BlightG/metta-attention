!(register-module! ../../../../../metta-attention)

!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:attention-value/get-min-max)
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)
!(import! &self metta-attention:attention-bank:bank/attention-bank)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention:RentCollectionAgent/RentCollectionBaseAgent/RentCollectionBaseAgent)
!(import! &self metta-attention:attention-bank:bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self metta-attention:attention-bank:bank/attentional-focus/attentional-focus)
!(import! &self metta-attention:attention:RentCollectionAgent/WARentCollectionAgent/WARentCollectionAgent)

; Lower max AF size for testing
!(updateAttentionParam MAX_AF_SIZE 4)
!(assertEqual (getAttentionParam MAX_AF_SIZE) 4)

; Stimulate atoms
!(stimulate b 3000.0)
!(stimulate c 1500.0)
!(stimulate d 290.0)
!(stimulate (Hebbianlink a b) 50.0)
!(stimulate (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)) 5.0)

; Assert initial STI values
!(assertEqual  (getSti b) 60000.0)
!(assertEqual (getSti c)  30000.0)
!(assertEqual (getSti d) 2900.0)
!(assertEqual (getSti (Hebbianlink a b)) 355.0)
!(assertEqual  (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725)

; Check selected targets
!(assertEqual (selectTargets) (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))

; Compute elapsed time for selected targets
!((let $res (selectTargets)
      (elapsedTime $res)
  ))

; Run WARentCollectionAgent
!(WARentCollectionAgent-Run)

; Sleep to simulate passage of time
!((py-atom time.sleep) 0.5)

; Run agent again
!(WARentCollectionAgent-Run)

; Assert that STI of the selected atom decreased
!(assertEqual (< (getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b))) 33.725) True)

; Check STI values of other atoms remain unchanged
!(getSti (Hebbianlink (Hebbianlink c d) (Hebbianlink c b)))
!(assertEqual  (getSti b) 60000.0)
!(assertEqual (getSti c)  30000.0)
!(assertEqual (getSti d) 2900.0)
!(assertEqual (getSti (Hebbianlink a b)) 355.0)
