(var main-font nil)
(var blinky-stars nil)
(var intro-music nil)

(var logo nil)

(local util (require "util"))

(defn generate-random-star [max-x max-y]
  (let [star {}]
    (set star.x (math.random 2 (- max-x 2)))
    (set star.y (math.random 2 (- max-y 2)))
    (set star.pulser (* 0.5 (math.random)))
    (set star.intensity (math.random))
    (set star.idir (if (< (math.random) 0.5) -1 1)) ;; which direction is the intensity going
    (set star.maxsize (math.floor (* 6 (math.random))))
    star))

(defn animate-star-field [dt]
  (each [k star (ipairs blinky-stars)]
    (let [newi (+ star.intensity (* dt star.pulser star.idir))
          ;; adjust the new intensity dir if it needs to be
          newid (if (< newi 0) 1 (if (> newi 1) -1 star.idir))
          newi (if (< newi 0) 0 (if (> newi 1) 1 newi))
          news (* star.maxsize newi)]
      ;;(print newid newi news)
      (set star.idir newid)
      (set star.intensity newi)
      (set star.size news))))

(defn render-star-field [stars]
  (each [k star (ipairs stars)]
    (let [hs (/ star.size 2)]
      (love.graphics.setColor 255 255 255 (* 255 star.intensity))
      (love.graphics.rectangle "fill" (- star.x hs) (- star.y hs)
                               star.size star.size))))

(fn create-star-field [max-x max-y]
  (let [stars {}]
    (for [i 1 200]
      (tset stars i (generate-random-star max-x max-y)))
    stars))

(fn love.load []
  (set blinky-stars (create-star-field 800 600))
  (set logo (love.graphics.newImage "assets/logo.png"))
  (set intro-music (love.audio.newSource "assets/intro.mp3"))

  (set main-font (love.graphics.newImageFont
                  "assets/font.png"
                  (.. " abcdefghijklmnopqrstuvwxyz"
                      "ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
                      "123456789.,!?-+/():;%&`'*#=[]\"")))
  
  )

(fn love.conf [t]
  (set t.window.title "Gravity - You think you know how to fall?"))

(defn center-text [s r]
  (let [w (/ (love.graphics.getWidth) 2)
        t (love.graphics.newText main-font s)
        x (math.floor (- w (/ (: t :getWidth) 2)))]
    (love.graphics.print s x r)))

(defn main-screen []
  (render-star-field blinky-stars)
  (love.graphics.draw logo
                      (/ (- (love.graphics.getWidth)
                            (: logo :getWidth))
                         2)
                      100)
  (love.graphics.setColor 255 0 0 200)
  (center-text "A mediocre space adventure" 180))


(var text-render-offset 600)
(var intro-text-opacity 255)

(defn offsetted-text [s offset color]
  (tset color 4 intro-text-opacity)
  (love.graphics.setColor (unpack color))
  (love.graphics.print s 20 (math.floor  (+ text-render-offset (* 20 offset)))))

(defn render-text []
  (let [s 0]
    (offsetted-text "Year: 3880 A.D. GAT, 34.33.090 STANDARD GALACTIC" s [0 255 0])

    (offsetted-text "Human reign on this galaxy is coming to an end." (+ s 2) [200 200 200])
    (offsetted-text "Uncontrolled greed has caused the already faltering galactic economy to collapse." (+ s 4) [200 200 200])
    (offsetted-text "The planetary systems are on their own." (+ s 5) [200 200 200])
    (offsetted-text "There's no SPOOKY-DORA plasma ion fuel left to power interplanetary" (+ s 7) [200 200 200])
    (offsetted-text "transport systems.  Lack of food and resources has caused unprecedented" (+ s 8) [200 200 200])
    (offsetted-text "civil unrest across planetary systems.  People are dying, there's" (+ s 9) [200 200 200])
    (offsetted-text "wide-spread looting." (+ s 10) [200 200 200])
    (offsetted-text "There's no law, no order." (+ s 11) [200 200 200])

    (offsetted-text "The only way to slow down the eventual demise of these systems is to" (+ s 13) [200 200 200])
    (offsetted-text "get transportation back up." (+ s 14) [200 200 200])

    (offsetted-text "There's no fuel to power transportation, but there's GRAVITY." (+ s 18) [200 200 200])

    (love.graphics.setColor 255 255 255 255)
    (love.graphics.draw logo
                        (/ (- (love.graphics.getWidth)
                              (: logo :getWidth))
                           2)
                        (math.floor (+ text-render-offset 600)))
    (center-text "An OK space adventure" (math.floor (+ text-render-offset 680)))))

(defn second-screen []
  (render-star-field blinky-stars)
  (render-text))

(var playing-intro-music? false)
(fn love.update [t]
  (animate-star-field t)
  (when (not playing-intro-music?)
    (: intro-music :play)
    (set playing-intro-music? true))

  (when (< text-render-offset -100)
    (let [new-op (math.max 0 (- intro-text-opacity (* 50 t)))]
      (set intro-text-opacity new-op)))
  
  (if (> text-render-offset -200)
      (set text-render-offset (- text-render-offset (* 20 t)))
      nil))

(fn love.draw []
  (love.graphics.setFont main-font)
  (second-screen))
