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
		
	gpu.setForeground(fg)
	gpu.setBackground(bg)
	
	
	gpu.set(x, y, b[1])		-- corner top left
	gpu.set(x+w, y, b[2])	-- corner top right
	
		
	for i=1,(h-2) do
		gpu.set(x, y+i, b[5])	-- frame left
		gpu.set(x+w, y+i, b[5])	-- frame right
	end
	
		
	for i=1,(w-1) do
		gpu.set(x+i, y, b[6])	-- frame top
		gpu.set(x+i, y+h-1, b[6])	-- frame bottom
	end
		
	gpu.set(x, y+h-1, b[3])	-- corner bottom left
	gpu.set(x+w, y+h-1, b[4]) -- corner bottom right	
end	

borders.addDivLine = function(x, y, w, fg, bg, type, gpu)
	gpu.set(x, y, b[7])		-- frame left (division)
	gpu.set(x+w, y, b[7])	-- frame right (division)
	
	for i=1,(w-2) do
		gpu.set(x+i, y, b[6]) -- frame line
	end	
end

return borders
