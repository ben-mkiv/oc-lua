function marketGUI:getUserItem()
	local i = component.proxy(_G.config.terminals[self.config.terminalIndex].t)
	
	if _G.config.terminals[self.config.terminalIndex].inputType == "QSU" then
		return i.getStackInSlot(_G.config.terminals[self.config.terminalIndex].input, 2)
	else
		return i.getStackInSlot(_G.config.terminals[self.config.terminalIndex].input, 1)
    end
end

function marketGUI:trade(data) 
  self.ui:drawScreen("clear")
 
  local cnt = data.cnt
  local offer = data.offer
  local price = data.price

  local pri = calcPrice(offer, price, cnt)

  local userItem = self:getUserItem()

  local   tradeLog = {}
		  tradeLog.user = self.lastTouchUser
		  tradeLog.date = os.date()
		  tradeLog.time = os.time()
		  tradeLog.offer = offer
		  tradeLog.price = price
		  tradeLog.userItem = userItem
		  tradeLog.cnt = cnt
		  tradeLog.cntLeft = cnt
	
  if not userItem then
	return self:warning({"please put your materials in the left QSU"})
  elseif not compareStacks(userItem, price) then
	return self:warning({"wrong material in the input QSU"})
  elseif userItem.size < pri and pri <= 64 then
	return self:warning({"not enough material to trade (lv)"})
  elseif getStockSize(offer) < cnt then
    return self:warning({"not enough material in stock for trade"})
  end
   
  local i = component.proxy(_G.config.terminals[self.config.terminalIndex].t)
  local s = component.proxy(_G.config.stock.t)
  
  lockMutex(self.config.terminalIndex)



  -- flush item buffer (shouldnt be necessary...)
  s.transferItem(_G.config.stock.input, _G.config.stock.side, s.getSlotStackSize(_G.config.stock.input, 1), 1)

  -- transfer user items to stock
  local tmpVal = self:transfer_user2stock(pri, price)
  
  local payBack = 0
  
  
  if tmpVal.left > 0 then
	self.ui:drawScreen("clear")
	
	payBack = pri - tmpVal.left
	local errorMessages = {}
	
	table.insert(errorMessages, "Trade failed, not enough Materials!?")
	
	if tmpVal.errorVal.exhaust > 0 then
		s.transferItem(_G.config.stock.input, _G.config.terminals[self.config.terminalIndex].output.side, tmpVal.exhaust.size, 1)	
		payBack = payBack - tmpVal.errorVal.exhaust.size
		table.insert(errorMessages, "stock may be full!")
		table.insert(errorMessages, "moved exhaust items to the output (right QSU)")
	end
	
	
	if payBack > 0 then
		if self:checkReturnVal(self:transfer_stock2user(payBack, price)) ~= true then
			table.insert(errorMessages, "oh dear, even the payback failed, not your day?!")
			table.insert(errorMessages, "please take a screenshot and show to Ben or James for refund.")
		end
	end 
	
	tradeMutex = false
	
	return self:warning(errorMessages)
  end  
  
  -- transfer stock items to user output
  local tmpValW = self:transfer_stock2user(cnt, offer)  
  
  if self:checkReturnVal(tmpValW) == true then
	tradeMutex = false
	_G.history.log(tradeLog)
	tradeLog.cntLeft = 0
    return self:info({"trade done", "your items are in the output (right QSU)"})
  end  
  
  tradeMutex = false
  _G.history.log(tradeLog)
  self:warning({"trade failed", "however you got here, something went terrible wrong... ;-)"})
end

function marketGUI:checkReturnVal(val, verbose)
	local msgs = {}
	
	for i=1,#val.errors do
		if val.errors[i] >= 20 then
			table.insert(msgs, " "..i..": "..val.errors[i].." errors")
		end
	end
	
	if val.left > 0 then
		table.insert(msgs, " "..val.left.." items left")
	end
	
	
	if #msgs > 0 then
		if verbose == true then self:warning(msgs) end
		return false
	end	
	return true	
end


function marketGUI:transfer_stock2user(cnt, item)
  local s = component.proxy(_G.config.stock.t)

  local returnVal = {}
		returnVal.left = cnt
		returnVal.errors = {}
		returnVal.errors[1] = 0
  
  local totalCnt = cnt

  for j=1,#_G.stock do
    if returnVal.left < 1 then break end	
	
	local c = returnVal.left
	
	if compareStacks(_G.stock[j], item) then      
      if _G.stock[j].size < returnVal.left then c = _G.stock[j].size end
	  self.ui:drawStatusbar(5, 15, 60, 1, totalCnt, c, "transfering items from stock to output (right QSU)")      
	 
	   while s.getSlotStackSize(_G.config.terminals[self.config.terminalIndex].output.side, 1) > 0 do 
	 	os.sleep(0.1) returnVal.errors[1] = returnVal.errors[1]+1
		if returnVal.errors[1] > 50 then break end
	   end
	 
       s.transferItem(_G.config.stock.side, _G.config.terminals[self.config.terminalIndex].output.side, c, _G.stock[j].invSlot)
      
       _G.stock[j].size = _G.stock[j].size - c;
		returnVal.left = returnVal.left - c
      end
  end 
  
  flushStock()  
  return returnVal
end

function marketGUI:transfer_user2stock(pri, item)
  local cntInLeft = pri
    
  for ts=1,math.ceil(pri/64) do
	self.ui:drawStatusbar(5, 5, 40, 1, pri, 64*(ts-1), "transfering items to stock")
	
	local copyCount = cntInLeft
	 
    if copyCount > 64 then copyCount = 64 end	
	
	local tmpVal = self:transferStack_user2stock(copyCount, item) 
	
	if self:checkReturnVal(tmpVal) == true then
		cntInLeft = cntInLeft - copyCount	
	else 
		cntInLeft = cntInLeft - (copyCount - tmpVal.left)
		return { left = cntInLeft, errorVal = tmpVal } 
	end
  end
  
  self.ui:drawStatusbar(5, 5, 40, 1, math.ceil(pri/64), math.ceil(pri/64), "transfering items to stock. done")
  
  return { left = cntInLeft, errorVal = nil }
end
 
function marketGUI:transferStack_user2stock(copyCount, item)
	local i = component.proxy(_G.config.terminals[self.config.terminalIndex].t)
	local s = component.proxy(_G.config.stock.t)
	
	local returnVal = {}
		  returnVal.left = copyCount
		  returnVal.errors = {}
		  returnVal.errors[1] = 0
    
    local pullSlot = 1
    if _G.config.terminals[self.config.terminalIndex].inputType == "QSU" then pullSlot = 2 end
    
	i.transferItem(_G.config.terminals[self.config.terminalIndex].input, _G.config.terminals[self.config.terminalIndex].buffer, copyCount, pullSlot)
	
	while s.getSlotStackSize(_G.config.stock.input, 1) < copyCount do
		os.sleep(0.05) returnVal.errors[1] = returnVal.errors[1]+1
		if returnVal.errors[1] > 20 then break end
	end 
	
	returnVal.left = copyCount - s.getSlotStackSize(_G.config.stock.input, 1)
	 
    s.transferItem(_G.config.stock.input, _G.config.stock.side, copyCount, 1)
	
	returnVal.exhaust = s.getSlotStackSize(_G.config.stock.input, 1)	
		
	return returnVal
end

