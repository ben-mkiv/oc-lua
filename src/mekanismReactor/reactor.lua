require("hazeUI")
require("reactorLib")

hazeUI.gpu = gpu

term.clear()

core = component.draconic_rf_storage

sideRedstone = sides.east

stopMe = false

tankName = "creative_gas_tank"

buttonIJ = {}
buttonIG = false
buttonHR = false

widget_categories = {}
widgets = {}

updateUI = function(category, subcategory)
    if category == "hohlraum" then
        hazeUI:setElement({ index = buttonHR, text = getHohlraumLabel() })
        hazeUI:drawElement(hazeUI.els[buttonHR])
    elseif category == "laser" then
        printLaserStats()
    elseif category == "reactor" then
        if subcategory == "ignite" then
            local state = canIgnite()
            if active then backgroundColor = 0x616161
            else
                if state.ready then backgroundColor = 0x00D217
                else backgroundColor = 0xD22B00 end
            end
            hazeUI:setElement({ index = buttonIG, bg = backgroundColor })
            hazeUI:drawElement(hazeUI.els[buttonIG])
        end
    end
end

function setupCategory(x, y, w, h, title)
    borders.drawBox(x, y, w, h, title, "bold", 0x0, 0xFFFFFF, 0xFF9800)
    table.insert(widget_categories, { name = title, x = x, y = y, w = w, h = h })
end

function setupStats(x, y, w, h, category, title)
    borders.drawBox(x, y, w, h, title, "slim_round", 0x0, 0xDADADA, 0xF8FF00)
    table.insert(widgets, { name = title, category = category, x = x, y = y, w = w, h = h })
end

function getWidgetData(category, title)
    for i=1,#widgets do if widgets[i].name == title then return widgets[i]; end end
    return false
end

function setupInjectionRateButtons(x, y)
    buttonIJ[1] = hazeUI:addButton(x, y, 5, 2, "-10", "all", 0x0, 0xFFFFFF, "center", setInjectionRate, { val=-10 })
    buttonIJ[2] = hazeUI:addButton(x+6, y, 4, 2, "-2", "all", 0x0, 0xFFFFFF, "center", setInjectionRate, { val=-2 })
    buttonIJ[3] = hazeUI:addButton(x+11, y, 4, 2, "+2", "all", 0x0, 0xFFFFFF, "center", setInjectionRate, { val=2 })
    buttonIJ[4] = hazeUI:addButton(x+16, y, 5, 2, "+10", "all", 0x0, 0xFFFFFF, "center", setInjectionRate, { val=10 })
end

function printHohlraumStats()
    storage = getHohlraum(sideStorage)
    reactorLoaded = "false"
    if hasHohlraum then reactorLoaded = "true" end
    widgetData = getWidgetData("mekanism reactor", "hohlraum")
    gpu.fill(widgetData.x+1, widgetData.y+1, widgetData.w-2, 2, " ")
    gpu.set(widgetData.x+2, widgetData.y+1, "stored: " .. format(storage.stack.size))
    gpu.set(widgetData.x+2, widgetData.y+2, "reactor loaded: " .. reactorLoaded)
end

function printReactorStats()
    if stopMe then return; end

    local running = "inactive"

    local couldIgnite = " (can ignite)"
    local state = canIgnite()

    newActive = reactor.getProducing() > 0

    if newActive ~= active then
        active = newActive
        updateUI("reactor", "ignite")
    end

    if active then running = "active" end
    if not state.ready then couldIgnite = " (cant ignite, ".. state.error ..")" end

    widgetData = getWidgetData("mekanism reactor", "reactor")

    borders.flushBoxSection({ x = widgetData.x, y = widgetData.y, w = widgetData.w, h = widgetData.h, bgColor = 0x0, gpu = gpu }, nil, nil, nil, 5)
    --gpu.fill(widgetData.x+1, widgetData.y+1, widgetData.w-2, 5, " ")

    gpu.set(widgetData.x+2, widgetData.y+1, "deuterium: " .. reactor.getDeuterium() .. "mB")
    gpu.set(widgetData.x+2, widgetData.y+2, "tritium: " .. reactor.getTritium() .. "mB")
    gpu.set(widgetData.x+2, widgetData.y+3, running .. couldIgnite)
    gpu.set(widgetData.x+2, widgetData.y+4, "producing: " .. format(math.floor(mj2rf(reactor.getProducing()))).."RF/tick")
    gpu.set(widgetData.x+2, widgetData.y+5, "injection rate: " .. injectionRate .. "mB/tick")

    if active then
        event.timer(0.2, printReactorStats)
        event.timer(0.2, printTankStats)
    end
end

function printTankStats()
    local deuteriumPerc = tankDeuterium.getStoredGas() / tankDeuterium.getMaxGas() * 100
    widgetData = getWidgetData("mekanism reactor", "deuterium")
    gpu.set(widgetData.x+2, widgetData.y+1, deuteriumPerc .. "% (" .. format(tankDeuterium.getStoredGas()).."B)")

    local tritiumPerc = tankTritium.getStoredGas() / tankTritium.getMaxGas() * 100
    widgetData = getWidgetData("mekanism reactor", "tritium")
    gpu.set(widgetData.x+2, widgetData.y+1, tritiumPerc .. "% ("..format(tankTritium.getStoredGas()).."B)")
end

function printLaserStats()
    local canIgnite = chargePercent >= 25

    widgetData = getWidgetData("mekanism reactor", "laser amplifier")

    gpu.fill(widgetData.x+1, widgetData.y+1, widgetData.w-2, widgetData.h-2, " ")
    gpu.set(widgetData.x+2, widgetData.y+1, "charge: " .. chargePercent .. "%")

    local charging = ""
    if fluxGateRate ~= 0 then charging = " (charging)" end

    if canIgnite then
        gpu.setForeground(0x00DD00)
        gpu.set(widgetData.x+2, widgetData.y+2, "ready" .. charging)
    else
        gpu.setForeground(0xDD0000)
        gpu.set(widgetData.x+2, widgetData.y+2, "not ready" .. charging)
    end
    gpu.setForeground(0xFFFFFF)
end

function updateFluxgate()
    if stopMe then return; end

    chargePercent = getLaserCharge()
    updateUI("laser")
    if chargePercent < 100 and fluxGateRate == 0 then
        fluxgate.setSignalLowFlow(10000)
        fluxGateRate = fluxgate.getSignalLowFlow()
    elseif chargePercent == 100 and fluxGateRate ~= 0 then
        fluxgate.setSignalLowFlow(0)
        fluxGateRate = fluxgate.getSignalLowFlow()
    elseif chargePercent < 100 then
        event.timer(0.2, updateFluxgate)
    end
end

function loadHohlraum()
    transferHohlraum()
    printReactorStats()
    printHohlraumStats()
end

function ignite()
    if reactor.isIgnited() then return; end
    redstone.setOutput(sideRedstone, 15)
    while not reactor.isIgnited() do os.sleep(0.2) end
    redstone.setOutput(sideRedstone, 0)
    hasHohlraum = getHohlraum(sideReactor) ~= false
    printReactorStats()
    printHohlraumStats()
    if fluxGateRate == 0 then updateFluxgate() end
end

function setInjectionRate(data)
    newInjectionRate = injectionRate + data.val

    if newInjectionRate < 0 then newInjectionRate = 0
    elseif newInjectionRate > 98 then newInjectionRate = 98 end

    reactor.setInjectionRate(newInjectionRate)
    injectionRate = reactor.getInjectionRate()
    printReactorStats()
end

function drawInjectionRateButtons()
    for i=1,#buttonIJ do hazeUI:drawElement(hazeUI.els[buttonIJ[i]]) end
end

function printCoreStats()
    if stopMe then return; end
    gpu.fill(2, 22, 70, 3, " ")
    stored = core.getEnergyStored()
    storedPercent = math.floor(stored / core.getMaxEnergyStored() * 1000) / 10
    gpu.set(3, 22, "transferrate: " .. format(core.getTransferPerTick()).. "RF/tick")
    gpu.set(3, 23, "stored: " .. storedPercent .. "% (" .. format(stored) .. "RF)")
    hazeUI:drawStatusbar(3, 24, 75, 1, 100, math.floor(storedPercent))
    event.timer(0.2, printCoreStats)
end

function touchEvent(event, uuid, x, y, button, user)
    if user == "ben_mkiv" then
        hazeUI:touchEvent(x, y, user)
    end
end

initializeReactor()

setupCategory(1, 1, 79, 20, "mekanism reactor")
setupCategory(1, 21, 79, 5, "energy core")

setupStats(3, 3, 25, 4, "mekanism reactor", "laser amplifier")

setupStats(3, 13, 25, 6, "mekanism reactor", "hohlraum")
buttonHR = hazeUI:addButton(5, 16, 22, 2, getHohlraumLabel(), "all", 0x0, 0xFFFFFF, "center", loadHohlraum)
hazeUI:drawElement(hazeUI.els[buttonHR])

setupStats(3, 10, 25, 3, "mekanism reactor", "tritium")

setupStats(3, 7, 25, 3, "mekanism reactor", "deuterium")

setupStats(30, 3, 47, 10, "mekanism reactor", "reactor")
borders.addDivLine(30, 9, 47, 0xDADADA, 0x0, "slim_round")
buttonIG = hazeUI:addButton(58, 10, 14, 2, "ignite", "all", 0x0, 0x616161, "center", ignite)
hazeUI:drawElement(hazeUI.els[buttonIG])

setupInjectionRateButtons(32, 10)
drawInjectionRateButtons()

updateFluxgate()
printReactorStats()
printTankStats()
printHohlraumStats()
printCoreStats()

event.listen("interrupted", function() stopMe=true end)
event.listen("touch", touchEvent)

while not stopMe do os.sleep(0.2) end

event.ignore("touch", touchEvent)

os.sleep(0.5)
term.clear()