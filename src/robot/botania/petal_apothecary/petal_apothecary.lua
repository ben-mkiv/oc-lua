require("petalsLib") -- part of petals tool

magnet = component.tractor_beam
geolyzer = component.geolyzer

tankBlocks = { { name = "cookingforblockheads:sink" } }
inventoryBlocks = { { name = "ironchest:iron_chest" } }
farmBlocks = { { name = "minecraft:dirt"}, { name = "minecraft:grass" } }
blockPetalApothecary = { { name = "botania:altar"} }

seedItems = { { name = "minecraft:wheat_seeds" } }
bucketItems = { { name = "minecraft:bucket"}, { name = "minecraft:water_bucket"} }

testRecipe = {
    name = "Munchdew",
    items = {
        { size = 1, label = "Mystical Green Petal" },
        { size = 2, label = "Mystical Lime Petal" },
        { size = 2, label = "Mystical Red Petal" },
        { size = 1, label = "Rune of Gluttony" }
    }
}

sideInventory = false;
sideFarm = false
sideTank = false

function isBlockInList(block, list)
    for i=1,#list do if list[i].name == block.name then return true; end end
    return false;
end

function findSideFromBlockList(list)
    for side=0,#sides-1 do
        block = geolyzer.analyze(side)
        if isBlockInList(block, list) then return side; end
    end
    return false;
end

function initialize()
    robot.setLightColor(0xFF9800)
    while robot.move(sides.down) do os.sleep(0) end

    block = geolyzer.analyze(sides.down)
    if block == nil or not isBlockInList(block, blockPetalApothecary) then
        robot.setLightColor(0xFF0000)
        print("no petal apothecary found below robot, exiting...")
        os.exit()
    end

    sideFarm = findSideFromBlockList(farmBlocks)
    sideInventory = findSideFromBlockList(inventoryBlocks)
    sideTank = findSideFromBlockList(tankBlocks)

    robot.setLightColor(0xFFEB3B)
end

function getListItemFromInventory(list, amount)
    return true
end

function getItemFromInventory(item, amount)
    return getListItemFromInventory({ item }, amount)
end

function dropInternalToInventory()
    for slot=1,robot.inventorySize() do
        robot.select(slot)
        robot.drop(sideInventory)
    end

    robot.select(1)
    inventory.equip()
    robot.drop(sideInventory)
end

function equipForRecipe(recipe)
    if not getListItemFromInventory(bucketItems) then return false; end

    inventory.equip()

    if not getListItemFromInventory(seedItems) then return false; end

    for i=1,#recipe.items do
        if not getItemFromInventory(recipe.items[i], recipe.items[i].size) then return false; end
    end

    if sideFarm then
        if not getListItemFromInventory(fertilizerItems) or not getListItemFromInventory(shearItems) then
            return false;
        end
    end
end

function craft(recipe)
    if not equipForRecipe(recipe) then
        dropInternalToInventory()
        print("couldnt start craft because items are missing")
    end

    robot.move(sides.up)
    for i=1,#recipe.items do
        slot = findSlotByLabel(recipe.items[i].label)
        robot.select(slot)
        robot.drop(sides.bottom, recipe.items[i].size)
    end

    robot.move(sides.down)
    slot = findSlotByLabel()
end


initialize()
