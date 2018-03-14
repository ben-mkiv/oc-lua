_G.gui = {}
_G.config = {}
_G.stock = {}
_G.trades = {}
_G.history = require("marketHistory")
require ("package").loaded.marketHistory = nil
require ("package").loaded.market = nil
require ("package").loaded.hazeUI = nil
require ("package").loaded.marketFunctions = nil
require "marketGUI"

market = require("market")
event = require("event")
ser = require("serialization")


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
	
	if i == 1 then
		_G.gui[i].ui:addButton(5,5,50,3,"touch to load stock", "startup", 0xFFFFFF, 0x202020, "center", "refreshStock")	
	end
	
	_G.gui[i].ui:drawScreen("startup")	
  end  
end

loadConfiguration()
init()

--interpret Events
while true do
  local id, screenID, x, y, btn, user = event.pullMultiple("touch", "interrupted")
  if id == "touch" then
    
    --for i=1,#_G.gui do
	--	if _G.gui[i].touchTimer then
	--		event.cancel(_G.gui[i].touchTimer)
	--		_G.gui[i].touchTimer = false
	--	end
    --end
	
	for i=1,#_G.gui do
		if _G.gui[i].ui.config.screen == screenID then
			_G.gui[i].ui:touchEvent(x, y, user)			
			--if _G.gui[i].currentScreen ~= "printTrades" then
			-- if _G.gui[i].currentScreen == "openTrade" then
			--	_G.gui[i].touchTimer = event.timer(30, _G.gui[i].printTrades)
			--  elseif _G.gui[i].currentScreen == "adminMenue" then
			--	_G.gui[i].touchTimer = event.timer(30, _G.gui[i].printTrades)
			--  elseif _G.gui[i].currentScreen == "importTradesList" then
			--	_G.gui[i].touchTimer = event.timer(60, _G.gui[i].printTrades)
			--  else
			--	_G.gui[i].touchTimer = event.timer(5, _G.gui[i].printTrades)    
			--  end
			--end
		end
	end

    
	end
end
