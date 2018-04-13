component = require("component")
modem = component.modem
event = require("event")
sides = require("sides")
serialization = require("serialization")

modem.open(42001) -- Redstone network

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


function netRS_get(i, side)
    return tonumber(sendC(machines[i].address, "return r.getOutput(" .. side .. ")"))
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

function wakeup()
    modem.broadcast(42001, "initRSNetwork")
end