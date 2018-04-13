require ("package").loaded.borders = nil
require ("package").loaded.hazeUI = nil
require ("package").loaded.wirelessRedstone = nil
require ("package").loaded.wirelessRedstoneGUI = nil


component = require("component")
sides = require("sides")

require("wirelessRedstoneGUI")

configFile = "/etc/wirelessRedstone.conf"

titleBar = gui:addButton(1, 1, 80, 1, "wireless redstone", "all", 0x282828, 0xFFB000, "left")

statusBar = gui:addButton(1, 25, 80, 1, "starting...", "all", 0x282828, 0xFFB000, "left")

gui.gpu.setResolution(80,25)
gui:drawScreen("all")
gui:setElement({index = titleBar, cb = "drawMain"})


io.write("waking up clients... ")
wakeup()
print("done.")

config = loadConfig(configFile)

if not config.outputs then
    config.outputs = {}
end

if not config.entityDetector then
    config.entityDetector = {}
    config.entityDetector.side = sides.top
end

if not config.grinder then
    config.grinder = {}
    config.grinder.side = sides.west
end

grinderButton = false

function toggleGrinder()
    local rs = component.redstone
    local label = "grinder (?)"
    local backgroundColor = 0xFFB000
    if rs.getOutput(config.grinder.side) > 0 then
        config.grinder.status = rs.setOutput(config.grinder.side, 0)
        backgroundColor = 0x4E4E4E
        label = "grinder (enable)"
        status("grinder disabled", 2)
    else
        config.grinder.status = rs.setOutput(config.grinder.side, 15)
        label = "grinder (disable)"
        status("grinder enabled", 2)
    end

    gui:setElement({ index = grinderButton, text = label, bg = backgroundColor })
    gui:drawElement(gui.els[grinderButton])
end

function gui:drawMain()
    self:flushElements(true)
    --self:setElement({index = titleBar, text = "wireless redstone"})
    self:addButton(59, 3, 20, 2, "add output", "main", 0x282828, 0xFFB000, "left", addOutput)

    self:addButton(59, 6, 20, 2, "turn off (all)", "main", 0x282828, 0xFFB000, "left", turnOffAll)

    grinderButton = self:addButton(59, 9, 20, 2, "grinder (?)", "main", 0x282828, 0x4E4E4E, "left", toggleGrinder)

    for i=1,#config.outputs do
        local bg = 0xFF841A

        if i%2 == 0 then bg = 0xFFB000 end

        local bIndex1 = self:addButton(2, 2+i, 40, 1, config.outputs[i].name, "main", 0x282828, bg, "left")

        local bIndex2 = self:addButton(42, 2+i, 5, 1, getStatusText(i), "main", 0x282828, bg, "center")
        self:setElement({ index = bIndex1, cb = toggleOutputGUI, cb_parm = { output = i, button = bIndex2} })
        self:setElement({ index = bIndex2, cb = toggleOutputGUI, cb_parm = { output = i, button = bIndex2} })

    end

    self:drawScreen("main")
end

getDevices()
getStatus()

gui:drawMain()

status("")
event.listen("touch", touchEventHandler)

event.pull("interrupted")

closeTool()