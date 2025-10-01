; =============================================
; Importance Index Management for Metta/One-Space
; =============================================

(: GroupSize Number)
(= (GroupSize) 8)

(: GroupNum Number)
(= (GroupNum) 12)

(: ImportanceIndexSize Number)
(= (ImportanceIndexSize) 104)

; ==========================
; Function: importanceBin
; ==========================
(: importanceBin (-> Number Number))
(= (importanceBin $impo)
   (let*
     (
       ($groupSize (GroupSize))
       ($impo_int (trunc-math $impo)) ; treat as integer
       ($firstCondition (< $impo_int 0))
       ($secondCondition (< $impo_int (* 2 $groupSize)))
     )
     (if $firstCondition
         0
         (if $secondCondition
             $impo_int
             (let*
               (
                 ($imp (trunc-math (/ (- $impo_int $groupSize) $groupSize)))
                 ($i (findGroup $imp 0 0))
                 ($num (- $i 1))
                 ($temp (ceil-math (/ $impo_int (pow-math 2 (- $i 1)))))
                 ($ad (- $groupSize $temp))
                 ($bin (- (* $i $groupSize) $ad))
               )
               $bin
             )
         )
     )
   )
)

; ==========================
; Function: update
; Updates global _minSTI and _maxSTI from all atoms in a space
; ==========================
(: update (-> hyperon::space::DynSpace Atom))
(= (update $space)
   (let*
     (
       ($collectedContents (getAllAtomsWithBins $space))
       ($max (getAllMaxSTI $collectedContents))
       ($min (getAllMinSTI $collectedContents))
       ($exitCondition (> $min $max))
     )
     (if $exitCondition
         (updateGlobalMaxAndMinSTI $max $max)
         (updateGlobalMaxAndMinSTI $min $max)
     )
   )
)

(: updateGlobalMaxAndMinSTI (-> Number Number))
(= (updateGlobalMaxAndMinSTI $min $max)
   (let*
     (
       ($firstRes (updateMin $min))
       ($secondRes (updateMax $max))
     )
     (trace! (updated) ("Updated"))
   )
)

; ==========================
; Function: filterContents
; Filters atoms whose STI falls within lower and upper bound
; ==========================
(: filterContents (-> Expression Number Number Expression))
(= (filterContents $contents $lower $higher)
   (if (== $contents ())
       ()
       (collapse
         (let* (($x (superpose $contents)))
           (if (and (>= (getSti $x) $lower) (<= (getSti $x) $higher))
               $x
               ()
           )
         )
       )
   )
)

; ==========================
; Function: getHandleSet
; Retrieves atoms within a STI range using bins
; ==========================
(: getHandleSet (-> Number Number Expression))
(= (getHandleSet $lowerBound $upperBound)
   (if (or (< $lowerBound 0) (< $upperBound 0))
       ()
       (let*
         (
           ($lowerBin (importanceBin $lowerBound))
           ($upperBin (importanceBin $upperBound))
           ($allContents (getContent $lowerBin $upperBin))
           ($filteredContents (filterContents $allContents $lowerBound $upperBound))
           ($finalContents (filter $filteredContents notEmpty))
         )
         $finalContents
       )
   )
)

; ==========================
; Functions: getMaxSTI / getMinSTI
; ==========================
(: getMaxSTI (-> Bool Number))
(= (getMaxSTI $avg)
   (let $recentVal (RecentVal)
     (if $avg
         (match $recentVal (recent_max $_) $_)
         (match $recentVal (value_max $_) $_)
     )
   )
)

(: getMaxSTI (-> Number))
(= (getMaxSTI)
   (let $recentVal (RecentVal)
       (match $recentVal (recent_max $_) $_)
   )
)

(: getMinSTI (-> Bool Number))
(= (getMinSTI $avg)
   (let $recentVal (RecentVal)
     (if $avg
         (match $recentVal (recent_min $_) $_)
         (match $recentVal (value_min $_) $_)
     )
   )
)

(: getMinSTI (-> Number))
(= (getMinSTI)
   (let $recentVal (RecentVal)
       (match $recentVal (recent_min $_) $_)
   )
)

; ==========================
; Function: getNormalisedZeroToOneSTI
; ==========================
(: getNormalisedZeroToOneSTI (-> Atom Bool Bool Number))
(= (getNormalisedZeroToOneSTI $atom $average $clip)
   (let*
       (
         ($sti (getSti $atom))
         ($maxSTI (getMaxSTI $average))
         ($minSTI (getMinSTI $average))
         ($normaliser (- $maxSTI $minSTI))
         ($diff (- $sti $minSTI))
         ($value (if (== $normaliser 0) 0.0 (/ $diff $normaliser)))
         ($minim (min-atom ($value 1.0)))
         ($clippedValue (if $clip (max-atom (0.0 $minim)) $value))
       )
       $clippedValue
   )
)

; ==========================
; Function: getNormalisedSTI (Single argument)
; ==========================
(: getNormalisedSTI (-> Atom Number))
(= (getNormalisedSTI $atom)
   (let*
     (
       ($atoms (getAfAtoms))
       ($s (getSti $atom))
       ($afMax (getAllMaxSTI $atoms))
       ($normaliser (if (> $s $afMax) (getMaxSTI) (getMinSTI)))
     )
     (if (== $normaliser 0)
         0.0
         (/ $s $normaliser)
     )
   )
)

; ==========================
; Function: getNormalisedSTI (With clip and average)
; ==========================
(: getNormalisedSTI (-> Atom Bool Bool Number))
(= (getNormalisedSTI $atom $average $clip)
   (let*
     (
       ($atoms (getAfAtoms))
       ($s (getSti $atom))
       ($afMax (getAllMaxSTI $atoms))
       ($diff (- $s $afMax))
       ($sum (+ $s $afMax))
       ($normaliser (if (> $s $afMax)
                        (- (getMaxSTI $average) $afMax)
                        (- (getMinSTI $average) $afMax)
                     )
       )
     )
     (if (== $normaliser 0)
         0.0
         (let*
           (
             ($val (if (> $s $afMax) (/ $diff $normaliser) (/ $sum $normaliser)))
             ($minim (min-atom ($val 1.0)))
           )
           (if $clip (max-atom (-1.0 $minim)) $val)
         )
     )
   )
)
