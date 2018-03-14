require("package").loaded.colorsRGB = nil
require("package").loaded.hazeUI = nil
require("package").loaded.conH = nil
require("colorsRGB")
require("conH")
require("motionUsers")

IC2_MASS_FABRICATOR = "58c455b0-bad0-4876-81d0-3de12b22e71f"
ET_ORE_MINER = "7369bfdd-dd44-4857-a27b-6d769a2c9372"
ET_RESOURCE_MINER = "92251945-526a-4167-9fa4-cedb457e041e"
TE_IGNEOUS_EXTRUDER = "36012308-f6a5-4c31-882c-688a2bacac41"

table.insert(machines, { address = IC2_MASS_FABRICATOR, name = "IC2 Mass Fabricator", status = 'unknown', activeState = 15 })
table.insert(machines, { address = ET_ORE_MINER, name = "ET Ore Miner", status = 'unknown', activeState = 15 })
table.insert(machines, { address = ET_RESOURCE_MINER, name = "ET Resource Miner", status = 'unknown', activeState = 15 })
table.insert(machines, { address = TE_IGNEOUS_EXTRUDER, name = "TE Igneous Extruder", status = 'unknown', activeState = 15 })

portalChest = sides.bottom
portalDislocator = sides.north

dP = 42001
modem.open(dP)

function clearScreen(bg, fg, char)
	if not bg or bg == nil then bg = 0x0 end
	if not fg or fg == nil then fg = bg end
	if not char or char == nil then char = " " end
	gui.gpu.setBackground(bg) 
	gui.gpu.setForeground(fg)
	
	local w, h = gui.gpu.getResolution()
	
	gui.gpu.fill(1, 1, w, h, " ")
end


function devices()
	
	gui:addButton(2, 23, 30, 2, "back to main menue", "rsNetDeviceInit", 0xFFFFFF, 0x4A4A4A, "left", drawMain)
	gui:drawScreen("rsNetDeviceInit")
	
	
	gui.gpu.setBackground(0x8AE700)
	gui.gpu.setForeground(0x0)	
	gui.gpu.fill( 35, 3, 44, 22, " ")
	
	
	
	gui.gpu.set(36, 3, "sending wakeup to devices...") 
	modem.broadcast(dP, "initRSNetwork")
	gui.gpu.set(62, 3, " [done]")
	
	for i=1,6 do gui:drawStatusbar(36, 5, 35, 1, 6, i, "waiting for wakeup") os.sleep(0.5) end
	sendCB("return m.address", false)
	deviceCnt = 0
	for i=1,10 do
		gui:drawStatusbar(36, 8, 35, 1, 10, i, "waiting for devices, try:")
		local nameRemote = modemMessageEvent(event.pull(0.5, "modem_message"))
		for j=1,#machines do
			if machines[j].address == nameRemote then
				nameRemote = machines[j].name
			end
		end			
		if nameRemote and nameRemote ~= nil then
		  deviceCnt = 1 + deviceCnt
		  gui.gpu.set(36, 11+deviceCnt, " "..nameRemote) 
		end		  
	end	
	
	gui.gpu.set(36, 23, "[x] done")
end

function drawMotionLog()
	gui.gpu.setBackground(0x7C0045)
	gui.gpu.setForeground(0xFFFFFF)
	gui.gpu.fill( 35, 3, 44, 22, " ")
	for i=1,#motionUsers do
		local t = motionUsers[i].name..", "..motionUsers[i].firstMove.." - "..motionUsers[i].lastMove
		gui.gpu.set( 35, 2+i, t)
	end
end

function drawTools()
	gui:addButton(2, 3, 30, 2, "send RSNet device init", "tools", 0x0, 0x8AE700, "left", devices)
	gui:addButton(2, 6, 30, 2, "motion log", "tools", 0xFFFFFF, 0x7C0045, "left", drawMotionLog)
	gui:addButton(49, 20, 30, 2, "exit to console", "tools", 0x0, 0xFF7723, "left", closeTool)
	gui:addButton(49, 23, 30, 2, "reboot computer", "tools", 0x0, 0xFF7723, "left", os.execute, "reboot")
	
	gui:addButton(2, 23, 30, 2, "back to main menue", "tools", 0xFFFFFF, 0x4A4A4A, "left", drawMain)
	gui:drawScreen("tools")
end

function drawMain()
	gui:flushElements(true)
	gui:addButton(1, 1, 80, 1, "Oo", "all", 0x0, 0xFFFFFF, "center", drawTools)
	
	for i=1,#machines do
	  local bgColor = 0x717171
	  if i%2 == 0 then bgColor = 0x464646 end
	  machines[i].l = 5+(2*i)
	  gui:addButton(2, machines[i].l, 36, 2, machines[i].name, "main", 0xF2F2F2, bgColor, "left", toggleMachine, i)
	end
	
	gui:addButton(2, 23, 39, 2, "tools", "main", 0x009AFF, 0x363636, "left", drawTools)
	
	gui:addButton(43, 3, 37, 1, "Portal", "main", 0x0, 0x72D6FF, "left", drawPortals)

	gui:drawScreen("main")
		
	gui.gpu.setForeground(0xFF8100)
	gui.gpu.fill(1, 2, 80, 1, borders.groups["slim_double"][6])
	
	gui.gpu.setForeground(0x393939)
	gui.gpu.setBackground(0xFF9D00)
	gui.gpu.set(2, 3, " Energy Storage ")
	gui.gpu.set(2, 4, "                ")
		
	gui.gpu.setBackground(0x0)
	gui.gpu.setForeground(0xFFFFFF)		
	-- border energy storage
	borders.draw(1, 2, 40, 4, 0xFFFFFF, 0x0, "bold", gui.gpu)
		
	-- border machines / tools
	borders.draw(1, 6, 40, 20, 0xFFFFFF, 0x0, "bold", gui.gpu)	
	
	-- border portals
	borders.draw(42, 2, 38, 24, 0xFFFFFF, 0x0, "bold", gui.gpu)	
	
	drawPortals()
	
	updateMachineState()
	
	gui.gpu.setBackground(0x0)
	gui.gpu.setForeground(0xFFFFFF)		
end

function touchEvent(id, device, x, y, button, user)
   if touchTimer then
     event.cancel(touchTimer)
	 touchTimer = false end   
   return gui:touchEvent(x, y, user)
end

function motionEvent(id, device, x, y, z, user)
	local onemin = (20 * 60)
	local now = os.time()
	local lm = getLastMove(user)
	setLastMove(user)
end

function closeTool()
	modem.close()
	gui.gpu.setBackground(0x0)
	gui.gpu.setForeground(0xFFFFFF)
	gui.gpu.setResolution(60,30)
	event.ignore("motion", motionEvent)
	event.ignore("touch", touchEvent)
	event.cancel(deTimer)
	term.clear()
	os.exit()
end

--
modem.broadcast(dP, "initRSNetwork")




gui.gpu.setResolution(80,25)
clearScreen()
drawMain()
getMachineState()

deTimer = event.timer(0.5, refreshEnergy, math.huge)
event.listen("motion", motionEvent)
event.listen("touch", touchEvent)

event.pull("interrupted")


closeTool()
