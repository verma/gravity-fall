local main_font = nil
local blinky_stars = nil
local intro_music = nil
local logo = nil
local util = require("util")
local function _0_(max_x, max_y)
  local star = ({})
  star.x = math.random(2, (max_x - 2))
  star.y = math.random(2, (max_y - 2))
  star.pulser = (0.5 * math.random())
  star.intensity = math.random()
  local function _1_()
    if (math.random()) < (0.5) then
      return -1
    else
      return 1
    end
  end
  star.idir = _1_()
  star.maxsize = math.floor((6 * math.random()))
  return star
end
local generate_random_star = _0_
local function _1_(dt)
  for k, star in ipairs(blinky_stars) do
    local newi = (star.intensity + (dt * star.pulser * star.idir))
    local function _2_()
      if (newi) < (0) then
        return 1
      else
        if (newi) > (1) then
          return -1
        else
          return star.idir
        end
      end
    end
    local newid = _2_()
    local function _3_()
      if (newi) < (0) then
        return 0
      else
        if (newi) > (1) then
          return 1
        else
          return newi
        end
      end
    end
    local newi = _3_()
    local news = (star.maxsize * newi)
    star.idir = newid
    star.intensity = newi
    star.size = news
  end
  return nil
end
local animate_star_field = _1_
local function _2_(stars)
  for k, star in ipairs(stars) do
    local hs = (star.size / 2)
    love.graphics.setColor(255, 255, 255, (255 * star.intensity))
    love.graphics.rectangle("fill", (star.x - hs), (star.y - hs), star.size, star.size)
  end
  return nil
end
local render_star_field = _2_
local function create_star_field(max_x, max_y)
  local stars = ({})
  for i = 1, 200 do
    stars[i] = generate_random_star(max_x, max_y)
  end
  return stars
end
do local _ = create_star_field end
love.load = function()
  blinky_stars = create_star_field(800, 600)
  logo = love.graphics.newImage("assets/logo.png")
  intro_music = love.audio.newSource("assets/intro.mp3")
  main_font = love.graphics.newImageFont("assets/font.png", (" abcdefghijklmnopqrstuvwxyz" .. "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" .. "123456789.,!?-+/():;%&`'*#=[]\""))
  return nil
end
do local _ = love.load end
love.conf = function(t)
  t.window.title = "Gravity - You think you know how to fall?"
  return nil
end
do local _ = love.conf end
local function _3_(s, r)
  local w = (love.graphics.getWidth() / 2)
  local t = love.graphics.newText(main_font, s)
  local x = math.floor((w - (t:getWidth() / 2)))
  return love.graphics.print(s, x, r)
end
local center_text = _3_
local function _4_()
  render_star_field(blinky_stars)
  love.graphics.draw(logo, ((love.graphics.getWidth() - logo:getWidth()) / 2), 100)
  love.graphics.setColor(255, 0, 0, 200)
  return center_text("A mediocre space adventure", 180)
end
local main_screen = _4_
local text_render_offset = 600
local intro_text_opacity = 255
local function _5_(s, offset, color)
  color[4] = intro_text_opacity
  love.graphics.setColor(unpack(color))
  return love.graphics.print(s, 20, math.floor((text_render_offset + (20 * offset))))
end
local offsetted_text = _5_
local function _6_()
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
local render_text = _6_
local function _7_()
  render_star_field(blinky_stars)
  return render_text()
end
local second_screen = _7_
local playing_intro_music_3f = false
love.update = function(t)
  animate_star_field(t)
  local function _8_()
    if not playing_intro_music_3f then
      intro_music:play()
      playing_intro_music_3f = true
      return nil
    end
  end
  _8_()
  local function _9_()
    if (text_render_offset) < (-100) then
      local new_op = math.max(0, (intro_text_opacity - (50 * t)))
      intro_text_opacity = new_op
      return nil
    end
  end
  _9_()
  if (text_render_offset) > (-200) then
    text_render_offset = (text_render_offset - (20 * t))
    return nil
  else
    return nil
  end
end
do local _ = love.update end
love.draw = function()
  love.graphics.setFont(main_font)
  return second_screen()
end
return love.draw
