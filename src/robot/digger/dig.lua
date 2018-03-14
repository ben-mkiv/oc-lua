local sides = require("sides")
local component = require("component")
local event = require("event")

local r = component.robot
--local g = component.geolyzer
local i = component.inventory_controller

local direction = sides.down
local directionAlt = sides.up

print("please enter robots current yLevel")
local y = io.read()
local yLimit = 60
local xLimit = 16
print("please enter robots current row (0 if you start)")
local x = io.read()
local stepSize = 5
local clockwise = true

-- slot for ender chest or something like that
local storageSlot = 1

local lines = {}

function dig()
  if direction == sides.up and lines[y-1] == false then
	r.select(3)
	i.equip()
	r.use(sides.up)
	if direction == sides.up then
		r.swing(sides.up)
	end
	i.equip()
	r.select(1)
  end
  
  if direction == sides.down and r.detect(sides.down) == false then
	r.select(3)
	i.equip()
	r.use(sides.down)
	i.equip()
	r.select(1)
  end    
  
  lines[y] = r.detect(direction)
  
  r.swing(direction)
  
  r.move(direction)
end

function moveForward()
	local step = 0
    while step < stepSize do
		r.swing(sides.front)    
		r.move(sides.front)
		step = step+1
	end
	r.swing(sides.front)
end

function initColumn()
	local line = 0
	while line <= yLimit do
	  lines[line] = false
	  line = line + 1
	end
end


function updateColumn()
	x = x + stepSize
	if x >= xLimit then
		while x > 0 do
		 x = x - 1
		 r.move(sides.back)
		end
		r.turn(clockwise)
		moveForward()
		clockwise = not clockwise;		
		r.turn(clockwise)		
	end
end

function dumpInventory()
	r.setLightColor(0x00FF00)
	local side = direction
	r.swing(direction)
	
	r.select(storageSlot)
	
	if direction == sides.up then
		r.move(sides.up)				
		side = sides.down	
	end
	
	r.swing(side)
		
	r.place(side)
	local sizeExtern = i.getInventorySize(side)
	local sizeIntern = r.inventorySize()
	local slot = 1
	while slot < sizeIntern and sizeExtern > 0 do
	 r.select(slot)
	 if slot ~= 2 and slot ~= 3 then r.drop(side) end
	 slot = slot + 1
	end	
	
	r.setLightColor(0xFF8200)
	
	r.select(storageSlot)
	r.swing(side)	
	r.setLightColor(0xFF0000)
end

function toggleDirection()
	moveForward()
	
	local dirTmp = direction
	direction = directionAlt
	directionAlt = dirTmp	
	
	updateColumn()
	initColumn()
end

function updatePos()
  if direction == sides.down then
   y = y-1  
   if y < 1 then
    toggleDirection()	
	dumpInventory()	
	y = 1	
   end   
  else
   y = y+1  
   if y >= yLimit then    
    toggleDirection()
   end       
  end
end

function work()  
  r.setLightColor(0xFF0000)
  dig()
  updatePos()  
  work()
end

r.setLightColor(0xFFFFFF)
work()
