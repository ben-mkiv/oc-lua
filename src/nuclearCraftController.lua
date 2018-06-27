r=component.proxy(component.list("redstone")())

function sleep(timeout)
    checkArg(1, timeout, "number", "nil")
    local deadline = computer.uptime() + (timeout or 0)
    repeat
        computer.pullSignal(deadline - computer.uptime())
    until computer.uptime() >= deadline
end


side = 0 -- sides.bottom == 0
while true do
    local output = r.getComparatorInput(side)
    r.setOutput(1, output)
    r.setOutput(0, output)
    sleep(5)
end
