; ---------------------------
; helper-functions.mettalog
; ---------------------------

; Filter function
(= (filter $array $func)
   (if (== $array ())
       () 
       ($func $array)
   )
)

(: notEmpty (-> Expression Expression))
(= (notEmpty $list)
   (collapse
        (let $x (superpose $list)
            (if (== $x ()) 
                (empty) 
                $x
            )
        ) 
   )
)

(: customFilter (-> Expression (-> Symbol Number Number Bool) Number Number Expression))
(= (customFilter $list $predicate $lower $upper)
  (if (== $list ())
    ()
    (let*
      (
       ($head (car-atom $list))
       ($tail (cdr-atom $list))
       ($res ($predicate $head $lower $upper))
       ($filteredTail (customFilter $tail $predicate $lower $upper))
      )
      (if $res
        (cons-atom $head $filteredTail)
        $filteredTail
      )
    )
   )
)

; Binary filter
(: binaryFilter (-> (-> Atom Atom Bool) Atom Expression Expression))
(= (binaryFilter $f $pivot $tuple)
   (if (== $tuple ())  
       ()
       (let* 
           (
               ($head (car-atom $tuple))  
               ($tail (cdr-atom $tuple))  
               ($isValid ($f $head $pivot)) 
               ($filteredTail (binaryFilter $f $pivot $tail)) 
           )
           (if $isValid
               (cons-atom $head $filteredTail) 
               $filteredTail
           ) 
       )
   )
)

; Recursive helper to calculate the group index
(= (findGroup $imp $sum $i)
   (if (<= $imp 0)
       0
       (let* (
           ($num (+ $imp 1))
           ($log_num (log-math 2 $num))
           ($int_num (ceil-math $log_num))
       )
       (if (<= $int_num (GroupNum))
           $int_num
           (GroupNum)
       ))
   )
)

(: ceil (-> Number Number))
(= (ceil $x)
   (let $int_part (trunc-math $x)
      (if (== $x $int_part)
         $int_part
         (+ $int_part 1)
      )
   )
)

; List utilities
(= (firstElement ($x $xs)) $x)

(= (maxValue $max ()) $max)
(= (maxValue $max ($x $xs))
    (if (> $max $x)
        (maxValue $max $xs)
        (maxValue $x $xs)
    )
)
(= (maxList $list)
    (maxValue -1 $list)
)

(= (minValue $min ()) $min)
(= (minValue $min ($x $xs))
    (if (< $min $x)
        (minValue $min $xs)
        (minValue $x $xs)
    )
)
(= (minList $list)
    (minValue (firstElement $list) $list)
)

(= (concatTuple $xs $ys)
    (if (== $xs ())
        $ys
        (let* ( 
            ($head (car-atom $xs))
            ($tail (cdr-atom $xs))
            ($tailNew (concatTuple $tail $ys))
        )
            (cons-atom $head $tailNew)
        )
    )
)

(: flatten (-> Expression Expression))
(= (flatten $expr)
   (if (== $expr ()) 
       () 
       (let* (($head (car-atom $expr))
              ($tail (cdr-atom $expr))
              ($flattened-head (if (== (get-metatype $head) Expression)
                                   (flatten $head)
                                   (cons-atom $head ())))
              ($flattened-tail (flatten $tail)))
         (union-atom $flattened-head $flattened-tail)
       )
   )
)

; Search and comparison utilities
(= (contains $list $x)
   (not (== (collapse (intersection (superpose ($x)) (superpose $list))) ()))
)

(: removeDuplicates (-> Expression Expression))
(= (removeDuplicates $list)
   (collapse (unique (superpose $list)))
)

(: abs (-> Number Number))
(= (abs $x)
    (if (< $x 0) (- 0 $x) $x)
)

(: approxEqual (-> Number Number Number Bool))
(= (approxEqual $a $b $tol)
    (<= (abs (- $a $b)) $tol)
)

; Atom extraction helpers
(: extractAndFlatten (-> Expression Expression))
(= (extractAndFlatten $expr)
   (if (== $expr ())
       ()
       (let* (($head (car-atom $expr))
              ($tail (cdr-atom $expr))
              ($firstElem (car-atom $head))
              ($rest (cdr-atom $head))
              ($processedHead (if (== (get-type $firstElem) Number) 
                                  $rest
                                  $head))
              ($flattenedTail (extractAndFlatten $tail))
       )
       (union-atom $processedHead $flattenedTail)
       )
   )
)

(: collectContents (-> Expression Expression Expression))
(= (collectContents $list $acc)
   (if (== $list ())
    $acc
    (let* (
        ($content (car-atom $list))
        ($tail (cdr-atom $list))
        ($rest (collectContents $tail $acc))
       )
      (union-atom $content $rest)
    )
   )
)

; Reverse and remove links
(= (reverseExpr $x ) (collapse (union (superpose $x) (superpose ()))))

(: removeLinksfromList (-> List List))
(= (removeLinksfromList $atoms)
    (if (== $atoms ())
        ()
        (let* (
            ($head (car-atom $atoms))
            ($tail (cdr-atom $atoms))
        )
        (if (== (get-metatype $head) Symbol)
            (concatTuple ($head) (removeLinksfromList $tail))
            (removeLinksfromList $tail)
        )
    )
)
)

; STI helpers
(= (getStiHelper $atoms)
    (let* (
        ($vals (getSti (superpose $atoms)))
    )
    $vals
    )
)

(: getAllMaxSTI  (-> Expression Number))
(= (getAllMaxSTI $atoms)
   (if (== $atoms ())
        0.0
        (let* (
            ($stiValues (collapse (getStiHelper $atoms)))
            ($maxSTI (max-atom $stiValues))
        )
        $maxSTI
        )
   )
)

(: getAllMinSTI  (-> Expression Number))
(= (getAllMinSTI $atoms)
    (if (== $atoms ())
        0.0
        (let* (
            ($stiValues (collapse (getStiHelper $atoms)))
            ($minSTI (min-atom $stiValues))
        )
        $minSTI
        )
    )
)

; Outgoing atoms and STI sorting
(: getOutGoingAtoms (-> Atom Atom))
(= (getOutGoingAtoms $link)
    (if (== (size-atom $link) 3)
        (cdr-atom $link)
        ()
    )
)

(= (sortAtomsDescending $atoms) 
    (if (== $atoms ())
        ()
        (let* (
            ($pivot (car-atom $atoms))
            ($tail (cdr-atom $atoms))
            ($lesser (binaryFilter lessThanSti $pivot $tail))
            ($greater (binaryFilter greaterThanSti $pivot $tail))
            ($sortedLesser (sortAtomsDescending $lesser))
            ($sortedGreater (sortAtomsDescending $greater))
        )   
        (concatTuple $sortedGreater (cons-atom $pivot $sortedLesser))
        )
    )
)

(= (lessThanSti $elem $pivot)
    (if (or (== $elem ()) (== $pivot ()))
        False
        (<= (getSti $elem) (getSti $pivot))
    )   
)

(= (greaterThanSti $elem $pivot)
    (if (or (== $elem ()) (== $pivot ()))
        False
        (> (getSti $elem) (getSti $pivot))
    )   
)
