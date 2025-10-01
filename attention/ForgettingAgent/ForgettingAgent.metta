!(bind! &removeSpace (new-space)) ; one space to store removed atoms

(: RemoveSpace (-> Grounding::space))
(= (RemoveSpace)
    &removeSpace
)

; Forgetting Agent runner
(: forgettingAgent-Run (-> Grounding::space empty))
(= (forgettingAgent-Run $space)
    (let*
        (
            ($count 0)
            ($maxSize (getAttentionParam MAX_SIZE))
            ($accDivSize (getAttentionParam ACC_DIV_SIZE))
            ($forgetThreshold (getAttentionParam FORGET_THRESHOLD))
            ($atoms (getAllAtomsWithBins))          ; all atoms from the bins
            ($size (countAtomsInTypeSpace))
            ($removalAmount (- $size (- $maxSize $accDivSize)))
            ($filteredatom (filterByLti $atoms $forgetThreshold))
            ($sortedatoms (ForgettingLtiThenTVAscendingSort $filteredatom))
        )
        (if (< $size (+ $maxSize $accDivSize))
            ()
            (checkThenRemoveAtom $sortedatoms $removalAmount $count)
        )
    )
)

; Filter atoms below threshold
(: filterByLti (-> List Number List))
(= (filterByLti $atoms $forgetThreshold)
    (if (== $atoms ())
        ()
        (let*
            (
                ($head (car-atom $atoms))
                ($tail (cdr-atom $atoms))
            )
            (if (<= (getLti $head) $forgetThreshold)
                (if (== (getVlti $head) 0)
                    (concatTuple ($head) (filterByLti $tail $forgetThreshold))
                    (filterByLti $tail $forgetThreshold)
                )
                (filterByLti $tail $forgetThreshold)
            )
        )
    )
)

; Sort atoms by Lti then TV.mean
(: ForgettingLtiThenTVAscendingSort (-> List List))
(= (ForgettingLtiThenTVAscendingSort $atoms)
    (if (== $atoms ())
        ()
        (let*
            (
                ($pivot (car-atom $atoms))
                ($tail (cdr-atom $atoms))
                ($lesser (binaryFilter lessThanLtiThenTV $pivot $tail))
                ($greater (binaryFilter greaterThanLtiThenTV $pivot $tail))
                ($sortedLesser (ForgettingLtiThenTVAscendingSort $lesser))
                ($sortedGreater (ForgettingLtiThenTVAscendingSort $greater))
            )
            (concatTuple $sortedLesser (cons-atom $pivot $sortedGreater))
        )
    )
)

(: lessThanLtiThenTV (-> Atom Atom Bool))
(= (lessThanLtiThenTV $elem $pivot)
    (if (or (== $elem ()) (== $pivot ()))
        False
        (if (== (getLti $elem) (getLti $pivot))
            (< (getMean $elem) (getMean $pivot))
            (< (getLti $elem) (getLti $pivot))
        )
    )
)

(: greaterThanLtiThenTV (-> Atom Atom Bool))
(= (greaterThanLtiThenTV $elem $pivot)
    (if (or (== $elem ()) (== $pivot ()))
        False
        (if (== (getLti $elem) (getLti $pivot))
            (>= (getMean $elem) (getMean $pivot))
            (> (getLti $elem) (getLti $pivot))
        )
    )
)

; Check and remove atoms recursively
(: checkThenRemoveAtom (-> List Number Number empty))
(= (checkThenRemoveAtom $sortedatoms $removalAmount $count)
    (if (== $sortedatoms ())
        ()
        (let*
            (
                ($head (car-atom $sortedatoms))
                ($tail (cdr-atom $sortedatoms))
                ($iset (globalIncomingSetByType $head ASYMMETRIC_HEBBIAN_LINK))
                ($niset (globalIncomingSetwithoutType $head))
            )
            (if (< $count $removalAmount)
                (if (== (size-atom $iset) (size-atom $niset))
                    (let*
                        (
                            ($size (size-atom $niset))
                            (() (globalRemoveAtom $head $niset))
                            ($newCount (+ (+ 1 $count) $size))
                        )
                        (checkThenRemoveAtom $tail $removalAmount $newCount)
                    )
                    (checkThenRemoveAtom $tail $removalAmount $count)
                )
                ()
            )
        )
    )
)

; Atom removal
(: globalRemoveAtom (-> Atom List empty))
(= (globalRemoveAtom $head $niset)
    (let*
        (
            (() (add-atom &removeSpace $head))   ; add original atom first
            (() (refundAV $head))               ; then refund & zero AV
            (() (extractAtomRecursive $niset))
            (() (removeTypeSpace $head))
        )
        ()
    )
)

; Recursively extract atoms
(: extractAtomRecursive (-> List empty))
(= (extractAtomRecursive $atoms)
    (if (== $atoms ())
        ()
        (let*
            (
                ($head (car-atom $atoms))
                ($tail (cdr-atom $atoms))
                (() (refundAV $head))
                (() (add-atom &removeSpace $head))
                (() (removeTypeSpace $head))
            )
            (extractAtomRecursive $tail)
        )
    )
)

; Refund AV values before removal
(: refundAV (-> Atom empty))
(= (refundAV $atom)
    (let ($av (getAv $atom))
        (if (== $av %Undefined%)
            ()
            (let ($sti (car-tuple $av))           ; STI component
                (updateAttentionParam FUNDS_STI (- (getAttentionParam FUNDS_STI) $sti))
                (setAv $atom (0 0 0))
            )
        )
    )
)

; Remove space utilities (unchanged)
(: getRemoveValueType (-> Atom Type))
(= (getRemoveValueType $pattern)
    (let $a
        (collapse (getRemoveValueType-helper $pattern))
        (if (== $a ())
            %Undefined%
            (car-atom $a)
        )
    )
)

(: getRemoveValueType-helper (-> Atom Type))
(= (getRemoveValueType-helper $pattern)
    (let $a
        (get-type-space &removeSpace $pattern)
        (unify $a
            (AV $sti $lti $vlti)
            (AV $sti $lti $vlti)
            (unify $a
                (STV $mean $conf)
                (STV $mean $conf)
                (unify $a
                    ((STV $mean $conf) (AV $sti $lti $vlti))
                    ((STV $mean $conf) (AV $sti $lti $vlti))
                    (empty)
                )
            )
        )
    )
)

(= (getRemoveAV $pattern)
    (let $type (getRemoveValueType $pattern)
        (if (== $type $Undefined$)
            %Undefined%
            (unify $type
                (AV $sti $lti $vlti)
                (AV $sti $lti $vlti)
                (unify $type
                    ((STV $mean $conf) (AV $sti $lti $vlti))
                    (AV $sti $lti $vlti)
                    %Undefined%
                )
            )
        )
    )
)

(: getRemoveLti (-> Atom Number))
(= (getRemoveLti $pattern)
    (let (AV $sti $lti $vlti) (getRemoveAV $pattern) $lti)
)

(: getRemoveSTI (-> Atom Number))
(= (getRemoveSTI $pattern)
    (let (AV $sti $lti $vlti) (getRemoveAV $pattern) $sti)
)

(: getAtomsInRemoveSpace-helper (-> List))
(= (getAtomsInRemoveSpace-helper)
    (let $a
        (get-atoms &removeSpace)
        (unify $a
            (: $pattern $x)
            $pattern
            (empty)
        )
    )
)

(: getAtomsInRemoveSpace (-> List))
(= (getAtomsInRemoveSpace)
    (collapse (getAtomsInRemoveSpace-helper))
)
