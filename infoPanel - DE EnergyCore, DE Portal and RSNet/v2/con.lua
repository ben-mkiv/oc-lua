require("package").loaded.colorsRGB = nil
require("package").loaded.hazeUI = nil
require("package").loaded.conH = nil
require("colorsRGB")
require("conH")
require("motionUsers")

IC2_MASS_FABRICATOR = "58c455b0-bad0-4876-81d0-3de12b22e71f"
ET_ORE_MINER = "7369bfdd-dd44-4857-a27b-6d769a2c9372"
ET_RESOURCE_MINER = "92251945-526a-4167-9fa4-cedb457e041e"
--TE_IGNEOUS_EXTRUDER = "36012308-f6a5-4c31-882c-688a2bacac41"

table.insert(machines, { address = IC2_MASS_FABRICATOR, name = "IC2 Mass Fabricator", status = 'unknown', activeState = 15 })
table.insert(machines, { address = ET_ORE_MINER, name = "ET Ore Miner", status = 'unknown', activeState = 15 })
table.insert(machines, { address = ET_RESOURCE_MINER, name = "ET Resource Miner", status = 'unknown', activeState = 15 })
--table.insert(machines, { address = TE_IGNEOUS_EXTRUDER, name = "TE Igneous Extruder", status = 'unknown', activeState = 15 })

portalChest = sides.bottom
portalDislocator = sides.north

modem.open(42001) -- Redstone network
modem.open(42006) -- woot robot network

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
	if user ~= "Ben85" and user ~= "BeBoo" then return end

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
	modem.close()
	_G.gui.gpu.setBackground(0x0)
	_G.gui.gpu.setForeground(0xFFFFFF)
	_G.gui.gpu.setResolution(60,30)
	event.ignore("motion", motionEvent)
	event.ignore("touch", touchEvent)
	event.cancel(deTimer)
	term.clear()
	os.exit()
end

modem.broadcast(42001, "initRSNetwork")
modem.broadcast(42001, "initWoot")

_G.gui.gpu.setResolution(80,25)

clearScreen()

_G.gui.gpu.setForeground(0xFFFFFF)
_G.gui.gpu.setBackground(0x0)

cachePortals()
_G.gui:drawMain()
getMachineState()
deTimer = event.timer(0.5, refreshEnergy, math.huge)
event.listen("motion", motionEvent)
event.listen("touch", touchEvent)
event.pull("interrupted")
closeTool()
