gpu = require("component").gpu
term = require("term")

local marketGUI = {}

marketGUI.buttons = {}

marketGUI.currentScreen = "unknown"


function marketGUI.drawStatusbar(x, y, w, h, s, j, prefix)
   perc = math.floor((100/s) * j)
   bar = math.floor(((w-2)/s) * j)   
   
   gpu.setBackground(0x000000)
   gpu.setForeground(0xFFFFFF)
   gpu.fill(x, y, w, h+1, " ");
   gpu.set(x, y, "[")
   gpu.set(x+w, y, "]")
   
   gpu.fill(x+1, y, bar, 1, "#");
   gpu.fill(x+1+bar, y, (w-bar-1), 1, "-");
   
   gpu.set(x, y+1, perc.."% ".. prefix..j.." of "..s)   
end


function marketGUI.drawButton(btn)
  if btn then
    if btn.fg then
      gpu.setForeground(btn.fg)
    end
    if btn.bg then
      gpu.setBackground(btn.bg)
    end

    gpu.fill(btn.x, btn.y, btn.w, btn.h, " ")
  
    xT = btn.x + 2
    yT = btn.y + math.ceil((btn.h-1)/2)

    gpu.set(xT, yT, btn.text)
  end

  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)  
end

function marketGUI.flush(force)
  if force == nil then
    force = false
  end

  for j=1,#marketGUI.buttons do
    local fl = false
    if marketGUI.buttons[j].window ~= marketGUI.currentScreen then
      if marketGUI.buttons[j].window ~= "all" then
       fl = true
      end
    end 
    
    if force then if marketGUI.buttons[j].window ~= "all" then
      fl = true
    end end

    if fl then
      table.remove(marketGUI.buttons, j)
      marketGUI.flush(force)
      return
    end

  end 
end

function marketGUI.drawScreen(name)
  term.clear()
  
  if name then
  marketGUI.currentScreen = name  
  else
  name = marketGUI.currentScreen
  end
  
  marketGUI.flush();

  

  for j=1,#marketGUI.buttons do
    local draw = false
    
  if marketGUI.buttons[j].window == name then
      draw = true
    end
         
    if marketGUI.buttons[j].window == "all" then
      draw = true
    end

    if draw then
      marketGUI.drawButton(marketGUI.buttons[j])
    end    
  end

end

-- add a button to the local cache
function marketGUI.addButton(x,y,w,h,text,window, fg,bg,textalign,cb,cb_parm)
  local btn = {}
  btn.x = x
  btn.y = y
  btn.w = w
  btn.h = h
  
  btn.text = text
  btn.fg = fg
  btn.bg = bg
  
  btn.text = text
  btn.textalign = "center"
  btn.cb = cb
  btn.cb_parm = cb_parm

  btn.window = window

  table.insert(marketGUI.buttons, btn)
end

-- interpret touch event
function marketGUI.touchEvent(x, y) 
  for j=1,#marketGUI.buttons do
    local t = marketGUI.buttons[j]
    if t then
    --print("#"..j..": parm: "..t.cb_parm..", screen: "..t.window)
      local hit = false
      if t.window == gui.currentScreen then
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
              t.cb(t.cb_parm)
--              print(t.cb)
            end
          end
        end
      end
    end
  end
end
end

-- remove all buttons which belongs to name
function marketGUI.removeScreen(name)
  for j=1,#marketGUI.buttons do
    if marketGUI.buttons[j].window == name then
      table.remove(marketGUI.buttons, j)
      -- do that recursion to avoid skipping entrys
      marketGUI.removeScreen(name)
      return
    end
  end
end



return marketGUI
