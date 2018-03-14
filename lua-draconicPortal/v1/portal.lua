require("package").loaded.hazeUI = nil
require("package").loaded.portalH = nil
require("portalH")

portalChest = sides.bottom
portalDislocator = sides.west

function clearScreen(bg, fg, char)
	if not bg or bg == nil then bg = 0x0 end
	if not fg or fg == nil then fg = bg end
	if not char or char == nil then char = " " end
	_G.gui.gpu.setBackground(bg) 
	_G.gui.gpu.setForeground(fg)
	
	local w, h = _G.gui.gpu.getResolution()
	
	_G.gui.gpu.fill(1, 1, w, h, " ")
end

function touchEvent(id, device, x, y, button, user)
  if touchTimer then
     event.cancel(touchTimer)
	 touchTimer = false end   
   return _G.gui:touchEvent(x, y, user)
end


function closeTool()
	modem.close()
	_G.gui.gpu.setBackground(0x0)
	_G.gui.gpu.setForeground(0xFFFFFF)
	_G.gui.gpu.setResolution(60,30)
	event.ignore("touch", touchEvent)
	term.clear()
	os.exit()
end

_G.gui.gpu.setResolution(40, 18)

clearScreen()

_G.gui.gpu.setForeground(0xFFFFFF)
_G.gui.gpu.setBackground(0x0)

cachePortals()
_G.gui:drawPortals()
event.listen("touch", touchEvent)
event.pull("interrupted")
closeTool()
