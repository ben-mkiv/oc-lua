require ("package").loaded.marketGUI = nil
gui = require ("marketGUI")

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


function split(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end


function trade(data)
  local cnt = data[1]
  local offer = data[2]
  local price = data[3]


  local pri = calcPrice(offer, price, cnt)
  
  local userItem = i.getStackInSlot(cIn, 1)
    if userItem then if userItem.name == price.name then
    
      if userItem.size >= pri then
         i.transferItem(cIn, cSto, pri, 1)
         if getStockSize(offer.name) >= cnt then
              -- update stock cache    
              local index = getStockIndex(offer.name)
              stock[index].size = stock[index].size - cnt;
        
              for j=1,i.getInventorySize(cSto) do
                local tmp = i.getStackInSlot(cSto, j)
                c = 0
                if tmp then if tmp.name == offer.name then
                  if tmp.size >= cnt then
                    c = cnt
                  else
                    c = tmp.size
                  end
                
                  i.transferItem(sides.top, sides.east, c, j)
                  cnt = cnt - c
                end end

               if cnt < 1 then
                gui.addButton(5, 5, 40, 2, "your items are now in the right chest", "trade", 0x00EF00, 0x202020, "center", printTrades)
                gui.drawScreen("trade")           
                return
               end
            end
         else
            gui.addButton(5, 4, 30, 2, "not enough items in stock to trade", "trade", 0xEF0000, 0x202020, "center", printTrades)
         end  
      else
      gui.addButton(5, 3, 30, 2, "not enough material to trade", "trade", 0xEF0000, 0x202020, "center", printTrades)
      end
  end end

  gui.addButton(5,10,40,2, "trade failed, back to main menue", "trade", 0xDDAAAA, 0x303030, "center", printTrades)
  gui.drawScreen("trade")
end



function refund()
  gui.addButton(4, 5, 40, 2, "your items are now in the middle chest", "refund", 0xFFEEDD, 0x303030, "center", printTrades)
  gui.addButton(4, 8, 20, 2, "back to main menue", "refund", 0xFFEEDD, 0x303030, "center", printTrades)
  i.transferItem(sides.north, sides.bottom)

  gui.drawScreen("refund")
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


trades = {}

function loadTrades()
  gui.addButton(1, 2, 50, 1, "loading trades, this may take some time...", "loadTrades", 0xFF00FF, 0x303030, "center")
  gui.drawScreen("loadTrades")
  
  trades = {}
  local s = i.getInventorySize(cP)
  
  for j=1,(s/2) do
    gui.drawStatusbar(5, 5, 40, 1, s/2, j, "reading pricing inventory ")
    
    local slot = j + (math.floor((j-1) / 9) * 9)
    local foo = {}
    foo.price = i.getStackInSlot(cP, slot)
    foo.offer = i.getStackInSlot(cP, (slot+9))



    if foo.offer then if foo.price then
      table.insert(trades, foo)
    end end
  end
end


function printTrades(page)
  gui.flush(true)  

  if page == nil then
    page = 1
  end 

 local userItems = i.getStackInSlot(cIn, 1)

 local o = ((page-1)*8)
 
 for s=1,#trades do
    local j = o+s 
   
    if j > #trades then
      break
    end    

    if s > 8 then
      break
    end

    local offer = trades[j].offer
    local price = trades[j].price
    local cnt = getStockSize(offer.name)
  
    local budget = false
    if userItems then if price.name == userItems.name then if price.size <= userItems.size then
      budget = true
    end end end
    
    local t = split(offer.name, ":")
    local offername = t[2]
    local t = split(price.name, ":")
    local pricename = t[2]

    if offername == "material" then
     offername = offer.name
    end

    if pricename == "material" then
      pricename = price.name
    end

    l = j - ((page-1) * 8)

    gui.addButton(2, yOffset+(l*2)-1, 40, 1, "‡ " .. offer.size .. " x " .. offername, 'printTrades', 0x10EF10, 0x202020, "center", openTrade, {offer, price})
    gui.addButton(2, yOffset+(l*2), 40, 1, "† price: " .. price.size .. " x " .. pricename, 'printTrades', 0xEF1010, 0x202020, "center", openTrade, {offer, price})
    gui.addButton(30, yOffset+(l*2), 20, 1, "(" .. cnt .. " in stock)", 'printTrades', 0xEFEF00, 0x202020, "center", openTrade, {offer, price})
  end

  if page > 1 then
    gui.addButton(1, 23, 24, 2, "<< Page left", "printTrades", 0xFFFFFF, 0x202020, "left", printTrades, page-1)
  end
   
  if (#trades/8)-page > 0 then
    gui.addButton(21, 23, 24, 2, "Page Right >>", "printTrades", 0xFFFFFF, 0x202020, "right", printTrades, page+1)
  end

  gui.drawScreen('printTrades')
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
  gui.addButton(1, 2, 50, 1, "loading stock, this may take some time...", "loadStock", 0xFF00FF, 0x303030, "center")
  gui.drawScreen("loadStock")
  
  local s = i.getInventorySize(cSto)
  
  for j=1,s do
   gui.drawStatusbar(5, 5, 40, 1, s, j, "reading stock inventory ")
     
   addToStock(i.getStackInSlot(cSto, j))     
   end
end

function addToStock(stack)
  if stack then
    local f = getStockIndex(stack.name)
    if f then
      stock[f].size = stock[f].size + stack.size
    else
      table.insert(stock, stack)
    end
  end
end

function calcPrice(offer, price, cnt)
  local p = 0
  
  local ratio = price.size/offer.size
  
  p = ratio * cnt

  return math.ceil(p)
end


function openTrade(data)
 local offer = data[1]
 local price = data[2]

 if offer then if price then
 curAction = "openTrade"
 
 local offername = split(offer.name, ":")[2]
 local pricename = split(price.name, ":")[2]

 gui.addButton(3, 6, 40, 2, 'get 1 (' .. calcPrice(offer, price, 1) .. ' x ' .. pricename .. ')', 'openTrade', 0xEFEFEF, 0x202020, "center", trade, { 1, offer, price })
 
 if price.size*2 <= 64 then
   gui.addButton(3, 9, 40, 2, 'get 2 (' .. calcPrice(offer, price, 2) .. ' x ' .. pricename .. ')', 'openTrade', 0xEFEFEF, 0x202020, "center", trade, { 2, offer, price })
 end
 
 if price.size*10 <= 64 then
   gui.addButton(3, 12, 40, 2, 'get 10 (' .. calcPrice(offer, price, 10) .. ' x ' .. pricename .. ')', 'openTrade', 0xEFEFEF, 0x202020, "center", trade, { 10, offer, price })
 end

 if price.size*32 <= 64 then
   gui.addButton(3, 15, 40, 2, 'get 32 (' .. calcPrice(offer, price, 32) .. ' x ' .. pricename .. ')', 'openTrade', 0xEFEFEF, 0x202020, "center", trade, { 32, offer, price })
 end
  
 if price.size*64 <= 64 then
   gui.addButton(3, 18, 40, 2, 'get 64 (' .. calcPrice(offer, price, 64) .. ' x ' .. pricename .. ')', 'openTrade', 0xEFEFEF, 0x202020, "center", trade, { 64, offer, price })
 end

 gui.addButton(5, 22, 20, 2, 'cancel', 'openTrade', 0xEFEF00, 0x202020, "center", printTrades)
 gui.drawScreen("openTrade")

 gpu.setForeground(0x11EE11)
 gpu.set(1, 3, 'offer: ' .. offer.size .. ' x ' .. offername) 
 gpu.setForeground(0xEE1111)
 gpu.set(1, 4, 'price: ' .. price.size .. ' x ' .. pricename)
end end 
end
