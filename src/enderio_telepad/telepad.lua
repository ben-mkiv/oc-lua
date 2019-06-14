component = require("component")
sides = require("sides")
transposer = nil
storages = {}

function addStorage(side, name, size)
    table.insert(storages, { side = side, name = name, size = size})
end

function isTelepadTransposer(transposer)
    print(transposer.getInventoryName(sides.top))
    return transposer.getInventoryName(sides.top) == "enderio:block_tele_pad"
end

for address, type in pairs(component.list("transposer")) do
    if isTelepadTransposer(component.proxy(address)) then
        transposer = component.proxy(address)
        for i=0,#sides-1 do
            if transposer.getInventoryName(i) ~= "enderio:block_tele_pad" and transposer.getInventorySize(i) ~= nil then
                local name = transposer.getInventoryName(i)
                addStorage(i, name, transposer.getInventorySize(i))
                print("adding storage '" .. name .. "'")
            end
        end
    end
end

