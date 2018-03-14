-- mekanism hud for openGlasses (installer)
fs = require("filesystem")

files = { 
	{ pastebin = "mSCjjB9u", path = "/usr/bin", filename = "mekhud.lua", label = "launcher" },
	{ pastebin = "XSKhxMUN", path = "/usr/lib/openglasses", filename = "mekanism-hud.lua", label = "lib" }
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

print("\n...done! run with 'mekhud'")
