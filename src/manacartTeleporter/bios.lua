r=component.proxy(component.list("redstone")())
--remote replyfunc
types = { "push", "pull" }
type = "push"

sideTop = 1
sideFront = 3
sideBack = 2
sideLeft = 5
sideRight = 4

currentAction = "idle"
--todo: read config from sign attached to the microcontroller
while true do
    local manaLevel = r.getComparatorInput(sideTop)
    local teleport = false
    if type == "push" then
        if manaLevel >= 13 then
            teleport = true
        elseif manaLevel > 0 then
            currentAction = "pushing"
        end
    else
        if manaLevel == 0 then
            teleport = true
        elseif manaLevel > 0 then
            currentAction = "pulling"
        end
    end

    if teleport and currentAction ~= "idle" then
        r.setOutput(sideRight, 15)
        os.sleep(1)
        r.setOutput(sideRight, 0)
        currentAction = "idle"
    end
end