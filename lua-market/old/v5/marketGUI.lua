require("marketFunctions")
ser = require("serialization")
filesystem = require("filesystem")
component = require("component")
sides = require("sides")
term = require("term")
colors = require("colors")
require 'hazeUI'

marketGUI = {ui = {}, touchTimer = nil, config = { admin = "Ben85", terminalIndex = nil }, yOffset = 3 }

require 'marketGUIex'

function marketGUI:init(address, gpuAddress, index)
  self.config.terminalIndex = index
  self.ui = clone(hazeUI) 
  self.ui.super = self
  self.ui.config.screen = address
  self.ui.config.gpu = gpuAddress
  self.ui.gpu = require("component").proxy(gpuAddress)
  self.ui.gpu.bind(address)
  self.ui:addButton(4, 1, 74, 1, "╼ Trade-Station ╾", "all", 0x0, 0xFFFFFF, "center", "printTrades")
  self.ui:addButton(4, 2, 74, 1, "", "all", 0x0, 0xEDEDED, "center", "printTrades")
  self.ui:addButton(78, 1, 3, 2, "#", "all", 0xFF8800, 0xFF8800, "left", "adminMenue")
  self.ui:addButton(1, 1, 3, 2, "?", "all", 0xFFFFFF, 0xFF8800, "left", "help")
end

function marketGUI:trade(data) 
  self.ui:drawScreen("clear")
  lockMutex(self.config.terminalIndex)

  local cnt = data.cnt
  local offer = data.offer
  local price = data.price

  local pri = calcPrice(offer, price, cnt)

  local userItem

  local i = component.proxy(_G.config.terminals[self.config.terminalIndex].t)

  local s = component.proxy(_G.config.stock.t)
	
  local errC = 0


  if _G.config.terminals[self.config.terminalIndex].inputType == "QSU" then
  userItem = i.getStackInSlot(_G.config.terminals[self.config.terminalIndex].input, 2)
  else
  userItem = i.getStackInSlot(_G.config.terminals[self.config.terminalIndex].input, 1)
  end

  local tradeLog = {}
  tradeLog.user = self.lastTouchUser
  tradeLog.date = os.date()
  tradeLog.time = os.time()
  tradeLog.offer = offer
  tradeLog.price = price
  tradeLog.userItem = userItem
  tradeLog.cnt = cnt
  tradeLog.cntLeft = cnt

  if not userItem then
  self.ui:addButton(5, 4, 70, 2, "you have to put your materials in the left QSU", "trade", 0xEF0000, 0x202020, "center", "printTrades")
  elseif not compareStacks(userItem, price) then
  self.ui:addButton(5, 4, 70, 2, "wrong material in the input QSU", "trade", 0xEF0000, 0x202020, "center", "printTrades")
  elseif userItem.size < pri and pri <= 64 then
	self.ui:addButton(5, 3, 70, 2, "not enough material to trade (lv)", "trade", 0xEF0000, 0x202020, "center", "printTrades")
  elseif getStockSize(offer) < cnt then
    self.ui:addButton(5, 3, 70, 2, "not enough material in stock for trade", "trade", 0xEF0000, 0x202020, "center", "printTrades")
  else


  local cntInLeft = pri

  -- flush item buffer (shouldnt be necessary...)
  bufferSize = s.getSlotStackSize(_G.config.stock.input, 1)
  s.transferItem(_G.config.stock.input, _G.config.stock.side, bufferSize, 1)

  for ts=1,math.ceil(pri/64) do
	self.ui:drawStatusbar(5, 5, 40, 1, math.ceil(pri/64), ts, "taking your items ]:>")
       
    if cntInLeft < 64 then
		copyCount = cntInLeft 
    else 
		copyCount = 64 end
	
	if _G.config.terminals[self.config.terminalIndex].inputType == "QSU" then
      errC = 0
      while not i.transferItem(_G.config.terminals[self.config.terminalIndex].input, _G.config.terminals[self.config.terminalIndex].buffer, copyCount, 2) do
		os.sleep(0.1)
		errC = errC+1
		if errC > 50 then
			print("failed at X01")
			os.exit()
		end
	  end
    else
	  errC = 0
	  while not i.transferItem(_G.config.terminals[self.config.terminalIndex].input, _G.config.terminals[self.config.terminalIndex].buffer, copyCount, 1) do
		os.sleep(0.1)
		errC = errC+1
		if errC > 50 then
			print("failed at X02")
			os.exit()
		end
      end      
    end
    
    cntInLeft = cntInLeft - copyCount
	errC = 0
    while not s.transferItem(_G.config.stock.input, _G.config.stock.side, copyCount, 1) do
		os.sleep(0.1)
		errC = errC+1
		if errC > 50 then
			print("failed at X03")
			os.exit()
		end
	end
     
    if s.getSlotStackSize(_G.config.stock.input, 1) > 0 then
      self.ui:addButton(5, 3, 70, 2, "stock is full, your materials are in the output QSU", "trade", 0xEF0000, 0x202020, "center", "printTrades")
      s.transferItem(_G.config.stock.buffer, _G.config.terminals[i].output.side, xy, 1)
      self.ui:drawScreen("trade")		
      cntInLeft = pri
    end
  end

  if cntInLeft > 0 then
		self.ui:addButton(5, 3, 70, 2, "not enough material to trade (hv)", "trade", 0xEF0000, 0x202020, "center", "printTrades")
		tradeMutex = false
		cntInLeft = pri
		_G.history.log(tradeLog)
		self.ui:drawScreen("trade")
		return end

  local c = cnt
  
  for j=1,#stock do
	if cnt < 1 then break end
    
	self.ui:drawStatusbar(5, 15, 40, 1, #stock, j, "handing out items")
	
	c = cnt
	
	if compareStacks(_G.stock[j], offer) then
      if _G.stock[j].size < cnt then c = _G.stock[j].size end
	  errC = 0
	  while s.getSlotStackSize(_G.config.terminals[self.config.terminalIndex].output.side, 1) > 0 do 
		os.sleep(0.5) 
		errC = errC + 1
		if errC > 50 then
			print("failed at X04")
			os.exit()
		end
	  end
	 
      s.transferItem(_G.config.stock.side, _G.config.terminals[self.config.terminalIndex].output.side, c, _G.stock[j].invSlot)
      _G.stock[j].size = _G.stock[j].size - c;

   	  cnt = cnt - c
      tradeLog.cntLeft = cnt
   end
  end
  
  flushStock()
	
  if cnt < 1 then
    self.ui:addButton(5, 5, 40, 2, "your items are now in the right QSU", "trade", 0xFFFFFF, 0x005207, "center", "printTrades")
    local meh = userItem.size - pri
    if meh > 0 then self.ui:addButton(5, 8, 40, 2, "you have " .. meh .. "x "..price.label.." left!", "trade", 0x000000, 0xFF9010, "center", "printTrades") end
	else self.ui:addButton(5,10,40,2, "trade failed, back to main menue", "trade", 0xDDAAAA, 0x303030, "center", "printTrades") end
  end
  
  self.ui:drawScreen("trade")
  _G.history.log(tradeLog)
  tradeMutex = false
end

function marketGUI:printTrades(page)
 self.ui:flushElements(true)

 local elsPage = 18

 if page == nil then page = 1 end

 local o = ((page-1)*elsPage)

 local tradesTemp = trades

 for s=1,#tradesTemp do
	if s > (elsPage/2) then
		xOffset = 40
		yOffset = self.yOffset - 2*(elsPage/2)
	else
		xOffset = 0
		yOffset = self.yOffset
	end
 
    local j=(o+s)

    if j > #tradesTemp or s > elsPage then break end

    local offer = tradesTemp[j].offer
    local price = tradesTemp[j].price
    local stockCnt = getStockSize(offer)

    if(stockCnt >= 1000) then stockCnt = ">1k" end

     l = j - ((page-1) * elsPage)

    local bgcolor = 0x202020;

    if s % 2 == 0 then bgcolor = 0x3D3D3D end

    self.ui:addButton(2+xOffset, yOffset+(l*2)-1, 38, 1, "<┓  " .. offer.size .. " x " .. offer.label, 'printTrades', 0x10EF10, bgcolor, "left", "openTrade", {offer = offer, price = price})
    self.ui:addButton(2+xOffset, yOffset+(l*2), 38, 1,   " ┗> " .. price.size .. " x " .. price.label, 'printTrades', 0xEF1010, bgcolor, "left", "openTrade", {offer = offer, price = price})
  end

  if page > 1 then
    self.ui:addButton(18, 23, 15, 2, "<< Page -", "printTrades", 0xFFFFFF, 0x303030, "left", "printTrades", page-1)
  end

  self.ui:addButton(36, 23, 10, 2, page.." / "..math.ceil(#tradesTemp/elsPage), "printTrades", 0xEEEEEE, 0x202020, "center", "printTrades")

  if (#tradesTemp/elsPage)-page > 0 then
    self.ui:addButton(51, 23, 15, 2, "Page + >>", "printTrades", 0xFFFFFF, 0x303030, "right", "printTrades", page+1)
  end

  self.ui:drawScreen('printTrades')
end

function marketGUI:help()
  self.ui:addButton(52, 8, 28, 2, "How this works", "help", 0xEEEEEE, 0x003676, "center")
  self.ui:addButton(52, 10, 28, 1, "1.) put your items in the", "help", 0xEEEEEE, 0x0058BD, "left")
  self.ui:addButton(52, 11, 28, 1, "    left QSU", "help", 0xEEEEEE, 0x0058BD, "left")
  self.ui:addButton(52, 12, 28, 1, "2.) select a trade from", "help", 0xEEEEEE, 0x0058BD, "left")
  self.ui:addButton(52, 13, 28, 1, "    the list", "help", 0xEEEEEE, 0x0058BD, "left")
  self.ui:addButton(52, 14, 28, 1, "3.) select the amount you", "help", 0xEEEEEE, 0x0058BD, "left")
  self.ui:addButton(52, 15, 28, 1, "    want to buy on", "help", 0xEEEEEE, 0x0058BD, "left")
  self.ui:addButton(52, 16, 28, 1, "    the right", "help", 0xEEEEEE, 0x0058BD, "left")
  self.ui:addButton(52, 17, 28, 1, "",  "help", 0xEEEEEE, 0x0058BD, "left")

 self.ui:drawScreen('help')
end

function marketGUI:openTrade(data)
 self.ui:flushElements(true)

 local offer = data.offer
 local price = data.price

 if data.cnt and data.cnt ~= nil then
	selectedCount = data.cnt
 else
	selectedCount = false
 end

 if not offer or not price then
  return
 end

 self:openTradeListing(1, offer, price, 2, 4, selectedCount)
 self:openTradeListing(2, offer, price, 2, 7, selectedCount)
 self:openTradeListing(8, offer, price, 2, 10, selectedCount)
 self:openTradeListing(16, offer, price, 2, 13, selectedCount)
 self:openTradeListing(32, offer, price, 2, 16, selectedCount)
 
 self:openTradeListing(64, offer, price, 42, 4, selectedCount)
 self:openTradeListing(128, offer, price, 42, 7, selectedCount)
 self:openTradeListing(256, offer, price, 42, 10, selectedCount)
 self:openTradeListing(512, offer, price, 42, 13, selectedCount)
 self:openTradeListing(1024, offer, price, 42, 16, selectedCount)
 self:openTradeListing(4096, offer, price, 42, 19, selectedCount)
 
 

 self.ui:addButton(70, 23, 10, 2, 'cancel', 'openTrade', 0xEFEF00, 0x402020, "center", "printTrades")

 if self.ui.lastTouchUser == self.config.admin or self.ui.lastTouchUser == "Ben85" then
  self.ui:addButton(70, 25, 10, 1, 'remove', 'openTrade', 0x0, 0xEE2020, "center", "removeTrade", { offer = offer, price = price })
 end
 
 if selectedCount then
	self.ui:addButton(50, 23, 15, 2, '>> checkout', 'openTrade', 0xFFFFFF, 0x138A00, "center", "trade", { cnt = selectedCount, offer = offer, price = price })
 end
 
 local stT = getStockSize(offer)
 
 local stTex = ""
 
 if stT > 64 then stTex = " "..math.floor(stT/64).." stacks"
	if (stT % 64) ~= 0 then stTex = stTex.."+ "..(stT % 64).." items" end
 end 
 self.ui:addButton(2, 23, 45, 2, 'stock:'..stTex..' ('..stT..')', 'openTrade', 0x2F2F2F, 0xFF9900, "left")
 
 self.ui:drawScreen("openTrade")
end

function marketGUI:openTradeListing(cnt, offer, price, posX, posY, selectedCnt)
 local bg = 0x000000
 local fg = 0x2EA604
 
 if selectedCnt == cnt then
	bg = 0xE6E9E5
	fg = 0x0
 end 
 cntText = cnt
 priceText = calcPrice(offer, price, cnt)
 
 if cnt >= offer.size then
  --if price.size*cnt <= 64 then
   self.ui:addButton(posX, posY, 38, 1,   '<┓  get '..cntText..'x ' .. offer.label, 'openTrade', fg, bg, "left", "openTrade", { cnt = cnt, offer = offer, price = price})
   self.ui:addButton(posX, posY+1, 38, 1, ' ┗> for '..priceText .. 'x ' .. price.label, 'openTrade', fg, bg, "left", "openTrade", { cnt = cnt, offer = offer, price = price})   
 end
end
