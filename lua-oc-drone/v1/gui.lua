require("package").loaded.ai = nil
require("package").loaded.colorsRGB = nil

ai = require("ai")
require("colorsRGB")
sides = require("sides")

n = component.navigation



function selectRGBColor()
  local i=1
  for c in pairs (colorsRGB.list) do
    
    local page = math.floor(i/30)
    local x = page * 3
    local y = i-(page*30)

    gui.addButton(2+x, 2+y, 2, 1, "#", "selectRGBColor", 0x0, colorsRGB.HEX(c), "center", ai.colorHEX, colorsRGB.HEX(c))
    i=i+1
  end
  gui.drawScreen("selectRGBColor")
end

function checkLocalFacing()
	if n then
		return n.getFacing()		
	end
	
	return false
end

steps = 1

function setSteps(val)
	steps = steps + val
	return drawMain()	
end
	


function drawMain()
  gui.flush(true)

  facing = checkLocalFacing()
  
  if facing then
	gui.addButton(1, 20, 30, 1, "tablet navi online ("..sides[facing]..")", "all", 0x2B2B2B, 0x156C00, "center", drawMain)	
  else
	gui.addButton(1, 20, 30, 1, "tablet navi offline", "all", 0xDEDEDE, 0x810000, "center", drawMain)	
  end
  
  gui.addButton(2, 3, 6, 2, "up", "main", 0x0, 0xB2F3FF, "center", ai.move, {x=0, y=steps, z=0})
  gui.addButton(2, 5, 6, 2, "down", "main", 0x0, 0xCCFFBC, "center", ai.move, {x=0, y=-1*steps, z=0})

  
  gui.addButton(20,  3, 5, 3, "n", "main", 0x0, 0xFFFFFF, "center", ai.move, {x=0, y=0, z=-1*steps})
  gui.addButton(15,  6, 5, 3, "w", "main", 0x0, 0xFFFFFF, "center", ai.move, {x=-1*steps, y=0, z=0})
  gui.addButton(25,  6, 5, 3, "e", "main", 0x0, 0xFFFFFF, "center", ai.move, {x=steps, y=0, z=0})
  gui.addButton(20,  9, 5, 3, "s", "main", 0x0, 0xFFFFFF, "center", ai.move, {x=0, y=0, z=steps})
  
  gui.addButton(20,  6, 5, 1, "+", "main", 0x0, 0xF6FF80, "center", setSteps, 1)
  
  local ix = gui.addButton(20,  7, 5, 1, ""..steps, "main", 0xEDEDFF, 0x696969, "center")
  gui.setElement({ index = ix, textPadding = 0 })
  
  gui.addButton(20,  8, 5, 1, "-", "main", 0x0, 0xF6FF80, "center", setSteps, -1)
  
  
  if ai.leash == true then
	gui.addButton(2, 9, 9, 1, "leash", "main", 0x0, 0x2EA100, "center", ai.leash, sides.bottom)
	gui.addButton(2, 10, 9, 1, "unleash", "main", 0x0, 0xBB3D00, "center", ai.unleash)
  end
  
  if ai.inventorySize > 0 then
	gui.addButton(2, 11, 9, 1, "use", "main", 0x0, 0x91008A, "center", selectSide, ai.use)
	gui.addButton(2, 12, 9, 1, "swing", "main", 0x0, 0x91008A, "center", selectSide, ai.swing)
end


  gui.addButton(2, 17, 14, 2, "change color", "main", 0x0, 0xFF9812, "center", selectRGBColor)
  
  gui.addButton(1, 19, 14, 1, "speed: "..(math.floor(0.5+(ai.curSpeed*10))/10), "main", 0x0, 0xFFFFFF, "center", setSpeed, 0.1)
  gui.addButton(14, 19, 4, 1, "-", "main", 0x0, 0xFFDDEE, "center", setSpeed, -0.1)
  gui.addButton(18, 19, 4, 1, "--", "main", 0x0, 0xFFDDEE, "center", setSpeed, -0.5)
  gui.addButton(22, 19, 4, 1, "+", "main", 0x0, 0xFFFFFF, "center", setSpeed, 0.1)
  gui.addButton(26, 19, 4, 1, "++", "main", 0x0, 0xFFFFFF, "center", setSpeed, 0.5)
  
  
  
  
  gui.drawScreen("main")
end

function findWaypoints(range)
	local data = ai.sendC("return n.findWaypoints("..range..")")
	
	if not data then
		return false
	end 
	
	return data[1]	
end

function listWaypoints(range)
	wayPointsDrone = findWaypoints(range)

end


function setSpeed(speed)
	ai.setSpeed(speed)
	ai.getSpeed()
	drawMain()
	return ai.curSpeed
end

function test()
	os.exit()
end

gui.addButton(1, 1, 30, 1, "drone control", "all", 0x0, 0xFFFFFF, "center", drawMain)

function selectSide(cb)
	for i=1,#sides do
		gui.addButton(2, 4+i, 20, 1, sides[i], "selectSide", 0x0, 0xFFFFFF, "center", cb, i)
	end
	
	gui.drawScreen("selectSide")
end


function checkAIComponents()
	print("init started")

	dC = ai.sendC("return component.list()")

	ai.curSpeed = ai.getSpeed()
	
	for ad in pairs(dC) do
		if dC[i] == "navigation" then
			print("found navigation on robot")
			ai.navigation = true
		elseif dC[i] == "leash" then
			print("found leash on robot")
			ai.leash = true
		end
	end
		
	print("checking inventory size on robot")	
	ai.inventorySize = ai.sendC("return d.inventorySize()")
	
	
	print("done with init")	
end

checkAIComponents()


gpu.setResolution(30,20)
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

    gui.touchEvent(x, y, user)

    if gui.currentScreen ~= "main" then
      if gui.currentScreen == "foobar" then
        touchTimer = event.timer(30, drawMain)
      else
        touchTimer = event.timer(5, drawMain)    
      end
    end
  end
end
