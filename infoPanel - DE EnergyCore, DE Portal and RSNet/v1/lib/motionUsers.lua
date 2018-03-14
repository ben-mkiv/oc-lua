motionUsers = {}

function getLastMove(user)
	for i=1,#motionUsers do
		if motionUsers[i].name == user then
			return motionUsers[i].timestamp
	end	end	
	return false
end

function setLastMove(user)
	for i=1,#motionUsers do	if motionUsers[i].name == user then
			motionUsers[i].lastMove = os.time()
			return true
	end	end	
	local new = {}
		  new.name = user
		  new.firstMove = os.time()	
	return table.insert(motionUsers, new)
end
