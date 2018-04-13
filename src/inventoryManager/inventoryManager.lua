require ("package").loaded.hazeUI = nil
require ("package").loaded.borders = nil

require("hazeUI")

event = require("event")
component = require("component")
sides = require("sides")

gui = clone(hazeUI)
gui.gpu = component.gpu
gui.super = gui
gui.self = gui

autoDump = { enabled = false, index = 1, timer = false, button = false, worker = nil }

component.gpu.setResolution(80, 30)

titleBar = gui:addButton(1, 1, 80, 1, "inventoryManager, starting up...", "all", 0x282828, 0xFFB000, "left", drawMain)

playerInterface = { side = sides.top }
playerInventory = { lastUpdate = false, data = {} }
inventoryStock = { side = sides.bottom }

function readInventory(transposer, side)
    if not transposer.getInventorySize(side) then print("no inventory found") return; end
    local inventory = { size = transposer.getInventorySize(side), data = {} }
    for i=1,inventory.size do
        gui:drawStatusbar(5, 5, 40, 1, inventory.size, i, "reading inventory...")
        local stack = transposer.getStackInSlot(side, i)
        if stack ~= nil then
            stack.slot = i
            stack.keep = false
            stack.restock = false
            table.insert(inventory.data, stack)
        end
    end

    return inventory
end

function loadFile(filename)
    if not require("filesystem").exists(filename) then return false; end
    local cf = io.open(filename, "r")
    local serData = cf:read("*a")
    cf:close()
    return require("serialization").unserialize(serData)
end

function toggleKeep(data)
    playerInventory.data[data.slot].keep = not playerInventory.data[data.slot].keep
    gui:setElement({ index = playerInventory.data[data.slot].keepButton, text = getBoolBox(playerInventory.data[data.slot].keep) })
    gui:drawElement(gui.els[playerInventory.data[data.slot].keepButton])
end

function getBoolBox(val)
    if val then return "[x]"; end;
    return "[ ]"
end

function toggleRestock(data)
    playerInventory.data[data.slot].restock = not playerInventory.data[data.slot].restock
    gui:setElement({ index = playerInventory.data[data.slot].restockButton, text = getBoolBox(playerInventory.data[data.slot].restock) })
    gui:drawElement(gui.els[playerInventory.data[data.slot].restockButton])
end

function getStack(stack)
    for i=1,#playerInventory.data do if stack.label == playerInventory.data[i].label then return playerInventory.data[i]; end end
    return false
end

autoDump.worker = function()
    local transposer = component.transposer
    if autoDump.index > transposer.getInventorySize(playerInterface.side) then
        autoDump.index = 1
    end
    local stack = transposer.getStackInSlot(playerInterface.side, autoDump.index)
    if stack ~= nil then
        local invStack = getStack(stack)
        if invStack and not invStack.keep then
            transposer.transferItem(playerInterface.side, inventoryStock.side, 64, autoDump.index)
        end
    end

    autoDump.index = autoDump.index + 1
end

function toggleAutoDump()
    autoDump.enabled = not autoDump.enabled
    gui:setElement({ index = autoDump.button, text = getBoolBox(autoDump.enabled).." auto-dump" })
    gui:drawElement(gui.els[autoDump.button])

    if autoDump.enabled then
        autoDump.timer = event.timer(0.05, autoDump.worker, math.huge)
    elseif autoDump.timer then event.cancel(autoDump.timer) end

end

function drawInventory()
    gui:addButton(64, 3, 6, 1, "keep", "main", 0xFFB000, 0x282828, "right")
    gui:addButton(70, 3, 9, 1, "restock", "main", 0xFF8600, 0x282828, "right")
    for i=1,#playerInventory.data do
        gui:addButton(24, 3+i, 45, 1, "["..playerInventory.data[i].slot.."] "..playerInventory.data[i].label, "main", 0xFFB000, 0x282828, "left")
        playerInventory.data[i].keepButton = gui:addButton(65, 3+i, 5, 1, getBoolBox(playerInventory.data[i].keep), "main", 0xFFB000, 0x282828, "right", toggleKeep, { slot = i })
        playerInventory.data[i].restockButton = gui:addButton(71, 3+i, 8, 1, getBoolBox(playerInventory.data[i].restock), "main", 0xFFB000, 0x282828, "right", toggleRestock, { slot = i })
    end

    gui:drawScreen("main")
end

function readPlayerInterface()
    local inv = readInventory(component.transposer, playerInterface.side)
    playerInventory.data = inv.data
    playerInventory.size = inv.size
    drawInventory()
end

function loadConfig()
    local config = loadFile("/etc/inventoryManager.conf")
    if config then
        --statsScreen = config.statsScreen
        --for i=1,#config.screens do
        --    setScreenFieldID({ screen = config.screens[i].screen, id = config.screens[i].fieldID }) end
        --for i=1,#config.projectors do
        --    selectProjector = config.projectors[i].device
        --    setupProjectorFieldID(config.projectors[i].fieldID)
        --end
        return true
    end

    return false
end

function touchEventHandler(id, device, x, y, button, user)
    gui:touchEvent(x, y, user)
end

loadConfig()

function drawMain()
    gui:flushElements(true)
    gui:setElement({index = titleBar, text = "inventoryManager"})

    gui:addButton(2, 3, 20, 2, "read inventory", "main", 0xFFB000, 0x282828, "left", readPlayerInterface)

    gui:addButton(2, 6, 20, 2, "store preset", "main", 0xFFB000, 0x282828, "left", readPlayerInterface)
    autoDump.button = gui:addButton(2, 9, 20, 2, getBoolBox(autoDump.enabled).." auto-dump", "main", 0xFFB000, 0x282828, "left", toggleAutoDump)

    drawInventory()
end

event.listen("touch", touchEventHandler)

drawMain()

event.pull("interrupted")

function saveConfig(cFile, cData)
    local cf = io.open(cFile, "w")
    cf:write(require("serialization").serialize(cData))
    cf:close()
end

function storeConfig()
    --local config = { statsScreen = statsScreen, screens = {}, projectors = {} }
    --for i=1,#screens do
    --    table.insert(config.screens, { screen = screens[i].address, gpu = screens[i].gpu.address, fieldID = screens[i].fieldID })
    --end
    --for i=1,#projector do
    --    table.insert(config.projectors, { device = projector[i].address, fieldID = projector[i].fieldID })
    --end

    saveConfig("/etc/inventoryManager.conf", config)
end

function closeTool()
    event.ignore("touch", touchEventHandler)
    if autoDump.timer then event.cancel(autoDump.timer) end
    component.gpu.setResolution(60, 20)
    require("term").clear()
    storeConfig()
end

closeTool()