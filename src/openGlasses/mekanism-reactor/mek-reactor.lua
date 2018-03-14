tankDeuterium = false
tankTritium = false

component = require("component")
event = require("event")
serialization = require("serialization")

glassesTerminal = component.glasses
glassesTerminal.removeAll()

reactor = component.reactor_logic_adapter

function readTankFull(address)
	local tank = component.proxy(address)
	return { gas = tank.getGas(), amount = tank.getStoredGas(), maxAmount = tank.getMaxGas(), tankType = tank.type }
end

function readTankStorage(tank)
	return { amount = tank.getStoredGas(), maxAmount = tank.getMaxGas() }
end

function checkTank(address)
	local tankData = readTankFull(address)
	print("# found ".. tankData.tankType .. " with " .. tankData.amount .. "/" .. tankData.maxAmount .. " of " .. tankData.gas)	
	if string.match(tankData.gas, "deuterium") then
		print(" ... adding tank")
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


-- read items from transposers
for address,type in pairs(component.list("_gas_tank")) do
	checkTank(address)
end

function touchEvent(EVENT, ID, USER, X, Y, BUTTON)
    print("HUD Touchevent")
end


--register event listeners and idle until user interrupts
event.listen("interact_overlay", touchEvent)
print("\n# mekanism reactor HUD loaded, close with [CTRL] + [C]")

offsetX = 0
offsetY = 60

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


stop = false

hudDeuterium = addInfoHUD(10, 10, 100, 20, "Deuterium")
hudTritium = addInfoHUD(10, 35, 100, 20, "Tritium")

hudProduction = addReactorHUD(10, 60, 100, 20, "Reactor")

function MJ2RF(mj)
	return math.ceil(mj * 0.4)
end

function formatRF(rf)
	if rf >= 1000000 then
		rf = (math.floor(0.5 + (rf*10/1000000)/10)) .. "M"
	elseif rf >= 1000 then
		rf = math.floor(0.5 + (rf/1000)).."k"
	end
	
	return rf
end

function stopHUD()
	stop = true
end

function setColor(el, p)
	local red = 1 * (1 - (p/100))
	local green = 1 * (p/100)
	
	el.updateModifier(2, red, green, 0, 0.7)
	el.updateModifier(3, red, green, 0, 0.8)	
end

event.listen("interrupted", stopHUD)
while stop == false do
	local tank, w
	
	tank = readTankStorage(tankDeuterium)	
	w = (94 * (tank.amount / tank.maxAmount))
	perc = math.floor(0.5 + ((tank.amount/tank.maxAmount) * 100))
	
	setColor(hudDeuterium[2], perc)
	
	hudDeuterium[2].setSize(w, 14)
	hudDeuterium[3].setText("Deuterium ".. perc .. "%")
	
	tank = readTankStorage(tankTritium)
	w = (94 * (tank.amount / tank.maxAmount))
	perc = math.floor(0.5 + ((tank.amount/tank.maxAmount) * 100))
	
	setColor(hudTritium[2], perc)
	
	hudTritium[2].setSize(w, 14)
	hudTritium[3].setText("Tritium " .. perc .. "%")
	
	hudProduction[2].setText(formatRF(MJ2RF(reactor.getProducing())).."RF/tick")
	
	os.sleep(0.05)
end

event.ignore("interrupted", stopHUD)
event.ignore("interact_overlay", touchEvent)

-- remove all widgets from glasses
glassesTerminal.removeAll()
