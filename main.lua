local main_font = nil
local blinky_stars = nil
local intro_music = nil
local logo = nil
local active_level = nil
local util = require("util")
local starfield = require("starfield")
local level = require("level")
local levels = ({({planets = ({({distance = 300, resources = ({0}), size = 2, tile = 1})}), ship = ({vx = -1, vy = 0}), vortex = ({radius = 40, x = 400, y = 100})})})
love.load = function()
  love.graphics.setDefaultFilter("nearest", "nearest")
  blinky_stars = starfield.create()
  math.randomseed(os.time())
  level.load()
  active_level = level.create(levels[1])
  logo = love.graphics.newImage("assets/logo.png")
  intro_music = love.audio.newSource("assets/intro.mp3")
  main_font = love.graphics.newImageFont("assets/font.png", (" abcdefghijklmnopqrstuvwxyz" .. "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" .. "123456789.,!?-+/():;%&`'*#=[]\""))
  return nil
end
do local _ = love.load end
love.conf = function(t)
  t.window.title = "Gravity : Fall"
  return nil
end
do local _ = love.conf end
local function _0_(s, r)
  local w = (love.graphics.getWidth() / 2)
  local t = love.graphics.newText(main_font, s)
  local x = math.floor((w - (t:getWidth() / 2)))
  return love.graphics.print(s, x, r)
end
local center_text = _0_
local function _1_()
  starfield.draw(blinky_stars)
  love.graphics.draw(logo, ((love.graphics.getWidth() - logo:getWidth()) / 2), 100)
  love.graphics.setColor(255, 0, 0, 200)
  return center_text("A mediocre space adventure", 180)
end
local main_screen = _1_
local text_render_offset = 600
local intro_text_opacity = 255
local function _2_(s, offset, color)
  color[4] = intro_text_opacity
  love.graphics.setColor(unpack(color))
  return love.graphics.print(s, 20, math.floor((text_render_offset + (20 * offset))))
end
local offsetted_text = _2_
local function _3_()
  local s = 0
  offsetted_text("Year: 3880 A.D. GAT, 34.33.090 STANDARD GALACTIC", s, ({0, 255, 0}))
  offsetted_text("Human reign on this galaxy is coming to an end.", (s + 2), ({200, 200, 200}))
  offsetted_text("Uncontrolled greed has caused the already faltering galactic economy to collapse.", (s + 4), ({200, 200, 200}))
  offsetted_text("The planetary systems are on their own.", (s + 5), ({200, 200, 200}))
  offsetted_text("There's no SPOOKY-DORA plasma ion fuel left to power interplanetary", (s + 7), ({200, 200, 200}))
  offsetted_text("transport systems.  Lack of food and resources has caused unprecedented", (s + 8), ({200, 200, 200}))
  offsetted_text("civil unrest across planetary systems.  People are dying, there's", (s + 9), ({200, 200, 200}))
  offsetted_text("wide-spread looting.", (s + 10), ({200, 200, 200}))
  offsetted_text("There's no law, no order.", (s + 11), ({200, 200, 200}))
  offsetted_text("The only way to slow down the eventual demise of these systems is to", (s + 13), ({200, 200, 200}))
  offsetted_text("get transportation back up.", (s + 14), ({200, 200, 200}))
  offsetted_text("There's no fuel to power transportation, but there's GRAVITY.", (s + 18), ({200, 200, 200}))
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(logo, ((love.graphics.getWidth() - logo:getWidth()) / 2), math.floor((text_render_offset + 600)))
  return center_text("An OK space adventure", math.floor((text_render_offset + 680)))
end
local render_text = _3_
local function _4_()
  starfield.draw(blinky_stars)
  return render_text()
end
local second_screen = _4_
local playing_intro_music_3f = false
local function second_screen_update(t)
  starfield.update(blinky_stars, t)
  local function _5_()
    if not playing_intro_music_3f then
      intro_music:play()
      playing_intro_music_3f = true
      return nil
    end
  end
  _5_()
  local function _6_()
    if (text_render_offset) < (-100) then
      local new_op = math.max(0, (intro_text_opacity - (50 * t)))
      intro_text_opacity = new_op
      return nil
    end
  end
  _6_()
  if (text_render_offset) > (-200) then
    text_render_offset = (text_render_offset - (20 * t))
    return nil
  else
    return nil
  end
end
do local _ = second_screen_update end
local function _5_(t)
  starfield.update(blinky_stars, t)
  return level.update(active_level, t)
end
local game_screen_update = _5_
local function game_screen()
  starfield.draw(blinky_stars)
  love.graphics.setColor(255, 255, 255, 255)
  return level.draw(active_level)
end
do local _ = game_screen end
love.update = function(t)
  return game_screen_update(t)
end
do local _ = love.update end
love.draw = function()
  love.graphics.setFont(main_font)
  return game_screen()
end
do local _ = love.draw end
love.keypressed = function(key, unicode)
  if active_level then
    return level.keypressed(active_level, key, unicode)
  end
end
return love.keypressed
