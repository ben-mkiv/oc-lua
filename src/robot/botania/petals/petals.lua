require("petalsLib")
event = require("event")

local stopTool = false
event.listen("interrupted", function() print("interrupting...") stopTool = true end)

while not stopTool do for i=1,#colors do
    local label = "Mystical ".. colors[i] .. " Petal"
    print("working on "..label)
    plantPetals(colors[i])
end end

event.ignore("interrupted")