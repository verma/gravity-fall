(local util (require "util"))
(local lume (require "lume"))

(defn planet-location [r angle]
  {:x (- (love.graphics.getWidth) (* r (math.cos angle))) 
   :y (- (/ (love.graphics.getHeight) 2) (* r (math.sin angle)))})

(var planet-texture nil)
(var planet-quads [])
(var crate nil)

(var crate-pickup-sound nil)

(var tile-colors [[17 146 23]
                  [211 157 75]
                  [255 194 0]
                  [0 191 255]])
(defn planet-bounds [planet]
  (let [psize (* 16 planet.size)
        px (- planet.location.x psize)
        py (- planet.location.y psize)]
    [px py
     (+ planet.location.x psize)
     (+ planet.location.y psize)]))

(defn planet-center-and-radius [planet]
  (let [psize (* 16 planet.size)]
    {:center planet.location
     :radius psize}))

(defn resource-center-and-radius [planet resource]
  (let [psize (* 16 planet.size)
        angle (* 2 math.pi (/ resource 100))]
    {:center {:x (+ planet.location.x (* 1.4 psize (math.sin angle)))
              :y (+ planet.location.y (* 1.4 psize (math.cos angle)))}
     ;; give users a little bit of room for resource collection, even
     ;; if the ship a little bit away from the resource, let the user
     ;; collect it
     :radius 12}))

(defn planet-do-resource-collision [planet s]
  ;; determine location of each resource and check if we collided with any of them
  (let [colliding-resources (lume.filter planet.resources
                                        (fn [r]
                                          (let [lr (resource-center-and-radius planet r)]
                                            (when (util.sphere-collision lr s)
                                              r))))]
    (lume.first colliding-resources)))


(defn do-resource-collision [planet resource t]
  ;; remove the resource from the list of resources
  ;;
  (lume.remove planet.resources resource)
  (: crate-pickup-sound :play)
  (let [lr (resource-center-and-radius planet resource)]
    (table.insert planet.going-away-resources {:r resource
                                               :x lr.center.x
                                               :y lr.center.y
                                               :angle  (* 3 planet.pulse)
                                               :start-time t
                                               :opacity 1})))


(defn update-going-away-resources [planet total-time]
  (let [left-resources (lume.filter planet.going-away-resources
                                    (fn [r]
                                      (when (< total-time (+ 0.2 r.start-time))
                                        r)))]
    (each [k r (ipairs left-resources)]
      (set r.opacity (- 1 (/ (- total-time r.start-time) 0.2))))
    (set planet.going-away-resources left-resources)))

(defn render-going-away-resources [planet]
  (each [k r (ipairs planet.going-away-resources)]
    (let [scale (* 2 (- 1 r.opacity))]
      (print scale r.opacity)
      (love.graphics.setColor 255 255 255 (* 255 r.opacity))
      (love.graphics.draw crate r.x r.y
                          r.angle scale scale
                          16 16))))

{:load (fn []
         (set planet-texture (love.graphics.newImage "assets/planets.png"))

         (for [i 0 3]
           (tset planet-quads (+ i 1)
                 (love.graphics.newQuad (* 32 (math.floor (/ i 2)))
                                        (* 32 (% i 2))
                                        32 32
                                        (: planet-texture :getWidth)
                                        (: planet-texture :getHeight))))
         (set crate (love.graphics.newImage "assets/crate.png"))
         (set crate-pickup-sound (love.audio.newSource "assets/pop.wav" "static")))

 :create (fn [size r resources tile]
           {:size size :r r
            :angle 0
            :location (planet-location r 0)
            :orbit-opacity 0
            :highlighted false
            :tile tile
            :orig-resources (lume.clone resources)
            :resources (lume.clone resources)
            :going-away-resources []
            :pulse 0})

 :reset (fn [planet]
          (set planet.resources (lume.clone planet.orig-resources))
          (set planet.going-away-resources []))

 :bounds (fn [planet]
           (planet-bounds planet))

 :adjust-position (fn [planet dx dy]
                    (let [new-angle (+ planet.angle (* dy 0.01))
                          new-position (planet-location planet.r new-angle)]
                      ;; if this position makes the planet go out of bounds then we don't want
                      ;; it
                      (tset planet :angle new-angle)
                      (tset planet :location (planet-location planet.r planet.angle))))

 ;; the planet is being dragged so mark it as highlighted
 :mark-highlight (fn [planet]
                   (tset planet :highlighted true))

 ;; the planet is not active anymore
 :unmark-highlight (fn [planet]
                     (tset planet :highlighted false))

 :update (fn [planet t]
           ;; when the planet highlight changes we need to animate the opacity
           (tset planet :pulse (+ planet.pulse t))
           (let [new-f (if planet.highlighted 1 -1)
                 new-opacity (+ planet.orbit-opacity (* 1000 t new-f))]
             (tset planet :orbit-opacity (if planet.highlighted
                                             (math.min new-opacity 150)
                                             (math.max new-opacity 0)))
             (update-going-away-resources planet planet.pulse)))

 ;; did the planet collide with the given bounds
 :collide (fn [planet ship-center-and-radius]
            (let [s ship-center-and-radius
                  p (planet-center-and-radius planet)]
              ;; using the ship's actual radius is kind of annoying since
              ;; we want exciting fly-bys, so cutting down the radius is more
              ;; fun
              (set s.radius (/ s.radius 2))
              (if
               (util.sphere-collision p s)
               "full-collide"

               ;; if a full planet collision didn't happen, then may be there was a
               ;; resource collision?
               (let [resource (planet-do-resource-collision planet s)]
                 (when resource
                   (do-resource-collision planet resource planet.pulse))

                 (if resource
                     "resource-collide"
                     "no-collide")))))

 :draw (fn [planet]
         ;; draw the planet's orbit if the opacity is non-zero
         (when (> planet.orbit-opacity 0)
           (let [color (. tile-colors planet.tile)]
             (love.graphics.setColor (. color 1) (. color 2) (. color 3)
                                     planet.orbit-opacity))
           (love.graphics.setLineWidth 10)
           (love.graphics.setLineStyle "rough")
           (love.graphics.arc "line" "open"
                              (love.graphics.getWidth)
                              (/ (love.graphics.getHeight) 2)

                              planet.r
                              (- math.pi) math.pi 100))

         
         (let [psize (* 16 planet.size)
               px (- planet.location.x psize)
               py (- planet.location.y psize)]
           (love.graphics.setColor 255 255 255)
           (love.graphics.draw planet-texture (. planet-quads planet.tile)
                               px py 0 planet.size planet.size)

           (let [rf (+ 0.99 (* 0.01 (math.sin (* 5 planet.pulse))))]
             (each [k r (ipairs planet.resources)]
               (let [angle (* 2 math.pi (/ r 100))]
                 (love.graphics.draw crate
                                     (+ planet.location.x (* 1.4 rf psize (math.sin angle)))
                                     (+ planet.location.y (* 1.4 rf psize (math.cos angle)))
                                     (* 3 planet.pulse) 0.3 0.3
                                     16 16)))))
         (render-going-away-resources planet))}
