component = require("component")
event = require("event")
serialization = require("serialization")
sides = require("sides")
tankDeuterium = false
tankTritium = false
laserAmplifier = false
laIgnitionEnergy = 1250000
redstone = false
redstoneSide = false
inductionMatrix = false
glassesTerminal = false
reactor = false
offsetX = 0
offsetY = 0
buttons = {}

maxCaseHeat = 0
maxPlasmaHeat = 0
maxEnergyStored = 0
maxEnergy = 0
laMaxEnergyStored = 0
imMaxStorage = 0

statusbox = {}
statusbox.widgets = {}

injectionRateWidget = {}

function initComponents()
	for address,type in pairs(component.list("reactor_logic_adapter")) do 
		if reactor == false then
			print("found reactor "..address)
			reactor = component.proxy(address)
		else
			print("found another reactor ("..address.."). first one will be used.")
		end
	end

	for address,type in pairs(component.list("glasses")) do 
		if glassesTerminal == false then
			print("found glasses Terminal "..address)
			glassesTerminal = component.proxy(address)
		else
			print("found another glasses Terminal ("..address.."). first one will be used.")
		end
	end

	for address,type in pairs(component.list("_gas_tank")) do checkTank(address); os.sleep(0); end

	for address,type in pairs(component.list("laser_amplifier")) do 
		if laserAmplifier == false then
			print("found laser amplifier "..address)
			laserAmplifier = component.proxy(address)
		else
			print("found another laser amplifier ("..address.."). first one will be used.")
		end
	end

	for address,type in pairs(component.list("redstone")) do 
		if redstone == false then
			print("found redstone interface "..address)
			redstone = component.proxy(address)
		else
			print("found another redstone interface ("..address.."). first one will be used.")
		end
	end

	for address,type in pairs(component.list("induction_matrix")) do 
		if inductionMatrix == false then
			print("found induction matrix "..address)
			inductionMatrix = component.proxy(address)
		else
			print("found another induction matrix ("..address.."). first one will be used.")
		end
	end
end

function val2perc(val, maxVal)
	if(maxVal == 0) then return 0; end
	return (math.floor(0.5 + ((val/maxVal) * 100)*10)/10)
end

function readTankFull(address)
	local tank = component.proxy(address)
	return { gas = tank.getGas(), amount = tank.getStoredGas(), maxAmount = tank.getMaxGas(), tankType = tank.type }
end

function readTankStorage(tank)
	return { amount = tank.getStoredGas(), maxAmount = tank.getMaxGas() }
end

function checkTank(address)
	local tankData = readTankFull(address)
	if tankData.gas == nil then tankData.gas = "unknown"; end
	print("# found ".. tankData.tankType .. " with " .. tankData.amount .. "/" .. tankData.maxAmount .. " of " .. tankData.gas)	
	if string.match(tankData.gas, "deuterium") then
		print(" ... adding tank with address " .. address)
		if tankDeuterium == false then
			tankDeuterium = component.proxy(address)
		else
			print("found more than one Deuterium Gas Tank, using first one found")
			print("set a address in the script to use a user defined tank")
		end
	elseif string.match(tankData.gas, "tritium") then
		print(" ... adding tank")
		if tankTritium == false then
			tankTritium = component.proxy(address)
		else
			print("found more than one Tritium Gas Tank, using first one found")
			print("set a address in the script to use a user defined tank")
		end
	end
end

function addInfoHUD(x, y, w, h, label)
	local boxPadding = 3
	local element = {}
	b = glassesTerminal.addBox2D()
	b.addTranslation(x + offsetX, y + offsetY, 0)
	b.setSize(w, h)
	b.addColor(0, 0, 0, 0.5)
	b.addColor(0.05, 0.05, 0.05, 0.5)
	table.insert(element, b)
	s = glassesTerminal.addBox2D()
	s.addTranslation(x + offsetX + boxPadding, y + offsetY + boxPadding, 0)
	s.setSize(w-(2*boxPadding), h-(2*boxPadding))
	s.addColor(0, 0.5, 0, 0.5)
	s.addColor(0.05, 1, 0.05, 0.5)
	table.insert(element, s)
	t = glassesTerminal.addText2D()
	t.addTranslation(x + offsetX + 7, y + offsetY + 7, 0)
	t.setText(label)
	t.addColor(1, 1, 1, 0.7)	
	table.insert(element, t)
	return element
end

function addReactorHUD(x, y, w, h, label)
	local boxPadding = 3
	local element = {}	
	b = glassesTerminal.addBox2D()
	b.addTranslation(x + offsetX, y + offsetY, 0)
	b.setSize(w, h)
	b.addColor(0, 0, 0, 0.5)
	b.addColor(0.05, 0.05, 0.05, 0.5)	
	table.insert(element, b)	
	t = glassesTerminal.addText2D()
	t.addTranslation(x + offsetX + 7, y + offsetY + 7, 0)
	t.setText(label)
	t.addColor(1, 1, 1, 0.7)	
	table.insert(element, t)	
	return element
end

function MJ2RF(mj)
	if type(mj) == "string" then
		return mj
	end	
	return math.ceil(mj * 0.4)
end

function formatNumber(rf)
	rf = (math.floor(0.5 + (rf*100)) / 100)
	if rf >= 1000000000000 then 
		rf = (math.floor(0.5 + (rf*10/1000000000000)/10)) .. "T"
	elseif rf >= 1000000000 then 
		rf = (math.floor(0.5 + (rf*10/1000000000)/10)) .. "G"
	elseif rf >= 1000000 then 
		rf = (math.floor(0.5 + (rf*10/1000000)/10)) .. "M"
	elseif rf >= 1000 then 
		rf = math.floor(0.5 + (rf/1000)).."k"
	end	
	return rf
end

function perc2color(p)
	return { red = (1 * (1 - (p/100))), green = (1 * (p/100)), blue = 0 }
end

function bool2color(bool)
	if bool == true then 
		return { red = 0.2, green = 1, blue = 0.2 }
	else 
		return { red = 1, green = 0.2, blue = 0.2 }
	end			
end

function addInfo(label, value, x, y)
	info = {}
	info.label = label
	info.statusBar = false
	info.r = 1
	info.g = 1
	info.b = 1
	if type(value) == "boolean" then
		color = bool2color(value)
		info.r = color.red
		info.g = color.green
		info.b = color.blue
		if value == true then 
			value = "true"
		else 
			value = "false"
		end			
	elseif type(value) == "number" then
		value = ""..value
	end
	info.widgets = {}
	os.sleep(0)
	info.widgets.key = glassesTerminal.addText2D()
	info.widgets.key.setText(label)
	info.widgets.key.addTranslation(x + 120 + 5, y + 10, 0)
	info.widgets.key.addColor(1, 1, 1, 0.7)
	os.sleep(0)
	info.widgets.value = glassesTerminal.addText2D()
	info.widgets.value.setText(""..value.."")
	info.widgets.value.addTranslation(x + 100 + 120 + 5, y + 10, 0)
	info.widgets.value.addColor(info.r, info.g, info.b, 0.7)
	return info
end

function setColor(el, p)
	color = perc2color(p)
	el.updateModifier(2, color.red, color.green, 0, 0.7)
	el.updateModifier(3, color.red, color.green, 0, 0.8)	
end

function updateInjectionRate()
	injectionRate = reactor.getInjectionRate()
	for i=1,#buttons do
		if injectionRate == buttons[i].value then
			buttons[i].widgets.box.updateModifier(2, 0, 0.7, 0, 0.5)
			buttons[i].widgets.box.updateModifier(3, 0.05, 0.7, 0.05, 0.5)
		else
			buttons[i].widgets.box.updateModifier(2, 0, 0, 0, 0.5)
			buttons[i].widgets.box.updateModifier(3, 0.05, 0.05, 0.05, 0.5)
		end
		os.sleep(0)
	end	
end

function addInjectionButton(value, x, y)
	return addButton(value, x, y, 25, 25, function(value)
		if value == 0 then
			print("canceling, injection rate of 0 would disable the reactor")
			return
		end
		reactor.setInjectionRate(value)
		updateInjectionRate()
		print("set injection rate to " .. value)		
	end)
end

function addStatusBar(label, value, x, y)
	b = glassesTerminal.addBox2D()
	b.addTranslation(x + 123, y - 3, 0)
	b.addColor(1, 1, 1, 0.3)
	b.addColor(1, 1, 1, 0.2)	
	
	return updateStatusBar(b, value)
end

function updateStatusBar(el, value)
	w = ((value+5)/100) * 85 -- +5 to always display something
	local color = perc2color(value)	
	el.setSize(w, 10)
	el.updateModifier(2, color.red, color.green, color.blue, 0.3)
	el.updateModifier(3, color.red, color.green, color.blue, 0.2)		
	return el
end

function addButton(value, x, y, w, h, cb)
	el = {}
	el.value = value
	el.x = x
	el.y = y
	el.width = w
	el.height = h
	el.widgets = {}
	el.widgets.box = glassesTerminal.addBox2D()
	el.widgets.box.addTranslation(x, y, 0)
	el.widgets.box.setSize(el.width, el.height)
	el.widgets.box.addColor(0, 0, 0, 0.5)
	el.widgets.box.addColor(0.05, 0.05, 0.05, 0.5)
	el.widgets.text = glassesTerminal.addText2D()
	el.widgets.text.addTranslation(x+5, y+5, 0)
	el.widgets.text.setText(""..value.."")	
	el.cb = cb
	table.insert(buttons, el)	
	return #buttons
end

function rsIgnite(side)
	if reactor.isIgnited() then
		print("reactor is already ignited!")
		return
	end
	io.write("ignating...")
	redstone.setOutput(side, 15)
	os.sleep(5 * 0.05) -- wait 5 ticks
	redstone.setOutput(side, 0)
	os.sleep(0.05)
	if reactor.isIgnited() then
		print(" succed!")
		return true
	else
		print(" FAILED!")
		return false; end
end

function ignite(foo)
	if redstone == false then
		print("no redstone interface found!")
		return false
	end
	if laserAmplifier ~= false and laserAmplifier.getEnergy() < laIgnitionEnergy then
		print("not enough energy stored in the laser amplifier!")
		return false
	end
	if redstoneSide == false then
		print("no default side set, trying to figure out, good luck...")
		for side=0,(#sides-1) do
			print("trying "..sides[side])
			if rsIgnite(side) then
				print("saving ".. sides[side] .." as default")
				redstoneSide = side				
				return true
			end
			os.sleep(0)
		end
	else 
		return rsIgnite(redstoneSide)
	end	
	return false
end

function getIndex(label)
	for i=1,#statusbox.widgets do
		if statusbox.widgets[i].label == label then
			return i
		end
		os.sleep(0)
	end	
	return false
end

function updateStatusBoxKeyValue(label, value, perc)
	index = getIndex(label)
	if index == false then
		print("unknown label: "..label)
		return
	end	
	statusbox.widgets[index].value = value
	statusbox.widgets[index].widgets.value.setText(""..value.."")	
	if statusbox.widgets[index].statusBar ~= false then		
		updateStatusBar(statusbox.widgets[index].statusBar, perc)
	end
end

function setVisibility(label, bool)
	index = getIndex(label)	
	if index == false then
		print("unknown label: "..label)
		return
	end
	
	statusbox.widgets[index].widgets.value.setVisible(bool)
	statusbox.widgets[index].widgets.key.setVisible(bool)
	if statusbox.widgets[index].statusBar then
		statusbox.widgets[index].statusBar.setVisible(bool)
	end
end

function initInjectionRateMenue(x, y)
	injectionRateWidget.box = glassesTerminal.addBox2D()
	injectionRateWidget.box.addTranslation(x, y, 0)
	injectionRateWidget.box.setSize(200, 90)
	injectionRateWidget.box.addColor(0, 0, 0, 0.5)
	injectionRateWidget.box.addColor(0.05, 0.05, 0.05, 0.6)
	--injectionRateWidget.box.setCondition(injectionRateWidget.box.addScale(0, 0, 0), "OVERLAY_INACTIVE", true)

	injectionRateWidget.text = glassesTerminal.addText2D()
	injectionRateWidget.text.addTranslation(x + 5, y + 5, 0)
	injectionRateWidget.text.setText("injection rate (ignition temp: "..formatNumber(reactor.getIgnitionTemp()).."°K)")	
	--injectionRateWidget.text.setCondition(injectionRateWidget.text.addScale(0, 0, 0), "OVERLAY_INACTIVE", true)

	for i=0,9 do
		if i < 5 then
			addInjectionButton(2*i, x + 5 + (i*30),  y + 25)
		else
			addInjectionButton(2*i, x + 5 + ((i-5)*30), y + 55)
		end	
		os.sleep(0)
	end

	updateInjectionRate()
end

function setIgniteButton(visible)
	for i=1,#buttons do
		if buttons[i].value == "ignite" then
			buttons[i].widgets.box.setVisible(visible)
			buttons[i].widgets.text.setVisible(visible)
		end
	end
end

function initStatusBox()
	statusbox.widgets = {}
	
	statusbox.box = glassesTerminal.addBox2D()
	statusbox.box.addTranslation(offsetX + 120, offsetY, 0)
	statusbox.box.addColor(0, 0, 0, 0.5)
	statusbox.box.addColor(0.05, 0.05, 0.05, 0.6)
	
	table.insert(statusbox.widgets, addInfo("reactor status", "", offsetX , offsetY + (12*#statusbox.widgets)));
		
	info = addInfo("energy", 0, offsetX , offsetY + (12*#statusbox.widgets))
	info.statusBar = addStatusBar("energy", 0, offsetX, offsetY + (12*(1+#statusbox.widgets)))
	table.insert(statusbox.widgets, info)
	
	info = addInfo("energy stored", 0, offsetX , offsetY + (12*#statusbox.widgets))
	info.statusBar = addStatusBar("energy stored", 0, offsetX, offsetY + (12*(1+#statusbox.widgets)))
	table.insert(statusbox.widgets, info)
		
	info = addInfo("case heat", 0, offsetX , offsetY + (12*#statusbox.widgets))
	info.statusBar = addStatusBar("case heat", 0, offsetX, offsetY + (12*(1+#statusbox.widgets)))
	table.insert(statusbox.widgets, info)
	
	info = addInfo("plasma heat", 0, offsetX , offsetY + (12*#statusbox.widgets))
	info.statusBar = addStatusBar("plasma heat", 0, offsetX, offsetY + (12*(1+#statusbox.widgets)))
	table.insert(statusbox.widgets, info)	
	
	table.insert(statusbox.widgets, addInfo("water", 0, offsetX , offsetY + (12*#statusbox.widgets))) 
	table.insert(statusbox.widgets, addInfo("steam", 0, offsetX , offsetY + (12*#statusbox.widgets)))

	table.insert(statusbox.widgets, addInfo("can extract", false, offsetX , offsetY + (12*#statusbox.widgets))) 
	table.insert(statusbox.widgets, addInfo("can receive", false, offsetX , offsetY + (12*#statusbox.widgets)))	
	
	info = addInfo("deuterium", 0, offsetX , offsetY + (12*#statusbox.widgets))
	info.statusBar = addStatusBar("deuterium", 0, offsetX, offsetY + (12*(1+#statusbox.widgets)))
	table.insert(statusbox.widgets, info)	
	
	info = addInfo("tritium", 0, offsetX , offsetY + (12*#statusbox.widgets))
	info.statusBar = addStatusBar("tritium", 0, offsetX, offsetY + (12*(1+#statusbox.widgets)))
	table.insert(statusbox.widgets, info)	
	
	info = addInfo("dt-Fuel", 0, offsetX , offsetY + (12*#statusbox.widgets))
	info.statusBar = addStatusBar("dt-Fuel", 0, offsetX, offsetY + (12*(1+#statusbox.widgets)))
	table.insert(statusbox.widgets, info)	

	info = addInfo("laser amplifier", 0, offsetX , offsetY + (12*#statusbox.widgets))
	info.statusBar = addStatusBar("laser amplifier", 0, offsetX, offsetY + (12*(1+#statusbox.widgets)))
	table.insert(statusbox.widgets, info)
	
	
	info = addInfo("induction matrix", 0, offsetX , offsetY + (12*#statusbox.widgets))
	info.statusBar = addStatusBar("induction matrix", 0, offsetX, offsetY + (12*(1+#statusbox.widgets)))
	table.insert(statusbox.widgets, info)
	
	table.insert(statusbox.widgets, addInfo("matrix input", 0, offsetX , offsetY + (12*#statusbox.widgets)))
	table.insert(statusbox.widgets, addInfo("matrix output", 0, offsetX , offsetY + (12*#statusbox.widgets)))
	
	statusbox.box.setSize(230, 15+(#statusbox.widgets*12))
	
	updateLazyValues()
	updateStatusBox()
end

function updateLazyValues()
	maxCaseHeat = reactor.getMaxCaseHeat()	
	maxPlasmaHeat = reactor.getMaxPlasmaHeat()
		
	maxEnergyStored = reactor.getMaxEnergyStored()
	if maxEnergyStored > 0 then
		setVisibility("energy stored", true)
	else
		setVisibility("energy stored", false)
	end
	
	maxEnergy = reactor.getMaxEnergy()
	if maxEnergy > 0 then
		setVisibility("energy", true)
	else
		setVisibility("energy", false)
	end

	if laserAmplifier then
		laMaxEnergyStored = laserAmplifier.getMaxEnergy()
		setVisibility("laser amplifier", true)
	else
		setVisibility("laser amplifier", false)		
	end
	
	if inductionMatrix then
		imMaxStorage = inductionMatrix.getMaxEnergy()		
		setVisibility("induction matrix", true)
		setVisibility("matrix input", true)
		setVisibility("matrix output", true)
	else
		setVisibility("induction matrix", false)
		setVisibility("matrix input", false)
		setVisibility("matrix output", false)
	end
end

function updateStatusBox()
	isIgnited = reactor.isIgnited()
	if isIgnited then
		setIgniteButton(false)
		updateStatusBoxKeyValue("reactor status", "active")
	else
		if reactor.canIgnite() then
			setIgniteButton(false)
			updateStatusBoxKeyValue("reactor status", "inactive (can ignite)")
		else
			setIgniteButton(true)
			updateStatusBoxKeyValue("reactor status", "inactive (can't ignite)")
		end	
	end	
	
	if laserAmplifier then
		laEnergyStored = laserAmplifier.getEnergy()
		value = val2perc(laEnergyStored, laMaxEnergyStored).."% ("..formatNumber(MJ2RF(laEnergyStored)).." / "..formatNumber(MJ2RF(laMaxEnergyStored)).."RF)"
		updateStatusBoxKeyValue("laser amplifier", value, val2perc(laEnergyStored, laMaxEnergyStored))
	end
	
	dtFuel = reactor.getFuel()	
	deuterium = reactor.getDeuterium()	
	tritium = reactor.getTritium()
		
	if dtFuel > 0 then
		updateStatusBoxKeyValue("dt-Fuel", dtFuel.."mB", val2perc(dtFuel, 1000))	
		setVisibility("dt-Fuel", true)
		setVisibility("deuterium", false)
		setVisibility("tritium", false)	
	elseif deuterium > 0 or tritium > 0 then
		updateStatusBoxKeyValue("deuterium", deuterium.."mB", val2perc(deuterium, 1000))
		updateStatusBoxKeyValue("tritium", tritium.."mB", val2perc(tritium, 1000))	
		setVisibility("dt-Fuel", false)
		setVisibility("deuterium", true)
		setVisibility("tritium", true)
	end
	
	caseHeat = reactor.getCaseHeat()
	value = val2perc(caseHeat, maxCaseHeat).."% ("..formatNumber(caseHeat).." / "..formatNumber(maxCaseHeat).."°K)"
	updateStatusBoxKeyValue("case heat", value, val2perc(caseHeat, maxCaseHeat))
	
	plasmaHeat = reactor.getPlasmaHeat()
	value = val2perc(plasmaHeat, maxPlasmaHeat).."% ("..formatNumber(plasmaHeat).." / "..formatNumber(maxPlasmaHeat).."°K)"
	updateStatusBoxKeyValue("plasma heat", value, val2perc(plasmaHeat, maxPlasmaHeat))
	
	water = reactor.getWater()
	steam = reactor.getSteam()	
	
	if water > 0 or steam > 0 then
		updateStatusBoxKeyValue("water", water.."mB", val2perc(water, 1000))
		updateStatusBoxKeyValue("steam", steam.."mB", val2perc(steam, 1000))
		updateStatusBoxKeyValue("can extract", reactor.canExtract())
		updateStatusBoxKeyValue("can receive", reactor.canReceive())
		setVisibility("water", true)
		setVisibility("steam", true)
		setVisibility("can extract", true)
		setVisibility("can receive", true)
	else
		setVisibility("water", false)
		setVisibility("steam", false)
		setVisibility("can extract", false)
		setVisibility("can receive", false)
	end
	
	if maxEnergy > 0 then
		energy = reactor.getEnergy()
		value = val2perc(energy, maxEnergy).."% ("..formatNumber(MJ2RF(energy)).." / "..formatNumber(MJ2RF(maxEnergy)).."RF)"
		updateStatusBoxKeyValue("energy", value, val2perc(energy, maxEnergy))
	end
	
	if maxEnergyStored > 0 then
		energyStored = reactor.getEnergyStored()
		value = val2perc(energyStored, maxEnergyStored).."% ("..formatNumber(MJ2RF(energyStored)).." / "..formatNumber(MJ2RF(maxEnergyStored)).."RF)"
		updateStatusBoxKeyValue("energy stored", value, val2perc(energyStored, maxEnergyStored))
	end
	
	if inductionMatrix then
		imStorage = inductionMatrix.getEnergy()
		value = val2perc(imStorage, imMaxStorage).."% ("..formatNumber(MJ2RF(imStorage)).." / "..formatNumber(MJ2RF(imMaxStorage)).."RF)"
		updateStatusBoxKeyValue("induction matrix", value, val2perc(imStorage, imMaxStorage))
		
		imInput = inductionMatrix.getInput()
		value = formatNumber(MJ2RF(imInput)).."RF/tick"
		updateStatusBoxKeyValue("matrix input", value)
		
		imOutput = inductionMatrix.getOutput()
		value = formatNumber(MJ2RF(imOutput)).."RF/tick"
		updateStatusBoxKeyValue("matrix output", value)		
	end
	
	os.sleep(0)
end

function updateTankHUD(label, tankComponent, el)
	if tankComponent == false then 
		return
	end
	
	local tank = readTankStorage(tankComponent)	
	local w = (94 * (tank.amount / tank.maxAmount))
	perc = val2perc(tank.amount, tank.maxAmount)
	setColor(el[2], perc)
	el[2].setSize(w, 14)
	el[3].setText(label.." ".. perc .. "%")	
	os.sleep(0)
end

function touchEvent(EVENT, ID, USER, X, Y, BUTTON) 
 for i=1,#buttons do
	if X >= buttons[i].x and X <= (buttons[i].x+buttons[i].width) then
		if Y >= buttons[i].y and Y <= (buttons[i].y+buttons[i].height) then
			buttons[i].cb(buttons[i].value)
 end; end; end
end
