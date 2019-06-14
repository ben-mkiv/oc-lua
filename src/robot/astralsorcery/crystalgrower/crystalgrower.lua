local component = require("component")
local robot = component.robot
local tank = component.tank_controller
local geo = component.geolyzer
local sides = require("sides")
local inventory = component.inventory_controller

local liquidStarlight = "astralsorcery.liquidstarlight"
local liquidStarlightBlock = "astralsorcery:fluidblockliquidstarlight"
local crystalCluster = "astralsorcery:blockcelestialcrystals"

function searchTank()
    for i=1,robot.inventorySize() do
        local fluid = tank.getFluidInTankInSlot(i)
        if fluid ~= nil and fluid.name == liquidStarlight then return i; end
    end
end

local slotTank = searchTank()

function isCrystal(block) return block.name == crystalCluster; end

function isLiquidStarlight(block) return block.name == liquidStarlightBlock; end

function isGrown(block) return isCrystal(block) and block.properties.stage == 4; end

function isAir(block) return block.name == "minecraft:air"; end

function fillInternalTank(slot)
    while tank.drain(1000) do print("drained 1 bucket from tank in slot " .. slot) end
end

function setupGrowth()

end

function analyze(side)
    local block = geo.analyze(side)
    if isAir(block) then
        print("block is air")
    elseif isCrystal(block) then
        io.write("crystal cluster found ")
        if isGrown(block) then
            print("[ready]")
        else
            print("[growing]")
        end
    elseif isLiquidStarlight(block) then
        print("found liquid starlight")
    end
end

stopme = false
function stopMe() stopMe = true; end

event.listen("interrupted", stopMe)

--while not stopme do
--    print("working...")
--end

event.ignore("interrupted", stopMe)