require("openglasses/mekanism-hud")
--tankDeuterium = "cxyc-dasda-23232-ycsdda" //the address!!!1111one
offsetY = 60

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


statusBox = glassesTerminal.addBox2D()
statusBox.addTranslation(offsetX + 120, offsetY, 0)
statusBox.setSize(230, 230)
statusBox.addColor(0, 0, 0, 0.5)
statusBox.addColor(0.05, 0.05, 0.05, 0.6)

isIgnited = reactor.isIgnited()
if isIgnited then
	status = "active"
else
	status = "inactive"
	if reactor.canIgnite() then
		status = status.." (can ignite)"
	else 
		status = status.." (can NOT ignite)"
	end	
end

statusBoxLines = 0
addInfo("reactor status", status, offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
addInfo("producing", formatNumber(MJ2RF(reactor.getProducing())).."RF/tick", offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
--addInfo("injection rate", reactor.getInjectionRate(), offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
--addInfo("ignition temp", formatNumber(reactor.getIgnitionTemp()).."°K", offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);

maxEnergyStored = reactor.getMaxEnergyStored()
if maxEnergyStored > 0 then
	energyStored = reactor.getEnergyStored()
	addInfo("energy stored", val2perc(energyStored, maxEnergyStored).."% ("..formatNumber(MJ2RF(energyStored)).." / "..formatNumber(MJ2RF(maxEnergyStored)).."RF)", offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
	addStatusBar("energy stored", val2perc(energyStored, maxEnergyStored), offsetX, offsetY + (12*statusBoxLines))
end

maxEnergy = reactor.getMaxEnergy()
if maxEnergy > 0 then
	energy = reactor.getEnergy()
	addInfo("energy", val2perc(energy, maxEnergy).."% ("..formatNumber(MJ2RF(energy)).." / "..formatNumber(MJ2RF(maxEnergy)).."RF)", offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
	addStatusBar("energy", val2perc(energy, maxEnergy), offsetX, offsetY + (12*statusBoxLines))
end

caseHeat = reactor.getCaseHeat()
maxCaseHeat = reactor.getMaxCaseHeat()
addInfo("case heat", val2perc(caseHeat, maxCaseHeat).."% ("..formatNumber(caseHeat).." / "..formatNumber(maxCaseHeat).."°K)", offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
addStatusBar("case heat", val2perc(caseHeat, maxCaseHeat), offsetX, offsetY + (12*statusBoxLines))

plasmaHeat = reactor.getPlasmaHeat()
maxPlasmaHeat = reactor.getMaxPlasmaHeat()
addInfo("plasma heat", val2perc(plasmaHeat, maxPlasmaHeat).."% ("..formatNumber(plasmaHeat).." / "..formatNumber(maxPlasmaHeat).."°K)", offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
addStatusBar("plasma heat", val2perc(plasmaHeat, maxPlasmaHeat), offsetX, offsetY + (12*statusBoxLines))

water = reactor.getWater()
steam = reactor.getSteam()
if water > 0 or steam > 0 then
	addInfo("water", water, offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
	addInfo("steam", steam, offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);

	addInfo("can extract", reactor.canExtract(), offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
	addInfo("can receive", reactor.canReceive(), offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
end

dtFuel = reactor.getFuel()
deuterium = reactor.getDeuterium()
tritium = reactor.getTritium()

--addInfo("has Fuel", reactor.hasFuel(), offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);

if dtFuel > 0 then
	addInfo("dt-Fuel", dtFuel, offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
	addStatusBar("dt-Fuel", val2perc(dtFuel, 1000), offsetX, offsetY + (12*statusBoxLines))
elseif deuterium > 0 or tritium > 0 then
	addInfo("deuterium", val2perc(deuterium, 1000).."% ("..deuterium.."/ 1000mB)", offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
	addStatusBar("deuterium", val2perc(deuterium, 1000), offsetX, offsetY + (12*statusBoxLines))

	addInfo("tritium", val2perc(tritium, 1000).."% ("..tritium.."/ 1000mB)", offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
	addStatusBar("tritium", val2perc(tritium, 1000), offsetX, offsetY + (12*statusBoxLines))
end

if laserAmplifier then
	laEnergyStored = laserAmplifier.getEnergy()
	laMaxEnergyStored = laserAmplifier.getMaxEnergy()
	addInfo("laser amplifier", val2perc(laEnergyStored, laMaxEnergyStored).."% ("..formatNumber(MJ2RF(laEnergyStored)).." / "..formatNumber(MJ2RF(laMaxEnergyStored)).."RF)", offsetX , offsetY + (12*statusBoxLines)); statusBoxLines = (statusBoxLines+1);
	addStatusBar("laser amplifier", val2perc(laEnergyStored, laMaxEnergyStored), offsetX, offsetY + (12*statusBoxLines))
end

statusBox.setSize(230, 15+(statusBoxLines*12))


addButton("ignitate", offsetX + 370, offsetY + 100, 100, 15, ignitate)

injectionRateBG = glassesTerminal.addBox2D()
injectionRateBG.addTranslation(offsetX + 370, offsetY, 0)
injectionRateBG.setSize(180, 90)
injectionRateBG.addColor(0, 0, 0, 0.5)
injectionRateBG.addColor(0.05, 0.05, 0.05, 0.6)
injectionRateBG.setCondition(injectionRateBG.addScale(0, 0, 0), "OVERLAY_INACTIVE", true)

injectionRateText = glassesTerminal.addText2D()
injectionRateText.addTranslation(offsetX + 370 + 5, offsetY + 5, 0)
injectionRateText.setText("injection rate")	
injectionRateText.setCondition(injectionRateText.addScale(0, 0, 0), "OVERLAY_INACTIVE", true)

for i=1,10 do
	if i <= 5 then
		addInjectionButton(2*i, offsetX + 370 + 5 + ((i-1)*30), offsetY+25)
	else
		addInjectionButton(2*i, offsetX + 370 + 5 + ((i-6)*30), offsetY + 55)
	end
	
	os.sleep(0)
end

updateInjectionRate()

if tankDeuterium ~= false then hudDeuterium = addInfoHUD(10, 0, 100, 20, "Deuterium"); end
if tankTritium ~= false then hudTritium = addInfoHUD(10, 25, 100, 20, "Tritium"); end

hudProduction = addReactorHUD(10, 50, 100, 20, "Reactor")

--register event listeners and idle until user interrupts
event.listen("interrupted", stopHUD)
event.listen("interact_overlay", touchEvent)
print("\n# mekanism reactor HUD loaded, close with [CTRL] + [C]")
while stop == false do
	local tank, w
	if tankDeuterium ~= false then 
		tank = readTankStorage(tankDeuterium)	
		w = (94 * (tank.amount / tank.maxAmount))
		perc = val2perc(tank.amount, tank.maxAmount)
	
		setColor(hudDeuterium[2], perc)
	
		hudDeuterium[2].setSize(w, 14)
		hudDeuterium[3].setText("Deuterium ".. perc .. "%")
	end
	if tankTritium ~= false then 
		tank = readTankStorage(tankTritium)
		w = (94 * (tank.amount / tank.maxAmount))
		perc = val2perc(tank.amount, tank.maxAmount)
	
		setColor(hudTritium[2], perc)
	
		hudTritium[2].setSize(w, 14)
		hudTritium[3].setText("Tritium " .. perc .. "%")
	end
	hudProduction[2].setText(formatNumber(MJ2RF(reactor.getProducing())).."RF/tick")
	os.sleep(0.1)
end

event.ignore("interrupted", stopHUD)
event.ignore("interact_overlay", touchEvent)

-- remove all widgets from glasses
glassesTerminal.removeAll()
