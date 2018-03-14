dP=42069
--modem
m=component.proxy(component.list("modem")())
--drone/robot proxy
if component.list("drone")() then d=component.proxy(component.list("drone")())
elseif component.list("robot")() then d=component.proxy(component.list("robot")()) end
--leash
if component.list("leash")() then l=component.proxy(component.list("leash")()) end
--geolyzer
if component.list("geolyzer")() then g=component.proxy(component.list("geolyzer")()) end
--redstone
if component.list("redstone")() then r=component.proxy(component.list("redstone")()) end
--inventory
if component.list("inventory_controller")() then i=component.proxy(component.list("inventory_controller")()) end
--navigation
if component.list("navigation")() then n=component.proxy(component.list("navigation")()) end
--serialization
local ser={}
local local_pairs=function(tbl)
local mt=getmetatable(tbl)
return (mt and mt.__pairs or pairs)(tbl)
end
function ser.seril(value)
local kw={["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,["end"]=true,["false"]=true,["for"]=true,["function"]=true,["goto"]=true,["if"]=true,["in"]=true,["local"]=true,["nil"]=true,["not"]=true,["or"]=true,["repeat"]=true,["return"]=true,["then"]=true,["true"]=true,["until"]=true,["while"]=true}
local id="^[%a_][%w_]*$"
local ts={}
local function s(v,l)
local t=type(v)
if t=="nil" then return "nil"
elseif t=="boolean" then return v and "true" or "false"
elseif t=="number" then
if v~=v then return "0/0"
elseif v==math.huge then return "math.huge"
elseif v==-math.huge then return "-math.huge"
else return tostring(v) end
elseif t=="string" then return string.format("%q",v):gsub("\\\n","\\n")
elseif t=="table" then
if ts[v] then error("tcyc") end
ts[v]=true
local i,r=1, nil
local f=table.pack(local_pairs(v))
for k,v in table.unpack(f) do
if r then r=r..","..(("\n"..string.rep(" ",l)) or "")
else r="{" end
local tk=type(k)
if tk=="number" and k==i then
i=i+1
r=r..s(v,l+1)
else
if tk == "string" and not kw[k] and string.match(k,id) then r=r..k
else r=r.."["..s(k,l+1).."]" end
r=r.."="..s(v,l+1) end end
ts[v]=nil
return (r or "{").."}"
else error("ut "..t) end end
return s(value, 1)
end
--drone-landing
landing=false
function land()
landing=true
while landing do waitMoving()
local s,b=d.detect(0)
if b=="solid" or b=="liquid" then break	end		
d.move(0,-1,0) end landing=false end
--drone movecheck
function waitMoving(p)
if not p then local p=0.5 end
while true do if d.getOffset()<p then return "true" end end end
--energyperc
function e2p() 
return math.floor((100/computer.maxEnergy())*computer.energy()) end
--remote replyfunc
local function respond(...)
local args=table.pack(...)
pcall(function()m.broadcast(dP,table.unpack(args)) end) end
local function receive()
while true do local evt,_,_,_,_,cmd=computer.pullSignal()
if evt=="modem_message" then return load(cmd) end end end
--init
m.open(dP)
if component.list("robot")() then while n.getFacing() ~= 2 do d.turn(true) end end
--mainloop
while true do
local r1,r2=pcall(function()
local r1,r2=receive()
respond(ser.seril({r1()})) end)
if not r1 and r2 then respond(ser.seril({r2})) end
end
