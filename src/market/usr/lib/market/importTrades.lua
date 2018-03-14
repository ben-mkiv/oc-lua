function marketGUI:addTrade(data)
  local offer = data[1]
  local price = data[2]
  if not offer or not price then return end
  table.insert(_G.trades, { offer = offer, price = price })
  saveTradesConfig()    
  self:importTrades()
end

function marketGUI:importTrades()
  self.ui:flushElements(true)

  self.ui:addButton(1, 4, 50, 3, "importing trades, this may take some time...", "market.importTrades", 0xFF00FF, 0x303030, "center")
  self.ui:drawScreen("market.importTrades")
    
  p = require("component").proxy(_G.config.pricing.t)
    
  s = p.getInventorySize(_G.config.pricing.side)
  fu = 1
  
  for j=1,(s/2) do
    self.ui:drawStatusbar(5, 10, 40, 1, s/2, j, "reading pricing inventory")
    
    local slot = j + (math.floor((j-1) / 9) * 9)
    
    local o = p.getStackInSlot(_G.config.pricing.side, slot);
    local p = p.getStackInSlot(_G.config.pricing.side, (slot+9))
    
    local addIt = false 
    
    if o and p then
    addIt = true
    for k=1,#_G.trades do
      if _G.trades[k].price.name == p.name and _G.trades[k].price.size == p.size then
       if _G.trades[k].offer.name == o.name and _G.trades[k].offer.size == o.size then
        addIt = false
      end end
    end
  end    
  if addIt then
    self.ui:addButton(2, 1+(fu*3), 40, 1, "‡ " .. o.size .. " x " .. o.name, 'market.importTradesList', 0x10EF10, 0x202020, "left", "addTrade", { o, p})
    self.ui:addButton(2, 2+(fu*3), 40, 1, "† price: " .. p.size .. " x " .. p.name, 'market.importTradesList', 0xEF1010, 0x202020, "left", "addTrade", { o, p})
    fu = fu + 1
  end 
  end
  
  self.ui:drawScreen("market.importTradesList")
end
