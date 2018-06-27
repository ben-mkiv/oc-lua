local component = require("component")
local robot = component.robot
local geolyzer = component.geolyzer
local sides = require("sides")
local inv = component.inventory_controller

local targetPlant = ""
local sourcePlant = ""

local fertilizer = 0

function restockFertilizer()
    robot.select(2)
    robot.equip()

    local stackSize = inv.getStackInInternalSlot(2).maxSize
    local fertilizerName = inv.getStackInInternalSlot(2).name

    for i=1,inv.getInventorySize(sides.up) do
        if inv.getStackInInternalSlot(1).size == stackSize then
            return
        end

        if inv.getStackInSlot(sides.up, i).name == fertilizerName then
            inv.suckFromSlot(sides.up, i, stackSize)
        end
    end
    robot.equip()
    robot.select(1)
end

function doFertilize()
    if fertilizer == 0 then
        return
    end

    if geolyzer.analyze(sides.front).name == sourcePlant then
        io.write("fertilizing")
        while geolyzer.analyze(sides.front).growth ~= nil and geolyzer.analyze(sides.front).growth < 1 do
            robot.use(sides.front)
            fertilizer = fertilizer - 1

            if fertilizer == 1 then restockFertilizer() end
            io.write(".")
        end
        print("")
    end
end

function doHarvest()
    if geolyzer.analyze(sides.front).name == targetPlant then
        print("harvesting")
        robot.swing(sides.front)
    end
end

function restockPlant()
    local stackSize = inv.getStackInInternalSlot(1).maxSize
    for i=1,inv.getInventorySize(sides.up) do
        if inv.getStackInInternalSlot(1).size == stackSize then
            return
        end

        if inv.getStackInSlot(sides.up, i).name == sourcePlant then
            inv.suckFromSlot(sides.up, i, stackSize)
        end
    end
end

function doReplant()
    if geolyzer.analyze(sides.front).name == "minecraft:air" then
        if inv.getStackInInternalSlot(1).size == 0 then restockPlant() end
        print("replanting")
        require("robot").place(sides.down)
    end
end

function dumpInventory()
    for i=2,robot.inventorySize() do
       robot.select(i)
       robot.drop(sides.up)
    end

    robot.select(1)
end

-- setup fertilizer
if inv.getStackInInternalSlot(2) ~= nil then
    print("using fertilizer from slot 2")
    fertilizer = inv.getStackInInternalSlot(2).size
    robot.select(2)
    robot.equip()
    robot.select(1)
end

-- setup plant
robot.select(1)
if geolyzer.analyze(sides.front).name == "minecraft:air" then
    if inv.getStackInInternalSlot(1) == nil then
        print("please place source plant in first inventory slot of the robot")
        while inv.getStackInInternalSlot(1) == nil do
            os.sleep(0.1)
            io.write(".")
        end
        print("")
    end
    sourcePlant = inv.getStackInInternalSlot(1).name
    print("setting source plant => " .. sourcePlant)
    doReplant()
    print("waiting for result")
    while geolyzer.analyze(sides.front).name == sourcePlant or geolyzer.analyze(sides.front).name == "minecraft:air" do
        os.sleep(0.1)
        io.write(".")
    end

    targetPlant = geolyzer.analyze(sides.front).name
    print("setting target plant => " .. targetPlant)
else
    print("remove any block/plant in front of the robot")
    os.exit()
end

-- main loop
while true do
    doReplant()
    doFertilize()

    if geolyzer.analyze(sides.front).name == sourcePlant then
        io.write("waiting for crop transformation.")
        while geolyzer.analyze(sides.front).name ~= targetPlant do
            os.sleep(0.1)
            io.write(".")
        end
        print("")
    end

    doHarvest()
    dumpInventory()
end
