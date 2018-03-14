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
 
 

 self.ui:addButton(70, 23, 10, 2, 'cancel', 'openTrade', 0xEFEF00, 0x5A5A5A, "center", "printTrades")

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
 self.ui:addButton(2, 23, 45, 2, 'stock:'..stTex..' ('..stT..')', 'openTrade', 0x2F2F2F, 0xFF9900, "left", "stockStatus")
 
 self.ui:drawScreen("openTrade")
end

function marketGUI:openTradeListing(cnt, offer, price, posX, posY, selectedCnt)
 local bg = 0x2D2D2D
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
