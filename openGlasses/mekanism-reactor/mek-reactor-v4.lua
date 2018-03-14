require("term").clear()
print("\n# Mekanism HUD starting...\n")
require("openglasses/mekanism-hud")
--tankDeuterium = "cxyc-dasda-23232-ycsdda" //the address!!!1111one
offsetY = 60

initComponents()
glassesTerminal.removeAll()
initStatusBox()
initInjectionRateMenue(offsetX + 370, offsetY);

stopme = false
function stop()
	stopme=true
end

if tankDeuterium ~= false then hudDeuterium = addInfoHUD(10, 0, 100, 20, "Deuterium"); end
if tankTritium ~= false then hudTritium = addInfoHUD(10, 25, 100, 20, "Tritium"); end
hudProduction = addReactorHUD(10, 50, 100, 20, "Reactor")

addButton("ignite", offsetX + 10, offsetY + 75, 100, 20, ignite)

bI = addButton("[X]", 5, 5, 25, 25, stop)
--buttons[bI].widgets.box.addAutoTranslation(100, 0)
--buttons[bI].widgets.text.addAutoTranslation(100, 0)

--register event listeners and idle until user interrupts

function refreshAll()
	--update tank status
	updateTankHUD("Tritium", tankTritium, hudTritium)	
	updateTankHUD("Deuterium", tankDeuterium, hudDeuterium) 
		
	--update reactor production rate
	hudProduction[2].setText(formatNumber(MJ2RF(reactor.getProducing())).."RF/tick")	
		
	--update big status box
	updateStatusBox()
end

--updateEvent = event.timer(1, refreshAll, math.huge)

event.listen("interact_overlay", touchEvent)

print("\n# Mekanism HUD loaded, close with [CTRL] + [C]")
--event.pull("interrupted")


event.listen("interrupted", stop)

while stopme == false do
	refreshAll()
end

-- cancel and ignore events
--event.cancel(updateEvent)
event.ignore("interact_overlay", touchEvent)
event.ignore("interrupted", stop)

-- remove all widgets from glasses
glassesTerminal.removeAll()

print("Mekanism HUD closed\n")
