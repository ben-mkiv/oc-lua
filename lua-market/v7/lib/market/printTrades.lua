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

    local bgcolor = 0x3C3C3C;

    if s % 2 == 0 then bgcolor = 0x696969 end

    self.ui:addButton(2+xOffset, yOffset+(l*2)-1, 38, 1, "<┓  " .. offer.size .. " x " .. offer.label, 'printTrades', 0x10EF10, bgcolor, "left", "openTrade", {offer = offer, price = price})
    self.ui:addButton(2+xOffset, yOffset+(l*2), 38, 1,   " ┗> " .. price.size .. " x " .. price.label, 'printTrades', 0xEF1010, bgcolor, "left", "openTrade", {offer = offer, price = price})
  end

  if page > 1 then
    self.ui:addButton(18, 23, 15, 2, "<< Page -", "printTrades", 0xFFFFFF, 0x5A5A5A, "left", "printTrades", page-1)
  end

  self.ui:addButton(36, 23, 10, 2, page.." / "..math.ceil(#tradesTemp/elsPage), "printTrades", 0xEEEEEE, 0x202020, "center", "printTrades")

  if (#tradesTemp/elsPage)-page > 0 then
    self.ui:addButton(51, 23, 15, 2, "Page + >>", "printTrades", 0xFFFFFF, 0x5A5A5A, "right", "printTrades", page+1)
  end

  self.ui:addButton(2, 23, 10, 2, "stock", "printTrades", 0x2F2F2F, 0xFF9900, "left", "stockStatus")

  self.ui:drawScreen('printTrades')
end
