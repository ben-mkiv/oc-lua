
local component = require("component")
local event = require("event")
local sides = require("sides")

local inv = component.inventory_controller
local robot = component.robot

stopme = false

event.listen("interrupted", function() stopme = true end)

--todo: add redstone control for a charger which is placed next to the robot
--todo: make robot refill table/press from internal inventory

print("")

while inv.getInventorySize(sides.front) ~= 3 do
    print("turning to typesetting table")
    robot.turn(false)
end

function selectEmptySlot()
    for slot=1,robot.inventorySize() do
        if inv.getStackInInternalSlot(slot) == nil then
            robot.select(slot)
            return true
        end
    end

    return false
end



function getEmptySlots()
    local freeSlots = {}
    for slot=5,robot.inventorySize() do
        if inv.getStackInInternalSlot(slot) == nil then
            table.insert(freeSlots, slot)
        end
    end
    return freeSlots
end


function refillSomething(sideSource, sideTarget, slotTarget, itemName)
    for i=1,inv.getInventorySize(sideSource) do
        if inv.getStackInSlot(sideSource, i) ~= nil and inv.getStackInSlot(sideSource, i).name == itemName then
            local transfer = 64
            if inv.getStackInSlot(sideTarget, slotTarget) ~= nil then
               transfer = transfer - inv.getStackInSlot(sideTarget, slotTarget).size
            end

            if not selectEmptySlot() then
                return { false, "no empty slot in robot for transfer found" }; end

            inv.suckFromSlot(sideSource, i, transfer)
            inv.dropIntoSlot(sideTarget, slotTarget)
            return { true, "refilled " .. transfer .. " items (" .. itemName .. ")", transfer }
        end
    end
end

function refillTypesettingTable(sideTypesettingTable)
    return refillSomething(sides.top, sideTypesettingTable, 2, "bibliocraft:bibliochase")
end

function refillPrintingpress(sidePrintingpress)
    return { refillSomething(sides.top, sidePrintingpress, 1, "minecraft:dye"),
    refillSomething(sides.top, sidePrintingpress, 3, "minecraft:book")}
end

local cachedPlates = {}


function getInternalPlates()
    cachedPlates = {}
    for slot=2,robot.inventorySize() do
        if inv.getStackInInternalSlot(slot) ~= nil and inv.getStackInInternalSlot(slot).name == "bibliocraft:enchantedplate" then
            table.insert(cachedPlates, slot)
        end
    end
    return cachedPlates
end


function getPlates(sideTypesettingTable)
    local emptySlots

    if inv.getStackInSlot(sideTypesettingTable, 3) == nil then
        return { false, "no plate found" }
    else
        emptySlots = getEmptySlots()
        if #emptySlots < 2 then
            return { false, "no inventory space in robot"}
        end
    end

    robot.select(emptySlots[1])

    if inv.suckFromSlot(sideTypesettingTable, 3) then
        table.insert(cachedPlates, emptySlots[1])
        robot.select(1)
        return { true, "cached enchanted plate" }
    else
        robot.select(1)
        return { false, "failed to cache enchanted plate" }
    end


end

function transferPlates(sidePrintingPress)
    if #cachedPlates == 0 then
        return { false, "no printing press cached" }
    elseif inv.getStackInSlot(sidePrintingPress, 2) ~= nil then
        return { false, "printing press is busy..." }
    end

    robot.select(cachedPlates[1])
    inv.equip()
    if robot.use(sidePrintingPress) then
        robot.select(1)
        table.remove(cachedPlates, 1)
        return { true, "press loaded to printing press" }
    else
        inv.equip()
        robot.select(1)
        return { false, "failed to load press" }
    end
end

getInternalPlates()

refillPrintingpress(sides.bottom)
refillTypesettingTable(sides.front)

function transferBooks(sidePrintingPress)
    if inv.getStackInSlot(sidePrintingPress, 4) == nil then
        return { false, "no book in printing press" }
    end

    inv.suckFromSlot(sidePrintingPress, 4)
    if robot.drop(sides.top) then
        return { true, "book transfered to inventory" }
    else
        local emptySlots = getEmptySlots()
        if #emptySlots < 2 then
            return { false, "book not transfered :(" }
        else
            inv.equip()
            robot.select(emptySlots[1])
            inv.equip()
            robot.select(1)
            inv.equip()
            return { true, "book stored in internal inventory" }
        end
    end
end

while not stopme do
    local data;
    data = transferPlates(sides.bottom)
    if data[1] then print(data[2]) end
    os.sleep(0.2)
    data = transferBooks(sides.bottom)
    if data[1] then
        print(data[2])
        data = refillPrintingpress(sides.bottom)
        if data[1][1] and data[1][3] > 0 then print(data[1][2]) end
        if data[2][1] and data[2][3] > 0 then print(data[2][2]) end
        os.sleep(0.2)
        data = refillTypesettingTable(sides.front)
        if data[1] and data[3] > 0 then print(data[2]) end
        os.sleep(0.2)
    end
    os.sleep(0.2)
    data = getPlates(sides.front)
    if data[1] then print(data[2]) end
    os.sleep(0.2)
end
