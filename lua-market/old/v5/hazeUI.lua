term = require("term")
borders = require("borders")

hazeUI = {
  els = {}, 
  lastTouchUser = nil, 
  currentScreen = nil, 
  config = { screen = false, gpu = false }, 
  gpu = nil,
  super = nil }

function copy (t) -- shallow-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do target[k] = v end
    setmetatable(target, meta)
    return target end

function clone (t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then target[k] = clone(v)
        else target[k] = v end end
    setmetatable(target, meta)
    return target end

function hazeUI:drawStatusbar(x, y, w, h, s, j, prefix)
   perc = math.floor((100/s) * j)
   bar = 1+math.floor( 0.5 + (((w-2) / s) * j))  
   self.gpu.fill(x, y, w, h+1, " ");
   self.gpu.set(x, y, "[")
   self.gpu.set(x+w, y, "]")
   self.gpu.fill(x+1, y, bar, 1, "#");
   self.gpu.fill(x+1+bar, y, (w-bar-1), 1, "-");
   self.gpu.set(x, y+1, perc.."% ".. prefix.." "..j.." of "..s)   
end

function hazeUI:drawElement(el)
  if not el or el == nil then return end
  
  local text = el.text
  local xOffset = 0
  
  if string.len(text) > (el.w - (2*el.textPadding)) then
    text = string.sub(text, 0, (el.w-(2*el.textPadding)))
  end

  if el.textalign == "center" then
    xOffset = math.floor((el.w-(2*el.textPadding)-string.len(text)) / 2)
  end

  if el.textalign == "right" then
    xOffset = (el.w-(2*el.textPadding)) - string.len(text)
  end

  if el.fg then self.gpu.setForeground(el.fg) end

  if el.bg then self.gpu.setBackground(el.bg) end

  self.gpu.fill(el.x, el.y, el.w, el.h, " ")
  
  xT = el.x + el.textPadding + xOffset
  yT = el.y + math.ceil((el.h-1)/2)

  self.gpu.set(xT, yT, text)

  if el.border ~= nil then
	borders.draw(el.x, el.y, el.w, el.h, el.borderColor, el.bg, el.border, self.gpu)
  end
  
  self.gpu.setBackground(0x000000)
  self.gpu.setForeground(0xFFFFFF)  
end

function hazeUI:flushElements(force)
  if force == nil then force = false end

  for j=1,#self.els do
    local fl = false
    if self.els[j].window ~= self.currentScreen then
      if self.els[j].window ~= "all" then
       fl = true
      end
    end 
    
    if force then if self.els[j].window ~= "all" then
      fl = true
    end end
    
    if fl then
      table.remove(self.els, j)
      self:flushElements(force)
      return
    end

  end 
end

function hazeUI:drawScreen(name)
  self.currentScreen = name
  self.gpu.setBackground(0x0)
  self.gpu.fill(1,1,80,25, " ")
  
  if name ~= "all" then self:drawGroup("all") end
  self:drawGroup(name)
end

function hazeUI:drawGroup(name, subgroup)
	for j=1,#self.els do
		if self.els[j].window == name then
		if not subgroup or self.els[j].group == subgroup then
			self:drawElement(self.els[j])
		end
	end end
end

-- add a button to the local cache
function hazeUI:addButton(x, y, w, h, text, group, foreground, background, textalign, cb, cb_parm)
 
  local el = {}
  el.x = x
  el.y = y
  el.w = w
  el.h = h
  
  el.border = nil
  el.borderColor = 0xABFEFE
  
  el.window = group

  el.bg = background 
  el.fg = foreground
  
  el.text = text
  el.textalign = textalign
  el.textPadding = 1
  
  el.cb = cb
  el.cb_parm = cb_parm  
  
  table.insert(self.els, el) 
  
  return #self.els
end


function hazeUI:setElement(options)
  index = options.index 
  if options.border then self.els[index].border = options.border end  
  if options.borderColor then self.els[index].borderColor = options.borderColor end  
  if options.textPadding then self.els[index].textPadding = options.textPadding end 
  if options.cb then self.els[index].cb = options.cb end 
  if options.cb_parm then self.els[index].cb_parm = options.cb_parm end 
  if options.text then self.els[index].text = options.text end 
  if options.textalign then self.els[index].textalign = options.textalign end 
  if options.bg then self.els[index].bg = options.bg end 
  if options.fg then self.els[index].fg = options.fg end 
  if options.window then self.els[index].window = options.window end 
  if options.group then self.els[index].group = options.group end 
  if options.x then self.els[index].x = options.x end 
  if options.y then self.els[index].y = options.y end 
  if options.w then self.els[index].w = options.w end 
  if options.h then self.els[index].h = options.h end 
end

-- interpret touch event
function hazeUI:touchEvent(x, y, user) 
  self.lastTouchUser = user
  for j=1,#self.els do
    local t = self.els[j]
    if t and t.cb then
		if t.window == self.currentScreen or t.window == "all" then 
  			 if t.x <= x and (t.x+t.w-1) >= x and t.y <= y and (t.y+t.h-1) >= y then
			 if type(t.cb) == "string" then return self.super[t.cb](self.super, t.cb_parm)
			 elseif type(t.cb) == "function" then return t.cb(t.cb_parm) end
		   end
		end
     end
   end
end

-- remove all buttons which belongs to name
function hazeUI:removeGroup(name)
  for j=1,#self.els do
    if self.els[j].window == name then
      table.remove(self.els, j)
      -- do that recursion to avoid skipping entrys
      return self:removeGroup(name)      
    end
  end
end

-- remove all buttons which belongs to name and group
function hazeUI:removeSubGroup(group, name)
  for j=1,#self.els do
    if self.els[j].window == group and self.els[j].group == name then
      table.remove(self.els, j)
      -- do that recursion to avoid skipping entrys
      return self:removeSubGroup(group, name)      
    end
  end
end
