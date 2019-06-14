component = require("component")
sides = require("sides")
db = component.database
dbSize = 49
me = component.me_exportbus
transposer = component.transposer

sideME = sides.south

function getInventorySide(name)
    for i=0,#sides-1 do
        if transposer.getInventoryName(i) == name then
            print(name .. " => " .. sides[i])
            return i
        end
    end
    print("cant find "..name)
end

sideChest = getInventorySide("extrautils2:minichest")
sideTable = getInventorySide("extendedcrafting:interface")

function exportItem(slot, amount)
    io.write("export slot #"..slot)
    me.setExportConfiguration(sideME, 1, db.address, slot)
    while transposer.getSlotStackSize(sideChest, 1) < amount do
        io.write(".")
        os.sleep(0.5)
    end
    me.setExportConfiguration(sideME, 1) -- reset export bus
    --  transposer.transferItem(sideChest, sideTable, amount, 1, slot)
    transposer.transferItem(sideChest, sideTable)

    while transposer.getSlotStackSize(sideTable, 1) > 0 do
        io.write("#")
    end

    io.write("\n")
end

i = 1
done = false

while not done and i <= dbSize do
    stack = db.get(i)

    if stack == nil then
        done = true
    else
        exportItem(i, 64)
    end
    i = i+1
end