r=component.proxy(component.list("redstone")())
s=component.proxy(component.list("sign")())
sideTop = 1
outputs={}

function readConfigFromSign()
    val = s.getValue()
    for str in string.gmatch(val, "([^\n]+)") do
        first = string.sub(str, 1, 1)
        last = string.sub(str, 3)
        table.add(outputs, { first, last })
    end
end

readConfigFromSign()

while true do
    val = s.getValue()
    if val ~= nil and string.sub(val, 1, 4) == "true" then
        r.setOutput(sideTop, 15)
    else
        r.setOutput(sideTop, 0)
    end
end
