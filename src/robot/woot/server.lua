require("package").loaded.woot = nil
dP=42006
--modem
component = require("component")
m=component.proxy(component.list("modem")())
r=component.proxy(component.list("robot")())
r.setLightColor(0x00FF00)

_G.serialization = require("serialization")

if component.list("drone")() then _G.d=component.proxy(component.list("drone")())
elseif component.list("robot")() then _G.d=component.proxy(component.list("robot")()) end
--leash
if component.list("leash")() then _G.l=component.proxy(component.list("leash")()) end
--geolyzer
if component.list("geolyzer")() then _G.g=component.proxy(component.list("geolyzer")()) end
--redstone
if component.list("redstone")() then _G.r=component.proxy(component.list("redstone")()) end
--inventory
if component.list("inventory_controller")() then _G.i=component.proxy(component.list("inventory_controller")()) end
--navigation
if component.list("navigation")() then _G.n=component.proxy(component.list("navigation")()) end

require "woot"

--remote replyfunc

local event = require("event")

--init
m.setWakeMessage("initWoot")
m.open(dP)
--m.broadcast(dP, '{init="'..m.address..'"}')
--mainloop

activeController = getMob()

print("robot server active")
while true do
	local tmp = select(6, event.pull("modem_message"))
	if tmp and tmp ~= "initWoot" then
		foo = load(tmp)
		if foo then 
			foo = foo() 
			m.broadcast(dP,_G.serialization.serialize(foo))
		end
	end	
end
m.close()
print("robot server closed")
