-- simple watch program, first argument is the sleep time after each system call

term = require("term")

args = { ... }

cmd = ""

for i=2,#args do
    cmd = cmd .. " " .. args[i]
end

while true do
    term.clear()
    print(os.date())

    os.execute(cmd)

    os.sleep(tonumber(args[1]))
end