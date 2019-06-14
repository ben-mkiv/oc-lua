component = require("component")
event = require("event")
sides = require("sides")
s = require("serialization")
os = require("os")
term = require("term")

require("ccRecipes")

inv = component.inventory_controller
robot = component.robot
nav = component.navigation
beam = component.tractor_beam
gpu = component.gpu

geo = component.geolyzer

pickName = "tconstruct:pickaxe"
angelBlockName = "extrautils2:angelblock"

buildPosition = {}

stopme = false


function getOffset(waypointName)
    waypoints = nav.findWaypoints(32)

    for i=1,#waypoints do
        local data = s.unserialize(waypoints[i].label)
        if data.n == waypointName then
            waypoints[i].position[2] = waypoints[i].position[2] + 1
            return waypoints[i].position
        end
    end

    return false
end

function moveSometime(side)
    if robot.move(side) then
        return
    end

    print("cant move, so im waiting")
    while not robot.move(side) do
        io.write(".")
    end
    print("")
end

function moveOffset(offset)

    while offset[2] < 0 do
        moveSometime(sides.down)
        offset[2] = offset[2] + 1;
    end
    while offset[2] > 0 do
        moveSometime(sides.up)
        offset[2] = offset[2] - 1;
    end

    if offset[3] ~= 0 then
        turnToSide(sides.north)
        while offset[3] < 0 do
            moveSometime(sides.front)
            offset[3] = offset[3] + 1;
        end
        while offset[3] > 0 do
            moveSometime(sides.back)
            offset[3] = offset[3] - 1;
        end
    end

    if offset[1] ~= 0 then
        turnToSide(sides.west)
        while offset[1] < 0 do
            moveSometime(sides.front)
            offset[1] = offset[1] + 1;
        end
        while offset[1] > 0 do
            moveSometime(sides.back)
            offset[1] = offset[1] - 1;
        end
        turnToSide(sides.north)
    end
end

function turnToSide(side)
    while nav.getFacing() ~= side do robot.turn(true); end
end

function selectEmptySlot()
    for slot=1,robot.inventorySize() do
        if inv.getStackInInternalSlot(slot) == nil then
            robot.select(slot)
            return true; end end

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

function refillSomething(sideSource, itemName, count)
    local transfer
    while count > 0 do
        transfer = 0
        for i=1,inv.getInventorySize(sideSource) do
            if inv.getStackInSlot(sideSource, i) ~= nil and inv.getStackInSlot(sideSource, i).name == itemName then
                if not selectEmptySlot() then
                    return { false, "no empty slot in robot for transfer found" }; end

                local stored = inv.getStackInSlot(sideSource, i).size
                local maxStackSize = inv.getStackInSlot(sideSource, i).maxSize
                transfer = count
                if stored < transfer then transfer = stored; end
                if maxStackSize < transfer then transfer = maxStackSize; end
                inv.suckFromSlot(sideSource, i, transfer)
                count = count - transfer

                if count == 0 then return { true, "refilled item (" .. itemName .. ")", count }; end
            end
        end

        if transfer == 0 then return { false, "failed", count }; end
    end
end


function moveInBuild(x, y, z)
    moveOffset({ x - buildPosition[1], y - buildPosition[2], z - buildPosition[3]})
    buildPosition = { x, y, z }
end

function findSlotByName(name)
    for i=1,robot.inventorySize() do
        local stack = inv.getStackInInternalSlot(i)
        if stack and stack.name == name then return i; end end
    return 0
end

function placeBlock(side, material)
    local matSlot = findSlotByName(material);

    robot.select(matSlot)

    if robot.place(side) then return; end

    print("cant place block, trying to fix with angelblock")
    moveSometime(sides.back)

    if geo.analyze(sides.bottom).name ~= "minecraft:air" then
        print("cant fix with angel block")
    else
        robot.select(findSlotByName(angelBlockName))
        inv.equip()
        robot.use(side)
        inv.equip()
        moveSometime(sides.front)
        robot.select(matSlot)
        robot.place(side)
        moveSometime(sides.back)
        local pickSlot = findSlotByName(pickName)
        robot.select(pickSlot)
        inv.equip()
        selectEmptySlot()
        robot.swing(side)
        robot.select(pickSlot)
        inv.equip()
    end

    moveSometime(sides.front)
end


function buildSomething(recipe)
    robot.setLightColor(0xBF00C0)

    for i=1,#recipe do
        gpu.set(1, 2, "block " .. i .. " of " .. #recipe)
        moveInBuild(recipe[i].x, recipe[i].y + 1, recipe[i].z)
        placeBlock(sides.bottom, recipe[i].block)
    end

    gpu.set(1, 5, "")
end
