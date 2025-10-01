; This is custom to AFImportancediffusion needs

(: getTargetNeighborsAFI (-> Atom Atom Atom Bool Atom))
(= (getTargetNeighborsAFI $iset $atom $type $match-subtype)
    (if (== $type UNORDERED_LINK)
        ()
        (let*
            (
                (($link $source $target) $iset)
                ($answer
                    (if (== $link $type)
                        (if (== $source $atom)
                            $target
                            ()
                        )
                        ()
                    )
                )
            )
            $answer
        )
    )
)

(: getTargetNeighbors (-> Atom Atom Atom List))
(= (getTargetNeighbors $target $type $space)
    (collapse
        (match $space 
            (($type $x $target) $value) 
            (filterTarget ($type $x $target) $target)
        )
    )
)

(: filterTarget (-> Atom Atom Atom))
(= (filterTarget $link $target)
    (let ($type $x $t) $link
        (if (or (== $type UNORDERED_LINK) (== $x $target))
            (empty)
            $x
        )
    )
)
