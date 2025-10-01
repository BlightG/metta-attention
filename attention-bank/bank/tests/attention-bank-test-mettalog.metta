!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)

!(import! &self metta-attention:attention-bank:bank/attention-bank)
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)
!(import! &self metta-attention:attention-bank:bank/attentional-focus/attentional-focus)

!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention-bank:utilities/recentVal)

;########################### Testing STI and LTI wages ######################
!(assertEqual (calculateSTIWage) 20.0)
!(assertEqual (calculateLTIWage) 20.0)

;########################### Prep: Initial AttentionValues ##################
!(setAv x (200.0 200.0 0.0))
!(setAv y (200.0 200.0 0.0))
!(setAv z (200.0 200.0 1.0))

;########################### Testing stimulate & update ####################
!(stimulate x 1.5)
!(assertEqual (getAv x) (AV 230.0 230.0 0))
!(assertEqual (getAttentionParam FUNDS_STI) 99370.0)
!(assertEqual (getAttentionParam FUNDS_LTI) 99370.0)

!(stimulate x 2)
!(assertEqual (getAv x) (AV 270.0 270.0 0))
!(assertEqual (getAttentionParam FUNDS_STI) 99330.0)
!(assertEqual (getAttentionParam FUNDS_LTI) 99330.0)

!(stimulate y 2)

;########################### Testing attentional focus update ################
!(stimulate w 0)

!(let $afAtoms
    (getAfAtoms)
    (assertEqual (subtraction-atom $afAtoms (x y z w)) ())
)
