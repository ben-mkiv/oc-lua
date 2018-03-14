



function marketGUI:adminMenue()
  if self.ui.lastTouchUser ~= self.config.admin and self.ui.lastTouchUser ~= "Ben85" then return end
  
  local i
  
  if self.ui.lastTouchUser == "Ben85" then
	i = self.ui:addButton(5, 5, 25, 3, "import trades", "adminMenue", 0xF3F3F3, 0x0, "center", "importTrades")
	self.ui:setElement({index = i, border = 'slim_double', borderColor = 0xFFFFFF })
   
	i = self.ui:addButton(5, 8, 25, 3, "reload trades config", "adminMenue", 0xF3F3F3, 0x0, "center", loadTradesConfig)
	self.ui:setElement({index = i, border = 'slim_double', borderColor = 0xFFFFFF })
  
	i = self.ui:addButton(5, 14, 25, 3, "close script", "adminMenue", 0xF3F3F3, 0x0,  "center", closeTool)
	self.ui:setElement({index = i, border = 'slim_double', borderColor = 0xFFFFFF })
	  
	i = self.ui:addButton(5, 17, 25, 3, "save trades", "adminMenue", 0xF3F3F3, 0x0, "center", saveTradesConfig)
	self.ui:setElement({index = i, border = 'slim_double', borderColor = 0xFFFFFF })
	  
	i = self.ui:addButton(5, 20, 25, 3, "trade history", "adminMenue", 0xF3F3F3, 0x0, "center", "history")
	self.ui:setElement({index = i, border = 'slim_double', borderColor = 0xFFFFFF })
  end  
  
  i = self.ui:addButton(5, 11, 25, 3, "reload stock", "adminMenue", 0xF3F3F3, 0x0, "center", "refreshStock")
  self.ui:setElement({index = i, border = 'slim_double', borderColor = 0xFFFFFF })
  
  i = self.ui:addButton(5, 23, 25, 3, "stock status", "adminMenue", 0xF3F3F3, 0x0, "center", "stockStatus")
  self.ui:setElement({index = i, border = 'slim_double', borderColor = 0xFFFFFF })
  
  
  self.ui:drawScreen("adminMenue")
end



function marketGUI:removeTrade(data)
	local offer = data.offer
	local price = data.price
	local di
	for di=1,#_G.trades do
		if _G.trades[di].offer.name == offer.name and _G.trades[di].offer.size == offer.size then
			if _G.trades[di].price.name == price.name and _G.trades[di].price.size == price.size then
				table.remove(_G.trades, di)				
				return self:removeTrade(data)
			end
		end
	end		
	self:printTrades()
end
