component = require("component")
sides = require("sides")
term = require("term")
colors = require("colors")
gpu = component.gpu

i = component.transposer

cP = sides.west
cIn = sides.north
cOut = sides.east
cRef = sides.bottom
cSto = sides.top

-- currently also offset for the trades...
yOffset = 2

curAction = "startup"
currentOffer = ""

stock = {}

print("stock size: " .. i.getInventorySize(cSto) .. " slots")



function trade(item, cnt)
  term.clear()
  local pri = (currentPrice.size * cnt)
  print(cnt .. ' x ' ..item.name .. ' for '.. pri .. ' x ' .. currentPrice.name) 
  
  local userItem = i.getStackInSlot(cIn, 1)
  if userItem then if userItem.name == currentPrice.name then
	if userItem.size >= pri then
	  
	  i.transferItem(cIn, cSto, pri, 1)
	  
	  if getStockSize(item.name) >= cnt
	  then
		-- update stock cache    
		local index = getStockIndex(item.name)
		stock[index].size = stock[index].size - cnt;
	  
		-- 
		
		for j=1,i.getInventorySize(cSto) do
		  local tmp = i.getStackInSlot(cSto, j)
		  c = 0
		  if tmp then if tmp.name == item.name then
			if tmp.size >= cnt then
			  c = cnt
			else
			  c = tmp.size
		  end
		  
		  i.transferItem(sides.top, sides.east, c, j)
		  cnt = cnt - c
		  end end
	  
		  if cnt < 1 then
			break
		  end

		end

	  else
		print("not enough items in stock to trade")
	  end  
	else
		print("you have to add more materials to the input")		
	end
  end end
  
  os.sleep(3)

  refresh()  
end

function touchEvent(x, y)
 if curAction == "printTrades"
  then
    if y == 1 then
--      curAction = "refund"
      refund()
    elseif y == 2 then
     curAction = "printTrades"
     refresh()
    else
     curAction = "openTrade"
     openTrade(y - yOffset)
    end
    return
  end

 if curAction == "openTrade"
  then
    local item = "minecraft:gold_ingot"
    if y == 5 then
      trade(currentOffer, currentOfferOffers[1])
    elseif y == 6 then
      trade(currentOffer, currentOfferOffers[2])
    elseif y == 7 then
      trade(currentOffer, currentOfferOffers[3])
    elseif y == 8 then
      trade(currentOffer, currentOfferOffers[4])
    elseif y == 9 then
      trade(currentOffer, currentOfferOffers[5])
    elseif y == 15 then
      refresh()
      curAction = "printTrades"
    elseif y == 13 then
      curAction = "refund"
      term.clear()
      refund()
      print("your items are now in the middle chest")
      os.sleep(3)
      refresh()
      curAction = "printTrades"
    end

    return
  end
end


function refund()
  i.transferItem(sides.north, sides.bottom)
end



function printBalance()
 local foo = i.getStackInSlot(cIn, 1)
 if foo
 then
   print(foo.size .. "x" .. foo.name)
 else
   print("please insert materials to trade in the left mini-chest")
 end
end


function printTrades()
 curAction = "printTrades"
 local userItems = i.getStackInSlot(cIn, 1)
 local d = 0 

 for j=1,(i.getInventorySize(cP)/2) do
  local slot = j + (math.floor((j-1) / 9) * 9)
  local price = i.getStackInSlot(cP, slot)
  local offer = i.getStackInSlot(cP, (slot+9))

  if offer then if price then
    gpu.setForeground(0xFFFFFF)
    local line = 1 + yOffset + d

    local cnt = getStockSize(offer.name)

    gpu.set(1, line, offer.size .. " x " .. offer.name)    

    gpu.setForeground(0xFF0000)
    if userItems then if price.name == userItems.name then if price.size <= userItems.size then
      gpu.setForeground(0x00FF00)
    end end end
    gpu.set(30, line, "price: " .. price.size .. " x " .. price.name)
    d=d+1

    gpu.setForeground(0x505050)
    gpu.set(65, line, "#" .. cnt)

  end end
 end

end


function getStockSize(itemName)
  local foo = getStockIndex(itemName)
  if foo then 
  return stock[foo].size
  else
   return 0
 end
end

function getStockIndex(itemName)
 for index, foo in pairs(stock) do
  if foo.name == itemName
  then
    return index
  end
 end

 return
end

function refreshStock()
  print("loading stock, this may take some time!")
  
  local s = i.getInventorySize(cSto)
  
  for j=1,s do
   stack = i.getStackInSlot(cSto, j)
   if stack then
    local f = getStockIndex(stack.name)
    if f then
     stock[f].size = stock[f].size + stack.size
    else
     stock[#stock+1] = stack
    end
   end
   term.write("#")
   end
end


function openTrade(index)
 local price = i.getStackInSlot(cP, index)
 local offer = i.getStackInSlot(cP, index+9)

 currentOffer = offer
 currentPrice = price

 if offer then if price then
 curAction = "openTrade"
 term.clear()
 
 gpu.setForeground(0x11EE11)
 gpu.set(1, 1, 'offer: ' .. offer.size .. ' x ' .. offer.name) 
 gpu.setForeground(0xEE1111)
 gpu.set(1, 2, 'price: ' .. price.size .. ' x ' .. price.name)

 gpu.setBackground(0x404040)
 gpu.setForeground(0xFFFFFF)
 gpu.set(5, 5, 'get 1 (' .. price.size/offer.size .. ' x ' .. price.name .. ')')
 gpu.set(5, 6, 'get '..(offer.size*2)..' (' .. (price.size*(offer.size*2))/offer.size .. ' x '  .. price.name .. ')')
 gpu.set(5, 7, 'get '..(offer.size*4)..' (' .. (price.size*(offer.size*4))/offer.size .. ' x '  .. price.name .. ')')
 gpu.set(5, 8, 'get '..(offer.size*8)..' (' .. (price.size*(offer.size*8))/offer.size .. ' x '  .. price.name .. ')')
 gpu.set(5, 9, 'get '..(offer.size*64)..' (' .. (price.size*(offer.size*64))/offer.size .. ' x '  .. price.name .. ')') 
 
 
 currentOfferOffers = { 1, (offer.size*2), (offer.size*4), (offer.size*8), (offer.size*64)}
 
 gpu.set(5, 13, 'cancel & refund')  
 
 gpu.set(5, 15, 'back to main menue')

 gpu.setBackground(0x000000)
 gpu.setForeground(0xFFFFFF)
end end 

end



function refresh()
-- curAction = "refresh"
 term.clear()
 gpu.setBackground(0x808080)
 gpu.setForeground(0x420420)
 gpu.set(1, 1, 'Trade-Station (refund items)')
 gpu.setForeground(0x424242)
 gpu.set(1, 2, 'click here to refresh')

 gpu.setBackground(0x000000)
 printTrades()
 
 gpu.setForeground(0xFFFFFF)
 gpu.setBackground(0x000000)
end
