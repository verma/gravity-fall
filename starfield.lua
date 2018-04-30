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
local function create_star_field(max_x, max_y)
  local stars = ({})
  for i = 1, 200 do
    stars[i] = generate_random_star(max_x, max_y)
  end
  return stars
end
do local _ = create_star_field end
local function _1_(stars)
  for k, star in ipairs(stars) do
    local hs = (star.size / 2)
    love.graphics.setColor(255, 255, 255, (255 * star.intensity))
    love.graphics.rectangle("fill", (star.x - hs), (star.y - hs), star.size, star.size)
  end
  return nil
end
local render_star_field = _1_
local function _2_(stars, dt)
  for k, star in ipairs(stars) do
    local newi = (star.intensity + (dt * star.pulser * star.idir))
    local function _3_()
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
    local newid = _3_()
    local function _4_()
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
    local newi = _4_()
    local news = (star.maxsize * newi)
    star.idir = newid
    star.intensity = newi
    star.size = news
  end
  return nil
end
local animate_star_field = _2_
local function _3_()
  return create_star_field(love.graphics.getWidth(), love.graphics.getHeight())
end
local function _4_(sf)
  return render_star_field(sf)
end
local function _5_(sf, dt)
  return animate_star_field(sf, dt)
end
return ({create = _3_, draw = _4_, update = _5_})
