(var crashed-image nil)
(var victory-image nil)


{:load (fn []
         (set crashed-image
              (love.graphics.newImage "assets/crashed.png"))
         (set victory-image
              (love.graphics.newImage "assets/victory.png")))
 
 :update (fn [level])
 :draw (fn [level]
         (if
          (= level.state :in-flight)
          (do
            (love.graphics.setColor 255 255 0 255)
            (love.graphics.print (string.format "IN-FLIGHT : %3.2fs" level.duration) 10 10))

          (= level.state :awaiting-launch)
          (do
            (love.graphics.setColor 0 255 0 255)
            (love.graphics.print "AWAITING LAUNCH : PRESS SPACE TO LAUNCH" 10 10)
            (love.graphics.print "CLICK AND DRAG PLANETS TO ADJUST POSITION" 10 25))

          (= level.state :crashed)
          (do
            (love.graphics.setColor 255 0 0 255)
            (love.graphics.print (string.format "Time: %3.2fs"
                                                level.duration)
                                 10 10)
            (love.graphics.draw crashed-image
                                (/ (- (love.graphics.getWidth)
                                      (: crashed-image :getWidth))
                                   2)
                                (/ (- (love.graphics.getHeight)
                                      (: crashed-image :getHeight))
                                   2)))

          (do
            (love.graphics.setColor 255 255 255 255)
            (love.graphics.draw victory-image
                                (/ (- (love.graphics.getWidth)
                                      (: victory-image :getWidth))
                                   2)
                                (/ (- (love.graphics.getHeight)
                                      (: victory-image :getHeight))
                                   2))
            (when (= level.resource-score 0)
              (love.graphics.print "Try and pick some resources next time, I mean, that's your mission."
                                   118 400))))
         
         (love.graphics.setColor 255 255 255 255)
         (love.graphics.printf (string.format "SURVIVAL SCORE: %08d"
                                              level.survival-score-offered)
                               (- (love.graphics.getWidth) 250)
                               10
                               230
                               "right")
         (love.graphics.printf (string.format "RESOURCE SCORE: %08d"
                                              level.resource-score)
                               (- (love.graphics.getWidth) 250)
                               25
                               230 "right")
         (love.graphics.printf (string.format "SCORE: %08d"
                                              (+ level.resource-score
                                                 level.survival-score-offered))
                               (- (love.graphics.getWidth) 250) 40
                               230 "right")
         (love.graphics.setColor 255 255 0 255)
         (if
          (= level.state :in-flight)
          (love.graphics.print (string.format
                                "SPACE : RESET     S : SPEED UP (%dx)"
                                level.speed-up)
                               10 (- (love.graphics.getHeight) 30))

          (= level.state :complete)
          (love.graphics.print "SPACE : NEXT MISSION         R : RETRY"
                               10 (- (love.graphics.getHeight) 30))


          (= level.state :crashed)
          (love.graphics.print "SPACE : RESTART"
                               10 (- (love.graphics.getHeight) 30))))}
