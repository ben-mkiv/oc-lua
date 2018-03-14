_G.motionUsers = {}

function getLastMove(user)
	for i=1,#_G.motionUsers do
		if _G.motionUsers[i].name == user then
			return _G.motionUsers[i].timestamp
	end	end	
	return false
end

function setLastMove(user)
	for i=1,#_G.motionUsers do	if _G.motionUsers[i].name == user then
			_G.motionUsers[i].lastMove = os.time()
			return true
	end	end	
	local new = {}
		  new.name = user
		  new.firstMove = os.time()	
	return table.insert(_G.motionUsers, new)
end
