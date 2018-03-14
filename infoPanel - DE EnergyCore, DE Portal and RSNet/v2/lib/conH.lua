component = require("component")
event = require("event")
sides = require("sides")
term = require("term")
serialization = require("serialization")

require "hazeUI"
_G.gui = clone(hazeUI) 
_G.gui.gpu = require("component").gpu 
_G.gui.super = _G.gui
_G.gui.self = _G.gui


modem = component.modem

de = component.draconic_rf_storage
deCharge = 0
deCharged = 0
deLoad = 0
deMaxCharge = de.getMaxEnergyStored()

de_portals = {}
de_currentPortal = nil

portalTransposer = component.transposer
portalChest = sides.bottom
portalDislocator = sides.north

machines = {}

wootMobs = {}
currentWootMob = "unknown"

function modemMessageEvent(a, receiver_address, sender_address, port, e, msg)
  if not msg or msg == nil then return false end
  
  data = serialization.unserialize(msg)[1]
  return data
end

function sendC(ad, cmd, waitReply)
  local data = {}
		data.a = ad
		data.c = cmd

		modem.send(ad, 42001, serialization.serialize(data))
	
	if waitReply ~= false then
		return modemMessageEvent(event.pull(3, "modem_message"))
	end
end

function sendCB(cmd, waitReply)
local data = {}
	 data.a = "all"
	 data.c = cmd
	 modem.broadcast(42001, serialization.serialize(data))
	if waitReply ~= false then
		return modemMessageEvent(event.pull(3, "modem_message"))
	end
end

function prettyRF(val)
	local n = {}
		  n.sd = {"k", "M", "T", "G", "P", "E"}	
		  n.ld = {"kilo", "Mega", "Tera", "Giga", "Peta", "Exa"}
	local e = 0
	local v2 = tonumber(val) 
	while math.floor(tonumber(v2/1000)) > 0 do
		v2 = (v2/1000)
		e=e+1 
	end
	val = math.floor((v2 * 100) + 0.5) / 100
	local g = {}
		g.val = val
		g.sd = ""
		g.ld = ""
	if e > 0 then
	  g.sd = n.sd[e]
	  g.ld = n.ld[e] 
	end
	return g 
end

function cachePortals()
	local t = getPortal()
	if t ~= false then table.insert(de_portals, t) end
	invSize = portalTransposer.getInventorySize(portalChest)
	for i=1,invSize do
		local t = portalTransposer.getStackInSlot(portalChest, i)
		if t and t.label ~= nil then table.insert(de_portals, t.label) end
	end
end

function disablePortal()
	if portalTransposer.getStackInSlot(portalDislocator, 1) ~= nil then
		portalTransposer.transferItem(portalDislocator, portalChest, 1, 1) end	
	de_currentPortal = false
end

function setPortal(name)
	if de_currentPortal == name then return true end	
	if de_currentPortal ~= false then disablePortal() end	
	if not name or name == nil then return false end
	invSize = portalTransposer.getInventorySize(portalChest)	
	for i=1,invSize do
		local t = portalTransposer.getStackInSlot(portalChest, i)
		if t and t.label == name then
			portalTransposer.transferItem(portalChest, portalDislocator, 1, i)
			return true
	end	end	
	return false
end

function getPortal()
	local t = portalTransposer.getStackInSlot(portalDislocator, 1)
	if t ~= nil then de_currentPortal = t.label
	else de_currentPortal = false end		
	return de_currentPortal
end

function getPortals()
	return de_portals
end


function refreshEnergy()
	if gui.currentScreen ~= "main" then return end
	deLoad = de.getTransferPerTick()
	deCharge = de.getEnergyStored()
	deCharged = math.floor(((100 / deMaxCharge) * de.getEnergyStored() * 100) + 0.5)/100
	local f = prettyRF(deCharge)
	local g = prettyRF(deLoad)
	dCharge = ""..f.val .. " " ..f.sd
	dLoad = ""..g.val .. " "..g.sd
	
	local loadColor = 0xD6D6D6
	if g.val > 0 then
		dLoad = "+"..dLoad
		loadColor = 0x00FF00
	elseif g.val < 0 then
		loadColor = 0xFF0000
	end	
	
	gui.gpu.setBackground(0x393939)
	gui.gpu.setForeground(0xFF9D00)
	gui.gpu.fill(18, 3, 23, 2, " ")	
	gui.gpu.set(18,3, " Charge: " .. dCharge .. "RF ")
	gui.gpu.set(18,4, " Load: ")
	gui.gpu.setForeground(loadColor)
	gui.gpu.set(25,4, dLoad .. "RF/t")
	gui.gpu.setForeground(0xFFFFFF)
end

function netRS_get(i)
	machines[i].status = tonumber(sendC(machines[i].address, "return r.getOutput(4)"))
	return machines[i].status
end

function netRS_toggle(i)
	if machines[i].status == 'unknown' then machines[i].status = netRS_get(i) end	
	if machines[i].status > 0 then machines[i].status = tonumber(sendC(machines[i].address, "return r.setOutput(4, 0)"))
	else machines[i].status = tonumber(sendC(machines[i].address, "return r.setOutput(4, 15)")) end	
	return machines[i].status
end

function toggleMachine(d)
	gui.gpu.setForeground(0x393939)
	gui.gpu.setBackground(0xFF9D00)
	gui.gpu.set(38, machines[d].l+1, " * ")
	netRS_toggle(d)
	_G.gui:updateMachineState(d)
end

function getMachineState(machine)
	if not machine or machine == nil then
		for i=1,#machines do getMachineState(i) end	
		return
	end
	
	return netRS_get(machine)
end

function _G.gui:updateMachineState(machine)
	if not machine or machine == nil then
	  for i=1,#machines do self:updateMachineState(i) end	
	  return 
	end
	
	local x = "[?]"
	
	if machines[machine].status == 'unknown' then
		x = "[?]"
		self.gpu.setForeground(0x737373)
	elseif machines[machine].status == machines[machine].activeState then
		x = "[x]"
		self.gpu.setForeground(0x00FF00)
	elseif machines[machine].status ~= machines[machine].activeState then
		x = "[ ]"
		self.gpu.setForeground(0xFF0000)
	end	
	
	self.gpu.setBackground(0x0)
	self.gpu.set(38, machines[machine].l+1, x)
end

function _G.gui:drawPortals(portalOffset)
	if not portalOffset or portalOffset == nil or portalOffset < 1 then
		portalOffset = 1 end	
	local portalPageLimit = 17
	
	self.gpu.setBackground(0x0)
	self.gpu.fill(43, 4, 37, 21, " ")
	self:removeSubGroup("main", "portals")
    getPortal()

	local portals = getPortals()

	if de_currentPortal ~= false then 
		local t = self:addButton(43, 4, 37, 1, "[x] active ("..de_currentPortal..")", "main", 0x0, 0x07A8FF, "left", selectPortal)
		self:setElement({ index = t, group = "portals" })
	else
		self.gpu.fill(43, 4, 37, 1, " ")	end	
	
	portalCount = 0
	i = 0
	for i=portalOffset,#portals do
		local bg = 0xD4D4D4
		if portalCount%2 == 0 then bg = 0xA3A3A3 end
		local t = gui:addButton(43, 5+portalCount, 37	, 1, portals[i], "main", 0x0, bg, "left", selectPortal, portals[i])
		self:setElement({ index = t, group = "portals" })		
		if de_currentPortal == portals[i] then 
			self:setElement({ index = t, bg = 0xFF5107, cb = selectPortal, cb_parm = nil })
		end
		
		portalCount = 1 + portalCount
		if portalCount > portalPageLimit then
			local t = self:addButton(62, 23, 18, 2, "next >>", "main", 0xFF9D00, 0x393939, "right", "drawPortals", (portalOffset+portalPageLimit+1))
			self:setElement({ index = t, group = "portals" })
			break
		end
	end
	
	if portalOffset > 1 then
		local t = self:addButton(43, 23, 18, 2, "<< prev", "main", 0xFF9D00, 0x393939, "left", "drawPortals", (portalOffset-portalPageLimit-1))	
		self:setElement({ index = t, group = "portals" })
	end
	
	self:drawGroup("main", "portals")
end

function selectPortal(name)
 setPortal(name) 
 _G.gui:drawPortals()
end








function wootNET_send(cmd, timeout)
  local m = require("component").modem
  m.broadcast(42006, cmd)
  
  if timeout == 0 then 
	return true 
  end  
  
  data = select(6, event.pull(timeout, "modem_message"))  
  if not data then
	return false
  elseif data == nil or data == false then 
	return false
  elseif data == true then 
	return true 
  end
  
  data = serialization.unserialize(data)
  
  return data
end


function _G.gui:wootUpdateMoblist()
	wootMobs = wootNET_send("return findWootpoints(32)", 10)	
	self:drawWoot()
end

function _G.gui:wootSetMob(name)
	wootNET_send('setController("'..name..'")', 0)	
	os.sleep(1)
	self:drawMain()
end

function _G.gui:wootGetCurrentMob()
	local tmp = wootNET_send('return activeController', 5)	
	if tmp and type(tmp) == "string" then currentWootMob = tmp end
	
	self:drawWoot()
end

function _G.gui:wootInit()
	modem.broadcast(42001, "initWoot")
end


function _G.gui:drawWoot(offset)
	self:flushElements(true)
	
	if not offset or offset == nil then offset = 1 end
	self:addButton(2, 3, 30, 2, "update moblist", "woot", 0x0, 0x8AE700, "left", "wootUpdateMoblist")
	
	self:addButton(2, 6, 30, 2, {"current mob:", currentWootMob}, "woot", 0x0, 0xE78500, "left", "wootGetCurrentMob")
	
	self:addButton(2, 9, 30, 2, "wakeup robot", "woot", 0x0, 0x8AE700, "left", "wootInit")
	
	local limit = 18
	
	local d = 0
	for i=offset,#wootMobs do
		d = 1+d
		local bgColor = 0x585858
		if d%2 == 0 then bgColor = 0x2B2B2B end		
		
		local tmp = self:addButton(48, 2+d, 31, 1, "#"..i.." "..wootMobs[i].label.woot, "woot", 0xFFFFFF, bgColor, "left", "wootSetMob", wootMobs[i].label.woot)	
		if wootMobs[i].label.woot == "front" or wootMobs[i].label.woot == "controller" then
		  self:setElement({ index = tmp, bg = 0x571300, cb = nil, cb_parm = nil })
		elseif wootMobs[i].label.woot == currentWootMob then 
		  self:setElement({ index = tmp, bg = 0xE78500, cb = nil, cb_parm = nil })
		end		
		
		if d > limit then self:addButton(64, 23, 15, 2, "next page", "woot", 0xFFFFFF, 0x4A4A4A, "left", "drawWoot", offset+limit+1) break end
	end
	
	if offset > 1 then 
		local lastPage = offset - limit - 1
		if lastPage < 1 then lastPage = 1 end
		self:addButton(48, 23, 15, 2, "prev page", "woot", 0xFFFFFF, 0x4A4A4A, "left", "drawWoot", lastPage)
	end
	
	self:addButton(2, 23, 30, 2, "back to main menue", "woot", 0xFFFFFF, 0x4A4A4A, "left", "drawMain")
	self:drawScreen("woot")
end

function _G.gui:drawMain()
	self:flushElements(true)
	self:addButton(1, 1, 80, 1, "Oo", "all", 0x0, 0xFFFFFF, "center", "drawMain")
		
	for i=1,#machines do
	  local bgColor = 0x717171
	  if i%2 == 0 then bgColor = 0x464646 end
	  machines[i].l = 5+(2*i)
	  self:addButton(2, machines[i].l, 36, 2, machines[i].name, "main", 0xF2F2F2, bgColor, "left", toggleMachine, i)
	end
	
	self:addButton(2, 8+(#machines*2), 39, 2, {"current Woot Mob:", currentWootMob}, "main", 0xFF9D00, 0x363636, "left", "drawWoot")
	
	self:addButton(2, 23, 39, 2, "tools", "main", 0x009AFF, 0x363636, "left", "drawTools")
	
	self:addButton(43, 3, 37, 1, "Portal", "main", 0x0, 0x72D6FF, "left", "drawPortals")

	self:drawScreen("main")
		
	_G.gui.gpu.setForeground(0xFF8100)
	gui.gpu.fill(1, 2, 80, 1, borders.groups["slim_double"][6])
	
	_G.gui.gpu.setForeground(0x393939)
	_G.gui.gpu.setBackground(0xFF9D00)
	_G.gui.gpu.set(2, 3, " Energy Storage ")
	_G.gui.gpu.set(2, 4, "                ")
		
	_G.gui.gpu.setBackground(0x0)
	_G.gui.gpu.setForeground(0xFFFFFF)		
	-- border energy storage
	borders.draw(1, 2, 40, 4, 0xFFFFFF, 0x0, "bold", gui.gpu)
		
	-- border machines / tools
	borders.draw(1, 6, 40, 20, 0xFFFFFF, 0x0, "bold", gui.gpu)	
	borders.addDivLine(1, 7+(#machines*2), 40, 0xFFFFFF, 0x0, "bold", gui.gpu)
	borders.addDivLine(1, 22, 40, 0xFFFFFF, 0x0, "bold", gui.gpu)
	
	-- border portals
	borders.draw(42, 2, 38, 24, 0xFFFFFF, 0x0, "bold", gui.gpu)	
	
	self:drawPortals(0)
	
	self:updateMachineState()
	
	_G.gui.gpu.setBackground(0x0)
	_G.gui.gpu.setForeground(0xFFFFFF)		
end

function _G.gui:drawMotionLog()
	_G.gui.gpu.setBackground(0x7C0045)
	_G.gui.gpu.setForeground(0xFFFFFF)
	gui.gpu.fill( 35, 3, 44, 22, " ")
	for i=1,#motionUsers do
		local t = motionUsers[i].name..", "..motionUsers[i].firstMove.." - "..motionUsers[i].lastMove
		_G.gui.gpu.set( 35, 2+i, t)
	end
end

function _G.gui:drawTools()
	self:addButton(2, 3, 30, 2, "send RSNet device init", "tools", 0x0, 0x8AE700, "left", "devices")
	self:addButton(2, 6, 30, 2, "motion log", "tools", 0xFFFFFF, 0x7C0045, "left", "drawMotionLog")
	--self:addButton(49, 20, 30, 2, "exit to console", "tools", 0x0, 0xFF7723, "left", closeTool)
	self:addButton(49, 23, 30, 2, "reboot computer", "tools", 0x0, 0xFF7723, "left", os.execute, "reboot")
	
	self:addButton(2, 23, 30, 2, "back to main menue", "tools", 0xFFFFFF, 0x4A4A4A, "left", "drawMain")
	self:drawScreen("tools")
end

function _G.gui:devices()	
	self:addButton(2, 23, 30, 2, "back to main menue", "rsNetDeviceInit", 0xFFFFFF, 0x4A4A4A, "left", "drawMain")
	self:drawScreen("rsNetDeviceInit")
	
	self.gpu.setBackground(0x8AE700)
	self.gpu.setForeground(0x0)	
	self.gpu.fill( 35, 3, 44, 22, " ")	
	
	self.gpu.set(36, 3, "sending wakeup to devices...") 
	modem.broadcast(42001, "initRSNetwork")
	self.gpu.set(62, 3, " [done]")
	
	for i=1,6 do self:drawStatusbar(36, 5, 35, 1, 6, i, "waiting for wakeup") os.sleep(0.5) end
	sendCB("return m.address", false)
	deviceCnt = 0
	for i=1,10 do
		self:drawStatusbar(36, 8, 35, 1, 10, i, "waiting for devices, try:")
		local nameRemote = modemMessageEvent(event.pull(0.5, "modem_message"))
		for j=1,#machines do
			if machines[j].address == nameRemote then
				nameRemote = machines[j].name
			end
		end			
		if nameRemote and nameRemote ~= nil then
		  deviceCnt = 1 + deviceCnt
		  self.gpu.set(36, 11+deviceCnt, " "..nameRemote) 
		end		  
	end	
	
	self.gpu.set(36, 23, "[x] done")
end

