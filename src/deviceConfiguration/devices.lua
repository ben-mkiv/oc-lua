component = require("component")
event = require("event")
serialization = require("serialization")

require("deviceConfig")

local args = {...}

local ignore = { "key_up", "key_down",
                 "interact_world_right", "interact_world_block_right", "interact_world_left", "interact_world_block_left" }

if #args < 1 then
    print("[!] please specify a outputfile as first argument")
    os.exit()
else
    outputFile = args[1]
end

function eventHandler(event, device, ...)
    --local args = {...}
    if hasEntry(ignore, event)
        then print("[x] skipping event: "..event) return;
        else addDeviceEvent(device, event)
    end
end

print("[i] listening to device events...")
local stopme = false
while not stopme do
    local eventResult = { event.pull(math.huge) }
    if eventResult[1] == "interrupted"
        then stopme = true
        elseif eventResult[1]  == "touch" then
            io.write("[?] process this screen touch event? [y/n] ")
            local answer = io.read();
            if answer == "y" or answer == "yes"
                then eventHandler(table.unpack(eventResult))
                else print("[x] skipping event: touch") end
        else eventHandler(table.unpack(eventResult))
    end
end

print("[i] stopped device listener\n\n")

saveDeviceConfig(outputFile)

printDeviceConfig()