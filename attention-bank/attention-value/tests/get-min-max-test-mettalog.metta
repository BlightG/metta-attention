!(register-module! ../../../../metta-attention)
!(import! &self metta-attention:attention:AttentionParam)
!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention-bank:attention-value/get-min-max)
!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention-bank:bank/attention-bank)

; Test Case 01: Testing Empty atomBin
!(assertEqual (getMaxContent) ())
!(assertEqual (getMinContent) ())

; Test Case 02: getSize for a Non-Existent Bin
!(assertEqual (binSize) 0)
!(assertEqual (getSize 20) 0)

; Setup: setAv values to atoms
!(setAv Human (100.0 100.0 1.0))
!(setAv Dog (200.0 200.0 1.0))
!(setAv Cat (300.0 300.0 1.0))
!(setAv Animal (400.0 400.0 1.0))
!(setAv Mother (500.0 500.0 1.0))

; Test Case 03: Testing getMaxContent and getMinContent with Initial Data
!(assertEqual (getMaxContent) (Mother))
!(assertEqual (getMinContent) (Human))

; Setup: add link atoms
!(setAv (EvaluationLink Dog Cat) (110.0 110.0 1.0))
!(setAv (Hebbianlink (Hebbianlink Human Cat) Animal) (120.0 120.0 1.0))
!(setAv (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Mother)) (1030.0 130.0 1.0))

; Test Case 04: Adding Atom to Max Bin
!(assertEqual (getMaxContent) (collapse (Hebbianlink (Hebbianlink Animal Human) (Hebbianlink Animal Mother))))

; Test Case 05: getMinContent for Multiple Min Bins
!(setAv Father (103.0 210.0 1.0))
!(assertEqual (getMinContent) (Father Human))

; Test Case 06: Testing getSize Function
!(setAv Humaner (104.0 220.0 1.0))
!(setAv Doger (201.0 230.0 1.0))
!(assertEqual (getSize 37.0) 3)
!(assertEqual (getSize 45.0) 2)
!(assertEqual (getSize 56.0) 1)
!(assertEqual (getSize 65.0) 1)

; Test Case 07: Testing binSize Function
!(assertEqual (binSize) 11)
