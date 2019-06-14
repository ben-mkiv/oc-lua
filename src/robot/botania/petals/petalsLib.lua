component = require("component")
sides = require("sides")

local validSides = { sides.north, sides.east, sides.south, sides.west }

local craftingSlots = { 1, 2, 3, 5, 6, 7, 9, 10, 11 }

local inventory = component.inventory_controller
local crafting = component.crafting

local robot = component.robot

local colors = { "White", "Orange", "Magenta", "Light Blue", "Yellow", "Lime", "Pink", "Gray", "Light Gray", "Cyan", "Purple", "Blue", "Brown", "Green", "Red", "Black" }

local shearItems = { { name = "minecraft:shears" }, { name = "mysticalagriculture:supremium_shears" } }
local fertilizerItems = { {label = "Bone Meal"}, {name = "forestry:fertilizer_compound"} }

local lastEquippedSlot = false

function stacksMatch(a, b) return a.name == b.name and a.label == b.label end

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

function findSlotByName(name)
    for i=1,robot.inventorySize() do
        local stack = inventory.getStackInInternalSlot(i)
        if stack and stack.name == name then return i; end end
    return 0
end

function itemIsInList(item, list)
    for i=1,#list do
        if list[i].name and list[i].name == item.name then return true;
        elseif list[i].label and list[i].label == item.label then return true; end
    end
    return false
end

function findSlotForList(list)
    for i=1,robot.inventorySize() do
        local stack = inventory.getStackInInternalSlot(i)
        if itemIsInList(stack, list) then return i; end end
    return false
end

function equipByName(name)
    local slot = findSlotByLabel(name)
    if slot == 0 then return false; end

    local stack = inventory.getStackInInternalSlot(slot)

    if stack and robot.select(slot) and inventory.equip() then
        lastEquippedSlot = slot
        stack.slot = slot
        return stack
    end
    return false
end

function equipFromList(list)
    for i=1,#list do
        if list[i].name ~= nil and equipByName(list[i].name) then return true;
        elseif list[i].label ~= nil and equipByLabel(list[i].label) then return true; end
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
    if not equipFromList(fertilizerItems) then return false; end
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

function equipShear()
    return equipFromList(shearItems)
end

function harvest(count)
    if not equipShear() then return false; end

    local flowerSlot = selectFreeSlot()

    robot.swing(sides.front)
    craftPetal(slot)
    return true
end

function plantPetal(color)
    local label = "Mystical ".. colors[i] .. " Petal"
    if equipByLabel(label) then
        robot.use(sides.front)
        if not fertilize() then return false; end;
        harvest()
        return true
    end
    return false
end

function plantPetals(color, limit)
    local i = 1
    if limit == nil then limit = 32; end
    local label = "Mystical ".. colors[i] .. " Petal"
    while plantPetal(label) do
        io.write(".")
        i = i+1
        if i > limit then
            print("limit of "..limit.." reached, ending loop")
            return; end
    end
end
