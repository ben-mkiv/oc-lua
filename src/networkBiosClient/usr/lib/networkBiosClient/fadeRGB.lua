local fadeRGB = {}


function fadeColorRGB(r, g, b)
  color = b + (g * 256) + (r * 256*256)
  ai.setColor(color)
end

local fadeRGB.r = 0
local fadeRGB.g = 0
local fadeRGB.b = 0

fadeRGB.updateColor = function()
  if fadeRGB.r > 255 then
    fadeRGB.r = 0
  end
  if fadeRGB.g > 255 then
    fadeRGB.g = 0
  end
  if fadeRGB.b > 255 then
    fadeRGB.b = 0
  end
  
  fadeRGB.r = fadeRGB.r + 10
  fadeRGB.g = fadeRGB.g + 20
  fadeRGB.b = fadeRGB.b + 20
end

return fadeRGB;
