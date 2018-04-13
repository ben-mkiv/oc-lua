component = require("component")
modem = component.modem
event = require("event")
sides = require("sides")
serialization = require("serialization")

modem.open(42001) -- Redstone network

config = {}
devices = {}

function modemMessageEvent(a, receiver_address, sender_address, port, e, msg)
    if not msg or msg == nil then return false end

    data = serialization.unserialize(msg)[1]
    return data
end

function sendC(ad, cmd, waitReply)
    local data = {}
    data.a = ad
    data.c = cmd

    modem.send(ad, 42001, serialization.serialize(data))

    if waitReply ~= false then
        return modemMessageEvent(event.pull(3, "modem_message"))
    end
end

function sendCB(cmd, waitReply)
    local data = {}
    data.a = "all"
    data.c = cmd
    modem.broadcast(42001, serialization.serialize(data))
    if waitReply ~= false then
        return modemMessageEvent(event.pull(3, "modem_message"))
    end
end


function sendCBM(cmd, waitReply)
    local data = {}
    data.a = "all"
    data.c = cmd
    modem.broadcast(42001, serialization.serialize(data))

    local messages = {}

    if waitReply ~= false then
        while true do
            local msg = modemMessageEvent(event.pull(3, "modem_message"))
            if msg ~= nil and msg then
                messages[#messages+1] = msg
            else
                return messages
            end
        end
    end

    return false
end


function netRS_toggle(i, side, state)
    if not state then
        if netRS_get(i) > 0 then
            state = 0
        else
            state = 15
        end
    end
    return tonumber(sendC(machines[i].address, "return r.setOutput(".. side ..", ".. state ..")"))
end

function getOutput(device, side)
    return tonumber(sendC(device, "return r.getOutput(".. side ..")", 2))
end

function setOutput(device, side, state)
    return tonumber(sendC(device, "return r.setOutput(" .. side .. ", " .. state .. ")", 2))
end

function wakeup()
    modem.broadcast(42001, "initRSNetwork")
end


function compareNames(a, b)
    return a.name < b.name
end

function sortOutputs()
    if #config.outputs > 1 then
        table.sort(config.outputs, compareNames)
    end
end

function loadConfig(cFile)
    local ser = require("serialization")
    local fs = require("filesystem")
    if not fs.exists(cFile) then
        return {}
    end

    local cf = io.open(cFile, "r")
    local serData = cf:read("*a")
    cf:close()

    return ser.unserialize(serData)
end

function saveConfig(cFile, cData)
    local ser = require("serialization")
    local cf = io.open(cFile, "w")
    cf:write(ser.serialize(cData))
    cf:close()
end

