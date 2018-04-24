default : main.lua util.lua

%.lua : %.fnl
	fennel --compile $< > $@
