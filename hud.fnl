{:update (fn [level])
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
            (love.graphics.print (string.format "CRASHED! Time: %3.2fs"
                                                level.duration)
                                 10 10))

          (do
            (love.graphics.setColor 255 13 255 255)
            (love.graphics.print "You Win!")))
         
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
         (if
          (= level.state :in-flight)
          (love.graphics.print (string.format
                                "SPACE : RESET     S : SPEED UP (%dx)"
                                level.speed-up)
                               10 (- (love.graphics.getHeight) 30))

          (= level.state :crashed)
          (love.graphics.print "SPACE : RESTART"
                               10 (- (love.graphics.getHeight) 30))))}
