function hazeUI:drawTools()
	self:addButton(32, 3, 20, 2, "read recipe", "tools", 0xFFB000, 0x282828, "left", "readRecipe")
	self:addButton(32, 6, 20, 2, "start crafting", "tools", 0xFFB000, 0x282828, "left", function()
		self:startCrafting()
		self:drawMain()
		end)
	self:addButton(32, 9, 20, 2, "sync inventory", "tools", 0xFFB000, 0x282828, "left", "readInventory")
	self:addButton(32, 12, 20, 2, "cleanup", "tools", 0xFFB000, 0x282828, "left", "cleanup")
	
	self:addButton(32, 15, 20, 2, "generate upgrade recipes", "tools", 0xFFB000, 0x282828, "left", "generateUpgradeRecipes")


	self:addButton(2, 23, 20, 3, "back", "tools", 0xFFA200, 0x282828, "center", "drawMain")
	
	self:drawScreen("tools")	
end


function hazeUI:generateUpgradeRecipes()
	upgradeRecipes = {
	Basic = { },
	Wyvern = { },
	Draconic = { },
	Chaotic = { }
	
	}
	
	
end

function hazeUI:drawMain()
	self:flushElements(true)
	self:setElement({index = titleBar, text = "draconic infusion crafting"})
	
	self:addButton(2, 3, 20, 2, "tools", "main", 0xFFB000, 0x282828, "left", "drawTools")
		
	self:addButton(2, 12, 20, 1, "upgrades", "main", 0x282828, 0xFFB000, "left")
	for i=1,#upgradeKeys do
		self:addButton(2, 12+i, 20, 1, upgradeKeys[i].nameShort, "main", 0xFFAD00, 0x4A4A4A, "left", "showUpgrade", i) end
		
	self:addButton(40, 3, 40, 1, "crafting recipes", "main", 0xFFB000, 0x282828, "left")
	for i=1,#recipes do		
		local bgColor = 0xFFB000
		if self:checkItems(i) ~= false then bgColor = 0x3AA700 end
		self:addButton(40, 3+i, 40, 1, recipes[i].output.label, "main", 0x282828, bgColor, "left", "showRecipe", i)
	end
	
	self:drawScreen("main")		
end



function hazeUI:readRecipe()
	self:drawScreen("clear")
	local crafter = component.proxy(config.devices.transposer.crafter.address)
	local recipe = {}
		  recipe.materials = {}
		  recipe.input = crafter.getStackInSlot(config.devices.transposer.crafter.sideCrafter, 1)
		  recipe.output = crafter.getStackInSlot(config.devices.transposer.crafter.sideOutput, 1)		  
    local s = #config.devices.transposer.injectors
	for i=1,s do
		self:drawStatusbar(5, 5, 40, 1, 1+s, i, "reading recipe")		
		local injector = component.proxy(config.devices.transposer.injectors[i].address)
		local tmp = injector.getStackInSlot(config.devices.transposer.injectors[i].sideInjector, 1)
		if tmp and tmp ~= nil then
			table.insert(recipe.materials, tmp)
		end
		os.sleep(0)
	end

	if not recipe.output then
		self:addButton(2, 3, 70, 3, " reading recipe failed, no output found", "readRecipeFailed", 0x282828, 0xFFA200, "left")
		self:drawScreen("readRecipeFailed")
		return false 
	end
	if not recipe.input then
		self:addButton(2, 3, 70, 3, " reading recipe failed, no input found", "readRecipeFailed", 0x282828, 0xFFA200, "left")
		self:drawScreen("readRecipeFailed")
		return false 
	end	
	table.insert(recipes, clone(recipe))	
	self:saveRecipesConfig()	
	return self:showRecipe(#recipes)
end

function hazeUI:loadRecipesConfig()
  local ser = require("serialization") 
  local fs = require("filesystem")
  if not fs.exists("/etc/de_infusioncrafting.conf") then
	self:saveRecipesConfig()	
  end
  
  local cf = io.open("/etc/de_infusioncrafting.conf", "r")
  local serData = cf:read("*a")
  cf:close()
  recipes = ser.unserialize(serData)  
  
  if not fs.exists("/etc/de_upgradeRecipes.conf") then
	local cf = io.open("/etc/de_upgradeRecipes.conf", "w")
	cf:write(ser.serialize(upgradeRecipes))
	cf:close()	
  end
  
  local cf = io.open("/etc/de_upgradeRecipes.conf", "r")
  local serData = cf:read("*a")
  cf:close()
  upgradeRecipes = ser.unserialize(serData)  
  self:compressRecipes()
end

function hazeUI:saveRecipesConfig()
	local ser = require("serialization") 
	local cf = io.open("/etc/de_infusioncrafting.conf", "w")
	cf:write(ser.serialize(recipes))
	cf:close()	
	self:compressRecipes()
end

function loadConfig()
  local ser = require("serialization") 
  local fs = require("filesystem")
  if not fs.exists("/etc/de.conf") then
	return
  end
  
  local cf = io.open("/etc/de.conf", "r")
  local serData = cf:read("*a")
  cf:close()
  config = ser.unserialize(serData)
end

function saveConfig()
	local ser = require("serialization") 
	local cf = io.open("/etc/de.conf", "w")
	cf:write(ser.serialize(config))
	cf:close()
end


function hazeUI:craftingStatus()
	local rs = component.proxy(config.devices.redstone.status.address)
	local status = rs.getInput(config.devices.redstone.status.side)
	local oldStatus = -1
	
	while status < 15 do
		status = rs.getInput(config.devices.redstone.status.side)
		if status ~= oldStatus then
			oldStatus = status
			self:drawStatusbar(5, 5, 40, 1, 15, status, "crafting...") end
		os.sleep(0.5) 
	end
	
	self:drawStatusbar(5, 5, 40, 1, 15, 15, "crafting. [done]")
	return true
end

function hazeUI:startCrafting()
	self:drawScreen("craftingStatus")
	self:drawStatusbar(5, 5, 40, 1, 100, 0, "starting crafting...")
	local rs = component.proxy(config.devices.redstone.crafter.address)
	rs.setOutput(config.devices.redstone.crafter.side, 15)
	os.sleep(0.5)
	self:drawStatusbar(5, 5, 40, 1, 100, 100, "starting crafting. [done]")	
	rs.setOutput(config.devices.redstone.crafter.side, 0)
	return self:craftingStatus()	
end

function hazeUI:craftRecipeLoop(data)
	for i=1,data.count do self:craftRecipe(data.recipe) end
	self:drawMain()
end

function hazeUI:showRecipe(i)
	local recipe = clone(recipes[i])
	
	local cnt = " "
	if recipe.output.size > 1 then cnt = " ".. recipe.output.size .. "x " end		
	self:addButton(30, 3, 40, 1, "output:"..cnt..recipe.output.label, "showRecipe", 0x282828, 0xFFA200, "left")
	
	local cnt = " "
	if recipe.input.size > 1 then cnt = " ".. recipe.input.size .. "x " end			
	self:addButton(30, 4, 40, 1, " input:"..cnt..recipe.input.label, "showRecipe", 0x282828, 0xFFA200, "left")
	
	local maxCraftable = math.huge

	for j=1,#recipe.materials do 
		local cnt = " "
		if recipe.materials[j].size > 1 then cnt = " "..recipe.materials[j].size.."x " end
		self:addButton(30, 5+j, 40, 1, "injector #"..j..cnt..recipe.materials[j].label, "showRecipe", 0xFFA200, 0x484848, "left") 
	end		
	for j=1,#recipes_compressed[i] do 
		local bgColor = 0x3AA700
		local stockCnt = self:checkItem(recipes_compressed[i][j])
		if stockCnt == false then
			bgColor = 0x9D0000
			maxCraftable = 0
		elseif math.floor(stockCnt / recipes_compressed[i][j].size) < maxCraftable then
		    maxCraftable = math.floor(stockCnt / recipes_compressed[i][j].size) end
		local cnt = " "
		if recipes_compressed[i][j].size > 1 then cnt = " "..recipes_compressed[i][j].size .. "x " end
		self:addButton(30, 17+j, 40, 1, cnt .. recipes_compressed[i][j].label, "showRecipe", 0x0, bgColor, "left") 
	end
	
	self:addButton(2, 23, 20, 3, "back", "showRecipe", 0xFFA200, 0x282828, "center", "drawMain")
	self:addButton(63, 25, 18, 1, "remove recipe", "showRecipe", 0x0, 0x9A1200, "center", "removeRecipe", recipe)
	
	if maxCraftable >= 1 then self:addButton(2, 8, 20, 3, "craft recipe", "showRecipe", 0x282828, 0xFFA200, "center", "craftRecipeLoop", {recipe = i, count = 1}) end	
	if maxCraftable > 1 then self:addButton(2, 12, 20, 3, "craft recipe "..maxCraftable.."x", "showRecipe", 0x282828, 0xFFA200, "center", "craftRecipeLoop", {recipe = i, count = maxCraftable}) end	
	self:drawScreen("showRecipe")	
end

function hazeUI:removeRecipe(recipe)
  for i=1,#recipes do
	if recipes[i].output.name == recipe.output.name and recipes[i].output.label == recipe.output.label then
		table.remove(recipes, i) end
  end
  self:saveRecipesConfig()
  self:drawMain()
end

function hazeUI:compressRecipes()
	recipes_compressed = {}
	for d=1,#recipes do
		recipes_compressed[d] = {}		
		self:addCompressedRecipeItem(d, recipes[d].input)		
		for i=1,#recipes[d].materials do
			self:addCompressedRecipeItem(d, recipes[d].materials[i])
	end	end		
	upgradeRecipes_compressed = {}
	for d=1,#upgradeRecipes do
		upgradeRecipes_compressed[d] = {}
		for i=1,#upgradeRecipes[d] do
			self:addCompressedUpgradeRecipeItem(d, upgradeRecipes[d][i])
	end end		
end

function hazeUI:addCompressedUpgradeRecipeItem(d, item)
	for i=1,#upgradeRecipes_compressed[d] do
		if upgradeRecipes_compressed[d][i].label == item.label and upgradeRecipes_compressed[d][i].name == item.name then
			upgradeRecipes_compressed[d][i].size = upgradeRecipes_compressed[d][i].size + item.size
			return true
	end end 
	table.insert(upgradeRecipes_compressed[d], clone(item)) 
end

function hazeUI:addCompressedRecipeItem(d, item)
	for i=1,#recipes_compressed[d] do
		if recipes_compressed[d][i].label == item.label and recipes_compressed[d][i].name == item.name then
			recipes_compressed[d][i].size = recipes_compressed[d][i].size + item.size
			return true
	end end 
	table.insert(recipes_compressed[d], clone(item)) 
end
 
function hazeUI:checkItems(recipe)	
	for i=1,#recipes_compressed[recipe] do
		if self:checkItem(recipes_compressed[recipe][i]) == false then
			return false 
		end end
	return true
end

function hazeUI:checkItem(item)
  for i=1,#inventory do
    if item.label == inventory[i].label and item.name == inventory[i].name then
	  if item.size <= inventory[i].size then 
	    return inventory[i].size
  end end end
  return false
end

function hazeUI:addCompressedInventory(item)	
	for i=1,#inventory do
		if inventory[i].label == item.label and inventory[i].name == item.name then
			inventory[i].size = inventory[i].size + item.size
			return true
	end end
	table.insert(inventory, clone(item))
end

function hazeUI:readInventory()
	self:drawScreen("clear")
	upgradeKeys = {}
	inventoryAll = {}
	local crafter = component.proxy(config.devices.transposer.crafter.address)
	local s = crafter.getInventorySize(config.devices.transposer.crafter.sideInput)
	for i=1,s do
		self:drawStatusbar(5, 5, 40, 1, s, i, "syncing inventory...")
		local tmp = crafter.getStackInSlot(config.devices.transposer.crafter.sideInput, i)
		if tmp ~= nil then
			tmp.invSlot = i
				
			if string.find(tmp.label, "Upgrade Key") then
				tmp.nameShort = string.gsub(tmp.label, 'Upgrade Key ', "")
			    tmp.nameShort = string.gsub(tmp.nameShort, "[-()]+", "")
			   table.insert(upgradeKeys, tmp)				
			else
				table.insert(inventoryAll, tmp)
			end end end	
	self:compressInventory()
	
	self:drawMain()
end

function hazeUI:compressInventory()
	inventory = {}	
	for i=1,#inventoryAll do	self:addCompressedInventory(inventoryAll[i]) end
end

function hazeUI:transferItemToCrafter(item, size)
  local i = self:getFromInventory(item)
  if inventoryAll[i].size < item.size then 
    size = inventoryAll[i].size 
  end
  local crafter = component.proxy(config.devices.transposer.crafter.address)
  crafter.transferItem(config.devices.transposer.crafter.sideInput, config.devices.transposer.crafter.sideCrafter, size, inventoryAll[i].invSlot)
  inventoryAll[i].size = (inventoryAll[i].size - size)
  return size
end

function hazeUI:transferItemToInjector(injec, item, size)
  local i = self:getFromInventory(item)
  if inventoryAll[i].size < size then 
    size = inventoryAll[i].size 
  end	
  if size > 0 then 
	index = getTransposerIndex(injec.address)
	injec.transferItem(config.devices.transposer.injectors[index].sideInventory, config.devices.transposer.injectors[index].sideInjector, size, inventoryAll[i].invSlot)
	inventoryAll[i].size = (inventoryAll[i].size - size) 
  end 
  return size
end

function hazeUI:moveCraftingOutputToInputChest()
	local crafter = component.proxy(config.devices.transposer.crafter.address)
	crafter.transferItem(config.devices.transposer.crafter.sideCrafter, config.devices.transposer.crafter.sideInput) 
	self:readInventory()
end

function hazeUI:craftRecipe(d)
  self:drawScreen("craftRecipe") 
  
  --self:setElement({index = titleBar, text = "draconic infusion crafting, crafting: "..recipes[d].output.label})
  --self:drawElement(titleBar)
  
  self:drawStatusbar(5, 5, 40, 1, 10, 1, "moving items to crafter...")
	
  local tmpSize = recipes[d].input.size
  while tmpSize > 0 do
	tmpSize = tmpSize - self:transferItemToCrafter(recipes[d].input, tmpSize)
  end

  for j=1,#recipes[d].materials do
    self:drawStatusbar(5, 5, 40, 1, 10, 1+j, "moving items to injectors...")
    local tmpSize = recipes[d].materials[j].size
    while tmpSize > 0 do
	  tmpSize = tmpSize - self:transferItemToInjector(component.proxy(config.devices.transposer.injectors[j].address), recipes[d].materials[j], tmpSize)
	end
  end  
  
  self:startCrafting()
  
  --self:setElement({index = titleBar, text = "draconic infusion crafting, "..recipes[d].output.label})
  --self:drawElement(titleBar)
  
  --self:drawElement(self:addButton(3, 15, 50, 3, "move items to input chest", "craftRecipe", 0xFFA200, 0x282828, "left", "moveCraftingOutputToInputChest"))
  
  --for j=1,10 do
--	self:drawStatusbar(3, 10, 50, 1, 10, j, "moving output to storage after timeout")
--	os.sleep(0.3)
 -- end
  local crafter = component.proxy(config.devices.transposer.crafter.address)
  if crafter.getStackInSlot(config.devices.transposer.crafter.sideCrafter, 2) ~= nil then 
	crafter.transferItem(config.devices.transposer.crafter.sideCrafter, config.devices.transposer.crafter.sideInput, 64, 2)
  end
end

function hazeUI:flushInventory()
  for i=1,#inventoryAll do if inventoryAll[i].size < 1 then 
    table.remove(inventoryAll, i) 
	return self:flushInventory()
  end end
  
  self:compressInventory()
  return true
end

function hazeUI:getFromInventory(item)
  self:flushInventory()  
  for i=1,#inventoryAll do
    if inventoryAll[i].name == item.name and inventoryAll[i].label == item.label then
		return i
  end end  
  return nil
end

function hazeUI:showUpgrade(i)	
	local tierNames = { "Basic", "Wyvern", "Draconic", "Chaotic" }
	
	self:addButton(25, 3, 55, 1, "upgrade: "..upgradeKeys[i].nameShort, "showUpgrade", 0xFFA200, 0x282828, "left")
	
	--self:setElement({index = titleBar, text = "draconic infusion crafting, upgrade: "..upgradeKeys[i].nameShort.." ("..item.label..")"})
	--self:drawElement(titleBar)	
	local crafter = component.proxy(config.devices.transposer.crafter.address)
	local item = crafter.getStackInSlot(1, 1)
	
	if item ~= nil then
		self:addButton(25, 4, 55, 1, "item: "..item.label, "showUpgrade", 0xFFA200, 0x282828, "left")	
	end
	
	local row = 1
	local col = 1
	for tier=1,#upgradeRecipes_compressed do
		if math.ceil(tier/2) > col then
			col = math.ceil(tier/2)
			row = 1
		end
		
		local xoffset = 25+((col-1)*28)
		
		local maxCraftable = math.huge
		self:addButton(xoffset, 5+row, 27, 1, tierNames[tier], "showUpgrade", 0x282828, 0xFFA200, "left", "startUpgrade", {i, tier}) 
			
		for j=1,#upgradeRecipes_compressed[tier] do 
			local bgColor = 0x3AA700
			local stockCnt = self:checkItem(upgradeRecipes_compressed[tier][j])
			if stockCnt == false then
			  bgColor = 0x9D0000
			  maxCraftable = 0
			elseif math.floor(stockCnt / upgradeRecipes_compressed[tier][j].size) < maxCraftable then
			  maxCraftable = math.floor(stockCnt / upgradeRecipes_compressed[tier][j].size) 
			end
					
			local cnt = ""
			if upgradeRecipes_compressed[tier][j].size > 1 then cnt = ""..upgradeRecipes_compressed[tier][j].size .. "x " end
			self:addButton(xoffset, 6+row, 2, 1, "", "showUpgrade", bgColor, bgColor, "left", "startUpgrade", {i, tier}) 
			self:addButton(xoffset+2, 6+row, 25, 1, cnt .. upgradeRecipes_compressed[tier][j].label, "showUpgrade", 0xFFA200, 0x282828, "left", "startUpgrade", {i, tier}) 
			row = row + 1
	end	
		row = row+2
	end
	self:addButton(2, 23, 20, 3, "back", "showUpgrade", 0xFFA200, 0x282828, "center", "drawMain")
	self:drawScreen("showUpgrade")	
end

function hazeUI:startUpgrade(data)
	local crafter = component.proxy(config.devices.transposer.crafter.address)
	local i = data[1]
	local d = data[2]
	local item = crafter.getStackInSlot(1, 1)
	
	if item == nil then
		self:addButton(2, 3, 70, 3, " put the item you want to upgrade in the crafter", "startUpgradeFailed", 0x282828, 0xFFA200, "left")
		self:drawScreen("startUpgradeFailed")
		return false 		
	end
	
	--self:setElement({index = titleBar, text = "draconic infusion crafting, upgrading: "..upgradeKeys[i].nameShort.." ("..item.label..")"})
	--self:drawElement(titleBar)
	
	self:addButton(2, 3, 70, 1, " upgrade: "..upgradeKeys[i].nameShort.." ("..item.label..")", "craftUpgrade", 0xFFA200, 0x282828, "left")
	self:drawScreen("craftUpgrade")	
	
	self:drawStatusbar(5, 5, 40, 1, 13, 1, "moving updatekey to injector...")
	
	local injector = component.proxy(config.devices.transposer.injectors[9].address)
	
	injector.transferItem(config.devices.transposer.injectors[9].sideInventory, config.devices.transposer.injectors[9].sideInjector, 1, upgradeKeys[i].invSlot)
	
	for j=1,#upgradeRecipes[d] do
		self:drawStatusbar(5, 5, 40, 1, 13, 1+j, "moving items to injectors...")
		local tmpSize = upgradeRecipes[d][j].size
		while tmpSize > 0 do
			tmpSize = tmpSize - self:transferItemToInjector(component.proxy(config.devices.transposer.injectors[j].address), upgradeRecipes[d][j], tmpSize)
		end
	end  
  
	self:startCrafting()
	self:drawStatusbar(5, 5, 40, 1, 13, 11, "moving updatekey back...")
	injector.transferItem(config.devices.transposer.injectors[9].sideInjector, config.devices.transposer.injectors[9].sideInventory, 1, 1, upgradeKeys[i].invSlot)
	
	self:drawStatusbar(5, 5, 40, 1, 13, 12, "moving item back to input")
	
	 crafter.transferItem(config.devices.transposer.crafter.sideCrafter, config.devices.transposer.crafter.sideCrafter, 1, 2, 1) 
	 self:drawStatusbar(5, 5, 40, 1, 13, 13, "done")
	  
	 self:drawMain()	
end

function hazeUI:cleanup()
	local crafter = component.proxy(config.devices.transposer.crafter.address)
	--crafter output to output
	if crafter.getStackInSlot(config.devices.transposer.crafter.sideCrafter, 2) ~= nil then 
		crafter.transferItem(config.devices.transposer.crafter.sideCrafter, config.devices.transposer.crafter.sideInput, 64, 2)
	end
	--crafter input to inputchest
	if crafter.getStackInSlot(config.devices.transposer.crafter.sideCrafter, 1) ~= nil then 
		crafter.transferItem(config.devices.transposer.crafter.sideCrafter, config.devices.transposer.crafter.sideInput, 64, 1)
	end
	
	--injectors to inputchest
	for i=1,#config.devices.transposer.injectors do component.proxy(config.devices.transposer.injectors[i].address).transferItem(config.devices.transposer.injectors[i].sideInjector, config.devices.transposer.injectors[i].sideInventory) end
	
	self:readInventory()
end

redstoneInitDone = false
function setRedstoneDevice(data)
	if data.label == "crafter" then	
		config.devices.redstone.crafter.address = data.e.address
	elseif data.label == "comparator" then
		config.devices.redstone.status.address = data.e.address
	end
	redstoneInitDone = true
end

function setRedstoneSide(data)
	if config.devices.redstone.crafter.address == data.e.address then
		config.devices.redstone.crafter.side = (data.value - 1)
	elseif config.devices.redstone.status.address == data.e.address then
		config.devices.redstone.status.side = (data.value - 1)
	end
		
	redstoneInitDone = true
end

function configureRedstoneDevice(address)
	gui:addButton(2, 3, 70, 3, "found redstone interface "..address, "initRedstone", 0x282828, 0xFFA200, "left")
	gui:drawScreen("initRedstone")
		
	redstoneInitDone = false
	gui:list("set redstone mode for "..address, "please select the connected device from the list", {"crafter", "comparator"}, { f = setRedstoneDevice, p = { address = address }}, nil, nil)
	while not redstoneInitDone do os.sleep(0.1); end	
				
	redstoneInitDone = false
	gui:list("set connected side for "..address, "please select the connected side from the list", {"bottom", "top", "north", "south", "west", "east"}, { f = setRedstoneSide, p = { address = address }}, nil, nil)
	while not redstoneInitDone do os.sleep(0.1); end	
end

function transposerStats(t)
	inventorys = {}
	if t ~= nil then for i=0,(#sides-1) do
		inv = t.getInventorySize(i)
		if inv ~= nil then
			table.insert(inventorys, { side = i, size = inv })
		end
	end end
	return inventorys
end

transposerInitDone = false
function setTransposerDevice(data)
	--s = transposerStats(component.proxy(data.e.address))	
	if data.label == "crafter" then	
		config.devices.transposer.crafter.address = data.e.address
	elseif data.label == "injector" then
		table.insert(config.devices.transposer.injectors, { address = data.e.address, sideInjector = sides.bottom, sideInventory = sides.top })		
	end	
	
	transposerInitDone = data.label
end

function getTransposerIndex(address)
	for i=1,#config.devices.transposer.injectors do
		if config.devices.transposer.injectors[i].address == address then
			return i
		end
	end
end

function setTransposerCrafter(data)
	config.devices.transposer.crafter.sideCrafter = (data.value - 1)	
	transposerInitDone = data.label
end

function setTransposerCrafterOutput(data)
	config.devices.transposer.crafter.sideOutput = (data.value - 1)	
	transposerInitDone = data.label
end

function setTransposerCrafterInput(data)
	config.devices.transposer.crafter.sideInput = (data.value - 1)	
	transposerInitDone = data.label
end

function configureTransposerDevice(address)
	gui:addButton(2, 3, 70, 3, "found transposer "..address, "initTransposer", 0x282828, 0xFFA200, "left")
	gui:drawScreen("initTransposer")
		
	local tStats = transposerStats(component.proxy(address))
	
	local maxInv = 0
	for i=1,#tStats do if tStats[i].size > maxInv then maxInv = tStats[i].size; end; end
	local minInv = maxInv	
	for i=1,#tStats do if tStats[i].size < minInv then minInv = tStats[i].size; end; end
	
	local text = "no idea... "..minInv.."/"..maxInv

	if minInv == 2 then
		text = "crafter?"
	elseif minInv == 1 then
		text = "injector?"
	end	
	  
	transposerInitDone = false
	gui:list("set mode for transposer "..address, text, {"crafter", "injector"}, { f = setTransposerDevice, p = { address = address }}, nil, nil)
	while transposerInitDone == false do os.sleep(0.1); end	
				  
	if transposerInitDone == "crafter" then
		transposerInitDone = false
		gui:list("set side for crafter", address, {"bottom", "top", "north", "south", "west", "east"}, { f = setTransposerCrafter, p = { address = address }}, nil, nil)
		while transposerInitDone == false do os.sleep(0.1); end
		
		transposerInitDone = false
		gui:list("set side for input", address, {"bottom", "top", "north", "south", "west", "east"}, { f = setTransposerCrafterInput, p = { address = address }}, nil, nil)
		while transposerInitDone == false do os.sleep(0.1); end	
		
		transposerInitDone = false
		gui:list("set side for output", address, {"bottom", "top", "north", "south", "west", "east"}, { f = setTransposerCrafterOutput, p = { address = address }}, nil, nil)
		while transposerInitDone == false do os.sleep(0.1); end	
	end
	
	os.sleep(0)
end 
