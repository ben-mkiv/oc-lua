local component = require("component")
local rs = component.redstone
local event = require("event")

local code = { 4, 8, 15, 16, 23, 42 }

-- one minecraft minute is one second in real time (whatever reality is...)

local time = 108

local detonationSide=require("sides").east

local validCode

function checkCode(code)
    return code == tonumber(io.read())
end

rs.setOutput(detonationSide, 0)

function stop(side)
    rs.setOutput(side, 15)
    require("term").clear()
    print("mind booooom")
    os.exit()
end


local term = require("term")

local codeCompleted
repeat
    codeCompleted = false
    event.timer(time/2, function() if not codeCompleted then stop() end end)
    term.clear()

    print("enter code")

    for i=1,#code do
        validCode = checkCode(code[i])
        if not validCode then
            stop(detonationSide)
        end
    end
    codeCompleted = true

    term.clear()
    print("please wait...")
    os.sleep(time)
until not validCode

stop(detonationSide)