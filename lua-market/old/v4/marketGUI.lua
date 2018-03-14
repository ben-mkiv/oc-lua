gpu = require("component").gpu
term = require("term")

local hazeUI = {}

hazeUI.elements = {}
hazeUI.config = {}
hazeUI.currentScreen = false

hazeUI.drawStatusbar = function(x, y, w, h, s, j, prefix)
   perc = math.floor((100/s) * j)
   bar = 1+math.floor( 0.5 + (((w-2) / s) * j))  
   
   gpu.bind(hazeUI.config.screen)
   gpu.setBackground(0x000000)
   gpu.setForeground(0xFFFFFF)
   gpu.fill(x, y, w, h+1, " ");
   gpu.set(x, y, "[")
   gpu.set(x+w, y, "]")
   
   gpu.fill(x+1, y, bar, 1, "#");
   gpu.fill(x+1+bar, y, (w-bar-1), 1, "-");
   
   gpu.set(x, y+1, perc.."% ".. prefix..j.." of "..s)   
end

hazeUI.drawElement = function(el)
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


  gpu.bind(hazeUI.config.screen)
   
  if el.fg then
     gpu.setForeground(el.fg)
  end

  if el.bg then
    gpu.setBackground(el.bg)
  end

  gpu.fill(el.x, el.y, el.w, el.h, " ")
  
  xT = el.x + el.textPadding + xOffset
  yT = el.y + math.ceil((el.h-1)/2)

  gpu.set(xT, yT, text)

  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)  
end

hazeUI.flush = function(force)
  if force == nil then force = false end

  for j=1,#hazeUI.buttons do
    local fl = false
    if hazeUI.buttons[j].window ~= hazeUI.currentScreen then
      if hazeUI.buttons[j].window ~= "all" then
       fl = true
      end
    end 
    
    if force then if hazeUI.buttons[j].window ~= "all" then
      fl = true
    end end
		
    if fl then
      table.remove(hazeUI.buttons, j)
      hazeUI.flush(force)
      return
    end

  end 
end

hazeUI.drawScreen = function(name)
  
  hazeUI.currentScreen = name
  
  for j=1,#hazeUI.buttons do
    local draw = false
    
  if hazeUI.buttons[j].window == name then
      draw = true
    end
         
    if hazeUI.buttons[j].window == "all" then
      draw = true
    end
  
	gpu.bind(hazeUI.config.screen)   
	term.clear()
  
    
    if draw then
	   hazeUI.drawButton(hazeUI.buttons[j])
    end    
  end

end

-- add a button to the local cache
hazeUI.addButton = function(x, y, w, h, text, group, foreground, background, textalign, cb, cb_parm)
  local element = {}
  element.x = x
  element.y = y
  element.w = w
  element.h = h
  
  element.window = group

  element.bg = background 
  element.fg = foreground
  
  element.text = text
  element.textalign = textalign
  element.textPadding = 1
  
  element.cb = cb
  element.cb_parm = cb_parm  
  
  table.insert(hazeUI.buttons, element) 
  
  return #hazeUI.buttons
end

hazeUI.setElement = function(options)
  index = options.index 
  
  if options.textPadding then
    hazeUI.buttons[index].textPadding = options.textPadding
  end 
  if options.cb then
    hazeUI.buttons[index].cb = options.cb
  end 
  if options.cb_parm then
    hazeUI.buttons[index].cb_parm = options.cb_parm
  end 
  if options.text then
    hazeUI.buttons[index].text = options.text
  end 
  if options.textalign then
    hazeUI.buttons[index].textalign = options.textalign
  end 
  if options.bg then
    hazeUI.buttons[index].bg = options.bg
  end 
  if options.fg then
    hazeUI.buttons[index].fg = options.fg
  end 
  if options.window then
    hazeUI.buttons[index].window = options.window
  end 
  if options.x then
    hazeUI.buttons[index].x = options.x
  end 
  if options.y then
    hazeUI.buttons[index].y = options.y
  end 
  if options.w then
    hazeUI.buttons[index].w = options.w
  end 
  if options.h then
    hazeUI.buttons[index].h = options.h
  end 
end

-- interpret touch event
hazeUI.touchEvent = function(x, y, user) 
  hazeUI.lastTouchUser = user
  
  for j=1,#hazeUI.buttons do
    local t = hazeUI.buttons[j]
    
    if t then if t.cb then
    local hit = false
      if t.window == hazeUI.currentScreen then
        hit = true
      end
    
      if t.window == "all" then
        hit = true
      end

    if hit then
      if t.x <= x then
        if (t.x+t.w-1) >= x then
          if t.y <= y then
            if (t.y+t.h-1) >= y then
              return t.cb(t.cb_parm)
            end
          end
        end
      end
    end
  end end
end
end

-- remove all buttons which belongs to name
hazeUI.removeGroup = function(name)
  for j=1,#hazeUI.buttons do
    if hazeUI.buttons[j].window == name then
      table.remove(hazeUI.buttons, j)
      -- do that recursion to avoid skipping entrys
      return hazeUI.removeGroup(name)      
    end
  end
end

return hazeUI
