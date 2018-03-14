--modem
m=component.proxy(component.list("modem")())
--drone
if component.list("drone")() then d=component.proxy(component.list("drone")()) local ty = "drone" end
if component.list("robot")() then d=component.proxy(component.list("robot")()) local ty = "robot" end
--leash
if component.list("leash")() then l=component.proxy(component.list("leash")()) end
--navigation
if component.list("navigation")() then n=component.proxy(component.list("navigation")()) end
local ser = {}
local local_pairs = function(tbl)
  local mt = getmetatable(tbl)
  return (mt and mt.__pairs or pairs)(tbl)
end
function ser.seril(value, pretty)
  local kw =  {["and"]=true, ["break"]=true, ["do"]=true, ["else"]=true,["elseif"]=true, ["end"]=true, ["false"]=true, ["for"]=true,["function"]=true, ["goto"]=true, ["if"]=true, ["in"]=true,["local"]=true, ["nil"]=true, ["not"]=true, ["or"]=true,["repeat"]=true, ["return"]=true, ["then"]=true, ["true"]=true,["until"]=true, ["while"]=true}
  local id = "^[%a_][%w_]*$"
  local ts = {}
  local function s(v, l)
    local t = type(v)
    if t == "nil" then return "nil"
    elseif t == "boolean" then return v and "true" or "false"
    elseif t == "number" then
      if v ~= v then return "0/0"
      elseif v == math.huge then return "math.huge"
      elseif v == -math.huge then return "-math.huge"
      else return tostring(v) end
    elseif t == "string" then return string.format("%q", v):gsub("\\\n","\\n")
    elseif t == "table" and pretty and getmetatable(v) and getmetatable(v).__tostring then return tostring(v)
    elseif t == "table" then
      if ts[v] then
        if pretty then return "recursion"
        else error("tablecycle") end end
      ts[v] = true
      local i, r = 1, nil
      local f
      if pretty then
        local ks, sks, oks = {}, {}, {}
        for k in local_pairs(v) do
          if type(k) == "number" then table.insert(ks, k)
          elseif type(k) == "string" then table.insert(sks, k)
          else table.insert(oks, k) end end
        table.sort(ks)
        table.sort(sks)
        for _, k in ipairs(sks) do table.insert(ks, k) end
        for _, k in ipairs(oks) do table.insert(ks, k) end
        local n = 0
        f = table.pack(function()
          n = n + 1
          local k = ks[n]
          if k ~= nil then return k, v[k]
          else return nil end end)
      else f = table.pack(local_pairs(v)) end
      for k, v in table.unpack(f) do
        if r then r = r .. "," .. (pretty and ("\n" .. string.rep(" ", l)) or "")
        else r = "{" end
        local tk = type(k)
        if tk == "number" and k == i then
          i = i + 1
          r = r .. s(v, l + 1)
        else
          if tk == "string" and not kw[k] and string.match(k, id) then r = r .. k
          else r = r .. "[" .. s(k, l + 1) .. "]" end
          r = r .. "=" .. s(v, l + 1) end end
      ts[v] = nil
      return (r or "{") .. "}"
    else
      if pretty then return tostring(v)
      else error("utype: " .. t) end end end
  local result = s(value, 1)
  local limit = type(pretty) == "number" and pretty or 10
  if pretty then
    local truncate = 0
    while limit > 0 and truncate do
      truncate = string.find(result, "\n", truncate + 1, true)
      limit = limit - 1
    end
    if truncate then return result:sub(1, truncate) .. "..." end end
  return result
end
landing=false
function land()
landing = true
while landing do
waitMoving()
local s,b=d.detect(0)
if b == "solid" or b == "liquid" then break	end		
d.move(0, -1, 0)		
end
landing = false
end
function waitMoving()
while true do if d.getOffset() < 0.5 then return "true" end end
end
function e2p() 
return math.floor((100/computer.maxEnergy())*computer.energy()) 
end
m.open(2412)
local function respond(...)
  local args=table.pack(...)
  pcall(function() m.broadcast(2412, table.unpack(args)) end)
end
local function receive()
  while true do
    local evt,_,_,_,_,cmd=computer.pullSignal()
    if evt=="modem_message" then return load(cmd) end
  end
end
while true do
  local r1,r2=pcall(function()
    local r1,r2=receive()
    respond(ser.seril({r1()}))
  end)
  if not r1 and r2 then respond(ser.seril({r2})) end
end
