-- autor is Igor Timofeev and this is originaly part of MineOS (check it out!)
-- https://github.com/IgorTimofeev/OpenComputers

local component = require("component")
local event = require("event")
local gpu = {}

--------------------------------------------------------------------------------------------------------------------

local backgroundColor = 0x000000
local maximumLines = 20
local minumLineLength = 5
local maximumLineLength = 25

--------------------------------------------------------------------------------------------------------------------

-- local chars = {"%", "?", "@", "#", "$", "!", "0", "/", "№", "&"}
local chars = {"ァ", "ア", "ィ", "イ", "ゥ", "ウ", "ェ", "エ", "ォ", "オ", "カ", "ガ", "キ", "ギ", "ク", "グ", "ケ", "ゲ", "コ", "ゴ", "サ", "ザ", "シ", "ジ", "ス", "ズ", "セ", "ゼ", "ソ", "ゾ", "タ", "ダ", "チ", "ヂ", "ッ", "ツ", "ヅ", "テ", "デ", "ト", "ド", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "バ", "パ", "ヒ", "ビ", "ピ", "フ", "ブ", "プ", "ヘ", "ベ", "ペ", "ホ", "ボ", "ポ", "マ", "ミ", "ム", "メ", "モ", "ャ", "ヤ", "ュ", "ユ", "ョ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ヮ", "ワ", "ヰ", "ヱ", "ヲ", "ン", "ヴ", "ヵ", "ヶ", "ヷ", "ヸ", "ヹ", "ヺ", "・", "ー", "ヽ", "ヾ", "ヿ"}
local lineColorsForeground = { 0xFFFFFF, 0xBBFFBB, 0x88FF88, 0x33FF33, 0x00FF00, 0x00EE00, 0x00DD00, 0x00CC00, 0x00BB00, 0x00AA00, 0x009900, 0x008800, 0x007700, 0x006600, 0x005500, 0x004400, 0x003300, 0x002200, 0x001100 }
local lineColorsBackground = { 0x004400, 0x004400, 0x003300, 0x003300, 0x002200, 0x001100 }
local lines = {}


-------------------------------------------------------------------------------------------------------------------
screens = {}
for i in pairs(component.list("screen")) do 
	table.insert(screens, i)
end

local xScreen = 80
local yScreen = 25

d=1
for i in pairs(component.list("gpu")) do
	gpu[d] = component.proxy(i)
	gpu[d].bind(screens[d])
	print("bind screen "..screens[d].." to gpu "..i)
	gpu[d].setResolution(xScreen, yScreen)
	d=d+1
end


for i=1,#gpu do
	gpu[i].setBackground(backgroundColor)
	gpu[i].fill(1, 1, xScreen, yScreen, " ")
end


while true do
	while #lines < maximumLines do
		table.insert(lines, { x = math.random(1, xScreen), y = 1, length = math.random(minumLineLength, maximumLineLength) })
	end

	for i=1,#gpu do
		gpu[i].copy(1, 1, xScreen, yScreen, 0, 1)
		gpu[i].setBackground(backgroundColor)
		gpu[i].fill(1, 1, xScreen, 1, " ")
	end

	local i = 1
	while i <= #lines do
		local part = math.ceil(lines[i].y * #lineColorsForeground / lines[i].length)
		
		for i=1,#gpu do
			gpu[i].setBackground(lineColorsBackground[part] or 0x000000)
			gpu[i].setForeground(lineColorsForeground[part])
			gpu[i].set(lines[i].x, 1, chars[math.random(1, #chars)])
		end

		lines[i].y = lines[i].y + 1
		if lines[i].y - lines[i].length > 0 then
			table.remove(lines, i)
			i = i - 1
		end
		i = i + 1
	end

	local e = {event.pull(0.03)}
	if (e[1] == "key_down" and e[4] == 28) or e[1] == "touch" then
		for i=1,#gpu do
			gpu[i].setBackground(backgroundColor)
			gpu[i].fill(1, 1, xScreen, yScreen, " ")
		end
		break
	end
end



