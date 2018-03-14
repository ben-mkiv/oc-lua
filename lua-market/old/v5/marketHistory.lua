local marketHistory = {}

marketHistory.files = {}

marketHistory.logDirectory = "/var/log"

marketHistory.load = function()
	marketHistory.files = {}
	
	for logFile in filesystem.list("/var/log/") do
		table.insert(marketHistory.files, logFile)
	end	
end

-- this will probably get slow after time...
marketHistory.log = function(logEl)
	if not filesystem.isDirectory(marketHistory.logDirectory) then
		filesystem.makeDirectory(marketHistory.logDirectory)
	end

	local logfile = marketHistory.logDirectory.."/market_"..os.time()..".log"
	
	while filesystem.exists(logfile) do
		os.sleep(1) -- yea no index, just chill :D
		logfile = marketHistory.logDirectory.."/market_"..os.time()..".log"
	end

	file = io.open(logfile, "w")	
	file:write(ser.serialize(logEl))	
	file:close()
end


return marketHistory
