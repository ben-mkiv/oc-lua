component = require("component")
event = require("event")
sides = require("sides")
term = require("term")
serialization = require("serialization")

require "hazeUI"
gui = clone(hazeUI)
gui.gpu = require("component").gpu

dP = 42001
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

function modemMessageEvent(a, receiver_address, sender_address, port, e, msg)
  if not msg or msg == nil then return false end
  
  data = serialization.unserialize(msg)[1]
  return data
end

function sendC(ad, cmd, waitReply)
  local data = {}
		data.a = ad
		data.c = cmd

		modem.send(ad, dP, serialization.serialize(data))
	
	if waitReply ~= false then
		return modemMessageEvent(event.pull(3, "modem_message"))
	end
end

function sendCB(cmd, waitReply)
local data = {}
	 data.a = "all"
	 data.c = cmd
	 modem.broadcast(dP, serialization.serialize(data))
	 
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
	gui.gpu.fill(2, 22, 39, 1, " ")
	gui.gpu.set(2, 22, " * updating, please wait...")
	netRS_toggle(d)
	updateMachineState(d)
	gui.gpu.setForeground(0xFFFFFF)
	gui.gpu.setBackground(0x0)
	gui.gpu.fill(2, 22, 39, 1, " ")
end

function getMachineState(machine)
	if not machine or machine == nil then
		for i=1,#machines do
			getMachineState(i)
		end	
		return
	end
	
	return netRS_get(machine)
end

function updateMachineState(machine)
	if not machine or machine == nil then
	  for i=1,#machines do updateMachineState(i) end	
	  return 
	end
	
	local x = "[?]"
	
	if machines[machine].status == 'unknown' then
		x = "[?]"
		gui.gpu.setForeground(0x737373)
	elseif machines[machine].status == machines[machine].activeState then
		x = "[x]"
		gui.gpu.setForeground(0x00FF00)
	elseif machines[machine].status ~= machines[machine].activeState then
		x = "[ ]"
		gui.gpu.setForeground(0xFF0000)
	end	
	
	gui.gpu.setBackground(0x0)
	gui.gpu.set(38, machines[machine].l+1, x)
end

function drawPortals()
	gui:removeSubGroup("main", "portals")
    getPortal()
	
	local portals = getPortals()
	
	if de_currentPortal ~= false then 
		local t = gui:addButton(43, 4, 37, 1, "[x] active ("..de_currentPortal..")", "main", 0x0, 0x07A8FF, "left", selectPortal)
		gui:setElement({ index = t, group = "portals" })
	else
		gui.gpu.fill(43, 4, 37, 1, " ")
	end	
	
	for i=1,#portals do
		local bg = 0xD4D4D4
		if i%2 == 0 then bg = 0xA3A3A3 end
		local t = gui:addButton(43, 4+i, 37	, 1, portals[i], "main", 0x0, bg, "left", selectPortal, portals[i])
		gui:setElement({ index = t, group = "portals" })		
		if de_currentPortal == portals[i] then 
			gui:setElement({ index = t, bg = 0xFF5107, cb = selectPortal, cb_parm = nil })
		end		
	end

	gui:drawGroup("main", "portals")
end

function selectPortal(name)
 setPortal(name) 
 drawPortals()
end

cachePortals()
