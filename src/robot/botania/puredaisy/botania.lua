local sides = require("sides")
local component = require("component")
local geolyzer = component.geolyzer
local robot = component.robot
local inventory = component.inventory_controller

local materialSlot = 4

--local inputLivingrock = "minecraft:stone"
--local inputLivingwood = "minecraft:log"

local inputLivingrock = "thaumcraft:stone_arcane"
local inputLivingwood = "astralsorcery:blockinfusedwood"



function placeBlock(side)
	robot.select(materialSlot)
	robot.place(side)
end

function doBlockWork(side)
	local blockName = geolyzer.analyze(side).name

	if blockName == "botania:livingwood" then
	  robot.swing(side)
	  placeBlock(side)
	end

	if blockName == "botania:livingrock" then
	  robot.swing(side)
	  placeBlock(side)
	end
	
	if blockName == "minecraft:air" then
	  placeBlock(side)
	  --os.sleep(5)
	end
	
	return false
end

function dumpInventory(side)
	robot.select(2)
	robot.drop(side)
	robot.select(3)
	robot.drop(side)
end

function refillInventory(side)
	robot.select(materialSlot)
	
	local size = inventory.getInventorySize(side)
	local slot = 1
	
	while slot < size and robot.count(materialSlot) < 1 do
	  local stack = inventory.getStackInSlot(side, slot)
	  if stack ~= nil then
		if stack.name == inputLivingrock or stack.name == inputLivingwood then
			inventory.suckFromSlot(side, slot, 64)
		end
	  end
	  
	  slot = slot + 1
	end
	
	
end


local lastTurn = 1


robot.turn(false)

while true do
	doBlockWork(sides.down)
	doBlockWork(sides.up)
	
	if lastTurn == 1 then
		if robot.count(2) > 32 or robot.count(3) > 32 then
			robot.turn(true)
			dumpInventory(sides.front)
			robot.turn(false)
		end
		
		if robot.count(materialSlot) < 8 then
			robot.turn(true)		
			refillInventory(sides.front)
			robot.turn(false)
		end		
	end
	
	if robot.move(sides.front) then
	  lastTurn = lastTurn + 1
	end
	
	if lastTurn == 2 then
	  robot.turn(true)
	  lastTurn = 0
	end
	
	os.sleep(1)
end
