!(bind! localToFarLinks 10) ; Ratio of local links to far links

; Function: HebbianCreationAgent-Run
; Description:
;   - Creates Hebbian links between atoms in the attentional focus (AF).
;   - Also creates links between AF atoms and atoms outside the AF.
;   - The number of links created between AF and outside is determined by localToFarLinks.
;   - Removes links if incoming links exceed maxLinkNum.
; Parameters: $space - the single working space (atomBin / Typespace)
; Returns: empty

!(= (HebbianCreationAgent-Run $space)
    (if (== (attentionalFocusSize) 0)
        ("Empty Attentional Focus")
        (let $source
            (let $afAtoms (getAfAtoms)
                (superpose $afAtoms)
            )
            (if (unify (get-metatype $source) Expression (== HEBBIAN_LINK (car-atom $source)) False)
                ("source is a hebbian link")
                (let*
                    (
                        ($existingAsSourceHS (getTargetNeighbors $source ASYMMETRIC_HEBBIAN_LINK $space))
                        ($needToBeTarget (subtraction-atom (getAfAtoms) $existingAsSourceHS))
                        ($count (size-atom $needToBeTarget))
                        ($farLinks (round' (/ $count localToFarLinks)))
                        ($incomingSet (getIncomingSetByType $source HEBBIAN_LINK))
                        ($maxLinkNum (getAttentionParam MAX_LINK_NUM))
                    )
                    (
                        ; Create Hebbian links to new AF targets
                        (collapse
                            (let $target (superpose $needToBeTarget)
                                (if (not (== $target $source))
                                    (addHebbian $target $source)
                                    ()
                                )
                            )
                        )

                        ; Add Hebbian links from AF → outside
                        (addFromOutSideAF $source $farLinks)

                        ; Enforce max incoming link constraint
                        (if (> (size-atom $incomingSet) $maxLinkNum)
                            (removeLinkRecursively (- (size-atom $incomingSet) $maxLinkNum))
                            ()
                        )
                    )
                )
            )
        )
    )
)

; Function: getSourceAtom
; Description: Returns the source atom of a link
!(= (getSourceAtom $source)
    (if (== (size-atom $source) 3)
        (let* (
            ($sourceAndTarget (cdr-atom $source))
            ($sourceAtom (car-atom $sourceAndTarget))
        )
            $sourceAtom
        )
        $source
    )
)

; Function: removeLinkRecursively
; Description: Removes Hebbian links from AF a given number of times
!(= (removeLinkRecursively $num)
    (if (or (== $num 0) (== 0 (attentionalFocusSize)))
        ()
        (let*
            (
                ($randomAtom (getRandomAtomInAF))
                ($_ (remove-atom (Typespace) $randomAtom))
            )
            (removeLinkRecursively (- $num 1))
        )
    )
)

; Function: setDifference
; Description: Returns AF atoms not in given list
!(= (setDifference $incomingList)
    (let $atomList (getAfAtoms)
        (subtraction-atom $atomList $incomingList)
    )
)

; Function: addFromOutSideAF
; Description: Adds Hebbian links from $source to atoms outside AF
!(= (addFromOutSideAF $source $farLinks)
    (if (== $farLinks 0)
        ()
        (let $target (getRandomAtomNotInAF)
            (if (== () $target)
                ()
                (if (== (get-metatype $target) Expression)
                    (if (== (car-atom $target) HEBBIAN_LINK)
                        ()
                        (if (and (not (== (getStv (ASYMMETRIC_HEBBIAN_LINK $source $target)) %Undefined%))
                                 (== $target $source))
                            ()
                            ((addHebbian $source $target)
                             (addFromOutSideAF $source (- $farLinks 1)))
                        )
                    )
                    (if (and (not (== (getStv (ASYMMETRIC_HEBBIAN_LINK $source $target)) %Undefined%))
                             (== $target $source))
                        ()
                        ((addHebbian $source $target)
                         (addFromOutSideAF $source (- $farLinks 1)))
                    )
                )
            )
        )
    )
)

; Function: addHebbian
; Description: Adds a Hebbian link with default stv
!(= (addHebbian $source $target)
    (let $link (ASYMMETRIC_HEBBIAN_LINK $source $target)
        (setStv $link (0.5 0.1))
    )
)

; Helper: round to nearest integer
!(= (round' $x)
    (let $floor (floor-math $x)
        (if (< (- $x $floor) 0.5)
            $floor
            (+ $floor 1)
        )
    )
)
