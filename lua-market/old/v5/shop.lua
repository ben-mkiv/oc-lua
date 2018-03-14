_G.gui = {}
_G.config = {}
_G.stock = {}
_G.trades = {}
_G.history = require("marketHistory")
_G.touchTimeouts = {}
require ("package").loaded.marketHistory = nil
require ("package").loaded.market = nil
require ("package").loaded.hazeUI = nil
require ("package").loaded.marketFunctions = nil
require ("package").loaded.marketGUI = nil
require ("package").loaded.borders = nil
require ("marketGUI")

market = require("market")
event = require("event")
ser = require("serialization")

table.insert(_G.touchTimeouts, { name = "default", t = 5 })
table.insert(_G.touchTimeouts, { name = "printTrades", t = 0 })
table.insert(_G.touchTimeouts, { name = "openTrade", t = 30 })
table.insert(_G.touchTimeouts, { name = "warning", t = 0 })
table.insert(_G.touchTimeouts, { name = "info", t = 10 })
table.insert(_G.touchTimeouts, { name = "adminMenue", t = 30 })
table.insert(_G.touchTimeouts, { name = "importTradesList", t = 60 })
table.insert(_G.touchTimeouts, { name = "stockStatus", t = 60 })

function getTouchtimeout(name)
	for i=1,#_G.touchTimeouts do if _G.touchTimeouts[i].name == name then return _G.touchTimeouts[i].t end end
	return getTouchtimeout("default")
end

function touchEvent(id, device, x, y, button, user)
  local i = 0
  for s=1,#_G.gui do if _G.gui[s].ui.config.screen == device then i = s end end
  
  if _G.gui[i].touchTimer ~= nil then
	event.cancel(_G.gui[i].touchTimer)
    _G.gui[i].touchTimer = nil    
  end
	
  _G.gui[i].ui:touchEvent(x, y, user)     
  
  local newTimer = getTouchtimeout(_G.gui[i].ui.currentScreen)
  if newTimer > 0 then 
	_G.gui[i].touchTimer = event.timer(newTimer, function() _G.gui[i]:printTrades() end) 
  end
end


function loadConfiguration()
  f = io.open("/etc/market_hw.conf", "r") 
  if not f or f == nil then
    print("no configuration found")
    return false
  end 
  _G.config = ser.unserialize(f:read("*a")) 
  f:close()
  return true
end

function init()
  for i=1,#config.terminals do
  _G.gui[i] = clone(marketGUI)
  _G.gui[i]:init(_G.config.terminals[i].s, _G.config.terminals[i].g, i)
  _G.gui[i].config.admin = _G.config.admin
  _G.gui[i].ui.gpu.setResolution(80,25)
  _G.gui[i].ui.gpu.fill(1,1,80,25, " ")
  end  
end

loadConfiguration()
init()
loadTradesConfig()

--_G.gui[1]:refreshStock()

for i=1,#_G.gui do _G.gui[i]:printTrades() end


function closeTool()
	event.ignore("touch", touchEvent)	
	for i=1,#_G.gui do
		_G.gui[i].ui.gpu.setBackground(0x0)
		_G.gui[i].ui.gpu.setForeground(0xFFFFFF)
		_G.gui[i].ui.gpu.setResolution(60,30)
		_G.gui[i].ui.gpu.fill(1,1,60,30, " ")
	end	
	require("term").clear()
	os.exit()
end    

event.listen("touch", touchEvent)

-- this is the main event
event.pull("interrupted")

-- exit when interrupted
closeTool()
