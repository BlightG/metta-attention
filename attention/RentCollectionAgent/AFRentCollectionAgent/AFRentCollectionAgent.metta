;################################ Bind Python time module #############################
!(bind! time-mod (py-atom time))
!(bind! timeTime (py-dot time-mod time (-> Number)))

;################################ AFRentCollectionAgent #############################
!(bind! &timer (new-space))
!(add-atom &timer (firstTime True))
!(add-atom &timer (lastUpdate (timeTime)))

;################################ Function: selectAFTargets #############################
(: selectAFTargets (-> Expression))
(= (selectAFTargets)
    (getAfAtoms)
)

;################################ Function: collectAFRent #############################
(: collectAFRent (-> Expression empty))
(= (collectAFRent $targetSet)
    (let*
        (
            ($currentTime (timeTime))
            ($updateFreq (getAttentionParam AFRentFrequency))
            ($lastUpdate (match &timer (lastUpdate $x) $x))
            ($elapsedTime (* (- $currentTime $lastUpdate) 1000000))
            ($timeThreshold (/ 1000000 $updateFreq))
            ($multiplier (/ $updateFreq 1000000))
        )
        (if (match &timer (firstTime $x) $x)
            (
                (setFirstTime False)
                (setLastUpdate $currentTime)
            )
            (if (< $elapsedTime $timeThreshold)
                (empty)
                (let*
                    (
                        ($w (* $elapsedTime $multiplier))
                        ($lists (superpose $targetSet))
                    )
                    (
                        (applyRent $w $lists)
                        (setLastUpdate (timeTime))
                    )
                )
            )
        )
    )
)

;################################ Function: applyRent #############################
(: applyRent (-> Number Atom empty))
(= (applyRent $w $atom)
    (let*
        (
            ($sti (getSti $atom))
            ($lti (getLti $atom))
            ($stiAtomRent (getAttentionParam StartingAtomStiRent))
            ($ltiAtomRent (getAttentionParam StartingAtomLtiRent))
            ($calculatestirent (calculateStiRent $stiAtomRent))
            ($calculateltirent (calculateLtiRent $ltiAtomRent))
        )
        (if (and (== $calculatestirent 0.0) (== $calculateltirent 0.0))
            ()
            (let*
                (
                    ($stiRent (* $calculatestirent $w))
                    ($ltiRent (* $calculateltirent $w))
                    ($minstiRent (min-atom ($stiRent $sti)))
                    ($minltiRent (min-atom ($ltiRent $lti)))
                    ($stiDiff (- $sti $minstiRent))
                    ($ltiDiff (- $lti $minltiRent))
                    ($atomVlti (getVlti $atom))
                )
                (setAv $atom ($stiDiff $ltiDiff $atomVlti))
            )
        )
    )
)

;################################ Function: setLastUpdate #############################
(: setLastUpdate (-> Number empty))
(= (setLastUpdate $time)
    (match &timer (lastUpdate $x)
        (let ()
            (remove-atom &timer (lastUpdate $x))
            (add-atom &timer (lastUpdate $time))
        )
    )
)

;################################ Function: setFirstTime #############################
(: setFirstTime (-> Bool empty))
(= (setFirstTime $flag)
    (match &timer (firstTime $x)
        (let ()
            (remove-atom &timer (firstTime $x))
            (add-atom &timer (firstTime $flag))
        )
    )
)

;################################ Entry Point: AFRentCollectionAgent-run #############################
(= (AFRentCollectionAgent-run)
    (let $res (selectAFTargets)
        (if (== $res ())
            (empty)
            (collectAFRent $res)
        )
    )
)
