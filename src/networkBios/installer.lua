-- draconic evolution crafting
fs = require("filesystem")

files = {
    

    { pastebin = "QPZZrQdS", path = "/usr/lib", filename = "borders.lua", label = "border/frame lib" },
    { pastebin = "9Ujn0eEn", path = "/usr/lib", filename = "hazeUI.lua", label = "hazeUI lib" }
}

function fetchFile(f)
    local file = f.path .. "/" .. f.filename
    if not fs.isDirectory(f.path) then fs.makeDirectory(f.path); end
    if fs.exists(file) then fs.remove(file); end

    print("fetching "..f.label)
    os.execute("pastebin get ".. f.pastebin .." " .. file)
end


for i=1,#files do
    fetchFile(files[i])
    os.sleep(0)
end

print("\n...done!")