require ("package").loaded.marketGUI = nil
gui = require ("marketGUI")
ser = require("serialization")
filesystem = require("filesystem")
component = require("component")
sides = require("sides")
term = require("term")
colors = require("colors")
gpu = component.gpu


local market = {}

-- currently also offset for the trades...
yOffset = 3

stock = {}
trades = {}
 
function compareStacks(s1, s2)
	local equal = true;
	
	if not s1 or not s2 then
		return false
	end
	
	if s1.name ~= s2.name then
		equal = false
	elseif s1.label ~= s2.label then
		equal = false
	end
	
	
	return equal;
end

function adminMenue(screen)
  if gui.config.terminals[screen].lastTouchUser ~= gui.config.admin then
    return
  end

  gui.addButton(5, 5, 25, 2, "import trades", "adminMenue", 0x0, 0x808080, "center", market.importTrades, screen, screen)
  gui.addButton(5, 8, 25, 2, "reload trades config", "adminMenue", 0x0, 0x808080, "center", market.loadTradesConfig, screen, screen)
  gui.addButton(5, 11, 25, 2, "reload stock", "adminMenue", 0x0, 0x808080, "center", market.refreshStock, screen, screen)
  gui.addButton(5, 14, 25, 2, "close script", "adminMenue", 0x0, 0xEE1010, "center", os.exit, nil, screen)
  gui.addButton(5, 17, 25, 2, "save trades", "adminMenue", 0x0, 0x808080, "center", market.saveTradesConfig, nil, screen)
  gui.addButton(5, 20, 25, 2, "trade history", "adminMenue", 0x0, 0x808080, "center", market.history, nil, screen)
  
  gui.drawScreen("adminMenue")
end

market.historyFiles = {}

market.loadHistory = function()
	market.historyFiles = {}
	
	for logFile in filesystem.list("/var/log/") do
		table.insert(market.historyFiles, logFile)
	end	
end


market.history = function(fileOffset)
	gui.flush(true)
	if not fileOffset or fileOffset == nil then
		market.loadHistory()
	end
	
	local pages = math.ceil(#market.historyFiles/8)

	

	if not fileOffset or fileOffset == nil or fileOffset < 0 or fileOffset > #market.historyFiles then
		fileOffset = (pages*8)-8
	end
	
	local page = 1+math.ceil(fileOffset/8)
	
	for i=1,#market.historyFiles do
		local fileIndex = fileOffset + i
			
		if i > 8 or fileIndex > #market.historyFiles then
			break
		end
		
		fd = io.open("/var/log/"..market.historyFiles[fileIndex], "r")
		local serTradeLog = fd:read("*a")
		fd:close()
		
		local tradeLog = ser.unserialize(serTradeLog)

		local color = 0x202020
		
		if tradeLog.cntLeft == 0 then
			color = 0x00EE00
		end
		
		local bgCol = 0xEEEEEE
		
		if i%2 == 0 then
			bgCol = 0xCCCCCC
		end
		
		gui.addButton(11, 3+(2*i), 40, 1, tradeLog.offer.label .. " <> " .. tradeLog.price.label, "history", 0x0, bgCol, "left", market.historyShow, "/var/log/"..market.historyFiles[fileIndex])
		gui.addButton(11, 4+(2*i), 40, 1, tradeLog.user .. " | " .. (tradeLog.cnt-tradeLog.cntLeft) .."/"..tradeLog.cnt, "history", 0x0, bgCol, "left", market.historyShow, "/var/log/"..market.historyFiles[fileIndex])
		
		gui.addButton(3, 3+(2*i), 8, 2, "#"..fileIndex, "history", 0x0, color, "right", market.historyShow, "/var/log/"..market.historyFiles[fileIndex])
	end
	
	if page > 1 then
		gui.addButton(1, 21, 15, 1, "< page "..(page-1), "history", 0x0, 0xFFFFFF, "left", market.history, (fileOffset-8))
	end
		
	if page < pages then
		gui.addButton(16, 21, 15, 1, "page "..(page+1).." >", "history", 0x0, 0xFFFFFF, "left", market.history, (fileOffset+8))
	end
	
	gui.addButton(1, 1, 30, 1, "file count: "..#files, "history", 0x0, 0xFFFFFF, "left")
	gui.drawScreen("history")
end

market.historyShow = function(filename)
	fd = io.open(filename, "r")
	local serTradeLog = fd:read("*a")
	fd:close()
	
	local tradeLog = ser.unserialize(serTradeLog)
	
	local color = 0x202020
		
	if tradeLog.cntLeft == 0 then
		color = 0x00EE00
	end
		
	gui.addButton(50, 3, 30, 1, "file: "..filename, "historyShow", 0x0, 0xFFFFFF, "left", market.history)
    gui.addButton(50, 4, 30, 1, "o>"..tradeLog.offer.label, "historyShow", 0x0, 0xFFFFFF, "center", market.history)
    gui.addButton(50, 5, 30, 1, "p<"..tradeLog.price.label, "historyShow", 0x0, 0xFFFFFF, "center", market.history)
    gui.addButton(50, 6, 30, 1, "date: "..tradeLog.date, "historyShow", 0x0, 0xFFFFFF, "left", market.history)
    gui.addButton(50, 7, 30, 1, "time: "..tradeLog.time, "historyShow", 0x0, 0xFFFFFF, "left", market.history)
	if tradeLog.userItem then
		gui.addButton(50, 8, 30, 1, "userItem: "..tradeLog.userItem.label, "historyShow", 0x0, 0xFFFFFF, "left", market.history)
	else
		gui.addButton(50, 8, 30, 1, "userItem: none", "historyShow", 0x0, 0xFFFFFF, "left", market.history)
	end	
	gui.addButton(50, 9, 30, 1, "username: "..tradeLog.user, "historyShow", 0x0, 0xFFFFFF, "left", market.history)
	gui.addButton(50, 10, 30, 1, 'cnt (left): '..tradeLog.cnt..'('..tradeLog.cntLeft..')', "historyShow", 0x0, color, "left", market.history)
	
	gui.addButton(65, 12, 15, 1, "back", "historyShow", 0x0, 0xFFFFFF, "center", market.history)
	
	gui.drawScreen("historyShow")
end


function market.loadTradesConfig()
  local config = io.open("/etc/market.conf", "r")
  local serTrades = 	config:read("*a")
  config:close()
  trades = ser.unserialize(serTrades)
  printTrades()
end

function market.saveTradesConfig()
	local config = io.open("/etc/market.conf", "w")
	config:write(ser.serialize(trades))
 config:close()
end

function addTrade(data)
	local offer = data[1]
	local price = data[2]

	if not offer then
		return
	end
	if not price then
		return
	end
	
    table.insert(trades, { offer = offer, price = price })
    market.saveTradesConfig()    
    
    market.importTrades()
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


function trade(data)
  local screen = data.screen
  
  lockMutex(screen)

  local cnt = data.cnt
  local offer = data.offer
  local price = data.price
  
  local pri = calcPrice(offer, price, cnt)
  
  local userItem
  
  
  local i = component.proxy(gui.config.terminals[screen].t)
  
  local s = component.proxy(gui.config.stock.t) 
  
  
  if gui.config.terminals[screen].inputType == "QSU" then
	userItem = i.getStackInSlot(gui.config.terminals[screen].input, 2)
  else
	userItem = i.getStackInSlot(gui.config.terminals[screen].input, 1)
  end

  local tradeLog = {}
	tradeLog.user = gui.lastTouchUser
	tradeLog.date = os.date()
	tradeLog.time = os.time()
	tradeLog.offer = offer
	tradeLog.price = price
	tradeLog.userItem = userItem
	tradeLog.cnt = cnt
	tradeLog.cntLeft = cnt
	
  if not userItem then
	gui.addButton(5, 4, 70, 2, "you have to put your materials in the left QSU", "trade", 0xEF0000, 0x202020, "center", printTrades, { screen = screen}, screen)
  elseif not compareStacks(userItem, price) then
	gui.addButton(5, 4, 70, 2, "wrong material in the input dsu", "trade", 0xEF0000, 0x202020, "center", printTrades, { screen = screen}, screen)
  elseif userItem.size < pri then
    gui.addButton(5, 3, 70, 2, "not enough material to trade (lv)", "trade", 0xEF0000, 0x202020, "center", printTrades, { screen = screen}, screen)
  elseif getStockSize(offer) < cnt then
    gui.addButton(5, 3, 70, 2, "not enough material in stock for trade", "trade", 0xEF0000, 0x202020, "center", printTrades, { screen = screen}, screen)
  else
	
	local cntInLeft = pri
	
	-- flush item buffer (shouldnt be necessary...)
	bufferSize = s.getSlotStackSize(gui.config.stock.input, 1)
	s.transferItem(gui.config.stock.input, gui.config.stock.side, bufferSize, 1)
	
	for ts=1,math.ceil(pri/64) do
		bufferSize = 0
		
		copyCount = 64
		
		if cntInLeft < 64 then
			copyCount = cntInLeft
		end
		
		if gui.config.terminals[screen].inputType == "QSU" then
			i.transferItem(gui.config.terminals[screen].input, gui.config.terminals[screen].buffer, copyCount, 2)
		else
			i.transferItem(gui.config.terminals[screen].input, gui.config.terminals[screen].buffer, copyCount, 1)
		end
		
		while s.getSlotStackSize(gui.config.stock.input, 1) < copyCount do
			os.sleep(0.05)
		end
		
		cntInLeft = cntInLeft - copyCount;
		
		s.transferItem(gui.config.stock.input, gui.config.stock.side, copyCount, 1)
		local xy = s.getSlotStackSize(gui.config.stock.input, 1)
			
		if xy > 0 then
			gui.addButton(5, 3, 70, 2, "stock is full, your materials are in the output QSU", "trade", 0xEF0000, 0x202020, "center", printTrades, { screen = screen}, screen)
			s.transferItem(gui.config.stock.buffer, gui.config.terminals[i].output.side, xy, 1)
			cntInLeft = cntInLeft + (copyCount - xy)			
		end		
	end
        
    if cntInLeft > 0 then
		gui.addButton(5, 3, 70, 2, "not enough material to trade (hv)", "trade", 0xEF0000, 0x202020, "center", printTrades, { screen = screen}, screen)
		
		-- now we hack around...
		cnt = pri - cntInLeft
		offer = price		
    end
        
	local c = cnt

	  for j=1,#stock do
		c = cnt
		
		if cnt < 1 then
			break;
		end
		
		 
		if compareStacks(stock[j], offer) then
		  if stock[j].size < cnt then
			c = stock[j].size
		  end
					
		  s.transferItem(gui.config.stock.side, gui.config.terminals[i].output.side, c, stock[j].invSlot)
		  stock[j].size = stock[j].size - c;
		  
		  -- if the slot is empty remove it from cache
		  if stock[j].size == 0 then
			table.remove(stock, j)
		  end
		  
		  
		  cnt = cnt - c
		  tradeLog.cntLeft = cnt
		end
	  end

	if cnt < 1 then
		gui.addButton(5, 5, 40, 2, "your items are now in the right QSU", "trade", 0xFFFFFF, 0x005207, "center", printTrades, { screen = screen}, screen)

		local meh = userItem.size - pri
		if meh > 0 then  
			gui.addButton(5, 8, 40, 2, "you have " .. meh .. "x "..price.label.." left!", "trade", 0x000000, 0xFF9010, "center", printTrades, { screen = screen}, screen)
		end
	else
		gui.addButton(5,10,40,2, "trade failed, back to main menue", "trade", 0xDDAAAA, 0x303030, "center", printTrades, { screen = screen}, screen)
	end
  end  
    gui.drawScreen("trade", screen)
--confusing
  logTrade(tradeLog) 
  tradeMutex = false
end

-- this will probably get slow after time...
function logTrade(logEl)
	if not filesystem.isDirectory("/var/log") then
		filesystem.makeDirectory("/var/log")
	end

	local logfile = "/var/log/market_"..os.time()..".log"
	
	while filesystem.exists(logfile) do
		os.sleep(1) -- yea no index, just chill :D
		logfile = "/var/log/market_"..os.time()..".log"
	end

	file = io.open(logfile, "w")	
	
	file:write(ser.serialize(logEl))
	
	file:close()
end


function market.importTrades(screen)
  gui.addButton(1, 4, 50, 3, "importing trades, this may take some time...", "market.importTrades", 0xFF00FF, 0x303030, "center", nil, nil, screen)
  gui.drawScreen("market.importTrades", screen)
  
  gui.selectScreen(screen)
  
  local s = p.getInventorySize(cP)
  local fu = 1
  for j=1,(s/2) do
    gui.drawStatusbar(5, 10, 40, 1, s/2, j, "reading pricing inventory ")
    
    local slot = j + (math.floor((j-1) / 9) * 9)
    
    local o = p.getStackInSlot(cP, slot);
    local p = p.getStackInSlot(cP, (slot+9))
    
    local addIt = false
		
    
    if o and p then
		addIt = true
		for k=1,#trades do
			if trades[k].price.name == p.name and trades[k].price.size == p.size then
			 if trades[k].offer.name == o.name and trades[k].offer.size == o.size then
				addIt = false
			end end
		end
	end
    
	if addIt then
		gui.addButton(2, 1+(fu*3), 40, 1, "‡ " .. o.size .. " x " .. o.name, 'market.importTradesList', 0x10EF10, 0x202020, "left", addTrade, { o, p}, screen)
		gui.addButton(2, 2+(fu*3), 40, 1, "† price: " .. p.size .. " x " .. p.name, 'market.importTradesList', 0xEF1010, 0x202020, "left", addTrade, { o, p}, screen)
		fu = fu + 1
	end
	
  end
  
  gui.drawScreen("market.importTradesList", screen)
end

function printTrades(d)
 local screen = d.screen
 local page = d.page
 
 gui.flush(screen, true)  

  if page == nil then
    page = 1
  end 

 local o = ((page-1)*8) 
 
 local tradesTemp = trades
 
 for s=1,#tradesTemp do
    local j = o+s 
   
    if j > #tradesTemp then
      break
    end    

    if s > 8 then
      break
    end

    local offer = tradesTemp[j].offer
    local price = tradesTemp[j].price
    local stockCnt = getStockSize(offer)
  
    if(stockCnt >= 1000) then
      stockCnt = ">1k"
    end
  
     l = j - ((page-1) * 8)
    
    local bgcolor = 0x202020;
    
    if s % 2 == 0 then
		bgcolor = 0x303030
    end
    
    
    gui.addButton(2, yOffset+(l*2)-1, 40, 1, "<| " .. offer.size .. " x " .. offer.label, 'printTrades', 0x10EF10, bgcolor, "left", openTrade, {offer, price, screen = screen}, screen)
    gui.addButton(2, yOffset+(l*2), 40, 1,   " |> " .. price.size .. " x " .. price.label, 'printTrades', 0xEF1010, bgcolor, "left", openTrade, {offer, price, screen = screen}, screen)
    gui.addButton(42, yOffset+(l*2)-1, 8, 2, "(" .. stockCnt .. ")", 'printTrades', 0x939393, bgcolor, "right", nil, nil, screen)
  end


  if page > 1 then
    gui.addButton(2, 21, 15, 2, "<< Page -", "printTrades", 0xFFFFFF, 0x303030, "left", printTrades, {page = (page-1), screen = screen}, screen)
  end

  gui.addButton(21, 21, 10, 2, page.." / "..math.ceil(#tradesTemp/8), "printTrades", 0xEEEEEE, 0x202020, "center", printTrades, {screen = screen}, screen)
   
  if (#tradesTemp/8)-page > 0 then
    gui.addButton(35, 21, 15, 2, "Page + >>", "printTrades", 0xFFFFFF, 0x303030, "right", printTrades, {page = (page+1), screen=screen}, screen)
  end
  
  gui.addButton(52, 8, 28, 2, "How this works", "printTrades", 0xEEEEEE, 0x003676, "center", nil, nil, screen)
  gui.addButton(52, 10, 28, 1, "1.) put your items in the", "printTrades", 0xEEEEEE, 0x0058BD, "left", nil, nil, screen)
  gui.addButton(52, 11, 28, 1, "    left QSU", "printTrades", 0xEEEEEE, 0x0058BD, "left", nil, nil, screen)
  gui.addButton(52, 12, 28, 1, "2.) select a trade from", "printTrades", 0xEEEEEE, 0x0058BD, "left", nil, nil, screen)
  gui.addButton(52, 13, 28, 1, "    the list", "printTrades", 0xEEEEEE, 0x0058BD, "left", nil, nil, screen)
  gui.addButton(52, 14, 28, 1, "3.) select the amount you", "printTrades", 0xEEEEEE, 0x0058BD, "left", nil, nil, screen)
  gui.addButton(52, 15, 28, 1, "    want to buy on", "printTrades", 0xEEEEEE, 0x0058BD, "left", nil, nil, screen)
  gui.addButton(52, 16, 28, 1, "    the right", "printTrades", 0xEEEEEE, 0x0058BD, "left", nil, nil, screen)
  gui.addButton(52, 17, 28, 1, "", 0xEEEEEE, 0x0058BD, "left", nil, nil, screen)
  
  
  gui.drawScreen('printTrades', screen)
end

	
function getStockSize(item)
  local cnt = 0;
  
  for i=1,#stock do
	if compareStacks(stock[i], item) then
		cnt = cnt + stock[i].size
	end
  end
  return cnt
end

function market.refreshStock(screen)
  gui.addButton(1, 4, 50, 3, "loading stock, this may take some time...", "loadStock", 0xFF00FF, 0x303030, "center", nil, nil, screen)
  gui.drawScreen("loadStock", screen)
  
  gui.selectScreen(screen)
  
  local s = i.getInventorySize(cSto)

  stock = {}
  
  for j=1,s do
	gui.drawStatusbar(5, 10, 40, 1, s, j, "reading stock inventory ")
	
	local stack = i.getStackInSlot(cSto, j)
	
	if stack then
		stack.invSlot = j
		table.insert(stock, stack)     
	end
   end
end

function calcPrice(offer, price, cnt)
  return math.ceil((price.size/offer.size) * cnt)
end

function removeTrade(data)
	local offer = data.offer
	local price = data.price
	local di
	for di=1,#trades do
		if trades[di].offer.name == offer.name and trades[di].offer.size == offer.size then
			if trades[di].price.name == price.name and trades[di].price.size == price.size then
				table.remove(trades, di)				
				return removeTrade(data)
			end
		end
	end		
	printTrades()
end

function removeTableTrade(inTable, priceName)
	for j=1,#inTable do
		if inTable[j].price.name ~= priceName then
			table.remove(inTable, j)
			return removeTableTrade(inTable, priceName)
		end
	end		
	
	return inTable
end

function openTrade(data)
 local offer = data[1]
 local price = data[2]
 local screen = data.screen

 if not offer or not price then
	return
 end
 
 openTradeListing(1, offer, price, 4, screen)
 openTradeListing(2, offer, price, 7, screen)
 openTradeListing(8, offer, price, 10, screen)
 openTradeListing(16, offer, price, 13, screen)
 openTradeListing(32, offer, price, 16, screen)
 openTradeListing(64, offer, price, 19, screen)
 
 gui.addButton(70, 22, 10, 2, 'cancel', 'openTrade', 0xEFEF00, 0x402020, "center", printTrades, {screen=screen}, screen)
  
 if gui.lastTouchUser == gui.config.admin then
	gui.addButton(50, 22, 15, 2, 'remove', 'openTrade', 0x0, 0xEE2020, "center", removeTrade, { offer = offer, price = price })
 end
 
 gui.drawScreen("openTrade", screen)
end

function openTradeListing(cnt, offer, price, posY, screen)
 if cnt >= offer.size and price.size*cnt <= 64 then
   gui.addButton(50, posY, 30, 1, 'get '..cnt..'x ' .. offer.label, 'openTrade', 0x2EA604, 0x202020, "left", trade, { cnt = cnt, offer = offer, price = price, screen = screen }, screen)
   gui.addButton(50, posY+1, 30, 1, 'for '..calcPrice(offer, price, cnt) .. 'x ' .. price.label, 'openTrade', 0xFF2A2A, 0x202020, "right", trade, { cnt = cnt, offer = offer, price = price, screen = screen }, screen)
 end

end

return market
