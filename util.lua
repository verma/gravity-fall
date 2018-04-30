local pretty = require("pl.pretty")
local function _0_(v)
  return pretty.dump(v)
end
pp = _0_
local function _1_(a, b)
  local d2 = (((a.center.x - b.center.x) * (a.center.x - b.center.x)) + ((a.center.y - b.center.y) * (a.center.y - b.center.y)))
  local r2 = ((a.radius + b.radius) * (a.radius + b.radius))
  return (d2) < (r2)
end
return ({["sphere-collision"] = _1_, pp = pp})
