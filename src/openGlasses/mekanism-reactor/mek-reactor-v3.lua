require("openglasses/mekanism-hud")
--tankDeuterium = "cxyc-dasda-23232-ycsdda" //the address!!!1111one
offsetY = 60


function initStatusBox()
	statusbox.widgets = {}
	
	statusbox.box = glassesTerminal.addBox2D()
	statusbox.box.addTranslation(offsetX + 120, offsetY, 0)
	statusbox.box.setSize(230, 230)
	statusbox.box.addColor(0, 0, 0, 0.5)
	statusbox.box.addColor(0.05, 0.05, 0.05, 0.6)
	
	table.insert(statusbox.widgets, addInfo("reactor status", status, offsetX , offsetY + (12*#statusbox.widgets)));
	table.insert(statusbox.widgets, addInfo("producing", 0, offsetX , offsetY + (12*#statusbox.widgets))); 
		
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
		
	updateStatusBox()
end

function updateStatusBox()
	skipped = 0
		
	isIgnited = reactor.isIgnited()
	if isIgnited then
		setIgnateButton(false)
		updateStatusBoxKeyValue("reactor status", "active")
	else
		if reactor.canIgnite() then
			setIgnateButton(true)
			updateStatusBoxKeyValue("reactor status", "inactive (can ignite)")
		else 
			setIgnateButton(false)
			updateStatusBoxKeyValue("reactor status", "inactive (can NOT ignite)")
		end	
	end	
	
	if laserAmplifier then
		laEnergyStored = laserAmplifier.getEnergy()
		laMaxEnergyStored = laserAmplifier.getMaxEnergy()		
		value = val2perc(laEnergyStored, laMaxEnergyStored).."% ("..formatNumber(MJ2RF(laEnergyStored)).." / "..formatNumber(MJ2RF(laMaxEnergyStored)).."RF)"
		updateStatusBoxKeyValue("laser amplifier", value, val2perc(laEnergyStored, laMaxEnergyStored))
		setVisibility("laser amplifier", true)
	else
		setVisibility("laser amplifier", false)
		skipped = (skipped + 1)
	end
	
	dtFuel = reactor.getFuel()
	updateStatusBoxKeyValue("dt-Fuel", dtFuel.."mB", val2perc(dtFuel, 1000))
	
	deuterium = reactor.getDeuterium()
	updateStatusBoxKeyValue("deuterium", deuterium.."mB", val2perc(deuterium, 1000))
	
	tritium = reactor.getTritium()
	updateStatusBoxKeyValue("tritium", tritium.."mB", val2perc(tritium, 1000))
		
	if dtFuel > 0 then
		setVisibility("dt-Fuel", true)
		setVisibility("deuterium", false)
		setVisibility("tritium", false)		
		skipped = (skipped + 2)
	elseif deuterium > 0 or tritium > 0 then
		setVisibility("dt-Fuel", false)
		setVisibility("deuterium", true)
		setVisibility("tritium", true)
		skipped = (skipped + 1)
	end
	
	caseHeat = reactor.getCaseHeat()
	maxCaseHeat = reactor.getMaxCaseHeat()
	value = val2perc(caseHeat, maxCaseHeat).."% ("..formatNumber(caseHeat).." / "..formatNumber(maxCaseHeat).."°K)"
	updateStatusBoxKeyValue("case heat", value, val2perc(caseHeat, maxCaseHeat))
	
	plasmaHeat = reactor.getPlasmaHeat()
	maxPlasmaHeat = reactor.getMaxPlasmaHeat()
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
		skipped = (skipped + 4)
	end
	
	maxEnergy = reactor.getMaxEnergy()
	if maxEnergy > 0 then
		energy = reactor.getEnergy()
		value = val2perc(energy, maxEnergy).."% ("..formatNumber(MJ2RF(energy)).." / "..formatNumber(MJ2RF(maxEnergy)).."RF)"
		updateStatusBoxKeyValue("energy", value, val2perc(energy, maxEnergy))
		setVisibility("energy", true)
	else
		setVisibility("energy", false)
		skipped = (skipped + 1)
	end
	
	maxEnergyStored = reactor.getMaxEnergyStored()
	if maxEnergyStored > 0 then
		energyStored = reactor.getEnergyStored()
		value = val2perc(energyStored, maxEnergyStored).."% ("..formatNumber(MJ2RF(energyStored)).." / "..formatNumber(MJ2RF(maxEnergyStored)).."RF)"
		updateStatusBoxKeyValue("energy stored", value, val2perc(energyStored, maxEnergyStored))
		setVisibility("energy stored", true)
	else
		setVisibility("energy stored", false)
		skipped = (skipped + 1)		
	end
	
	producing = reactor.getProducing()
	value = formatNumber(MJ2RF(producing)).."RF/tick"
	updateStatusBoxKeyValue("producing", value)
	
	if inductionMatrix then
		imStorage = inductionMatrix.getEnergy()
		imMaxStorage = inductionMatrix.getMaxEnergy()
		value = val2perc(imStorage, imMaxStorage).."% ("..formatNumber(MJ2RF(imStorage)).." / "..formatNumber(MJ2RF(imMaxStorage)).."RF)"
		updateStatusBoxKeyValue("induction matrix", value, val2perc(imStorage, imMaxStorage))
		
		imInput = inductionMatrix.getInput()
		value = formatNumber(MJ2RF(imInput)).."RF/tick"
		updateStatusBoxKeyValue("matrix input", value)
		
		imOutput = inductionMatrix.getOutput()
		value = formatNumber(MJ2RF(imOutput)).."RF/tick"
		updateStatusBoxKeyValue("matrix output", value)
		
		setVisibility("induction matrix", true)
		setVisibility("matrix input", true)
		setVisibility("matrix output", true)
	else
		setVisibility("induction matrix", false)
		setVisibility("matrix input", false)
		setVisibility("matrix output", false)
	end
	
	statusbox.box.setSize(230, 15+(#statusbox.widgets*12))
end

initComponents()

glassesTerminal.removeAll()

initStatusBox()
initInjectionRateMenue(offsetX + 370, offsetY);

addButton("ignate", offsetX + 370, offsetY + 100, 100, 15, ignate)

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
	os.sleep(0)
	if tankTritium ~= false then 
		tank = readTankStorage(tankTritium)
		w = (94 * (tank.amount / tank.maxAmount))
		perc = val2perc(tank.amount, tank.maxAmount)
		setColor(hudTritium[2], perc)
		hudTritium[2].setSize(w, 14)
		hudTritium[3].setText("Tritium " .. perc .. "%")
	end
	os.sleep(0)
	hudProduction[2].setText(formatNumber(MJ2RF(reactor.getProducing())).."RF/tick")
	os.sleep(0)
	updateStatusBox()
	os.sleep(0)
end

event.ignore("interrupted", stopHUD)
event.ignore("interact_overlay", touchEvent)

-- remove all widgets from glasses
glassesTerminal.removeAll()
