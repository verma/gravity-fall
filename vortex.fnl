{:create (fn [x y radius]
           {:x x :y y :radius radius :index 1 :t 0 :tt 0})
 :update (fn [vortex t]
           (set vortex.t (+ vortex.t t))
           (when (> vortex.t 1)
             (set vortex.t 0)))

 :center-and-radius (fn [vortex]
                      {:center {:x vortex.x :y vortex.y}
                       :radius vortex.radius})
 
 :draw (fn [vortex]
         (let [circles 10
               gi (if (> vortex.t 0.5) 1
                      (- circles (math.floor (* 2 vortex.t circles))))
               lw (/ vortex.radius circles)]
           (for [i 1 circles]
             (love.graphics.setColor 255 (+ 13 (* i 20)) 255
                                     (if (= gi i) 255 60))
             (love.graphics.setLineWidth 3)
             (love.graphics.circle (if (= i 1) "fill" "line")
                                   vortex.x vortex.y
                                   (* i lw)))))}
