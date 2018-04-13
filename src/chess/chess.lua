require ("package").loaded.hazeUI = nil
require ("package").loaded.chessH = nil
require ("package").loaded.borders = nil

components = require("component")
event = require("event")
require("hazeUI")
require("chessH")

initFigures()
initProjectors()
initScreens()

function loadConfig()
    local config = loadFile("/etc/chess.conf")
    if config then
        statsScreen = config.statsScreen
        for i=1,#config.screens do
            setScreenFieldID({ screen = config.screens[i].screen, id = config.screens[i].fieldID }) end
        for i=1,#config.projectors do
            selectProjector = config.projectors[i].device
            setupProjectorFieldID(config.projectors[i].fieldID)
        end
        return true
    end

    return false
end

if not loadConfig() then setup() end

event.listen("touch", touchEventHandler)

event.pull("interrupted")

function saveConfig(cFile, cData)
    local cf = io.open(cFile, "w")
    cf:write(require("serialization").serialize(cData))
    cf:close()
end

function storeConfig()
    local config = { statsScreen = statsScreen, screens = {}, projectors = {} }
    for i=1,#screens do
        table.insert(config.screens, { screen = screens[i].address, gpu = screens[i].gpu.address, fieldID = screens[i].fieldID })
    end
    for i=1,#projector do
        table.insert(config.projectors, { device = projector[i].address, fieldID = projector[i].fieldID })
    end

    saveConfig("/etc/chess.conf", config)
end

function closeTool()
    event.ignore("touch", touchEventHandler)
    for i=1,#screens do
        screens[i].gpu.setBackground(0x0)
        screens[i].gpu.setForeground(0xFFFFFF)
        screens[i].gpu.setResolution(60, 20)
        screens[i].gpu.fill(1, 1, 60, 20, " ")
    end
    require("term").bind(screens[statsScreen].gpu, components.proxy(screens[statsScreen].address))
    require("term").clear()
    storeConfig()
end

closeTool()