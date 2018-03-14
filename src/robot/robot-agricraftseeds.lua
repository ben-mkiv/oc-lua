component = require("component")
shell = require("shell")
side = require("sides")
t = require("term")
c = require("computer")
r = require("robot")
ser = require("serialization")
fs = require("filesystem")
inv = component.inventory_controller
gen = component.generator
tb = component.tractor_beam

version = "1.0.0"



numOfSubGenerations = 40
sleepAmountBetweenGenerations = 10 
sleepAmountWhenWachingSeeds = 5

startpos = {x = 0, y = -1, z = 2}
pos = {x = 0, y = -1, z = 2}
fl = {pos = {}}
fl.pos[0] = {x = 0, y = 0, z = 1}
fl.pos[1] = {x = -1, y = 0, z = 0}
fl.pos[2] = {x = 0, y = 0, z = -1}
fl.pos[3] = {x = 1, y = 0, z = 0}
fl.pos[4] = {x = 0, y = 0, z = 0}
fl.pos[5] = {x = 0, y = 1, z = 0}

cpos = {}
cpos.anlzer = {x = -1, y = 0, z = 1}
cpos.bin = {x = -1, y = 0, z = -1}
cpos.chest = {x = 1, y = 0, z = -1}

slot = {sticks = {}, fuel = 1, rake = 4, seeds = 5, seedsExtra = 6}
slot.sticks[1] = 2
slot.sticks[2] = 3

_G.seedName = "unknown"

curSubGen = 2
seedRepl = 1
r.select(1)


----------------------------------------------------
-----------------LANG VARIABLES---------------------
----------------------------------------------------
lang_noFuel = "Please insert a valid fuel in slot "..slot.fuel.."!"
lang_noSticks = "Please insert Crop Sticks in slot "..slot.sticks[1].." or "..slot.sticks[2].."!"
lang_noRake = "Please insert a Hand Rake in slot "..slot.rake.."!"
lang_noSeed = "Please insert ONLY 1 valid seeds in slot "..slot.seeds.."!"
lang_timeBtwGen = "Waiting time between generations: "
lang_curGen = "Current generation: "
lang_line = "---------------------------------------"
----------------------------------------------------
----------------ERROR MESSAGES----------------------
----------------------------------------------------
function noFuel()
	while not gen.insert(1) do
		t.clear()
		t.setCursor(1,1)
		t.write(lang_noFuel)
		os.sleep(1)
	end
	t.clear()
	return true
end
function noSticks()
	while not tidySticks() do
		t.clear()
		t.setCursor(1,1)
		t.write(lang_noSticks)
		os.sleep(1)
	end
	t.clear()
	return true
end
function noRake()
	while not compareItemInSlot("agricraft:rake",slot.rake) do
		t.clear()
		t.setCursor(1,1)
		t.write(lang_noRake)
		os.sleep(1)
	end
	t.clear()
	return true
end
function noSeeds()
	while not checkCount(slot.seeds,1) do
		t.clear()
		t.setCursor(1,1)
		t.write(lang_noSeed)
		os.sleep(1)
	end
	if seeds() >= 1 then
		t.clear()
		return true
	else
		noSeeds()
	end
end

function compareItemInSlot(item,slot) -- Compares $item with the item in $slot
    itemInfo = inv.getStackInInternalSlot(slot)
	if itemInfo ~= nil then --If $slot has item
		--print("Comparing: "..item.." AND: "..itemInfo.name)
		if item == itemInfo.name then -- If $item matches item name in $slot
			return true
		end
	end
	return false
end
function checkCount(slot,count)
	itemInfo = inv.getStackInInternalSlot(slot)
	if itemInfo ~= nil and itemInfo.size >= count then
		return true
	end
	return false
end
function count(slot)
	itemInfo = inv.getStackInInternalSlot(slot)
	if itemInfo ~= nil then 
		return itemInfo.size 
	end
	return 0 
end
function transferItem(fromSlot,toSlot)
	lastSl = r.select(fromSlot)
	r.transferTo(toSlot,64)
	r.select(lastSl)
end
function suckItems()
	local suckToSlot = 9
	
	r.select(suckToSlot)
	tb.suck()			
	r.select(lastSl)	
end
function isEquipEmpty()
  lastSl = r.select(slot.seeds)
  inv.equip()
  if checkCount(slot.seeds,1) then
    return false
  end
  return true
end

function putInAnlzer()
	move(cpos.anlzer)
	lastSl = r.select(slot.seeds)
	succes = r.dropDown()
	r.select(lastSl)
	return succes
end

function takeFromAnlzer()
	move(cpos.anlzer)
	lastSl = r.select(slot.seeds)
	succes = inv.suckFromSlot(side.bottom,1)
	r.select(lastSl)
	return succes
end
function analyze()
	move(cpos.anlzer)
	print("Analyzing")
	if putInAnlzer() then
		os.sleep(1.7)
		return takeFromAnlzer()
	end
	return false
end

function fuel() -- Fuels Robot
	if c.energy() < 1000 then -- If energy is less than 1000 insters coal in generator
		lastSl = r.select(1) -- Selects slot 1 (Where fuel should be placed) and gets the previously selected slot
		if gen.insert(1) or noFuel() then -- Inserts fuel it in generator and test if it succeded
			r.select(lastSl) -- Selects prevously selected slot
			return true
		end
		r.select(lastSl) -- Selects prevously selected slot
		return false
	end
	return true -- When the energy is highter or equal than 1000
end

function tidySticks()
	if compareItemInSlot("agricraft:crop_sticks",slot.sticks[1]) then
		return true
	else
		if compareItemInSlot("agricraft:crop_sticks",slot.sticks[2]) then
			transferItem(slot.sticks[2],slot.sticks[1])
			return true
		end
	end
	return false
end
function sticks()
	if tidySticks() then
		return true
	end
	noSticks()
	return true
end
function rake()
	if compareItemInSlot("agricraft:rake",slot.rake) then
		return true
	end
	noRake()
	return true
end
function seeds()
	seedCount = count(slot.seeds)
	if seedCount >= 1 then
		if analyze() then
			return seedCount
		end
	end
	return 0
end

function useRakeDown(slotArg)
	lastsl = r.select(slot.rake)
	inv.equip()
	r.useDown(side.bottom)
	transferItem(slot.rake,slotArg)
	inv.equip()
	r.select(lastsl)
end

function placeStick(posTable,crossStick)
	move(posTable)
	lastSl = r.select(slot.sticks[1])
	if sticks() then
	r.swingDown(side.down)
		if crossStick then
			print("Placing Cross Sticks")
			r.select(slot.sticks[1])
			r.transferTo(15,1)
			r.select(15)
			inv.equip()
			r.useDown(side.bottom)
		end
		if sticks() then
			print("Placing Sticks")
			r.select(slot.sticks[1])
			r.transferTo(14,1)
			r.select(14)
			inv.equip()
			r.useDown(side.bottom)
		end
	end
	r.select(lastSl)
	return true
end
function breakStick(posTable)
  move(posTable)
  return r.swingDown()
end
function getSeedName()
	itemInfo = inv.getStackInInternalSlot(slot.seeds)
	return itemInfo.name
end
function placeSeed(posTable)
	move(posTable)
	print("Placing Seeds")
	lastsl = r.select(slot.seeds)
	r.transferTo(13,1)
	r.select(13)
	inv.equip()
	r.useDown(side.bottom)
	while not isEquipEmpty() do
	  print("Removing weeds")
	  breakStick(posTable)
	  placeStick(posTable,false)
    lastsl = r.select(slot.seeds)
    r.transferTo(13,1)
    r.select(13)
    inv.equip()
    r.useDown(side.bottom)
	end
	r.select(lastsl)
end
function replaceSeeds(posTable)
	print("Replacing Seeds")
	move(posTable)
	lastsl = r.select(slot.rake)
	--useRakeDown(slot.seedsExtra)
	placeSeed(posTable)
end
function trashSeed(slot)
	print("Trashing")
	move(cpos.bin)
	lastSl = r.select(slot)
	succes = r.dropDown()
	r.select(lastSl)
	return succes
end
function storeYeld()
	print("Storing Yelds")
	localSlot = slot.seedsExtra
	if not compareItemInSlot("minecraft:coal",1) and checkCount(1,1) then
		localSlot = 1
	end
	if not compareItemInSlot("agricraft:crop_sticks",2) and checkCount(2,1) then
		localSlot = 2
	end
	if not compareItemInSlot("agricraft:crop_sticks",3) and checkCount(3,1) then
		localSlot = 3
	end
	if not compareItemInSlot("agricraft:rake",4) and checkCount(4,1) then
		localSlot = 4
	end
	move(cpos.chest)
	lastSl = r.select(localSlot)
	succes = r.dropDown()
	r.select(lastSl)
end

function waitForSeedToGrow()
	while count(slot.seeds) < 1 do
		move(fl.pos[5])
		toDelete = {empty = true}
		for i=5,16,1 do
		  if checkCount(i,1) and toDelete.empty then
		    --print("Trashing item in slot "..i)
		    toDelete.empty = false
		 end end
		if not toDelete.empty then
		  move(cpos.bin)
		  local lastSl = r.select(5)
		  for i=5,16,1 do
        local lastSl = r.select(i)
        r.dropDown()
		  end
		   r.select(lastSl)
		end
		os.sleep(sleepAmountWhenWachingSeeds)
		move(fl.pos[4])
		useRakeDown(slot.seeds)
		if count(slot.seeds) < 1 then
			r.swingDown(side.down)
			if count(slot.seeds) < 1 then
				placeStick(fl.pos[4],true)
		end	end
		if not compareItemInSlot(seedName,slot.seeds) and checkCount(slot.seeds,1) then
			trashSeed(slot.seeds)
		end	end
	return true
end

function forward(n)
	if fuel() then -- Checks for fuel()
		for i=1,n do -- Executes r.forward() $n number of times
			r.forward() -- Moves the robot forward
		end
		return true
	end
	return false
end
function back(n)
	if fuel() then -- Checks for fuel()
		for i=1,n do -- Executes r.back() $n number of times
			r.back() -- Moves the robot backwards
		end
		return true
	end
	return false
end
function up(n)
	if fuel() then -- Checks for fuel()
		for i=1,n do -- Executes r.up() $n number of times
			r.up() -- Moves the robot upwards
		end
		return true
	end
	return false
end
function down(n)
	if fuel() then -- Checks for fuel()
		for i=1,n do -- Executes r.down() $n number of times
			r.down() -- Moves the robot downwards
		end
		return true
	end
	return false
end
function left(n)
	if fuel() then -- Checks for fuel()
		r.turnLeft() -- Turns the robot to the left
		for i=1,n do -- Executes r.forward() $n number of times
			r.forward() -- Moves the robot forward
		end
		r.turnRight() -- Turns the robot to the right
		return true
	end
	return false
end
function right(n)
	if fuel() then 
	  r.turnRight() -- Turns the robot to the right
	  for i=1,n do -- Executes r.forward() $n number of times
		r.forward() -- Moves the robot forward
	  end
	  r.turnLeft() -- Turns the robot to the left
	  return true
	end
	return false
end


function move(x,y,z)
	if y == nil then
		tbl = x
		x = tbl.x - pos.x
		y = tbl.y - pos.y
		z = tbl.z - pos.z
	else
		x = x - pos.x
		y = y - pos.y
		z = z - pos.z		
	end
	if y > 0 then
		up(y)
		os.sleep(0.1)
	end
	if x > 0 then
		right(x)
		os.sleep(0.1)
	end
	if x < 0 then
		left(math.abs(x))
		os.sleep(0.1)
	end
	if z > 0 then
		back(z)
		os.sleep(0.1)
	end
	if z < 0 then
		forward(math.abs(z))
		os.sleep(0.1)
	end
	if y < 0 then
		down(math.abs(y))
		os.sleep(0.1)
	end
	pos.x = pos.x + x
	pos.y = pos.y + y
	pos.z = pos.z + z
end





function main()
  t.clear()
  t.setCursor(1,1)
  print("Number of generations: "..numOfSubGenerations/4)
  print("Sleep amount between generations: "..sleepAmountBetweenGenerations.."s")
  print("Sleep amount when watching seeds: "..sleepAmountWhenWachingSeeds.."s")
  print(lang_line)
	if fuel() and sticks() and rake() then
		numOfSeeds = seeds()
		if numOfSeeds == 1 then
      _G.seedName = getSeedName()
      print("Seed set to: ".._G.seedName)
			placeStick(fl.pos[0])
			placeSeed(fl.pos[0])
			placeStick(fl.pos[4],true)
			waitForSeedToGrow()
			analyze()
			storeYeld()
		else
			noSeeds()
		end
		while numOfSubGenerations > curSubGen do
			placeStick(fl.pos[seedRepl])
			replaceSeeds(fl.pos[seedRepl])
			storeYeld()
			trashSeed(slot.seedsExtra+1)
			placeStick(fl.pos[4],true)
			waitForSeedToGrow()
			analyze()
			storeYeld()
			seedRepl = seedRepl + 1
			if seedRepl >= 4 then
				seedRepl = 0
				print(lang_line)
				print(lang_timeBtwGen..sleepAmountBetweenGenerations)
				print(lang_curGen..curSubGen/4)
				print(lang_line)
				breakStick(fl.pos[4])
				os.sleep(sleepAmountBetweenGenerations)
			end
			curSubGen = curSubGen + 1
		end
		print("Maximum number of generations reached! You seed might not be 10/10/10!")
	end
end
 

local suckTimer = require("event").timer(0.5, suckItems, math.huge)
main()

event.cancel(suckTimer)

