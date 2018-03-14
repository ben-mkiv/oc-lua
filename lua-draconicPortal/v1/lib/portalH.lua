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

de_portals = {}
de_currentPortal = nil

portalTransposer = component.transposer
portalChest = sides.bottom
portalDislocator = sides.west

local screenW, screenH = _G.gui.gpu.getResolution()

portalListWidth = screenW
portalListHeight = screenH
portalListOffsetX = 0
portalListOffsetY = 0

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

function selectPortal(name)
 setPortal(name)
 _G.gui:drawPortals()
end

function _G.gui:drawPortals(portalOffset)
	self:flushElements(true)

	if not portalOffset or portalOffset == nil or portalOffset < 1 then
		portalOffset = 1 end	
	local portalPageLimit = portalListHeight-1
	
	self.gpu.setBackground(0x0)
	self.gpu.fill(1, 1, portalListWidth, 1+portalPageLimit, " ")
    getPortal()

	self:addButton(1+portalListOffsetX, 1+portalListOffsetY, portalListWidth, 1, "select a location", "main", 0x0, 0xFFB000, "center")
	
	portalCount = 0
	i = 0
	for i=portalOffset,#de_portals do
		local bg = 0xD4D4D4
		if portalCount%2 == 0 then bg = 0xA3A3A3 end
		local t = self:addButton(1+portalListOffsetX, (2+portalCount+portalListOffsetY), portalListWidth, 1, de_portals[i], "main", 0x0, bg, "left", selectPortal, de_portals[i])
		if de_currentPortal == de_portals[i] then 
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

