(local hud (require "hud"))
(local ship (require "ship"))
(local planet (require "planet"))
(local vortex (require "vortex"))

(local lume (require "lume"))
(local util (require "util"))

(var tracking-info nil)
(var bg-music nil)
(var victory-music nil)

(var level-switcher nil)
(var level-replay nil)

(defn find-mouse-intersect-planet [planets]
  (let [x (love.mouse.getX)
        y (love.mouse.getY)]
    (lume.first
     (lume.filter planets
                  (fn [p]
                    (let [[x1 y1 x2 y2] (planet.bounds p)]
                      (when (and (<= x1 x x2)
                                 (<= y1 y y2))
                        p)))))))

(defn launch-level [level]
  (set level.state :in-flight))

(defn reset-level [level]
  (set level.state :awaiting-launch)
  (set level.duration 0)
  (set level.ship (ship.create level.level-info.ship.vx
                               level.level-info.ship.vy))
  (set level.resource-score 0)
  (set level.survival-score-offered 0)
  (each [k p (ipairs level.planets)]
    (planet.reset p)))

(defn trigger-game-over [level]
  ;; when game is over due to crash, first the game state goes to
  ;; :crash, we need to tell the ship that it needs to animate to crash
  (set level.state :crashed)
  (ship.trigger-crash level.ship))

(defn finish-level [level]
  (ship.fall-into-vortex level.ship
                         [level.level-info.vortex.x
                          level.level-info.vortex.y])
  (set level.state :complete))

{:load (fn [switcher replay]
         (planet.load)
         (ship.load)
         (hud.load)

         (set level-switcher switcher)
         (set level-replay replay)

         (set bg-music (love.audio.newSource "assets/alone.mp3"))
         (: bg-music :setLooping true)

         (set victory-music (love.audio.newSource "assets/victory.mp3"))
         (: victory-music :setVolume 0.3))

 :create (fn [level-info]
           (let [planets []]
             (each [k p (ipairs level-info.planets)]
               (table.insert planets
                             (planet.create p.size
                                            p.distance
                                            p.resources
                                            p.tile)))
             (util.pp planets)
             {:ship (ship.create level-info.ship.vx level-info.ship.vy)
              :duration 0
              :level-info level-info
              :state :awaiting-launch
              :speed-up 1
              :resource-score 0
              :survival-score-offered 0
              :planets planets
              :vortex (vortex.create level-info.vortex.x
                                     level-info.vortex.y
                                     level-info.vortex.radius)}))
 :keypressed (fn [level key unicode]
               (if
                (= key "s")
                (let [new-s (+ level.speed-up 1)]
                  (set level.speed-up
                       (if (> new-s 4) 1 new-s)))

                (and (= key "space")
                     (= level.state :awaiting-launch))
                (launch-level level)

                (and (= key "space")
                     (= level.state :in-flight))
                (reset-level level)

                (and (= key "space")
                     (= level.state :in-flight))
                (reset-level level)

                (and (= key "space")
                     (= level.state :crashed))
                (reset-level level)

                (and (= key "space")
                     (= level.state :complete))
                (level-switcher)

                (and (= key "r")
                     (= level.state :complete))
                (level-replay)))
 
 :update (fn [level tt]
           ;; play music if we are not paying
           (when (and (not (: bg-music :isPlaying))
                      (= level.state :awaiting-launch))
             (: victory-music :stop)
             (: bg-music :play))

           ;; stop music when complete
           (when (and (: bg-music :isPlaying)
                      (= level.state :complete))
             (: victory-music :play)
             (: bg-music :stop))

           (let [t (* tt level.speed-up)]
             ;; when we're inflight update the duration
             (when (= level.state :in-flight)
               ;; survival score
               (set level.survival-score-offered
                    (math.min
                     10000
                     (+ level.survival-score-offered (math.floor (* tt 1000)))))
               
               (set level.duration (+ level.duration tt))

               ;; apply any forces due to gravity on the ship
               (ship.apply-planetary-forces level.ship level.planets)
               (ship.update-forces level.ship t))

             ;; when we're awaiting launch, allow players to adjust orbital positions
             (when (= level.state :awaiting-launch)
               ;; if mouse is down on one of our planets then we need to track the mouse
               ;; movement to allow the planet to move
               ;;
               (if (love.mouse.isDown 1)
                   (when (not tracking-info)
                     (let [p (find-mouse-intersect-planet level.planets)]
                       (when p
                         (print "found planet:" p)
                         (love.mouse.setGrabbed true)
                         (planet.mark-highlight p)
                         (set tracking-info {:planet p
                                             :x (love.mouse.getX)
                                             :y (love.mouse.getY)}))))
                   (when tracking-info
                     (love.mouse.setGrabbed false)
                     (planet.unmark-highlight tracking-info.planet)
                     (set tracking-info nil)))

               ;; when the mouse is being tracked, we need to know how much the mouse is moving
               ;; so we can pass that info down to our planets
               (when tracking-info
                 (let [mx (love.mouse.getX)
                       my (love.mouse.getY)
                       dx (- tracking-info.x mx)
                       dy (- tracking-info.y my)]
                   (planet.adjust-position tracking-info.planet dx dy)
                   (tset tracking-info :x mx)
                   (tset tracking-info :y my))))

             ;; update each planet and the ship
             (each [k p (ipairs level.planets)]
               (planet.update p t))
             (ship.update level.ship t)
             (vortex.update level.vortex t))

           ;; check for collisions
           ;; did we reach the end by hitting the vortex
           (let [vortex-bounds (vortex.center-and-radius level.vortex)
                 ship-bounds (ship.center-and-radius level.ship)]
             (when (and (util.sphere-collision vortex-bounds ship-bounds)
                        (= level.state :in-flight))
               ;; we reached the vortex
               (finish-level level)))

           ;; check the ship bounds against bounds of each planet, each planet may report that some
           ;; of the resources where collided against or a full collision happened
           (let [ship-center-and-radius (ship.center-and-radius level.ship)
                 coll-status (lume.map level.planets
                                       (fn [p]
                                         (planet.collide p ship-center-and-radius)))
                 full-collide? (lume.first (lume.filter coll-status
                                                        (fn [s] (= s "full-collide"))))
                 resource-collides (# (lume.filter coll-status
                                                   (fn [s] (= s "resource-collide"))))]
             ;; if there's a resource collision add score
             (set level.resource-score
                  (+ level.resource-score (* 50000 resource-collides)))
             
             (when (and (= level.state :in-flight)
                        full-collide?)
               (trigger-game-over level))))

 :reset (fn [level]
          (reset-level level))
 
 :draw (fn [level]
         (each [k p (ipairs level.planets)]
           (planet.draw p))
         (ship.draw level.ship)
         (vortex.draw level.vortex)
         (hud.draw level))}
