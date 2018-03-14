require("package").loaded.ai = nil
require("package").loaded.colorsRGB = nil

ai = require("ai")
require("colorsRGB")
sides = require("sides")

if component.list("navigation")() then n = component.navigation end

function flyStupid(pos)
	ai.move({ x = pos[1], y = 0, z = 0})
	ai.move({ x = 0, y = pos[2], z = 0})
	ai.move({ x = 0, y = 0, z = pos[3]})
end

function addWaypoint(wp, source)
	if source == "drone" then wp.drone = wp.position 
	elseif source == "tablet" then wp.tablet = wp.position end
	
	for i=1,#ai.wayPoints do
		if wp.label == ai.wayPoints[i].label then
			if source == "drone" then
				ai.wayPoints[i].drone = wp.position
				return true
			elseif source == "tablet" then
				ai.wayPoints[i].tablet = wp.position
				return true	
			end
			return false
	end	end
	
	table.insert(ai.wayPoints, wp)
	return true
end

function findWaypoints(range, tablet)
	local tw
	if tablet == true then tw = n.findWaypoints(range)
	else tw = ai.sendC("return n.findWaypoints("..range..")") end	
	
	for i=1, #tw do	tw[i] = interpretWaypoint(tw[i]) end		
	return tw
end

function interpretWaypoint(wp)
	if serialization.unserialize(wp.label) then
		local tmp = serialization.unserialize(wp.label)
		wp.label = tmp[1]
		
		if tmp[2] then
			wp.position[1] = wp.position[1] + tmp[2][1]
			wp.position[2] = wp.position[2] + tmp[2][2]
			wp.position[3] = wp.position[3] + tmp[2][3]
	end	end
	
	return wp
end

function findWootpoints(range)
	local tw = ai.sendC("return n.findWaypoints("..range..")")	
	local wootPoints = {}
	for i=1, #tw do	
		if serialization.unserialize(tw[i].label) then 
			tw[i].label = serialization.unserialize(tw[i].label)
			if tw[i].label.woot then table.insert(wootPoints, tw[i]) end 
	end	end 
	return wootPoints 
end

function goStupid(pos, try, skip) 
	if not try then try = 1 end
	if not skip then skip = 0 end
	while tonumber(ai.sendC("return n.getFacing()")) ~= sides.north do
		ai.sendC("d.turn(false)") end	
	
	if skip < 1 then
	while pos[3] > 0 do 
		if not ai.sendC("return d.move(2)") then break end
		pos[3]=pos[3]-1 end	
	while pos[3] < 0 do 
		if not ai.sendC("return d.move(3)")  then break end
		pos[3]=pos[3]+1 end	
	end
	
	if skip < 2 then
	while pos[2] > 0 do 
		if not ai.sendC("return d.move(1)")  then break end
		pos[2]=pos[2]-1 end	
	while pos[2] < 0 do 
		if not ai.sendC("return d.move(0)")  then break end
		pos[2]=pos[2]+1 end	
	end
	
	if skip < 3 then
	while tonumber(ai.sendC("return n.getFacing()")) ~= sides.east do
		ai.sendC("d.turn(true)") end	
	while pos[1] > 0 do 
		if not ai.sendC("return d.move(3)")  then break end
		pos[1]=pos[1]-1 end	
	while pos[1] < 0 do 
		if not ai.sendC("return d.move(2)")  then break end
		pos[1]=pos[1]+1 end	
	end
	
	while tonumber(ai.sendC("return n.getFacing()")) ~= sides.north do
		ai.sendC("d.turn(false)") end	
		
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

wootOrientation = false
lastTarget = false

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
	gotoWoot("controller")
	ai.sendC("while n.getFacing() ~= "..wootOrientation.." do d.turn(true) end")
	
	ai.sendC("return d.detect(3)")

end

function listWootpoints(onlyMobs)
	local tw = findWootpoints(32)
	for i=1,#tw do 
		if onlyMobs == true and ( tw[i].label.woot == "controller" or tw[i].label.woot == "front" ) then
		else
		 print(tw[i].label.woot.." :: "..tw[i].label[1])	
end end end

function findWaypointDrone(name, range)
	local tw = findWaypoints(range, false)
	for i=1,#tw do if tw[i].label == name then return tw[i] end end
	return false	
end

function pos2txt(t, short)
	if short then return ""..t[1]..","..t[2]..","..t[3]	end
	return "x: "..t[1]..", y: "..t[2]..", z: "..t[3]	
end

function listWaypoints(range)
	if not range or range == nil then range = 16 end
	ai.wayPoints = {}
	local wayPointsTablet
	local wayPointsDrone = findWaypoints(range, false)

	if wayPointsDrone then for i=1,#wayPointsDrone do
		addWaypoint(wayPointsDrone[i], "drone")
	end	end
	
	if n then
		wayPointsTablet = findWaypoints(range, true)
		for i=1,#wayPointsTablet do	addWaypoint(wayPointsTablet[i], "tablet") end		
	end
	
	gui:addButton(2, 3, 28, 1, "waypoints", "waypointList", 0x0, 0xFF8300, "center", drawMain)
	
	for i=1,#ai.wayPoints do
		bgcol = 0xFF0000
		if i%2 == 0 then bgcol = bgcol - 0x101010 end	
		gui:addButton(3, 4+(3*(i-1)), 26, 1, ai.wayPoints[i].label, "waypointList", 0x0, bgcol, "left")
		if ai.wayPoints[i].drone then		
			gui:addButton(3, 5+(3*(i-1)), 26, 1, "drone: ".. pos2txt(ai.wayPoints[i].drone), "waypointList", 0x0, bgcol, "left", flyStupid, ai.wayPoints[i].drone)
		end
		if ai.wayPoints[i].tablet then		
			if ai.wayPoints[i].drone then
				local userOffset = { ai.wayPoints[i].drone[1]-ai.wayPoints[i].tablet[1], ai.wayPoints[i].drone[2]-ai.wayPoints[i].tablet[2], ai.wayPoints[i].drone[3]-ai.wayPoints[i].tablet[3] }
				userOffset[2] = userOffset[2] + 3
			else local userOffset = {0, 0, 0} end
			gui:addButton(3, 6+(3*(i-1)), 26, 1, " user: ".. pos2txt(ai.wayPoints[i].tablet), "waypointList", 0x0, bgcol, "left", flyStupid, userOffset)
		end
	end
	
	gui:drawScreen("waypointList")
end

function drawMain()
  gui:flushElements(true)

  facing = checkLocalFacing()
  
  if facing then
	gui:addButton(1, 20, 30, 1, "tablet navi online ("..sides[facing]..")", "all", 0x2B2B2B, 0x156C00, "center", drawMain)	
  else
	gui:addButton(1, 20, 30, 1, "tablet navi offline", "all", 0xDEDEDE, 0x810000, "center", drawMain)	
  end
  
  gui:addButton(2, 3, 6, 2, "up", "main", 0x0, 0xB2F3FF, "center", ai.move, {x=0, y=steps, z=0})
  gui:addButton(2, 5, 6, 2, "down", "main", 0x0, 0xCCFFBC, "center", ai.move, {x=0, y=-1*steps, z=0})

  
  gui:addButton(20,  3, 5, 3, "n", "main", 0x0, 0xFFFFFF, "center", ai.move, {x=0, y=0, z=-1*steps})
  gui:addButton(15,  6, 5, 3, "w", "main", 0x0, 0xFFFFFF, "center", ai.move, {x=-1*steps, y=0, z=0})
  gui:addButton(25,  6, 5, 3, "e", "main", 0x0, 0xFFFFFF, "center", ai.move, {x=steps, y=0, z=0})
  gui:addButton(20,  9, 5, 3, "s", "main", 0x0, 0xFFFFFF, "center", ai.move, {x=0, y=0, z=steps})
  
  gui:addButton(20,  6, 5, 1, "+", "main", 0x0, 0xF6FF80, "center", setSteps, 1)
  
  local ix = gui:addButton(20,  7, 5, 1, ""..steps, "main", 0xEDEDFF, 0x696969, "center")
  gui:setElement({ index = ix, textPadding = 0 })
  
  gui:addButton(20,  8, 5, 1, "-", "main", 0x0, 0xF6FF80, "center", setSteps, -1)
  
  
  if ai.leash == true then
	gui:addButton(2, 9, 9, 1, "leash", "main", 0x0, 0x2EA100, "center", ai.leash, sides.bottom)
	gui:addButton(2, 10, 9, 1, "unleash", "main", 0x0, 0xBB3D00, "center", ai.unleash)
  end
  
  if ai.inventorySize > 0 then
	gui:addButton(2, 11, 9, 1, "use", "main", 0x0, 0x91008A, "center", selectSide, ai.use)
	gui:addButton(2, 12, 9, 1, "swing", "main", 0x0, 0x91008A, "center", selectSide, ai.swing)
  end


  gui:addButton(2, 17, 14, 2, "change color", "main", 0x0, 0xFF9812, "center", selectRGBColor)
  
  gui:addButton(1, 19, 14, 1, "speed: "..(math.floor(0.5+(ai.curSpeed*10))/10), "main", 0x0, 0xFFFFFF, "center", setSpeed, 0.1)
  gui:addButton(14, 19, 4, 1, "-", "main", 0x0, 0xFFDDEE, "center", setSpeed, -0.1)
  gui:addButton(18, 19, 4, 1, "--", "main", 0x0, 0xFFDDEE, "center", setSpeed, -0.5)
  gui:addButton(22, 19, 4, 1, "+", "main", 0x0, 0xFFFFFF, "center", setSpeed, 0.1)
  gui:addButton(26, 19, 4, 1, "++", "main", 0x0, 0xFFFFFF, "center", setSpeed, 0.5)
 
  gui:addButton(13, 15, 16, 2, "list waypoints", "main", 0x0, 0xFF9812, "center", listWaypoints, 32)

  gui:drawScreen("main")
end

function selectRGBColor()
  local i=1
  for c in pairs (colorsRGB.list) do
    local page = math.floor(i/30)
    local x = page * 3
    local y = i-(page*30)

    gui:addButton(2+x, 2+y, 2, 1, "#", "selectRGBColor", 0x0, colorsRGB.HEX(c), "center", ai.colorHEX, colorsRGB.HEX(c))
    i=i+1
  end
  gui:drawScreen("selectRGBColor")
end

function checkLocalFacing()
  if n then return n.getFacing() end
  return false
end

steps = 1
function setSteps(val)
  steps = steps + val
  return drawMain()	
end

function setSpeed(speed)
	ai.setSpeed(speed)
	ai.getSpeed()
	drawMain()
	return ai.curSpeed
end

function checkAIComponents()
	print("init started")
	dC = ai.sendC("return component.list()")
	if not dC or dC == nil then
		print(":( init failed")
		os.exit() end
	ai.curSpeed = ai.getSpeed()
	for ad in pairs(dC) do
		if dC[ad] == "navigation" then
			print("found navigation on robot")
			ai.navigation = true
		elseif dC[ad] == "leash" then
			print("found leash on robot")
			ai.leash = true
		elseif dC[ad] == "inventory_controller" then
			print("found inventory controller on robot")
			ai.inventoryController = true
		end
	end
	print("checking inventory size on robot")	
	ai.inventorySize = ai.sendC("return d.inventorySize()")
	print("done with init")	
end
