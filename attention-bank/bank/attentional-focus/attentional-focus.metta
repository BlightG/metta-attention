!(bind! &attentionalFocus (new-space))
!(bind! &newAtomInAV (new-space))

(= (AttentionalFocus) &attentionalFocus)
(= (newAtomInAV) &newAtomInAV)

(= (maxAFSize) 1000)

; -----------------------
; Basic AF helpers
; -----------------------
(: atomIsInAF (-> Atom Bool))
(= (atomIsInAF $atom)
   (if (== (collapse (match &attentionalFocus $atom $atom)) ())
       False
       True
   )
)

(: atomIsNotInAF (-> Expression Expression))
(= (atomIsNotInAF $list)
   (collapse
     (let $x (superpose $list)
       (if (atomIsInAF $x)
         (empty)
         $x
       )
     )
   )
)

(: addAtomToAF (-> Atom Bool Symbol))
(= (addAtomToAF $atom $new)
   (if (== (getValueType $atom) %Undefined%)
       ("Atom is not valid")
       (let*
         (
           (() (add-atom &attentionalFocus $atom))
           (() (if (contains (getNewAtomInAVList) $atom)
                  ()
                  (if $new
                      (let $wrote
                        (write_csv_wrapper (attentionalFocus))
                        (add-atom &newAtomInAV $atom)
                      )
                      ()
                  )
              )
          )
         )
         ("Atom Added")
       )
   )
)

(: getAtomList (-> Symbol))
(= (getAtomList)
   (collapse (get-atoms &attentionalFocus))
)

(: getNewAtomInAVList (-> Symbol))
(= (getNewAtomInAVList)
   (collapse (get-atoms &newAtomInAV))
)

(: attentionalFocusSize (-> Number))
(= (attentionalFocusSize)
   (let $atomList (getAtomList)
     (size-atom $atomList)
   )
)

; -----------------------
; Sorting and comparisons (by STI)
; -----------------------
(: lessThanSti (-> Atom Atom Bool))
(= (lessThanSti $elem $pivot)
   (if (or (== $elem ()) (== $pivot ()))
       False
       (< (getSti $elem) (getSti $pivot))
   )
)

(: greaterEqualSti (-> Atom Atom Bool))
(= (greaterEqualSti $elem $pivot)
   (if (or (== $elem ()) (== $pivot ()))
       False
       (let* (($stiE (getSti $elem)) ($stiP (getSti $pivot)))
         (or (> $stiE $stiP) (and (<= $stiE $stiP) (not (< $stiE $stiP))))
       )
   )
)

(: sortAtomsBySti (-> Symbol Symbol))
(= (sortAtomsBySti $atoms)
   (if (== $atoms ())
       ()
       (let*
         (
           ($pivot (car-atom $atoms))
           ($tail (cdr-atom $atoms))
           ($lesser (binaryFilter lessThanSti $pivot $tail))
           ($greater (binaryFilter greaterEqualSti $pivot $tail))
           ($sortedLesser (sortAtomsBySti $lesser))
           ($sortedGreater (sortAtomsBySti $greater))
         )
         (concatTuple $sortedLesser (cons-atom $pivot $sortedGreater))
       )
   )
)

(: sortAtomsByStiDescending (-> Symbol Symbol))
(= (sortAtomsByStiDescending $atoms)
   (if (== $atoms ())
       ()
       (let*
         (
           ($pivot (car-atom $atoms))
           ($tail (cdr-atom $atoms))
           ($greater (binaryFilter greaterEqualSti $pivot $tail))
           ($lesser (binaryFilter lessThanSti $pivot $tail))
           ($sortedGreater (sortAtomsByStiDescending $greater))
           ($sortedLesser (sortAtomsByStiDescending $lesser))
         )
         (concatTuple $sortedGreater (cons-atom $pivot $sortedLesser))
       )
   )
)

; -----------------------
; Get lowest STI atom in AF
; -----------------------
(= (getLowestStiAtomInAFHelper $atoms $minAtom $minSTI)
   (if (== $atoms ())
       $minAtom
       (let*
         (
           ($current (car-atom $atoms))
           ($sti (getSti $current))
           ($newMinAtom (if (< $sti $minSTI) $current $minAtom))
           ($newMinSTI (if (< $sti $minSTI) $sti $minSTI))
         )
         (getLowestStiAtomInAFHelper (cdr-atom $atoms) $newMinAtom $newMinSTI)
       )
   )
)

(: getLowestStiAtomInAF (-> Atom))
(= (getLowestStiAtomInAF)
   (let $atoms (getAtomList)
     (if (== $atoms ())
         ()
         (let $atom (car-atom $atoms)
           (getLowestStiAtomInAFHelper $atoms (car-atom $atoms) (getSti $atom))
         )
     )
   )
)

; -----------------------
; Update attentional focus (old behavior kept)
; -----------------------
(: updateAttentionalFocus (-> Atom Bool empty))
(= (updateAttentionalFocus $atom $newAtom)
   (let*
     (
       ($maxSize (getAttentionParam MAX_AF_SIZE))
       ($sti (getSti $atom))
       ($currentSize (attentionalFocusSize))
       ($isInAF (atomIsInAF $atom))
     )
     (if $isInAF
         (let ()
           (remove-atom &attentionalFocus $atom)
           (addAtomToAF $atom $newAtom)
         )
         (if (< $currentSize $maxSize)
             (addAtomToAF $atom $newAtom)
             (let $lowestAtom (getLowestStiAtomInAF)
               (if (> $sti (getSti $lowestAtom))
                   (let ()
                     (remove-atom &attentionalFocus $lowestAtom)
                     (addAtomToAF $atom True)
                   )
                   ()
               )
             )
         )
     )
   )
)

; -----------------------
; Incoming links helpers (AF-filtered)
; -----------------------
(: getIncomingSet (-> Atom Type List))
(= (getIncomingSet $atom $type)
   (let*
     (
       ($incoming_set (getIncomingSetByType $atom $type))
       ($filtered_set (filterLinksInAF $incoming_set))
     )
     $filtered_set
   )
)

(: filterLinksInAF (-> List List))
(= (filterLinksInAF $incoming_set)
   (let $atoms (collapse (filterLinksInAFHelper $incoming_set))
     $atoms
   )
)

(: filterLinksInAFHelper (-> List List))
(= (filterLinksInAFHelper $incoming_set)
   (let $atom (superpose $incoming_set)
     (if (atomIsInAF $atom)
         $atom
         (emtpy)
     )
   )
)

; -----------------------
; getIncomingSetByType using AF matching (old-style)
; kept for backward compatibility — returns links that are in &attentionalFocus
; -----------------------
(: getIncomingSetByType (-> Atom Type List))
(= (getIncomingSetByType $atom $type)
   (collapse
     (superpose
       (
         (match &attentionalFocus ($type $atom $b) ($type $atom $b))
         (match &attentionalFocus ($type $b $atom) ($type $b $atom))
       )
     )
   )
)

(: nodeMatch (-> Atom Atom Bool))
(= (nodeMatch $node1 $node2)
   (if (and (== $node1 $node2) (atomIsInAF $node2))
       True
       False
   )
)

; -----------------------
; Tuple utilities (kept)
; -----------------------
(: tupleCount (-> %Undefined% Number))
(= (tupleCount $atom) (if (== $atom ()) 0 (+ 1 (tupleCount (cdr-atom $atom)))))

(= (getArity $pattern)
   (if (== $pattern ())
       0
       (- (tupleCount $pattern) 1)
   )
)

(= (getVariables $pattern)
   (if (== $pattern ())
       ()
       (if (== (let* (($var (car-atom $pattern))) (get-metatype $var)) Variable)
           ( (car-atom $pattern) (getVariables (cdr-atom $pattern)))
           (getVariables (cdr-atom $pattern))
       )
   )
)

(: termMatchMixinLinkMatch ( -> Atom Atom Bool))
(= (termMatchMixinLinkMatch $ptm $lsoln)
   (if (== $ptm $lsoln)
       True
       (if (== (car-atom $ptm) CHOICE_LINK)
           True
           (if (not (== (car-atom $ptm) (car-atom $lsoln)))
               False
               (let* (($ptmArity (getArity $ptm)) ($lsolnArity (getArity $lsoln)))
                 (if (not (== $ptmArity $lsolnArity))
                     False
                     (if (== (car-atom $ptm) SCOPE_LINK)
                         (if (not (== (getVariables $ptm) (getVariables $lsoln)))
                             False
                             True
                         )
                         True
                     )
                 )
               )
           )
       )
   )
)

( :linkMatch (-> Atom Atom Bool))
( = (linkMatch $ptm $lsoln)
   (if (and (termMatchMixinLinkMatch $ptm $lsoln) (atomIsInAF $lsoln))
       True
       False
   )
)

; -----------------------
; AF-related one-space helpers (new in one-space design)
; -----------------------

; getAfAtoms: returns expression of atoms to be considered AF (top MAX_AF_SIZE atoms by bin/st i)
(: getAfAtoms (-> Expression))
(= (getAfAtoms)
   (let*
     (
       ($afSize (getAttentionParam MAX_AF_SIZE))
       ($allAtoms (getAllAtomsWithBins))
     )
     (if (not (<= $afSize (size-atom $allAtoms)))
         (let $wrote
           (write_csv_wrapper $allAtoms)
           $allAtoms
         )
         (getAfAtomsHelper $afSize)
     )
   )
)

(: getAfAtomsHelper (-> Number Expression))
(= (getAfAtomsHelper $size)
   (let*
     (
       ($binList (sortDecend (getBinList (TypeSpace))))
       (($min $atomsList) (minBin $binList $size ())) ; returns (minBinNumber atomsAboveMin)
       ($remainSize (- $size (size-atom $atomsList)))
       ($minAtomsSti (getAtomsByBin $min))
       ($sortedMinList (sortAtomsDescending $minAtomsSti))
       ($lastAtoms (getNatoms $sortedMinList $remainSize))
       ($afAtoms (union-atom $atomsList $lastAtoms))
       ($wrote (write_csv_wrapper $afAtoms))
     )
     $afAtoms
   )
)

(: minBin (-> Expression Number Expression Expression))
(= (minBin $binList $size $acc)
   (if (== $binList ())
       (-1 $acc)
       (let* (
               (($bin $tail) (decons-atom $binList))
               ($atoms (getAtomsByBin $bin))
               ($atomsList (union-atom $atoms $acc))
             )
         (if (< $size (size-atom $atomsList))
             ($bin $acc)
             (minBin $tail $size $atomsList)
         )
       )
   )
)

(: getRandomAtomNotInAF (-> Symbol))
(= (getRandomAtomNotInAF)
   (let*
     (
       ($afAtoms (getAfAtoms))
       ($atoms (getAllAtomsWithBins))
       ($outsideAf (subtraction-atom $atoms $afAtoms))
       ($size (size-atom $outsideAf))
     )
     (if (== $size 0)
         ()
         (let $rand (random-int 0 $size)
           (index-atom $outsideAf $rand)
         )
     )
   )
)

(= (getRandInAf)
   (let $atoms (getAfAtoms)
     (if (== (size-atom $atoms) 0)
         ()
         (let $rand (random-int 0 (size-atom $atoms))
           (index-atom $atoms $rand)
         )
     )
   )
)

(: isAtomInAf (-> Symbol Bool))
(= (isAtomInAf $atom)
   (let $x (getAllMinSTI (getAfAtoms))
     (< (getSti $x) (getSti $atom))
   )
)

; new getIncomingSetByType which searches incoming links from the AF atom set (returns expression)
(: getIncomingSetByType (-> Atom Type Expression))
(= (getIncomingSetByType $atom $type)
   (let $list (getAfAtoms)
     (collapse
       (let*
         (
           ($x (superpose $list))
           ($y (unify ($type $elem $atom) $x ($type $elem $atom) ()))
           ($l (unify ($type $atom $z) $x ($type $atom $z) ()))
         )
         (if (and (== $y ()) (== $l ())) Empty (union-atom $y $l))
       )
     )
   )
)

; -----------------------
; AF space accessors and removers
; -----------------------
(= (attentionalFocus) &attentionalFocus)

(: removeAtomAttentionalfocus (-> atom empty))
(= (removeAtomAttentionalfocus $atom)
   (if (atomIsInAF $atom)
       (remove-atom &attentionalFocus $atom)
       ()
   )
)

(= (removeNewAtomAV $head)
   (remove-atom &newAtomInAV $head)
)
