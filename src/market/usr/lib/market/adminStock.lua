function marketGUI:refreshStock() 
  self.ui:addButton(1, 4, 50, 3, "loading stock, this may take some time...", "loadStock", 0xFF00FF, 0x303030, "center")
  self.ui:drawScreen("loadStock")
   
  local sc = require("component").proxy(_G.config.stock.t)
  local s = sc.getInventorySize(_G.config.stock.side)
  
  _G.stock = {}
  
  for j=1,s do
    self.ui:drawStatusbar(5, 10, 40, 1, s, j, "reading stock inventory ")
    local stack = sc.getStackInSlot(_G.config.stock.side, j)
    if stack then
    stack.invSlot = j
    table.insert(_G.stock, stack)     
  end end
  
  for i=1,#_G.gui do _G.gui[i]:printTrades() end
end

function marketGUI:stockStatus(offset)
  self.ui:flushElements(true)
  local tradesTMP = {}
  
  if not offset or offset == nil then offset = 1 end
  
  for s=1,#trades do
    local addIt = true
    for i=1,#tradesTMP do if tradesTMP[i].label == trades[s].offer.label then addIt = false end end
    if addIt == true then table.insert(tradesTMP, trades[s].offer) end
  end
   
  local pageItemLimit = 17
  local d=0
  for i=offset,#tradesTMP do
    local cnt = getStockSize(tradesTMP[i])
    local bgC = 0x4B4B4B
    if i%2 == 0 then bgC = 0x696969 end    
   
    local fgC = 0x00FF00
    if cnt < 64 then fgC = 0xFF0000
    elseif cnt < 256 then fgC = 0xFF4D00
    elseif cnt < 512 then fgC = 0xFFDB00
    elseif cnt < 1024 then fgC = 0xBEFF00      
    end
   
    self.ui:addButton(2, 4+d, 8, 1, " "..cnt, "stockStatus", fgC, bgC, "right")      
    self.ui:addButton(10, 4+d, 50, 1, tradesTMP[i].label, "stockStatus", 0xFFFFFF, bgC, "left")
	
    d = 1+d
   
    if d > pageItemLimit then 
		self.ui:addButton(65, 23, 10, 3, " next ", "stockStatus", 0xEEEEEE, 0x5A5A5A, "center", "stockStatus", (offset+pageItemLimit))
		break
    end
  end
  
  if offset > 1 then 
	local tmpN = offset-pageItemLimit
	if tmpN < 1 then tmpN = 1 end
	self.ui:addButton(53, 23, 10, 3, " prev ", "stockStatus", 0xEEEEEE, 0x5A5A5A, "center", "stockStatus", tmpN)
  end   
  
  self.ui:addButton(2, 23, 30, 2, "back", "stockStatus", 0xEEEEEE, 0x5A5A5A, "center", "printTrades")
 
  self.ui:drawScreen("stockStatus")  
end
