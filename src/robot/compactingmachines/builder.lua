require("builderLib")

local args = { ... }

local build = args[1]
local buildCount = args[2]

event.listen("interrupted", function() stopme = true end)
print("")

robot.setLightColor(0xFFFF00)

term.clear()
print("trying to build "..buildCount.."x "..build)

print("moving to storage")
moveOffset(getOffset(build))


for i=1,#recipes[build].items do
    print("refilling " .. recipes[build].items[i][1])
    local result = refillSomething(sides.bottom, recipes[build].items[i][1], buildCount * recipes[build].items[i][2])
    if not result[1] then
        print("refilling failed, exiting")
        robot.setLightColor(0xFF0000)
        os.exit()
    end
end

for i=1,buildCount do
    robot.setLightColor(0xFFA500)
    print("moving to build plot")
    moveOffset(getOffset("build"))
    buildPosition = { 0, 0, 0 }

    beam.suck()

    term.clear()
    print("starting to build "..i.."/"..buildCount)
    buildSomething(recipes[build].structure)
    print("finishing build")

    robot.select(findSlotByName(recipes[build].extraItem))
    moveInBuild(0, 6, 0)
    robot.drop(sides.bottom, 1)

    robot.setLightColor(0xFFFF00)
    print("waiting for cc build process.")
    for i=1,recipes[build].sleepTicks%10 do
        io.write(".")
        os.sleep(10)
    end
    print("")
end

moveInBuild(0, 0, 0)
beam.suck()
robot.setLightColor(0x00FF00)

