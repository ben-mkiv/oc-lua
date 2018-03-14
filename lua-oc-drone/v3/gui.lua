require("package").loaded.guiH = nil
require("guiH")

gpu = require("component").gpu

function moveWaypoint(name, offset)
	local wp = findWaypointDrone(name, 32)
	
	if offset then
		wp.position[1] = wp.position[1] + offset[1]
		wp.position[2] = wp.position[2] + offset[2]
		wp.position[3] = wp.position[3] + offset[3]
	end
	
	flyStupid({wp.position[1], wp.position[2], wp.position[3]})
	ai.sendC("return waitMoving()")	
end


function botania()
	print("botania cycle")
	ai.sendC("return waitMoving()")
	moveWaypoint("Botania")
	
	ai.sendC("land()")
	droneEnergy = tonumber(ai.sendC("return e2p()"))
	while droneEnergy < 90 do
		ai.sendC("d.setStatusText('cE: "..droneEnergy.."%')")
		droneEnergy = tonumber(ai.sendC("return e2p()"))
	end
		
	moveWaypoint("Botania")	
	
	ai.sendC("d.setStatusText('flowers!!!11')")
	
	for offX=1,7 do	
		for offZ=1,7 do
			--moveWaypoint("Botania", {(-1*offX), 1, offZ})
			ai.sendC("return waitMoving()")
			ai.sendC("if d.detect(0) == true then d.swing(0) end")
			flyStupid({0, 0, 1})
			
			if offZ == 7 then 
				flyStupid({-1, 0, 0})
				if offX ~= 7 then flyStupid({0, 0, -7}) end
			end
		end 
	end	
	botania()
end


gui:addButton(1, 1, 30, 1, "drone control", "all", 0x0, 0xFFFFFF, "center", drawMain)

gui:addButton(20, 17, 10, 2, "test", "all", 0x0, 0xFF9812, "center", botania, 32)


function selectSide(cb)
	for i=1,#sides do
		gui:addButton(2, 4+i, 20, 1, sides[i], "selectSide", 0x0, 0xFFFFFF, "center", cb, i)
	end
	
	gui:drawScreen("selectSide")
end


checkAIComponents()


gpu.setResolution(40,40)
drawMain()

--interpret Events
while true do
  local id, _, x, y, btn, user = event.pullMultiple("touch", "interrupted")

  if id == "interrupted" then
	term.clear()
	gpu.setResolution(60,30)
	os.exit()
  end

  if id == "touch" then
    if touchTimer then
      event.cancel(touchTimer)
      touchTimer = false
    end

    gui:touchEvent(x, y, user)

    if gui.currentScreen ~= "main" then
      if gui.currentScreen == "foobar" then
        --touchTimer = event.timer(30, drawMain)
      else
        --touchTimer = event.timer(5, drawMain)    
      end
    end
  end
end
