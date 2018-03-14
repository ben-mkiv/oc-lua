require("package").loaded.hazeUI = nil
require("package").loaded.motionUsers = nil
require("package").loaded.instructions = nil
require("motionUsers") 
require("instructions")

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

function motionEvent(id, device, x, y, z, user)
	local onemin = (20 * 60)
	local now = os.time()
	local lm = getLastMove(user)
	setLastMove(user)
end

function closeTool()
	_G.gui.gpu.setBackground(0x0)
	_G.gui.gpu.setForeground(0xFFFFFF)
	_G.gui.gpu.setResolution(60,30)
	event.ignore("motion", motionEvent)
	event.ignore("touch", touchEvent)
	term.clear()
	os.exit()
end

_G.gui.gpu.setResolution(40,15)

clearScreen()

_G.gui.gpu.setForeground(0xFFFFFF)
_G.gui.gpu.setBackground(0x0)
_G.gui:drawMain()

event.listen("motion", motionEvent)
event.listen("touch", touchEvent)
event.pull("interrupted")
closeTool()
