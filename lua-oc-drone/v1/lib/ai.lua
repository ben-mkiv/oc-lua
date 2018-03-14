component = require("component")
event = require("event")
modem = component.modem

require ("package").loaded.marketGUI = nil
gui = require("marketGUI")

serialization = require("serialization")

local ai = {}

ai.setSpeed = function(speed)
  return ai.sendC("d.setAcceleration(d.getAcceleration()+("..speed.."))")
end

ai.getSpeed = function()
  ai.curSpeed = tonumber(ai.sendC("return d.getAcceleration()"))
  return ai.curSpeed
end

dP = 2412

modem.open(dP)

ai.sendC = function(cmd)
  modem.broadcast(dP, cmd)
  return serialization.unserialize(select(6, event.pull(5, "modem_message")))[1]
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

