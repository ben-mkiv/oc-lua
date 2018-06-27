-- wirelessRedstone installer
fs = require("filesystem")

files = {
    { pastebin = "QPZZrQdS", path = "/usr/lib", filename = "borders.lua", label = "border/frame lib" },
    { pastebin = "9Ujn0eEn", path = "/usr/lib", filename = "hazeUI.lua", label = "hazeUI lib" },
    { pastebin = "8uKiRNHb", path = "/usr/lib", filename = "wirelessRedstone.lua", label = "wirelessRedstone lib" },
    { pastebin = "TnxwEbt2", path = "/usr/lib", filename = "wirelessRedstoneGUI.lua", label = "wirelessRedstone GUI lib" },
    { pastebin = "nTNrHUbs", path = "/usr/bin", filename = "wirelessRedstoneClient.lua", label = "wirelessRedstoneClient" },
    { pastebin = "mYAQN1dv", path = "/usr/share/wirelessRedstone", filename = "wirelessRedstone_BIOS.lua", label = "wirelessRedstone BIOS" }
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