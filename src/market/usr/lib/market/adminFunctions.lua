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
