(var main-font nil)
(var blinky-stars nil)
(var intro-music nil)
(var logo nil)

(var inst-vortex nil)
(var active-level nil)
(var current-level 1)

(var showing-instructions? false)
(var ended? false)

(local util (require "util"))
(local starfield (require "starfield"))
(local level (require "level"))
(local vortext (require "vortex"))

(local levels
       [{:ship {:vx -1 :vy 0}
         :planets [{:size 2
                    :distance 300
                    :resources [0]
                    :tile 1}]
         :vortex {:x 400 :y 100 :radius 40}}

        {:ship {:vx -0.5 :vy 0.5}
         :planets [{:size 3
                    :distance 400
                    :resources [0]
                    :tile 1}]
         :vortex {:x 300 :y 200 :radius 30}}

        {:ship {:vx -0.5 :vy 0.5}
         :planets [{:size 3
                    :distance 400
                    :resources [0]
                    :tile 1}
                   {:size 2
                    :distance 300
                    :resources [0 10]
                    :tile 3}]
         :vortex {:x 300 :y 100 :radius 50}}

        {:ship {:vx -0.5 :vy 0.0}
         :planets [{:size 3
                    :distance 400
                    :resources [0]
                    :tile 1}
                   {:size 2
                    :distance 250
                    :resources [50]
                    :tile 3}
                   {:size 1
                    :distance 500
                    :resources [0]
                    :tile 2}]
         :vortex {:x 100 :y 300 :radius 50}}

        {:ship {:vx -0.5 :vy 0.0}
         :planets [{:size 3
                    :distance 400
                    :resources [0 50]
                    :tile 1}
                   {:size 2
                    :distance 500
                    :resources [25 75]
                    :tile 3}
                   {:size 1
                    :distance 600
                    :resources [0]
                    :tile 2}]
         :vortex {:x 600 :y 100 :radius 50}}])

(defn move-to-next-level []
  (set current-level (+ current-level 1))
  (if (> current-level 5)
      (set ended? true)
      (set active-level (level.create (. levels current-level)))))

(defn replay-level []
  (set active-level (level.create (. levels current-level))))

(defn start-game []
  (set active-level (level.create (. levels current-level))))

(fn love.load []
  (love.graphics.setDefaultFilter "nearest" "nearest")
  (set blinky-stars (starfield.create))

  (math.randomseed (os.time))

  ;; pre-load resources for level set
  (level.load move-to-next-level replay-level)

  (set inst-vortex (vortext.create (/ (love.graphics.getWidth) 2)
                                   130
                                   40))

  ;; intro stuff
  (set logo (love.graphics.newImage "assets/logo.png"))
  (set intro-music (love.audio.newSource "assets/intro.mp3"))
  (: intro-music :setVolume 0.3)
  (: intro-music :setLooping true)
  (set main-font (love.graphics.newImageFont
                  "assets/font.png"
                  (.. " abcdefghijklmnopqrstuvwxyz"
                      "ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
                      "123456789.,!?-+/():;%&`'*#=[]\""))))

(defn center-text [s r]
  (let [w (/ (love.graphics.getWidth) 2)
        t (love.graphics.newText main-font s)
        x (math.floor (- w (/ (: t :getWidth) 2)))]
    (love.graphics.print s x r)))

(defn main-screen []
  (starfield.draw blinky-stars)
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

    (love.graphics.setColor 255 13 255 255)
    (love.graphics.draw logo
                        (/ (- (love.graphics.getWidth)
                              (: logo :getWidth))
                           2)
                        (math.floor (+ text-render-offset 600)))
    (center-text "An OK space adventure" (math.floor (+ text-render-offset 680)))

    (love.graphics.setColor 255 255 255 255)
    (center-text "Press the SPACE key to continue." (math.floor (+ text-render-offset 700)))))

(defn second-screen []
  (starfield.draw blinky-stars)
  (render-text))

(var playing-intro-music? false)
(fn second-screen-update [t]
  (starfield.update blinky-stars t)
  (when (not playing-intro-music?)
    (: intro-music :play)
    (set playing-intro-music? true))

  (when (< text-render-offset -100)
    (let [new-op (math.max 0 (- intro-text-opacity (* 50 t)))]
      (set intro-text-opacity new-op)))
  
  (if (> text-render-offset -200)
      (set text-render-offset (- text-render-offset (* 20 t)))
      nil)

  )

(defn game-screen-update [t]
  (starfield.update blinky-stars t)
  (level.update active-level t))

(fn game-screen []
  (starfield.draw blinky-stars)
  (love.graphics.setColor 255 255 255 255)
  (level.draw active-level))

(defn instructions-screen-update [t]
  (starfield.update blinky-stars t)
  (vortext.update inst-vortex t))

(defn instructions-screen []
  (starfield.draw blinky-stars)
  (love.graphics.setColor 255 255 255 255)
  (center-text "GOAL: Pick up as many planetary resources as possible and reach the" 50)

  (vortext.draw inst-vortex)
  (love.graphics.setColor 255 13 255 255)
  (center-text "The N.E.O.N. Vortex" 180)
  (love.graphics.setColor 128 255 128 255)
  (center-text "Planetary resources hover around the planets." 205)

  (love.graphics.setColor 255 255 255 255)
  (center-text "          SPACE : Launch Spacecraft               " 230)
  (center-text "              S : Adjust Speed up                 ", 245)
  (center-text "          MOUSE : Adjust planet's orbital position", 260)

  (center-text "Launch vector and thrust cannot be configured, we try to make" 290)
  (center-text "do with whatever propulsion resources we have." 305)
  (center-text "Needless to say, don't run into planets." 340)

  (center-text "When ready, press the SPACE key." 380))

(defn thanks-screen []
  (love.graphics.setColor 255 255 255 255)
  (center-text "Thanks for playing!" 20)
  (center-text "Attributions" 60)
  (center-text "----------------------" 75)
  (center-text "Planets textures: Rawdanitsu @ OpenGameArt" 95)
  (center-text "Explosion: StumpyStrust @ OpenGameArt" 110)
  (center-text "Explosion Sound: NenadSimic @ OpenGameArt" 125)
  (center-text "Resource Pop: farfadet46 @ OpenGameArt" 140)
  (center-text "Gameplay Music: Alone by Sudocolon @ OpenGameArt" 155)
  (center-text "Victory Music: Axton Crolly @ OpenGameArt" 170)
  (center-text "Crate Image: Bluerobin2 @ OpenGameArt" 185))


(fn love.update [t]
  (if
   active-level
   (game-screen-update t)

   showing-instructions?
   (instructions-screen-update t)

   (second-screen-update t)))


(fn love.draw []
  (love.graphics.setFont main-font)
  (if
   ended?
   (thanks-screen)

   active-level
   (game-screen)

   showing-instructions?
   (instructions-screen)
   
   (second-screen)))

(fn love.keypressed [key unicode]
  (print (math.floor text-render-offset))
  (if
   active-level
   (level.keypressed active-level key unicode)

   (and showing-instructions?
        (= key "space"))
   (start-game)

   (and (not showing-instructions?)
        (= key "space")
        (<= (math.floor text-render-offset) -200))
   (do
     (set showing-instructions? true)
     (: intro-music :stop))

   (= key "space")
   (do
     (set intro-text-opacity 0)
     (set text-render-offset -200))))
