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

_G.tutorials = { 
	{ 
		title = {"Beginner Tutorial", "for those who are new to modded mc" }, side = sides.south} , 
	{   title = {"Advanced Tutorial", "xnet, woot, void miners and more"}, side = sides.bottom }, 
	{   title = {"Advanced+ Tutorial", "chunks, wireless energy, more AE2"}, side = sides.north }}


function _G.gui:drawMain()
	self:flushElements(true)
	self:addButton(1, 1, 40, 1, "Toasty Tutorials", "all", 0x0, 0xFFFFFF, "center", "drawTools")
	
	for i=1,#_G.tutorials do
		self:addButton(2, (i*3), 39, 2, _G.tutorials[i].title, "main", 0xFFB000, 0x363636, "left", "dropItem", _G.tutorials[i].side)
	end
	
	self:drawScreen("main")
		
	-- border portals
	borders.draw(1, 2, 39, 14, 0xFFFFFF, 0x0, "bold", self.gpu)
		
	_G.gui.gpu.setBackground(0x0)
	_G.gui.gpu.setForeground(0xFFFFFF)		
end

function _G.gui:drawMotionLog()
	_G.gui.gpu.setBackground(0x7C0045)
	_G.gui.gpu.setForeground(0xFFFFFF)
	gui.gpu.fill( 35, 3, 44, 22, " ")
	for i=1,#_G.motionUsers do
		local t = _G.motionUsers[i].name..", ".._G.motionUsers[i].firstMove.." - ".._G.motionUsers[i].lastMove
		_G.gui.gpu.set( 35, 2+i, t)
	end
end

function _G.gui:dropItem(sourceSide, amount)
	if not amount or amount == nil then amount = 1 end
	local t = require("component").transposer
	t.transferItem(sourceSide, 1, require("sides").top, amount)
end

function _G.gui:drawTools()
	if self.lastTouchUser ~= "Ben85" then return end
	
	self:addButton(2, 6, 30, 2, "motion log", "tools", 0xFFFFFF, 0x7C0045, "left", "drawMotionLog")
	
	self:addButton(2, 9, 30, 2, "handout item 1", "tools", 0xFFFFFF, 0x7C0045, "left", "dropItem", sides.south)
	self:addButton(2, 12, 30, 2, "handout item 2", "tools", 0xFFFFFF, 0x7C0045, "left", "dropItem", sides.bottom)
	self:addButton(2, 15, 30, 2, "handout item 3", "tools", 0xFFFFFF, 0x7C0045, "left", "dropItem", sides.north)
	
	--self:addButton(49, 20, 30, 2, "exit to console", "tools", 0x0, 0xFF7723, "left", closeTool)
	self:addButton(49, 23, 30, 2, "reboot computer", "tools", 0x0, 0xFF7723, "left", os.execute, "reboot")
	
	self:addButton(2, 23, 30, 2, "back to main menue", "tools", 0xFFFFFF, 0x4A4A4A, "left", "drawMain")
	self:drawScreen("tools")
end
