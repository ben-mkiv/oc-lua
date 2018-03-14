require ("package").loaded.hazeUI = nil
require ("package").loaded.borders = nil

_G.touchTimeouts = {}

event = require("event")
ser = require("serialization")
sides = require("sides")   
component = require("component")

require("hazeUI") 

_G.gui = clone(hazeUI)
gui.gpu = component.gpu

iT = component.proxy("932010ac-1a24-4e26-874f-105b367a6976")
iS = sides.north

spawnerList = {}

table.insert(spawnerList, { a = "edd40f2e-becf-4d24-9c59-acffdb23970f", name = "witch", side = sides.north})
table.insert(spawnerList, { a = "edd40f2e-becf-4d24-9c59-acffdb23970f", name = "horse", side = sides.east})
table.insert(spawnerList, { a = "edd40f2e-becf-4d24-9c59-acffdb23970f", name = "cow", side = sides.south})
table.insert(spawnerList, { a = "edd40f2e-becf-4d24-9c59-acffdb23970f", name = "sheep", side = sides.west})

table.insert(spawnerList, { a = "f664d326-b9dc-4c6b-9de4-2f3e4983ec62", name = "ghast", side = sides.north})
table.insert(spawnerList, { a = "f664d326-b9dc-4c6b-9de4-2f3e4983ec62", name = "squid", side = sides.east})
table.insert(spawnerList, { a = "f664d326-b9dc-4c6b-9de4-2f3e4983ec62", name = "enderman", side = sides.south})
table.insert(spawnerList, { a = "f664d326-b9dc-4c6b-9de4-2f3e4983ec62", name = "guardian", side = sides.west})

table.insert(spawnerList, { a = "8bbdce98-d0c5-44d5-ac18-5ad517fafd02", name = "bat", side = sides.north})
table.insert(spawnerList, { a = "8bbdce98-d0c5-44d5-ac18-5ad517fafd02", name = "polar bear", side = sides.east})
table.insert(spawnerList, { a = "8bbdce98-d0c5-44d5-ac18-5ad517fafd02", name = "blizz", side = sides.south})
table.insert(spawnerList, { a = "8bbdce98-d0c5-44d5-ac18-5ad517fafd02", name = "ancient golem", side = sides.west})

table.insert(spawnerList, { a = "1feebe72-ab2c-4367-98b0-0dce1d416409", name = "wither skell", side = sides.north})
table.insert(spawnerList, { a = "1feebe72-ab2c-4367-98b0-0dce1d416409", name = "slime", side = sides.south})
table.insert(spawnerList, { a = "1feebe72-ab2c-4367-98b0-0dce1d416409", name = "wolf", side = sides.east})
table.insert(spawnerList, { a = "1feebe72-ab2c-4367-98b0-0dce1d416409", name = "ocelot", side = sides.west})

table.insert(_G.touchTimeouts, { name = "default", t = 5 })
table.insert(_G.touchTimeouts, { name = "warning", t = 0 })
table.insert(_G.touchTimeouts, { name = "info", t = 10 })
table.insert(_G.touchTimeouts, { name = "main", t = 0 })
table.insert(_G.touchTimeouts, { name = "fillMob", t = 0 })
table.insert(_G.touchTimeouts, { name = "fillMobDone", t = 10 })
table.insert(_G.touchTimeouts, { name = "fillMobFailed", t = 10 })


function getTouchtimeout(name)
	for i=1,#_G.touchTimeouts do if _G.touchTimeouts[i].name == name then return _G.touchTimeouts[i].t end end
	return getTouchtimeout("default")
end

function importVial()
  gui:flushElements(true)
  local item = iT.getStackInSlot(iS, 1)
  
  if item and item.label == "Soul Vial" and item.name == "enderio:itemSoulVessel" then
    if item.hasTag == false then
      iT.transferItem(iS, sides.bottom, 1, 1, 1)

      if iT.getStackInSlot(sides.bottom, 1) then
        return true
      end
    else
      gui:addButton(4, 4, 60, 3, "soul vial must be empty", "fillMob", 0x0, 0xFF2020, "center", drawMain)
    end
  else
    gui:addButton(4, 4, 60, 3, "please put a empty soul vial on the injector", "fillMob", 0x0, 0xFF2020, "center", drawMain)
  end
  
  gui:drawScreen("fillMob")
  return false  
end


function fillMob(spawner)
  if importVial() then
  gui:flushElements(true)
  gui:addButton(4, 4, 60, 3, "filling mob", "fillMob", 0x0, 0xFFD200, "center")
  gui:drawScreen("fillMob");
  
  local j=0
   
  while not spawner.t.transferItem(sides.bottom, spawner.side, 1, 1) do
	j = 1+j
	gui:drawStatusbar(5, 10, 40, 1, 250, j, "moving vial to spawner")	
  end
	
  while spawner.t.getStackInSlot(spawner.side, 2) == nil do
	j = 1+j
	gui:drawStatusbar(5, 10, 40, 1, 250, j, "filling mob to soul vial")	
  end

  while not spawner.t.transferItem(spawner.side, sides.bottom, 1, 2, 2) do
    j = 1+j
	gui:drawStatusbar(5, 10, 40, 1, 250, j, "moving vial back to injector")	
  end  
  
  while not iT.transferItem(sides.bottom, iS, 1, 2, 1) do
    j = 1+j
	gui:drawStatusbar(5, 10, 40, 1, 250, j, "moving vial back to injector")	
  end   
  
  gui:drawStatusbar(5, 10, 40, 1, 250, 250, "done")	
  
  gui:addButton(4, 20, 40, 3, "done, your filled vial is in the injector", "fillMobDone", 0x0, 0x9DFF68, "center", drawMain)
  gui:drawScreen("fillMobDone");
    return true
  end
  
  gui:addButton(4, 20, 60, 3, "filling failed!", "fillMobFailed",  0x0, 0xFF2020,"center", drawMain)
  gui:drawScreen("fillMobFailed");
  return false
end

function drawMain()
  local col = 1
  local y = 1
  for i=1,#spawnerList do
    local color = 0xEAEAEA
    
    if i%2 == 0 then
     color = 0xC7C7C7
    end 
    if y%9 == 0 then
      col = col + 1
      y=1
    end
    y=y+1
   
    x=(22*col)-22

    gui:addButton(3+x, 3+(2*y), 20, 2, spawnerList[i].name, "main", 0x0, color, "left", fillMob, spawnerList[i])
  end
  
  gui:addButton(52, 8, 28, 2, "How this works", "main", 0xEEEEEE, 0x003676, "center")
  gui:addButton(52, 10, 28, 1, "1.) put an empty soul vial", "main", 0xEEEEEE, 0x0058BD, "left")
  gui:addButton(52, 11, 28, 1, "    on the injector", "main", 0xEEEEEE, 0x0058BD, "left")
  gui:addButton(52, 12, 28, 1, "2.) select a mob from", "main", 0xEEEEEE, 0x0058BD, "left")
  gui:addButton(52, 13, 28, 1, "    the list", "main", 0xEEEEEE, 0x0058BD, "left")
  gui:addButton(52, 14, 28, 1, "3.) wait for the vial to", "main", 0xEEEEEE, 0x0058BD, "left")
  gui:addButton(52, 15, 28, 1, "    fill, it will be put", "main", 0xEEEEEE, 0x0058BD, "left")
  gui:addButton(52, 16, 28, 1, "    back on the injector", "main", 0xEEEEEE, 0x0058BD, "left")
  gui:addButton(52, 17, 28, 1, "", 0xEEEEEE, 0x0058BD, "left")
  
  gui:drawScreen("main")
end

function touchEvent(id, device, x, y, button, user)
  if _G.gui.touchTimer ~= nil then
	event.cancel(_G.gui.touchTimer)
    _G.gui.touchTimer = nil    
  end
	
  _G.gui:touchEvent(x, y, user)     
  
  local newTimer = getTouchtimeout(_G.gui.currentScreen)
  if newTimer > 0 then 
	_G.gui.touchTimer = event.timer(newTimer, drawMain) 
  end
end

for i=1,#spawnerList do
	spawnerList[i].t = component.proxy(spawnerList[i].a)
end

gui.gpu.setResolution(80,25)

gui:addButton(1, 1, 80, 1, "soul vial filling station", "all", 0x252525, 0xFF8C00, "center", drawMain)
gui:addButton(1, 2, 80, 1, "", "all", 0x252525, 0xCB6F00, "center", drawMain)

drawMain()

--interpret Events

event.listen("touch", touchEvent)

event.pull("interrupted")


