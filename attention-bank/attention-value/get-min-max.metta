; Function: getMaxContent
; Description: finds atoms in the largest bin index in the current space
(: getMaxContent (-> Expression))
(= (getMaxContent)
    (let $bins 
         (getBinList) ; retrieves bin indices from the global space
         (if (== $bins ()) 
            () 
            (let $max 
                    (max-atom $bins)
                    (getAtomsByBin $max)
            )
        )
    )
)

; Function: getMinContent
; Description: finds atoms in the smallest bin index in the current space
(: getMinContent (-> Expression))
(= (getMinContent)
    (let $bins 
         (getBinList)
         (if (== $bins ()) 
            () 
            (let $min 
                    (min-atom $bins)
                    (getAtomsByBin $min)
            )
        )
    )
)

; Function: getSize
; Description: takes a bin number and returns the number of atoms in that bin
(: getSize (-> Number Number))
(= (getSize $binNumber)
    (let $atoms 
         (getAtomsByBin $binNumber)
         (size-atom $atoms)
    )
)

; Function: binSize
; Description: calculates total number of atoms across all bins
(: binSize (-> Number))
(= (binSize)
    (let $x (getAllAtomsWithBins)
         (size-atom $x)
    )
)
