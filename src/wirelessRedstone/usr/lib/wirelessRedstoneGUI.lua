require("wirelessRedstone")
require("hazeUI")

gui = clone(hazeUI)
gui.gpu = component.gpu
gui.super = gui
gui.self = gui

function touchEventHandler(id, device, x, y, button, user)
    --if user ~= "ben_mkiv" then return false; end
    return gui:touchEvent(x, y, user)
end

function closeTool()
    gui.gpu.setBackground(0x0)
    gui.gpu.setForeground(0xFFFFFF)
    gui.gpu.setResolution(60,30)
    event.ignore("touch", touchEventHandler)
    saveConfig(configFile, config)
    require("term").clear()
    os.exit()
end

function status(message, timeout)
    local backgroundColor = 0xFFB000

    if message == "" then
        backgroundColor = 0x4E4E4E
    end

    gui:setElement({index = statusBar, text = message, bg = backgroundColor })

    gui:drawElement(gui.els[statusBar])

    if timeout ~= nil and timeout > 0 then
        event.timer(timeout, function() status("") end)
    end
end

function toggleOutput(output)
    local statusMessage = "toggle output " .. output.device .. ", " .. output.side .. "... "
    status(statusMessage)
    local rs = 15
    if output.status ~= nil and output.status > 0 then rs = 0; end

    output.status = setOutput(output.device, output.side, rs)

    for i=1,#config.outputs do
        if config.outputs[i].device == output.device and config.outputs[i].side == output.side then
            config.outputs[i].status = output.status
        end
    end

    status(statusMessage .. "done. (" .. output.status .. ")", 2)
end

function addRedstoneOutput(address, side, name, outputStatus)
    local output = {}
    output.device = address
    output.side = side
    output.name = name

    if outputStatus == nil then
        output.status = getOutput(output.device, output.side)
    else
        output.status = outputStatus
    end

    table.insert(config.outputs, output)
    sortOutputs()
    status("added new output '" .. output.name .. "'", 5)
end

function addOutputFinal(data)
    if data.value ~= "" then
        addRedstoneOutput(data.e.device, data.e.side, data.value)
    end
    gui:drawMain()
end

function addOutputName(data)
    local output = {}

    for i=1,#sides do if sides[i-1] == data.label then output.side = (i-1) end end

    output.device = data.e.device
    output.status = 0

    gui:addButton(42, 4, 20, 2, "toggle", "hazeUI_textInput", 0x282828, 0xFFB000, "left", toggleOutput, output)

    gui:textInput("enter name:", { f = addOutputFinal, p = { side = output.side, device = output.device } })
end

function addOutputSide(data)
    os.sleep(0.2)

    local values = {}
    for s=1,#sides do
        local add = true
        for i=1,#config.outputs do
            if config.outputs[i].device == data.label then
                if config.outputs[i].side == (s-1) then
                    add = false
                end end end

        if add then table.insert(values, sides[s-1]) end
    end

    gui:list("select output side", data.label, values, { f = addOutputName, p = { device = data.label } })
end

function addOutput()
    os.sleep(0.2)
    gui:list("select device", "-", devices, { f = addOutputSide, p = {} })
end

function getStatusText(i)
    if config.outputs[i].status ~= nil and config.outputs[i].status > 0 then
        return "[X]"
    elseif config.outputs[i].status ~= nil and config.outputs[i].status == 0 then
        return "[ ]"
    else
        return "[?]"
    end
end

function toggleOutputGUI(data)
    toggleOutput(config.outputs[data.output])

    gui:setElement({ index = data.button, text = getStatusText(data.output) })
    gui:drawElement(gui.els[data.button])
end

function turnOffAll()
    status("disabling all spawners...")
    --for i=1,#sides do
    --    sendCB("r.setOutput("..(i-1)..", 0)", false)
    --end

    for i=1,#config.outputs do
        status("disabling all spawners... " .. i .. "/" .. #config.outputs)
        config.outputs[i].status = setOutput(config.outputs[i].device, config.outputs[i].side, 0)
    end

    status("disabling all spawners... done.", 5)
    gui:drawMain()
end

function getDevices()
    io.write("fetch client data... ")
    devices = sendCBM("return m.address", 2)
    print("done. found " .. #devices .. " devices.")
end

function getStatus()
    io.write("fetch client redstone status... ")
    for i=1,#config.outputs do
        config.outputs[i].status = getOutput(config.outputs[i].device, config.outputs[i].side)
    end
    print("done.")
end