local marketHistory = {}

marketHistory.files = {}

marketHistory.logDirectory = "/var/log"

marketHistory.load = function()
	local filesystem = require("filesystem")
	local ser = require("serialization")
	self.files = {}
	
	for logFile in filesystem.list("/var/log/") do
		table.insert(self.files, logFile)
	end	
end

-- this will probably get slow after time...
marketHistory.log = function(logEl)
	local filesystem = require("filesystem")
	local ser = require("serialization")
	if not filesystem.isDirectory(self.logDirectory) then
		filesystem.makeDirectory(self.logDirectory)
	end

	local logfile = self.logDirectory.."/market_"..os.time()..".log"
	
	while filesystem.exists(logfile) do
		os.sleep(1) -- yea no index, just chill :D
		logfile = self.logDirectory.."/market_"..os.time()..".log"
	end

	file = io.open(logfile, "w")	
	file:write(ser.serialize(logEl))	
	file:close()
end


return marketHistory
