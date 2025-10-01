!(bind! &space (new-space))

;########################## STI Wage Calculation ###########################
(: calculateSTIWage (-> Number))
(= (calculateSTIWage)
   (let* (
           ($funds (getAttentionParam FUNDS_STI))
           ($targetSTI (getAttentionParam TARGET_STI))
           ($stiFundsBuffer (getAttentionParam STI_FUNDS_BUFFER))
           ($STIAtomWage (getAttentionParam STI_ATOM_WAGE))
           ($diff (- $funds $targetSTI))
           ($ndiff-raw (/ $diff $stiFundsBuffer))
           ($ndiff-clamped-min (min-atom ($ndiff-raw 1.0)))
           ($ndiff (max-atom ($ndiff-clamped-min -1.0)))
           ($atom-wage $STIAtomWage)
         )
         (+ $atom-wage (* $atom-wage $ndiff))
   )
)

;########################## LTI Wage Calculation ###########################
(: calculateLTIWage (-> Number))
(= (calculateLTIWage)
   (let* (
           ($funds (getAttentionParam FUNDS_LTI))
           ($targetLTI (getAttentionParam TARGET_LTI))
           ($ltiFundsBuffer (getAttentionParam LTI_FUNDS_BUFFER))
           ($LTIAtomWage (getAttentionParam LTI_ATOM_WAGE))
           ($diff (- $funds $targetLTI))
           ($ndiff-raw (/ $diff $ltiFundsBuffer))
           ($ndiff-clamped-min (min-atom ($ndiff-raw 1.0)))
           ($ndiff (max-atom ($ndiff-clamped-min -1.0)))
           ($atom-wage $LTIAtomWage)
         )
         (+ $atom-wage (* $atom-wage $ndiff))
   )
)

;########################## Stimulate Atom ###########################
(: stimulate (-> Atom Number empty))
(= (stimulate $pattern $stimulus)
   (let* (
           ($sti (getSti $pattern))
           ($lti (getLti $pattern))
           ($vlti (getVlti $pattern))
           ($sti-wage (* (calculateSTIWage) $stimulus))
           ($lti-wage (* (calculateLTIWage) $stimulus))
           ($new-sti (+ $sti $sti-wage))
           ($new-lti (+ $lti $lti-wage))
           ($new-av ($new-sti $new-lti $vlti))
           ($res (setAv $pattern $new-av))
         )
         "Updated"
   )
)

;########################## Handle Attention Value Changes #################
(: attentionValueChanged (-> Atom Number Number empty))
(= (attentionValueChanged $pattern $newSTIFund $newLTIFund)
   (let* (
           ($stiUpdated (updateAttentionParam FUNDS_STI $newSTIFund))
           ($ltiUpdated (updateAttentionParam FUNDS_LTI $newLTIFund))
           ($atombin (AtomBin))
           ($binUpdate (update $atombin))
           ($focusUpdate (updateAttentionalFocus $pattern True))
         )
         $binUpdate
   )
)
