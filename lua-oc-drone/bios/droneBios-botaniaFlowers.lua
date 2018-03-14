--drone
d=component.proxy(component.list("drone")())
--navigation
n=component.proxy(component.list("navigation")())



function unserialize(data)
  checkArg(1, data, "string")
  local result, reason = load("return " .. data, "=data", _, {math={huge=math.huge}})
  if not result then
    return nil, reason
  end
  local ok, output = pcall(result)
  if not ok then
    return nil, output
  end
  return output
end


function interpretWaypoint(wp)
	if unserialize(wp.label) then
		local tmp = unserialize(wp.label)
		wp.label = tmp[1]
		wp.position[1] = wp.position[1] + tmp[2][1]
		wp.position[2] = wp.position[2] + tmp[2][2]
		wp.position[3] = wp.position[3] + tmp[2][3]
	end	
	return wp
end

function findWaypoints(range)
	local tw = n.findWaypoints(range)	
	for i=1, #tw do	tw[i] = interpretWaypoint(tw[i]) end		
	return tw
end


function findWaypointDrone(name, range)
	local tw = findWaypoints(range)
	if not tw or tw == nil then return end
	for i=1,#tw do if tw[i].label == name then return tw[i] end	end
	return false	
end

function moveWaypoint(name, offset)
	local wp = findWaypointDrone(name, 32)	
	if not wp or wp == nil then error("no waypoint found") end	
	if offset then
		wp.position[1] = wp.position[1] + offset[1]
		wp.position[2] = wp.position[2] + offset[2]
		wp.position[3] = wp.position[3] + offset[3]
	end	
	d.move(wp.position[1], wp.position[2], wp.position[3])
	return waitMoving()	
end

function botania()
	d.setLightColor(0xFFB300)	
	waitMoving()	
	moveWaypoint("Botania")
	land()
	dE = e2p()
	d.setLightColor(0xFF0000)
	while dE < 90 do		
		d.setStatusText("dE: "..dE.."%")
		dE = e2p()
	end	
	d.setLightColor(0xFFB300)
	
	moveWaypoint("Botania")		
	
	d.setLightColor(0x00FF00)	
	d.setStatusText("flowers!!!11")	
	for offX=1,7 do	
		for offZ=1,7 do
			waitMoving()
			if d.detect(0) == true then d.swing(0) end
			
			if offX%2 == 0 then d.move(0,0,-1)
			else d.move(0,0,1) end			
			
			if offZ == 7 and offX ~= 7 then d.move(-1,0,0) end
		end 
	end
end

landing=false
function land()
landing = true
while landing do
waitMoving()
local s,b=d.detect(0)
if b == "solid" or b == "liquid" then break	end		
d.move(0, -1, 0)		
end
landing = false
end
function waitMoving()
while true do if d.getOffset() < 0.1 then return "true" end end
end
function e2p() 
return math.floor((100/computer.maxEnergy())*computer.energy()) 
end

while true do
	botania()
end
