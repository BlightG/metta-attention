;;##########################################################################
;; Diffusion Source Vector (one-space version)
;; Collect all atoms from AF that are not Hebbian links
;;##########################################################################
(: diffusionSourceVector (-> Grounded Atom))
(= (diffusionSourceVector $space)
    (let*
        (
            ($atoms (collapse
                (let $temp (superpose (getAfAtoms))
                    (if (== (get-metatype $temp) Expression)
                        (if (== (car-atom $temp) HEBBIAN_LINK)
                            (empty)
                            $temp
                        )
                        $temp
                    )
                )
            ))
        )
        $atoms
    )
)

;;##########################################################################
;; Calculate Diffusion Amount
;;##########################################################################
(: calculateDiffusionAmount (-> Atom Number))
(= (calculateDiffusionAmount $atom)
    (* (getSti $atom) (getAttentionParam MAX_SPREAD_PERCENTAGE))
)

;;##########################################################################
;; Spread Importance (one-space)
;; Retrieves diffusion source vector and calls diffuseAtom
;;##########################################################################
(: spreadImportance (-> Grounded Empty))
(= (spreadImportance $space)
    (let*
        (
            ($diffusionSourceVector (diffusionSourceVector $space))
            ($result (collapse (let ($atom $atomToReceive $stiGiven)
                                   (diffuseAtom (superpose $diffusionSourceVector) $space AF)
                                   (tradeSti $atom $atomToReceive $stiGiven)
                               )
                            )
                    )
        )
        $result
    )
)

;;##########################################################################
;; Entry Point: AFImportanceDiffusionAgent
;;##########################################################################
(: AFImportanceDiffusionAgent-Run (-> Grounded Empty))
(= (AFImportanceDiffusionAgent-Run $space)
    (spreadImportance $space)
)
