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
      return love.graphics.print(string.format("CRASHED! Time: %3.2fs", level.duration), 10, 10)
    else
      love.graphics.setColor(255, 13, 255, 255)
      return love.graphics.print("You Win!")
    end
  end
  _1_()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.printf(string.format("SURVIVAL SCORE: %08d", level["survival-score-offered"]), (love.graphics.getWidth() - 250), 10, 230, "right")
  love.graphics.printf(string.format("RESOURCE SCORE: %08d", level["resource-score"]), (love.graphics.getWidth() - 250), 25, 230, "right")
  love.graphics.printf(string.format("SCORE: %08d", (level["resource-score"] + level["survival-score-offered"])), (love.graphics.getWidth() - 250), 40, 230, "right")
  if (level.state) == ("in-flight") then
    return love.graphics.print(string.format("SPACE : RESET     S : SPEED UP (%dx)", level["speed-up"]), 10, (love.graphics.getHeight() - 30))
  elseif (level.state) == ("crashed") then
    return love.graphics.print("SPACE : RESTART", 10, (love.graphics.getHeight() - 30))
  end
end
local function _1_(level)
end
return ({draw = _0_, update = _1_})
