local crashed_image = nil
local victory_image = nil
local function _0_(level)
  local function _1_()
    if (level.state) == ("in-flight") then
      love.graphics.setColor(255, 255, 0, 255)
      return love.graphics.print(string.format("IN-FLIGHT : %3.2fs", level.duration), 10, 10)
    elseif (level.state) == ("awaiting-launch") then
      love.graphics.setColor(0, 255, 0, 255)
      love.graphics.print("AWAITING LAUNCH : PRESS SPACE TO LAUNCH", 10, 10)
      return love.graphics.print("CLICK AND DRAG PLANETS TO ADJUST POSITION", 10, 25)
    elseif (level.state) == ("crashed") then
      love.graphics.setColor(255, 0, 0, 255)
      love.graphics.print(string.format("Time: %3.2fs", level.duration), 10, 10)
      return love.graphics.draw(crashed_image, ((love.graphics.getWidth() - crashed_image:getWidth()) / 2), ((love.graphics.getHeight() - crashed_image:getHeight()) / 2))
    else
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.draw(victory_image, ((love.graphics.getWidth() - victory_image:getWidth()) / 2), ((love.graphics.getHeight() - victory_image:getHeight()) / 2))
      if (level["resource-score"]) == (0) then
        return love.graphics.print("Try and pick some resources next time, I mean, that's your mission.", 118, 400)
      end
    end
  end
  _1_()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.printf(string.format("SURVIVAL SCORE: %08d", level["survival-score-offered"]), (love.graphics.getWidth() - 250), 10, 230, "right")
  love.graphics.printf(string.format("RESOURCE SCORE: %08d", level["resource-score"]), (love.graphics.getWidth() - 250), 25, 230, "right")
  love.graphics.printf(string.format("SCORE: %08d", (level["resource-score"] + level["survival-score-offered"])), (love.graphics.getWidth() - 250), 40, 230, "right")
  love.graphics.setColor(255, 255, 0, 255)
  if (level.state) == ("in-flight") then
    return love.graphics.print(string.format("SPACE : RESET     S : SPEED UP (%dx)", level["speed-up"]), 10, (love.graphics.getHeight() - 30))
  elseif (level.state) == ("complete") then
    return love.graphics.print("SPACE : NEXT MISSION         R : RETRY", 10, (love.graphics.getHeight() - 30))
  elseif (level.state) == ("crashed") then
    return love.graphics.print("SPACE : RESTART", 10, (love.graphics.getHeight() - 30))
  end
end
local function _1_()
  crashed_image = love.graphics.newImage("assets/crashed.png")
  victory_image = love.graphics.newImage("assets/victory.png")
  return nil
end
local function _2_(level)
end
return ({draw = _0_, load = _1_, update = _2_})
