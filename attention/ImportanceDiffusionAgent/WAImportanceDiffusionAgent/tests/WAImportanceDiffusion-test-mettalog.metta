!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention-bank:attention-value/get-min-max)
!(import! &self metta-attention:attention-bank:bank/attention-bank)
!(import! &self metta-attention:attention-bank:bank/attentional-focus/attentional-focus)
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)
!(import! &self metta-attention:attention:Neighbors)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent/ImportanceDiffusionBase/ImportanceDiffusionBase)
!(import! &self metta-attention:attention:ImportanceDiffusionAgent/WAImportanceDiffusionAgent/WAImportanceDiffusionAgent)
!(import! &self metta-attention:attention-bank:bank/stochastic-importance-diffusion/stochastic-importance-diffusion)
!(import! &self metta-attention:attention-bank:utilities/recentVal)

;;################################ Updating Attention Parameter #############################
!(updateAttentionParam MAX_AF_SIZE 4.0)

;;################################ Stimulating atoms so that they enter AF #############################
!(stimulate source 500)
!(stimulate target1 400)
!(stimulate target2 400)
!(stimulate target3 400)
!(stimulate target4 300)

;;################################ Creating links between atoms #############################
!(setStv (HEBBIAN_LINK source target1) (0 1))
!(setStv (HEBBIAN_LINK source target2) (0 1))
!(setStv (ASYMMETRIC_HEBBIAN_LINK source target3) (0 1))

!(setStv (INHERITANCE_LINK target3 source) (0 1))
!(setStv (INHERITANCE_LINK source target4) (0 1))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target1 target2) (0 1))
!(setStv (ASYMMETRIC_HEBBIAN_LINK target2 target1) (0 1))

;;################################ Running the WA Importance Diffusion Agent (one-space) #############################
!(
    (WAImportanceDiffusionAgent-Run (TypeSpace))
    (WAImportanceDiffusionAgent-Run (TypeSpace))
    (WAImportanceDiffusionAgent-Run (TypeSpace))
)

;;################################ Testing the STI values #############################
!(assertEqual (< (getSti target4) 6000.0) True)
!(assertEqual (> (getSti (INHERITANCE_LINK source target4)) 0.0) True)
