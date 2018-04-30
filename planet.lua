local util = require("util")
local lume = require("lume")
local function _0_(r, angle)
  return ({x = (love.graphics.getWidth() - (r * math.cos(angle))), y = ((love.graphics.getHeight() / 2) - (r * math.sin(angle)))})
end
local planet_location = _0_
local planet_texture = nil
local planet_quads = ({})
local crate = nil
local crate_pickup_sound = nil
local tile_colors = ({({17, 146, 23}), ({211, 157, 75}), ({255, 194, 0}), ({0, 191, 255})})
local function _1_(planet)
  local psize = (16 * planet.size)
  local px = (planet.location.x - psize)
  local py = (planet.location.y - psize)
  return ({px, py, (planet.location.x + psize), (planet.location.y + psize)})
end
local planet_bounds = _1_
local function _2_(planet)
  local psize = (16 * planet.size)
  return ({center = planet.location, radius = psize})
end
local planet_center_and_radius = _2_
local function _3_(planet, resource)
  local psize = (16 * planet.size)
  local angle = (2 * math.pi * (resource / 100))
  return ({center = ({x = (planet.location.x + (1.3999999999999999 * psize * math.sin(angle))), y = (planet.location.y + (1.3999999999999999 * psize * math.cos(angle)))}), radius = 12})
end
local resource_center_and_radius = _3_
local function _4_(planet, s)
  local function _5_(r)
    local lr = resource_center_and_radius(planet, r)
    if util["sphere-collision"](lr, s) then
      return r
    end
  end
  local colliding_resources = lume.filter(planet.resources, _5_)
  return lume.first(colliding_resources)
end
local planet_do_resource_collision = _4_
local function _5_(planet, resource, t)
  lume.remove(planet.resources, resource)
  crate_pickup_sound:play()
  do
    local lr = resource_center_and_radius(planet, resource)
    return table.insert(planet["going-away-resources"], ({["start-time"] = t, angle = (3 * planet.pulse), opacity = 1, r = resource, x = lr.center.x, y = lr.center.y}))
  end
end
local do_resource_collision = _5_
local function _6_(planet, total_time)
  local function _7_(r)
    if (total_time) < ((0.20000000000000001 + r["start-time"])) then
      return r
    end
  end
  local left_resources = lume.filter(planet["going-away-resources"], _7_)
  for k, r in ipairs(left_resources) do
    r.opacity = (1 - ((total_time - r["start-time"]) / 0.20000000000000001))
  end
  planet["going-away-resources"] = left_resources
  return nil
end
local update_going_away_resources = _6_
local function _7_(planet)
  for k, r in ipairs(planet["going-away-resources"]) do
    local scale = (2 * (1 - r.opacity))
    print(scale, r.opacity)
    love.graphics.setColor(255, 255, 255, (255 * r.opacity))
    love.graphics.draw(crate, r.x, r.y, r.angle, scale, scale, 16, 16)
  end
  return nil
end
local render_going_away_resources = _7_
local function _8_(planet, dx, dy)
  local new_angle = (planet.angle + (dy * 0.01))
  local new_position = planet_location(planet.r, new_angle)
  planet["angle"] = new_angle
  planet["location"] = planet_location(planet.r, planet.angle)
  return nil
end
local function _9_(planet)
  planet["highlighted"] = true
  return nil
end
local function _10_(planet)
  planet["highlighted"] = false
  return nil
end
local function _11_(planet)
  return planet_bounds(planet)
end
local function _12_(planet, ship_center_and_radius)
  local s = ship_center_and_radius
  local p = planet_center_and_radius(planet)
  s.radius = (s.radius / 2)
  if util["sphere-collision"](p, s) then
    return "full-collide"
  else
    local resource = planet_do_resource_collision(planet, s)
    local function _13_()
      if resource then
        return do_resource_collision(planet, resource, planet.pulse)
      end
    end
    _13_()
    if resource then
      return "resource-collide"
    else
      return "no-collide"
    end
  end
end
local function _13_(size, r, resources, tile)
  return ({["going-away-resources"] = ({}), ["orbit-opacity"] = 0, ["orig-resources"] = lume.clone(resources), angle = 0, highlighted = false, location = planet_location(r, 0), pulse = 0, r = r, resources = lume.clone(resources), size = size, tile = tile})
end
local function _14_(planet)
  local function _15_()
    if (planet["orbit-opacity"]) > (0) then
      do
        local color = tile_colors[planet.tile]
        love.graphics.setColor(color[1], color[2], color[3], planet["orbit-opacity"])
      end
      love.graphics.setLineWidth(10)
      love.graphics.setLineStyle("rough")
      return love.graphics.arc("line", "open", love.graphics.getWidth(), (love.graphics.getHeight() / 2), planet.r, ( - math.pi), math.pi, 100)
    end
  end
  _15_()
  do
    local psize = (16 * planet.size)
    local px = (planet.location.x - psize)
    local py = (planet.location.y - psize)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(planet_texture, planet_quads[planet.tile], px, py, 0, planet.size, planet.size)
    do
      local rf = (0.98999999999999999 + (0.01 * math.sin((5 * planet.pulse))))
      for k, r in ipairs(planet.resources) do
        local angle = (2 * math.pi * (r / 100))
        love.graphics.draw(crate, (planet.location.x + (1.3999999999999999 * rf * psize * math.sin(angle))), (planet.location.y + (1.3999999999999999 * rf * psize * math.cos(angle))), (3 * planet.pulse), 0.29999999999999999, 0.29999999999999999, 16, 16)
      end
    end
  end
  return render_going_away_resources(planet)
end
local function _15_()
  planet_texture = love.graphics.newImage("assets/planets.png")
  for i = 0, 3 do
    planet_quads[(i + 1)] = love.graphics.newQuad((32 * math.floor((i / 2))), (32 * (i % 2)), 32, 32, planet_texture:getWidth(), planet_texture:getHeight())
  end
  crate = love.graphics.newImage("assets/crate.png")
  crate_pickup_sound = love.audio.newSource("assets/pop.wav", "static")
  return nil
end
local function _16_(planet)
  planet.resources = lume.clone(planet["orig-resources"])
  planet["going-away-resources"] = ({})
  return nil
end
local function _17_(planet, t)
  planet["pulse"] = (planet.pulse + t)
  do
    local function _18_()
      if planet.highlighted then
        return 1
      else
        return -1
      end
    end
    local new_f = _18_()
    local new_opacity = (planet["orbit-opacity"] + (1000 * t * new_f))
    local function _19_()
      if planet.highlighted then
        return math.min(new_opacity, 150)
      else
        return math.max(new_opacity, 0)
      end
    end
    planet["orbit-opacity"] = _19_()
    return update_going_away_resources(planet, planet.pulse)
  end
end
return ({["adjust-position"] = _8_, ["mark-highlight"] = _9_, ["unmark-highlight"] = _10_, bounds = _11_, collide = _12_, create = _13_, draw = _14_, load = _15_, reset = _16_, update = _17_})
