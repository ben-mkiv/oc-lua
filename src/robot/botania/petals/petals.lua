component = require("component")
sides = require("sides")
event = require("event")

local validSides = { sides.north, sides.east, sides.south, sides.west }
local craftingSlots = { 1, 2, 3, 5, 6, 7, 9, 10, 11 }

local colors = { "White", "Orange", "Magenta", "Light Blue", "Yellow", "Lime", "Pink", "Gray", "Light Gray", "Cyan", "Purple", "Blue", "Brown", "Green", "Red", "Black" }

local inventory = component.inventory_controller
local crafting = component.crafting

local robot = component.robot

local slotData = { bonemeal = false, shears = false, currentPetal = false }

function stacksMatch(a, b)
    if a.label ~= b.label then return false; end
    return true
end

function hasValue(t, val)
    if not t or not #t then return false; end
    for i=1,#t do if t[i] == val then return true; end end
    return false;
end

function moveSlotContent(sourceStack, avoidSlots)
    for i=1,robot.inventorySize() do
        if not hasValue(avoidSlots, i) then
            local stack = inventory.getStackInInternalSlot(i)
            if stack == nil or stacksMatch(stack, sourceStack) and stack.size + sourceStack.size <= stack.maxSize then
                if robot.select(sourceStack.slot) then
                    return robot.transferTo(i, sourceStack.maxSize); end end end end
    return false
end

function findSlotByLabel(label)
    for i=1,robot.inventorySize() do
        local stack = inventory.getStackInInternalSlot(i)
        if stack and stack.label == label then return i; end end
    return 0
end

local lastEquippedSlot = false
function equipByLabel(label)
    local slot = findSlotByLabel(label)
    if slot == 0 then return false; end

    local stack = inventory.getStackInInternalSlot(slot)

    if stack and robot.select(slot) and inventory.equip() then
        lastEquippedSlot = slot
        stack.slot = slot
        return stack
    end
    return false
end

function clearCraftingGrid()
    for i=1,#craftingSlots do
        local stack = inventory.getStackInInternalSlot(craftingSlots[i])

        if stack ~= nil then
            stack.slot = craftingSlots[i]
            moveSlotContent(stack, craftingSlots)
        end
    end
end

function craftPetal(flowerSlot)
    clearCraftingGrid()
    robot.select(flowerSlot)
    robot.transferTo(craftingSlots[1], 16);
    return crafting.craft()
end

function fertilize()
    if not equipByLabel("Bone Meal") then return false; end
    robot.use(sides.front)
    return true
end

function selectFreeSlot()
    for i=1,robot.inventorySize() do if not hasValue(craftingSlots, i) then
        local stack = inventory.getStackInInternalSlot(i)
        if not stack then
            return robot.select(i); end end end
        return false;
end

function harvest(count)
    if not equipByLabel("item.shears_of_winter.name") then return false; end

    local flowerSlot = selectFreeSlot()

    robot.swing(sides.front)
    craftPetal(slot)
    return true
end

function plantPetals(label)
    local i = 1
    while equipByLabel(label) do
        robot.use(sides.front)
        if not fertilize() then return false; end;
        harvest()
        io.write(".")
        i = i+1
        if i > 32 then
            print("limit of 32 reached, canceling this color")
            return; end
    end
end

local stopTool = false
event.listen("interrupted", function() print("interrupting...") stopTool = true end)

while not stopTool do for i=1,#colors do
    local label = "Mystical ".. colors[i] .. " Petal"
    print("working on "..label)
    plantPetals(label)
end end

event.ignore("interrupted")