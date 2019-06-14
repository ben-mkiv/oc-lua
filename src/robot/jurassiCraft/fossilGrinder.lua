component = require("component")
sides = require("sides")

robot = component.robot
inv = component.inventory_controller

function refillBucket()
    inv.suckFromSlot(sides.front, 2, 1)
    inv.equip()
    robot.use(sides.up)
    inv.equip()
    robot.drop(sides.front, 2, 1)
end

while inv.getInventorySize(sides.front) ~= 8 do
    robot.turn(true) end

while true do
    if inv.getStackInSlot(sides.front, 2).name == "minecraft:bucket" then
        refillBucket() end

    for i=1,6 do
        if inv.getStackInSlot(sides.front, (i + 2)) ~= nil then
            inv.suckFromSlot(sides.front, (i + 2), 1)
            robot.turn(true)
            robot.turn(true)
            robot.drop(sides.front)
            robot.turn(true)
            robot.turn(true)
        end
    end

    os.sleep(0.5)
end

