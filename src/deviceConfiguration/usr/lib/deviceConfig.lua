local config = {}

function hasEntry(tab, event)
    for n,name in pairs(tab) do if name == event then return true; end end
    return false
end

function addDeviceEvent(device, eventName)
    if config[device] == nil then
        config[device] = { uuid = device, type = component.proxy(device).type, events = {} }
    end

    if not hasEntry(config[device].events, eventName) then
        table.insert(config[device].events, eventName)
        print("[+] added event "..eventName.." for device "..device)
    end
end

function saveDeviceConfig(filename)
    print("# writing config to file '" .. filename .. "'")
    local file = io.open(filename, "w")
    file:write(serialization.serialize(config))
    file:close()
    io.write("\n")
end

function printDeviceConfig()
    print("#** devices / events")
    for n,device in pairs(config) do
        print("#* " .. device.uuid)
        for j=1,#device.events do print("* " .. device.events[j]) end
        io.write("\n")
    end
end