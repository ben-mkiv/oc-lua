sides = require("sides")
 
wootOrientation = false
lastTarget = false
activeController = false

function saveMob(mob)
	d = io.open("/etc/woot.cfg", "w")
	d:write(mob)
	d:close()
end

function getMob()
	d = io.open("/etc/woot.cfg", "r")
	local mob = d:read("*a")
	d:close()
	return mob
end

function findWootpoints(range)
	print("searching woot points, range: "..range)
	local tw = _G.n.findWaypoints(range)
	local wootPoints = {}
	for i=1, #tw do	
		if _G.serialization.unserialize(tw[i].label) then 
			tw[i].label = _G.serialization.unserialize(tw[i].label)
			if tw[i].label.woot then table.insert(wootPoints, tw[i]) end 
	end	end 
	return wootPoints 
end

function goStupid(pos, try, skip) 
	print("going stupid... ".._G.serialization.serialize(pos))
	if not try then try = 1 end
	if not skip then skip = 0 end
	while _G.n.getFacing() ~= sides.north do
		_G.d.turn(false) end	
	
	if skip < 1 then
	while pos[3] > 0 do 
		if not _G.d.move(2) then break end
		pos[3]=pos[3]-1 end	
	while pos[3] < 0 do 
		if not _G.d.move(3)  then break end
		pos[3]=pos[3]+1 end	
	end
	
	if skip < 2 then
	while pos[2] > 0 do 
		if not _G.d.move(1) then break end
		pos[2]=pos[2]-1 end	
	while pos[2] < 0 do 
		if not _G.d.move(0) then break end
		pos[2]=pos[2]+1 end	
	end
	
	if skip < 3 then
	while _G.n.getFacing() ~= sides.east do
		_G.d.turn(true) end	
	while pos[1] > 0 do 
		if not _G.d.move(3) then break end
		pos[1]=pos[1]-1 end	
	while pos[1] < 0 do 
		if not _G.d.move(2) then break end
		pos[1]=pos[1]+1 end	
	end
	
	while _G.n.getFacing() ~= sides.north do
		_G.d.turn(false) end	
		
	if try > 3 then
		gotoWoot(lastTarget, true)
		return goStupid(pos, nil, (skip+1))		
	end
	
	if skip > 2 then
		print("tried so hard ;_;")
		return false
	end
			
	if pos[1] ~= 0 or pos[2] ~= 0 or pos[3] ~= 0 then
		return goStupid(pos, (try+1))
	end
	
	return true	
end 

function mineBlock(side, inventory_slot)
	print("mining block at: "..sides[side])
	if not inventory_slot or inventory_slot == nil then local inventory_slot = 1 end
	if _G.d.detect(side) then
		if _G.d.count(inventory_slot) > 0 then
			print("no space in current inventory slot")
			return false
		end
		
		_G.d.swing(side)		
		
		if _G.d.count(inventory_slot) == 1 then 
			print("succedd")
			return true 
		end
	end 
	
	print("something went wrong")
	return false		
end

function getWootOrientation()
	gotoWoot("front") 
	local tw = findWootpoints(32) 
	for i=1,#tw do if tw[i].label.woot == "controller" then 
		if tw[i].position[1] > 0 then 
			wootOrientation = sides.east
		elseif tw[i].position[1] < 0 then 
			wootOrientation = sides.west
		elseif tw[i].position[3] > 0 then 
			wootOrientation = sides.south
		elseif tw[i].position[3] < 0 then 
			wootOrientation = sides.north 
end end end 
	return wootOrientation 
end

function gotoWoot(name, fromPosition) 
	print("going to wootpoint: "..name)
	if wootOrientation == false and name ~= "front" then getWootOrientation() end
		
	local tw = findWootpoints(32) 
	for i=1,#tw do 
		if tw[i].label.woot == name then 
			print("found it")
			local p1 = tw[i].position[1]
			local p2 = tw[i].position[2]
			local p3 = tw[i].position[3]
			
			if name == "controller" then
				if wootOrientation == sides.north then p1 = 1+tw[i].position[3]
				elseif wootOrientation == sides.south then p1 = -1+tw[i].position[3]
				elseif wootOrientation == sides.east then p1 = -1+tw[i].position[1]
				elseif wootOrientation == sides.west then p1 = 1+tw[i].position[1] end
			else p2 = 1+tw[i].position[2] end			
			if goStupid({p1, p2, p3}) then
				lastTarget = name
			end
	end	end 
end

function getCurrentController()
	print("going to mine the active woot controller")
	gotoWoot("controller")
	while _G.n.getFacing() ~= wootOrientation do _G.d.turn(true) end
	
	local s = mineBlock(3, 1) 
	gotoWoot("front")
	if s then 
		activeController = false
		return true 
	end	
	
	return false		
end

function getStorageController(name)
	print("getting controller from storage: "..name)

	gotoWoot("storage")
	gotoWoot(name)
	
	local s = mineBlock(0)
	
	gotoWoot("storage")
		
	if s then return true end
	
	return false
end

function putBackController(name)
	print("putting back controller: "..name)
	if not name then name = activeController end
	
	if getCurrentController() then
		gotoWoot("storage")
		gotoWoot(name)
		_G.d.place(0)
		gotoWoot("storage")
		gotoWoot("front")
	end
	
	return false	
end

function setController(name)
	print("set Controller: "..name)
	if activeController then
		local t = activeController
		if getCurrentController() then
			gotoWoot("storage")
			gotoWoot(t)
			_G.d.place(0)
		end
	end
	
	gotoWoot("storage")
	
	gotoWoot(name)
	
	if mineBlock(0, 1) then activeController = false end
		
	gotoWoot("storage")
	gotoWoot("front")
	gotoWoot("controller")
	while _G.n.getFacing() ~= wootOrientation do _G.d.turn(true) end	
	_G.d.place(3)
	activeController = name
	saveMob(activeController)
	gotoWoot("front")		
end

function listWootpoints(onlyMobs)
	local tw = findWootpoints(32)
	for i=1,#tw do 
		if onlyMobs == true and ( tw[i].label.woot == "controller" or tw[i].label.woot == "front" ) then
		else
		 print(tw[i].label.woot.." :: "..tw[i].label[1])	
end end end

