(local pretty (require "pl.pretty"))

(global pp (fn [v]
             (pretty.dump v)))

{:pp pp}
