local function _0_(vortex)
  return ({center = ({x = vortex.x, y = vortex.y}), radius = vortex.radius})
end
local function _1_(x, y, radius)
  return ({index = 1, radius = radius, t = 0, tt = 0, x = x, y = y})
end
local function _2_(vortex)
  local circles = 10
  local function _3_()
    if (vortex.t) > (0.5) then
      return 1
    else
      return (circles - math.floor((2 * vortex.t * circles)))
    end
  end
  local gi = _3_()
  local lw = (vortex.radius / circles)
  for i = 1, circles do
    local function _4_()
      if (gi) == (i) then
        return 255
      else
        return 60
      end
    end
    love.graphics.setColor(255, (13 + (i * 20)), 255, _4_())
    love.graphics.setLineWidth(3)
    local function _5_()
      if (i) == (1) then
        return "fill"
      else
        return "line"
      end
    end
    love.graphics.circle(_5_(), vortex.x, vortex.y, (i * lw))
  end
  return nil
end
local function _3_(vortex, t)
  vortex.t = (vortex.t + t)
  if (vortex.t) > (1) then
    vortex.t = 0
    return nil
  end
end
return ({["center-and-radius"] = _0_, create = _1_, draw = _2_, update = _3_})
