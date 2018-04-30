(local pretty (require "pl.pretty"))

(global pp (fn [v]
             (pretty.dump v)))

{:pp pp
 :sphere-collision (fn [a b]
                     (let [d2 (+ (* (- a.center.x b.center.x)
                                    (- a.center.x b.center.x))
                                 (* (- a.center.y b.center.y)
                                    (- a.center.y b.center.y)))
                           r2 (* (+ a.radius b.radius)
                                 (+ a.radius b.radius))]
                       (< d2 r2)))}
