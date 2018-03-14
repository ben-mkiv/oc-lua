function calcPrice(offer, price, cnt)
  return math.ceil((price.size/offer.size) * cnt)
end

function compareStacks(s1, s2)
	local equal = true;
	
	if not s1 or not s2 then
		return false
	end
	
	if s1.name ~= s2.name then
		equal = false
	elseif s1.label ~= s2.label then
		equal = false
	end	
	return equal;
end

function removeTableTrade(inTable, priceName)
	for j=1,#inTable do
		if inTable[j].price.name ~= priceName then
			table.remove(inTable, j)
			return removeTableTrade(inTable, priceName)
		end
	end		
	
	return inTable
end

