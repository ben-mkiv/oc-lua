-- ─	━	│	┃	┄	┅	┆	┇	┈	┉	┊	┋	┌	┍	┎	┏
--
-- ┐	┑	┒	┓	└	┕	┖	┗	┘	┙	┚	┛	├	┝	┞	┟
--
-- ┠	┡	┢	┣	┤	┥	┦	┧	┨	┩	┪	┫	┬	┭	┮	┯
--
-- ┰	┱	┲	┳	┴	┵	┶	┷	┸	┹	┺	┻	┼	┽	┾	┿
--
-- ╀	╁	╂	╃	╄	╅	╆	╇	╈	╉	╊	╋	╌	╍	╎	╏
--
-- ═	║	╒	╓	╔	╕	╖	╗	╘	╙	╚	╛	╜	╝	╞	╟
--
-- ╠	╡	╢	╣	╤	╥	╦	╧	╨	╩	╪	╫	╬
--
-- 	╱	╲	╳	╴	╵	╶	╷	╸	╹	╺	╻	╼	╽	╾	╿

local borders = {}

borders.groups = {
	slim_round = { "╭", "╮", "╰", "╯", "│", "─", "├", "┤" },
	slim_double = { "╔", "╗", "╚", "╝", "║", "═", "╠", "╣" },
	bold = { "┏", "┓", "┗", "┛", "┃", "━", "┣", "┫" }
}

borders.draw = function(x, y, w, h, fg, bg, type, gpu)
	local b = borders.groups[type]

	local oldBg = gpu.getBackground()
	local oldFg = gpu.getForeground()

	if bgColor == nil then bgColor = oldBg end
	if fgColor == nil then fgColor = oldFg end

	gpu.setForeground(fg)
	gpu.setBackground(bg)

	gpu.set(x, y, b[1])		-- corner top left
	gpu.set(x+w, y, b[2])	-- corner top right
	gpu.set(x, y+h-1, b[3])		-- corner bottom left
	gpu.set(x+w, y+h-1, b[4]) 	-- corner bottom right

	gpu.fill(x, y+1, 1, h-2, b[5])		-- frame left
	gpu.fill(x+w, y+1, 1, h-2, b[5])	-- frame right
	gpu.fill(x+1, y, w-1, 1, b[6])			-- frame top
	gpu.fill(x+1, y+h-1, w-1, 1, b[6])	-- frame bottom

	gpu.setForeground(oldFg)
	gpu.setBackground(oldBg)
end

borders.addDivLine = function(x, y, w, fg, bg, type, gpu)
	local b = borders.groups[type]

	if gpu == nil then gpu = require("component").gpu end

	local oldBg = gpu.getBackground()
	local oldFg = gpu.getForeground()
	gpu.setForeground(fg)
	gpu.setBackground(bg)
	gpu.set(x, y, b[7])		-- frame left (division)
	gpu.set(x+w, y, b[8])	-- frame right (division)
	gpu.fill(x+1, y, w-1, 1, b[6]) -- frame line
	gpu.setForeground(oldFg)
	gpu.setBackground(oldBg)
end

borders.addBoxDivLine = function(box, posY)
	borders.addDivLine(box.x, box.y + posY, box.w, box.bgColor, box.fgColor, box.type, box.gpu)
end

borders.drawBox = function(posX, posY, width, height, title, border, bgColor, fgColor, textColor, gpu)
	if gpu == nil then gpu = require("component").gpu end
	if border == nil then border = "slim_round" end
	if textColor == nil then textColor = oldFg end

	borders.draw(posX, posY, width, height, fgColor, bgColor, border, gpu)
	gpu.setForeground(textColor)
	gpu.set(posX+2, posY, " "..title.." ")
	return { x = posX, y = posY, w = width, h = height, fgColor = fgColor, bgColor = bgColor, gpu = gpu, type = border }
end


borders.flushBox = function(box)
	local oldBg = box.gpu.getBackground()
	local oldFg = box.gpu.getForeground()
	box.gpu.setBackground(box.bgColor)
	box.gpu.setForeground(box.bgColor)
	box.gpu.fill(box.x + 1, box.y + 1, box.w - 2, box.h - 2, " ")
	box.gpu.setForeground(oldFg)
	box.gpu.setBackground(oldBg)
end

borders.flushBoxSection = function(box, offsetX, offsetY, w, h)
	if offsetX == nil then offsetX = 0 end
	if offsetY == nil then offsetY = 0 end
	if w == nil then w = box.w end
	if h == nil then h = box.h end

	box.x = box.x + offsetX
	box.y = box.y + offsetY
	box.w = w - offsetX
	box.h = h - offsetY
	borders.flushBox(box)
end

return borders
