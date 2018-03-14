-- draconic evolution crafting
fs = require("filesystem")

files = { 
	{ pastebin = "7hg27efY", path = "/usr/bin", filename = "de.lua", label = "launcher" },
	{ pastebin = "12uhN6Z9", path = "/usr/lib", filename = "deH.lua", label = "lib" },
	{ pastebin = "8mjXs9Xu", path = "/etc", filename = "de_upgradeRecipes.conf", label = "upgradeRecipes" },
	{ pastebin = "zPW4RjWq", path = "/etc", filename = "de_infusioncrafting.conf", label = "recipes" },   
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

print("\n...done! run with 'de'")
