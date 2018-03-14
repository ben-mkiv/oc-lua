local component = require("component")
local keyboard = require("keyboard")
local shell = require("shell")
local glyphs = require("holo-glyphs")

local args = shell.parse(...)

local hologram = nil
j=1
for i in pairs(component.list("hologram")) do
	if args[1] and tonumber(args[1]) == j then
		hologram = component.proxy(i)
	end	
	
	print("["..j.."] "..i)
	
	j=j+1
end

if args[3] then
	print(tonumber(args[3]))
	hologram.setPaletteColor(1, tonumber(args[3]))
end


if not args[1] or not args[2] then
	print("provide hologram index and text")
	os.exit()
end

local text = tostring(args[2]).." "

hologram.clear()


-- Generate one big string that represents the concatenated glyphs for the provided text.
local value = ""
for row = 1, 5 do
  for col = 1, #text do
    local char = string.sub(text:lower(), col, col)
    local glyph = glyphs[char]
    if glyph then
      local s = 0
      for _ = 2, row do
        s = string.find(glyph, "\n", s + 1, true)
        if not s then
          break
        end
      end
      if s then
        local line = string.sub(glyph, s + 1, (string.find(glyph, "\n", s + 1, true) or 0) - 1)
        value = value .. line .. " "
      end
    end
  end
  value = value .. "\n"
end

local bm = {}
for token in value:gmatch("([^\r\n]*)") do
  if token ~= "" then
    table.insert(bm, token)
  end
end
local h,w = #bm,#bm[1]
local sx, sy = math.max(0,(16*3-w)/2), 2*16-h-1
local z = 16*3/2

for i=1, math.min(16*3,w) do
    local x = sx + i
    for j=1, h do
      local y = sy + j-1
      if bm[1+h-j]:sub(i, i) ~= " " then
        hologram.set(x, y, z, 1)
      else
        hologram.set(x, y, z, 0)
      end
    end
end
