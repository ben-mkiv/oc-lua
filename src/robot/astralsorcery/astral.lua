local component = require("component")
local inv = component.inventory_controller
local ser = require("serialization")
local sides = require("sides")
local fs = require("filesystem")
local recipe = {}

local commandlineArguments = {...}
local filename = commandlineArguments[1]

if #commandlineArguments < 1 then
    print("not enough arguments: astral [filename]")
end

function saveRecipe(side, filename)
    io.write("reading inventory ")
    for slot=1,inv.getInventorySize(side) do
        local stack = inv.getStackInSlot(side, slot)
        if stack == nil then io.write(".") else
            table.insert(recipe, {slot, stack} )
            io.write("#")
        end
    end

    print("")
    io.write("writing recipe: ")
    local cf = io.open(filename, "w")
    cf:write(ser.serialize(recipe))
    cf:close()
    io.write("done!")
    print("")
end

function readRecipe(side, filename)
    recipe = {}
    io.write("reading file...")
    local cf = io.open(filename, "r")
    local serData = cf:read("*a")
    cf:close()
    recipe = ser.unserialize(serData)
    io.write(" done!")
    print("")
end

function clearExternalInventory(side)
    io.write("clearing external inventory ")
    for slot=1,inv.getInventorySize(side) do
        local stack = inv.getStackInSlot(side, slot)
        if stack == nil then io.write(".") else
            inv.suckFromSlot(side, slot, 64)
            io.write("#")
        end
    end
end

function placeRecipe(side)
    io.write("placing recipe ")
    for i=1,#recipe do placeItem(recipe[2], side, recipe[1]) end
end

function placeItem(stackIn, side, slot)
    for slot=1,inv.getInventorySize(side) do
        local stack = inv.getStackInSlot(side, slot)
        if stack == nil then io.write(".") else
            if stack ~= stackIn then io.write("#") else
                io.write("*")
                inv.dropIntoSlot(side, slot, 1)
            end
        end
    end
end

if fs.exists(filename) then
    readRecipe(sides.down, filename)
else
    saveRecipe(sides.down, filename)
end

