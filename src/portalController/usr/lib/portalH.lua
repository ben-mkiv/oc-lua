component = require("component")
event = require("event")
sides = require("sides")
term = require("term")
serialization = require("serialization")
redstone = component.redstone
shield = component.shield_projector

require "hazeUI"
_G.gui = clone(hazeUI) 
_G.gui.gpu = require("component").gpu 
_G.gui.super = _G.gui
_G.gui.self = _G.gui

de_portals = {}
de_currentPortal = nil

_G.portalTransposer = nil
_G.portalChest = nil
_G.portalDislocator = nil
_G.portalType = nil

local screenW, screenH = _G.gui.gpu.getResolution()

portalListWidth = screenW
portalListHeight = screenH
portalListOffsetX = 0
portalListOffsetY = 0



function initInventorys()	
	if component.list("debug")[0] then	
		print("[x] using debug card")
		_G.portalType = "debug"
		os.sleep(2)
		return
	end	
	
	print("[ ] using debug card")
	_G.portalTransposer = component.transposer
	
	for i=1,#sides do
		local side = i-1
		local invSize = _G.portalTransposer.getInventorySize(side)
		
		if invSize ~= nil then
			print("side: ".. sides[side] .." slots:" .. invSize)
			
			if invSize >= 27 then
				print("^^ setting up as location inventory")
				_G.portalChest = side
			elseif invSize == 2 then
				print("^^ setting up as enderIO Telepad")
				_G.portalDislocator = side
				_G.portalType = "eio"
			elseif invSize == 1 then
				print("^^ setting up as Draconic Evolution Portal")
				_G.portalDislocator = side
				_G.portalType = "de"
			end
		end
	end
end

function cachePortals()
	if _G.portalType == "debug" then
		local cf = io.open("/etc/portal.conf", "r")
		de_portals = serialization.unserialize(cf:read("*a"))
		cf:close()
		return true
	end

	local t = getPortal()
	if t ~= false then table.insert(de_portals, t) end
	invSize = _G.portalTransposer.getInventorySize(_G.portalChest)
	for i=1,invSize do
		local t = _G.portalTransposer.getStackInSlot(_G.portalChest, i)
		if t and t.label ~= nil then table.insert(de_portals, t.label) end
	end
	
	return true
end

function disablePortal()
	if _G.portalType == "debug" then return false end

	if _G.portalTransposer.getStackInSlot(_G.portalDislocator, 1) ~= nil then
		_G.portalTransposer.transferItem(_G.portalDislocator, _G.portalChest, 1, 1) end	
	de_currentPortal = false
	
	-- for shield
	component.redstone.setOutput(sides.bottom, 0)
	
end

function setPortal(name)
	if _G.portalType == "debug" then 
		d = component.debug
		p = _G.gui.lastTouchUser
		
		for i=1,#de_portals do
			if de_portals[i].name == name then 
				pos = de_portals[i].pos
				break
			end
		end
				
		return d.getPlayer(p).setPosition(pos.x, pos.y, pos.z)
	elseif _G.portalType == "de" then 
		if de_currentPortal == name then return true end	
		if de_currentPortal ~= false then disablePortal() end
	end
	
	if not name or name == nil then return false end
	
	invSize = _G.portalTransposer.getInventorySize(_G.portalChest)	
	for i=1,invSize do
		local t = _G.portalTransposer.getStackInSlot(_G.portalChest, i)
		if t and t.label == name then
			_G.portalTransposer.transferItem(_G.portalChest, _G.portalDislocator, 1, i)
			
			if _G.portalType == "eio" then
				while _G.portalTransposer.getStackInSlot(_G.portalDislocator, 2) == nil do
					os.sleep(0.05)
				end
				_G.portalTransposer.transferItem(_G.portalDislocator, _G.portalChest, 1, 2)
				component.redstone.setOutput(_G.portalDislocator, 15)
				os.sleep(0.2)
				component.redstone.setOutput(_G.portalDislocator, 0)
			end
			
			
			--shield
			redstone.setOutput(sides.bottom, 15)
			
			event.timer(2, disablePortal)
			
			return true
	end	end	
	return false
end


function getPortal()
	if _G.portalType == "debug" then return false end
	local t = _G.portalTransposer.getStackInSlot(_G.portalDislocator, 1)
	if t ~= nil then de_currentPortal = t.label
	else de_currentPortal = false end		
	return de_currentPortal
end

function selectPortal(name)
 setPortal(name) 
 if _G.portalType ~= "debug" then _G.gui:drawPortals() end
end

function _G.gui:drawPortals(portalOffset)
	self:flushElements(true)

	if not portalOffset or portalOffset == nil or portalOffset < 1 then
		portalOffset = 1 end	
	local portalPageLimit = 2*(portalListHeight-1)
	
	self.gpu.setBackground(0x0)
	self.gpu.fill(1, 1, portalListWidth, 1+portalPageLimit, " ")
    getPortal()

	self:addButton(1+portalListOffsetX, 1+portalListOffsetY, portalListWidth, 1, "select a location", "main", 0x0, 0xFFB000, "center")
	
	portalCount = 0
	i = 0
	for i=portalOffset,#de_portals do
		if _G.portalType == "debug" then 
			portalName = de_portals[i].name
		else
			portalName = de_portals[i]
		end
		
		local bg = 0xD4D4D4
		local colOffset = 0
		if portalCount%2 == 0 then 
			bg = 0xA3A3A3 			
		end
		
		if portalCount > portalPageLimit/2 then
			colOffset = (portalListWidth/2)+2
		end
		
		
		local t = self:addButton(colOffset+1+portalListOffsetX, (2+portalCount+portalListOffsetY), (portalListWidth/2)-2, 1, portalName, "main", 0x0, bg, "left", selectPortal, portalName)
		if de_currentPortal == portalName then 
			self:setElement({ index = t, bg = 0xFF5107, cb = selectPortal, cb_parm = nil })
		end
		
		portalCount = 1 + portalCount
		
		if portalCount > portalPageLimit then
			local t = self:addButton((1+portalListOffsetX+portalListWidth-10), 1+portalListOffsetY, 9, 1, "next >>", "main", 0xFF9D00, 0x393939, "right", "drawPortals", (portalOffset+portalPageLimit+1))
			break
		end
	end
	
	if portalOffset > 1 then
		local t = self:addButton(1, 1+portalListOffsetY, 9, 1, "<< prev", "main", 0xFF9D00, 0x393939, "left", "drawPortals", (portalOffset-portalPageLimit-1))		
	end
	
	self:drawScreen("main")
end

