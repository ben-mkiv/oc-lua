require ("package").loaded.borders = nil
require ("package").loaded.hazeUI = nil
require ("package").loaded.deH = nil

sides = require("sides")
component = require("component") 
event = require("event") 
require "hazeUI" 
	 
recipes = {} 
recipes_compressed = {} 
upgradeRecipes = {} 
upgradeRecipes_compressed = {} 
upgradeKeys = {} 
inventory = {} 
inventoryAll = {} 

config = {}
config.target = "actuallyadditions"
config.devices =  {}
		
config.devices.redstone = { 
	crafter = { address = false, side = false },
	status  = { address = false, side = false } }
		
config.devices.transposer = { 
	crafter = {
		address = false,
		sideCrafter = false,
		sideInput = false,
		sideOutput = false }, 
	injectors = {} }
	
config.devices.ae2 = { 
	controller = false, 
	interface = {},
	exportbus = {} }

require "deH"

loadConfig()

gui = clone(hazeUI) 
gui.gpu = component.gpu 
gui.super = gui
gui.self = gui
titleBar = gui:addButton(1, 1, 80, 1, "draconic infusion crafting, starting up...", "all", 0x282828, 0xFFB000, "left")

function closeTool()
	gui.gpu.setBackground(0x0)
	gui.gpu.setForeground(0xFFFFFF)
	gui.gpu.setResolution(60,30)
	event.ignore("touch", touchEventHandler)
	require("term").clear()
	os.exit()
end

function touchEventHandler(id, device, x, y, button, user)
	--if user ~= "ben_mkiv" then return false; end
	return gui:touchEvent(x, y, user)	
end

gui.gpu.setResolution(80,25)
gui:drawScreen("all")
gui:setElement({index = titleBar, cb = "drawMain"})

event.listen("touch", touchEventHandler)

for address,type in pairs(component.list("redstone")) do
	if config.devices.redstone.crafter.address == address and config.devices.redstone.crafter.side ~= false then
		print("device " .. address .. " already configured as crafter redstone")
	elseif config.devices.redstone.status.address == address and config.devices.redstone.status.side ~= false then
		print("device " .. address .. " already configured as comparator redstone")
	else
		config.devices.redstone.status.address = address
		config.devices.redstone.crafter.address = address
		configureRedstoneDevice(address)
	end
end

for address,type in pairs(component.list("transposer")) do 
	local index = getTransposerIndex(address)
	if index and config.devices.transposer.injectors[index].sideInventory ~= false and config.devices.transposer.injectors[index].sideInjector ~= false then
		print("device " .. address .. " already configured for injector")
	elseif config.devices.transposer.crafter.address == address and config.devices.transposer.crafter.sideInput ~= false and config.devices.transposer.crafter.sideOutput ~= false and config.devices.transposer.crafter.sideCrafter ~= false then
		print("device " .. address .. " already configured for crafter")
	else
		configureTransposerDevice(address)
	end	
end

for address,type in pairs(component.list("me_network")) do
	print("[i] found me network controller "..address)
	config.devices.ae2.controller = component.proxy(address)
end

for address,type in pairs(component.list("me_exportbus")) do
	print("[+] adding me exportbus")
	config.devices.ae2.exportbus[#config.devices.ae2.exportbus+1] = {}
	config.devices.ae2.exportbus[#config.devices.ae2.exportbus].address = address
end

os.sleep(3)

saveConfig()

gui:cleanup()
gui:loadRecipesConfig()
gui:drawMain()

event.pull("interrupted")
closeTool()
