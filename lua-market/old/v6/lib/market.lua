require ("package").loaded.marketGUI = nil

stock = {}
trades = {}

function loadTradesConfig()
  local cf = io.open("/etc/market.conf", "r")
  local serTrades = cf:read("*a")
  cf:close()
  trades = ser.unserialize(serTrades)    
end

function saveTradesConfig()
	local cf = io.open("/etc/market.conf", "w")
	cf:write(ser.serialize(trades))
	cf:close()
end

function getStockSize(item)
  local cnt = 0;
  
  for i=1,#_G.stock do
	if compareStacks(_G.stock[i], item) then
		cnt = cnt + _G.stock[i].size
	end
  end
  return cnt
end


function flushStock()
for j=1,#stock do
  if _G.stock[j].size == 0 then 
    table.remove(_G.stock, j) 
    return flushStock()
  end
end
return true
end

tradeMutex = false


function lockMutex(id)
  while tradeMutex == true do
	os.sleep(0.5)
  end
	
  tradeMutex = id
  
  if tradeMutex ~= id then
	return lockMutex(id)
  end
end
