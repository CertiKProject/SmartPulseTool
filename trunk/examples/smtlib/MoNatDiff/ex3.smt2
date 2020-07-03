(set-logic UFLIA)

; MoNatDiff specific declarations
(declare-sort SetOfInt 0)
(declare-fun element (Int SetOfInt) Bool)
(declare-fun subsetInt (SetOfInt SetOfInt) Bool)
(declare-fun strictSubsetInt (SetOfInt SetOfInt) Bool)

(declare-fun x () Int)
(declare-fun y () Int)
(declare-fun S () SetOfInt)

(assert (exists ((S SetOfInt)) (and (element (+ x 0) S) (and (element (+ y 0) S) (<= y 2)))))

(check-sat)
(get-model)
