local lume = require("lume")
local ship_texture = nil
local ship_quads = nil
local explosion_texture = nil
local explosion_quads = nil
local explosion_sound = nil
local function _0_(ship, planets)
  local f = ({x = 0, y = 0})
  for k, p in ipairs(planets) do
    local px = p.location.x
    local py = p.location.y
    local d2 = (((px - ship.x) * (px - ship.x)) + ((py - ship.y) * (py - ship.y)))
    local gf = (0.050000000000000003 * ((9.8000000000000007 * (p.size * 10)) / d2))
    local fx = ((px - ship.x) * gf)
    local fy = ((py - ship.y) * gf)
    f["x"] = (f.x + fx)
    f["y"] = (f.y + fy)
  end
  ship["gfx"] = f.x
  ship["gfy"] = f.y
  return nil
end
local function _1_(ship)
  return ({center = ({x = ship.x, y = ship.y}), radius = 16})
end
local function _2_(ship, vortex_location)
  print("falling!")
  ship.state = "falling"
  ship["fall-start-time"] = ship["total-run-time"]
  ship["fall-target"] = vortex_location
  return nil
end
local function _3_(ship)
  explosion_sound:play()
  ship.state = "exploding"
  return nil
end
local function _4_(ship, t)
  if (ship.state) == ("alive") then
    do
      local tfx = (ship.gfx + ship.fx)
      local tfy = (ship.gfy + ship.fy)
      ship.vx = (ship.vx + (tfx * t * 10))
      ship.vy = (ship.vy + (tfy * t * 10))
    end
    ship.fx = (ship.fx * t * 0.10000000000000001)
    ship.fy = (ship.fy * t * 0.10000000000000001)
    ship.x = (ship.x + (ship.vx * t * 100))
    ship.y = (ship.y + (ship.vy * t * 100))
    return nil
  end
end
local function _5_(ship)
  return ({(ship.x - 16), (ship.y - 16), (ship.x + 16), (ship.y + 16)})
end
local function _6_(vx, vy)
  return ({["explosion-frame"] = 1, ["fall-start-time"] = 0, ["fall-target"] = ({0, 0}), ["last-trail-add-time"] = 0, ["total-run-time"] = 0, ["total-time"] = 0, current = 0, fx = 0, fy = 0, gfx = 0, gfy = 0, state = "alive", trail = ({}), vx = vx, vy = vy, x = (love.graphics.getWidth() - 50), y = (love.graphics.getHeight() / 2)})
end
local function _7_(ship)
  local function _8_()
    if (#ship.trail) >= (4) then
      love.graphics.setLineWidth(4)
      love.graphics.setColor(200, 200, 200, 200)
      love.graphics.line(ship.trail)
      do
        local lp = lume.last(ship.trail, 2)
        return love.graphics.line(lp[1], lp[2], ship.x, ship.y)
      end
    end
  end
  _8_()
  if (ship.state) == ("alive") then
    love.graphics.setColor(255, 255, 255, 255)
    return love.graphics.draw(ship_texture, ship_quads[ship.current], ship.x, ship.y, ((math.pi / 2) + math.atan2(ship.vy, ship.vx)), 1, 1, 16, 16)
  elseif (ship.state) == ("falling") then
    local f = (ship["total-run-time"] - ship["fall-start-time"])
    if (f) < (1) then
      local x = (((1 - f) * ship.x) + (f * ship["fall-target"][1]))
      local y = (((1 - f) * ship.y) + (f * ship["fall-target"][2]))
      love.graphics.setColor(255, 255, 255, 255)
      return love.graphics.draw(ship_texture, ship_quads[ship.current], x, y, (f * 15), (1 - f), (1 - f), 16, 16)
    end
  elseif (ship.state) == ("exploding") then
    love.graphics.setColor(255, 255, 255, 255)
    return love.graphics.draw(explosion_texture, explosion_quads[ship["explosion-frame"]], ship.x, ship.y, ((math.pi / 2) + math.atan2(ship.vy, ship.vx)), 2, 2, 16, 24)
  end
end
local function _8_()
  ship_texture = love.graphics.newImage("assets/ship.png")
  local function _9_()
    local a = love.graphics.newQuad(0, 0, 32, 32, ship_texture:getWidth(), ship_texture:getHeight())
    local b = love.graphics.newQuad(32, 0, 32, 32, ship_texture:getWidth(), ship_texture:getHeight())
    return ({a, b})
  end
  ship_quads = _9_()
  explosion_texture = love.graphics.newImage("assets/boom.png")
  explosion_quads = ({})
  for i = 0, 63 do
    local x = (i % 8)
    local y = math.floor((i / 8))
    explosion_quads[(i + 1)] = love.graphics.newQuad((32 * x), (32 * y), 32, 32, explosion_texture:getWidth(), explosion_texture:getHeight())
  end
  explosion_sound = love.audio.newSource("assets/explode.wav", "static")
  return nil
end
local function _9_(ship, t)
  ship["total-run-time"] = (ship["total-run-time"] + t)
  if (ship.state) == ("alive") then
    local new_time = (ship["total-time"] + t)
    local function _10_()
      if (new_time) > (1.6000000000000001) then
        return 0
      else
        return new_time
      end
    end
    ship["total-time"] = _10_()
    local function _11_()
      if (ship["total-time"]) > (1.5) then
        return 2
      else
        return 1
      end
    end
    ship.current = _11_()
    if ((ship["total-run-time"] - ship["last-trail-add-time"])) > (0.20000000000000001) then
      table.insert(ship.trail, ship.x)
      table.insert(ship.trail, ship.y)
      ship["last-trail-add-time"] = ship["total-run-time"]
      return nil
    end
  elseif (ship.state) == ("exploding") then
    ship["explosion-frame"] = (ship["explosion-frame"] + 1)
    if (ship["explosion-frame"]) > (64) then
      ship.state = "dead"
      return nil
    end
  end
end
return ({["apply-planetary-forces"] = _0_, ["center-and-radius"] = _1_, ["fall-into-vortex"] = _2_, ["trigger-crash"] = _3_, ["update-forces"] = _4_, bounds = _5_, create = _6_, draw = _7_, load = _8_, update = _9_})
