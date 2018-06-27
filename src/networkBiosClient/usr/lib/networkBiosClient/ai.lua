component = require("component")
event = require("event")
modem = component.modem

require ("package").loaded.hazeUI = nil
require("hazeUI")

gui = clone(hazeUI)

gui.gpu = require("component").gpu

--gui.config.screen = address
--gui.config.gpu = gpuAddress
--gui.gpu.bind(address)

serialization = require("serialization")

local ai = {}
ai.wayPoints = {}

ai.setSpeed = function(speed)
  return ai.sendC("d.setAcceleration(d.getAcceleration()+("..speed.."))")
end

ai.getSpeed = function()
  ai.curSpeed = tonumber(ai.sendC("return d.getAcceleration()"))
  return ai.curSpeed
end

dP = 42069

modem.open(dP)

ai.sendC = function(cmd, timeout)
  if not timeout or timeout == nil then timeout = 5 end
  
  modem.broadcast(dP, cmd)
  data = select(6, event.pull(timeout, "modem_message"))
  
  if not data then
	return false
  elseif data == nil or data == false then 
	return false
  elseif data == true then 
	return true 
  end
  
  data = serialization.unserialize(data)
  
  if data ~= nil and data[1] then return data[1] end
  
  return data
end

ai.move = function(data)
  ai.sendC("d.move("..data.x..","..data.y..","..data.z..")")
end

ai.color = function(data)
  local col = data.b + (256*data.g) + (256*256*data.r)
  ai.colorHEX(col)
end

ai.colorHEX = function(col)
  ai.sendC("d.setLightColor("..col..")")
end

ai.use = function(side)
  ai.sendC("d.use("..side..")")
end

ai.swing = function(side)
  ai.sendC("d.swing("..side..")")
end

-- navigation


-- leash
	ai.leash = function(side)
	  ai.sendC("l.leash("..side..")")
	end

	ai.unleash = function()
	  ai.sendC("l.unleash()")
	end

return ai

