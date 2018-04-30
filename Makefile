default : main.lua util.lua starfield.lua ship.lua level.lua planet.lua hud.lua vortex.lua

%.lua : %.fnl
	fennel --compile $< > $@
