;; starfield.fnl
;; render starfield
;;

(defn generate-random-star [max-x max-y]
  (let [star {}]
    (set star.x (math.random 2 (- max-x 2)))
    (set star.y (math.random 2 (- max-y 2)))
    (set star.pulser (* 0.5 (math.random)))
    (set star.intensity (math.random))
    (set star.idir (if (< (math.random) 0.5) -1 1)) ;; which direction is the intensity going
    (set star.maxsize (math.floor (* 6 (math.random))))
    star))

(fn create-star-field [max-x max-y]
  (let [stars {}]
    (for [i 1 200]
      (tset stars i (generate-random-star max-x max-y)))
    stars))


(defn render-star-field [stars]
  (each [k star (ipairs stars)]
    (let [hs (/ star.size 2)]
      (love.graphics.setColor 255 255 255 (* 255 star.intensity))
      (love.graphics.rectangle "fill" (- star.x hs) (- star.y hs)
                               star.size star.size))))

(defn animate-star-field [stars dt]
  (each [k star (ipairs stars)]
    (let [newi (+ star.intensity (* dt star.pulser star.idir))
          ;; adjust the new intensity dir if it needs to be
          newid (if (< newi 0) 1 (if (> newi 1) -1 star.idir))
          newi (if (< newi 0) 0 (if (> newi 1) 1 newi))
          news (* star.maxsize newi)]
      ;;(print newid newi news)
      (set star.idir newid)
      (set star.intensity newi)
      (set star.size news))))

{:create (fn []
           (create-star-field (love.graphics.getWidth)
                              (love.graphics.getHeight)))
 :update (fn [sf dt]
           (animate-star-field sf dt))
 :draw (fn [sf]
         (render-star-field sf))}
