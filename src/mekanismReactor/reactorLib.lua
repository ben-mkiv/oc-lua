require("fluxgateLib")
component = require("component")
event = require("event")
gpu = component.gpu
sides = require("sides")

term = require("term")

laser = component.laser_amplifier
reactor = component.reactor_logic_adapter
redstone = component.redstone
transposer = false --determined on init

tankTritium = false
tankDeuterium = false

sideRedstone = false
sideReactor = false
sideStorage = false

hasHohlraum = false

tankName = false

chargePercent = false

injectionRate = 0
active = nil

reactorTransposer = false

function updateUI(category, subcategory) end

function mj2rf(val) return val * 0.4; end

function format(val)
    if val > 1000000000000 then return (math.floor(val/100000000000)/10) .. "T"
    elseif val > 1000000000 then return (math.floor(val/100000000)/10) .. "G"
    elseif val > 1000000 then return (math.floor(val/100000)/10) .. "M"
    elseif val > 1000 then return (math.floor(val/100)/10) .. "k"
    else return math.floor(val*10)/10; end
end

function getHohlraum(side)
    for i=1,transposer.getInventorySize(side) do
        slotData = transposer.getStackInSlot(side, i)
        if slotData ~= nil and slotData.name == "mekanismgenerators:hohlraum" then
            return { slot = i, stack = slotData }
        end
    end
    return false
end

function getHohlraumLabel()
    if hasHohlraum then return "eject hohlraum"
    else return "load hohlraum"; end
end

function getLaserCharge()
    return laser.getEnergy() / laser.getMaxEnergy() * 100
end

function canIgnite()
    if injectionRate == 0 then return { ready = false, error = "injection rate is 0" }; end
    if chargePercent < 25 then return { ready = false, error = "laser not charged" }; end
    if reactor.getDeuterium() < 500 then return { ready = false, error = "<500mB deuterium" }; end
    if reactor.getTritium() < 500 then return { ready = false, error = "<500mB tritium" }; end
    if not hasHohlraum then return { ready = false, error = "missing hohlraum" }; end

    return { ready = true }
end

function transferHohlraum()
    if hasHohlraum then
        transposer.transferItem(sideReactor, sideStorage, 1)
    else
        data = getHohlraum(sideStorage)
        if not data then return false; end
        transposer.transferItem(sideStorage, sideReactor, 1, data.slot)
    end

    hasHohlraum = getHohlraum(sideReactor) ~= false

    updateUI("hohlraum")
    updateUI("reactor", "ignite")
    return hasHohlraum
end

function isReactorTransposer(transposer)
    for i=0,#sides-1 do
        if transposer.getInventoryName(i) == "mekanismgenerators:reactor" then
            return true
        end
    end
    return false
end

function initializeReactor()
    for address,type in pairs(component.list(tankName)) do
        local tank = component.proxy(address)
        local gas = tank.getGas()
        if gas.name == "tritium" then
            tankTritium = tank
        elseif gas.name == "deuterium" then
            tankDeuterium = tank
        end
    end

    for address, type in pairs(component.list("transposer")) do
        if isReactorTransposer(component.proxy(address)) then
            transposer = component.proxy(address)
            for i=0,#sides-1 do
                if transposer.getInventoryName(i) == "mekanismgenerators:reactor" then
                    sideReactor = i
                elseif transposer.getInventorySize(i) ~= nil then
                    sideStorage = i
                end
            end
        end
    end

    injectionRate = reactor.getInjectionRate()
    active = reactor.getProducing() > 0
    chargePercent = getLaserCharge()
    hasHohlraum = getHohlraum(sideReactor) ~= false
end
