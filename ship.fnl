(local lume (require "lume"))

(var ship-texture nil)
(var ship-quads nil)
(var explosion-texture nil)
(var explosion-quads nil)
(var explosion-sound nil)

{:load (fn []
         (set ship-texture (love.graphics.newImage "assets/ship.png"))
         (set ship-quads (let [a (love.graphics.newQuad 0 0 32 32
                                                        (: ship-texture :getWidth)
                                                        (: ship-texture :getHeight))
                               b (love.graphics.newQuad 32 0 32 32
                                                        (: ship-texture :getWidth)
                                                        (: ship-texture :getHeight))]
                           [a b]))
         (set explosion-texture (love.graphics.newImage "assets/boom.png"))
         (set explosion-quads [])
         (for [i 0 63]
           (let [x (% i 8)
                 y (math.floor (/ i 8))]
             (tset explosion-quads (+ i 1)
                   (love.graphics.newQuad (* 32 x) (* 32 y)
                                          32 32
                                          (: explosion-texture :getWidth)
                                          (: explosion-texture :getHeight)))))

         (set explosion-sound (love.audio.newSource "assets/explode.wav" "static")))

 :bounds (fn [ship]
           [(- ship.x 16) (- ship.y 16)
            (+ ship.x 16) (+ ship.y 16)])

 :center-and-radius (fn [ship]
                      {:center {:x ship.x
                                :y ship.y}
                       :radius 16})
 
 :apply-planetary-forces (fn [ship planets]
                           (let [f {:x 0 :y 0}]
                             (each [k p (ipairs planets)]
                               (let [px p.location.x
                                     py p.location.y
                                     d2 (+ (* (- px ship.x)
                                              (- px ship.x))
                                           (* (- py ship.y)
                                              (- py ship.y)))
                                     gf (* 0.05 (/ (* 9.8 (* p.size 10))
                                                  d2))
                                     ;; the force is applied from the ship to the planet
                                     fx (* (- px ship.x) gf)
                                     fy (* (- py ship.y) gf)]
                                 (tset f :x (+ f.x fx))
                                 (tset f :y (+ f.y fy))))

                             (tset ship :gfx f.x)
                             (tset ship :gfy f.y)))
 :create (fn [vx vy]
           {:current 0
            :total-time 0
            :total-run-time 0
            :x (- (love.graphics.getWidth)
                  50)
            :y (/ (love.graphics.getHeight) 2)
            :gfx 0 :gfy 0 ;; forces due to gravity
            :fx 0 :fy 0   ;; forces due to thrust
            :vx vx :vy vy
            :state :alive
            :explosion-frame 1
            :fall-target [0 0]
            :fall-start-time 0
            :trail []
            :last-trail-add-time 0})

 :fall-into-vortex (fn [ship vortex-location]
                     (print "falling!")
                     (set ship.state :falling)
                     (set ship.fall-start-time ship.total-run-time)
                     (set ship.fall-target vortex-location))

 :update-forces (fn [ship t]
                  ;; move ship based on its velocity
                  (when (= ship.state :alive)
                    (let [tfx (+ ship.gfx ship.fx)
                          tfy (+ ship.gfy ship.fy)]
                      (set ship.vx (+ ship.vx (* tfx t 10)))
                      (set ship.vy (+ ship.vy (* tfy t 10))))

                    ;; dampen the force
                    (set ship.fx (* ship.fx t 0.1))
                    (set ship.fy (* ship.fy t 0.1))

                    (set ship.x (+ ship.x (* ship.vx t 100)))
                    (set ship.y (+ ship.y (* ship.vy t 100)))))

 :update (fn [ship t]
           (set ship.total-run-time (+ ship.total-run-time t))
           (if
            (= ship.state :alive)
            (let [new-time (+ ship.total-time t)]
              (set ship.total-time (if (> new-time 1.6) 0 new-time))
              (set ship.current (if (> ship.total-time 1.5) 2 1))

              ;; ship is alive so progress 
              (when (> (- ship.total-run-time ship.last-trail-add-time) 0.2)
                (table.insert ship.trail ship.x)
                (table.insert ship.trail ship.y)
                (set ship.last-trail-add-time ship.total-run-time)))

            (= ship.state :exploding)
            (do
              (set ship.explosion-frame (+ ship.explosion-frame 1))
              (when (> ship.explosion-frame 64)
                (set ship.state :dead)))))

 :trigger-crash (fn [ship]
                  ;; stop moving, hide the ship and trigger ship explosion
                  ;;
                  (: explosion-sound :play)
                  (set ship.state :exploding))

 :draw (fn [ship]
         ;; draw the trail
         (when (>= (# ship.trail) 4)
           (love.graphics.setLineWidth 4)
           (love.graphics.setColor 200 200 200 200)
           (love.graphics.line ship.trail)
           ;; draw a connector to the ship
           (let [lp (lume.last ship.trail 2)]
             (love.graphics.line (. lp 1) (. lp 2)
                                 ship.x ship.y)))


         (if
          (= ship.state :alive)
          (do
            (love.graphics.setColor 255 255 255 255)
            (love.graphics.draw ship-texture
                                (. ship-quads ship.current)
                                ship.x ship.y
                                (+ (/ math.pi 2)
                                   (math.atan2 ship.vy ship.vx))
                                1 1 16 16))
          (= ship.state :falling)
          (let [f (- ship.total-run-time ship.fall-start-time)]
            (when (< f 1)
              (let [x (+ (* (- 1 f) ship.x)
                         (* f (. ship.fall-target 1)))
                    y (+ (* (- 1 f) ship.y)
                         (* f (. ship.fall-target 2)))]
                (love.graphics.setColor 255 255 255 255)
                (love.graphics.draw ship-texture
                                    (. ship-quads ship.current)
                                    x y (* f 5)
                                    (- 1 f)
                                    (- 1 f)
                                    16 16))))
          
          (= ship.state :exploding)
          (do
            (love.graphics.setColor 255 255 255 255)
            (love.graphics.draw explosion-texture
                                (. explosion-quads ship.explosion-frame)
                                ship.x ship.y
                                (+ (/ math.pi 2)
                                   (math.atan2 ship.vy ship.vx))
                                2 2 16 24))))}
