require ("package").loaded.ar = nil

component = require("component")
event = require("event")

_G.ar = require("openglasses/ar")

_G.g = component.glasses
_G.g.removeAll()

_G.resolution = { x = 512, y = 288 }

_G.g.setRenderResolution("", _G.resolution.x, _G.resolution.y);

_G.buttons = {}

f = _G.ar:addToOverlay("background", "Box2D")
f.setSize(512, 288)
f.addColor(0,0,0,0)
f.addColor(0,0,0,0)
f.addColor(0.1, 0.1, 0.1, 0.5)
f.addColor(0.2, 0.2, 0.2, 0.5)
f.setCondition(3, "OVERLAY_ACTIVE", true)
f.setCondition(4, "OVERLAY_ACTIVE", true)

fBl = _G.ar:addToOverlay("widgets_list_l", "Box2D")
fBl.setSize(70, 273)
fBl.addColor(0.1, 0.1, 0.1, 0.1)
fBl.addColor(0.1, 0.1, 0.1, 0.1)
fBl.addColor(0.1, 0.1, 0.1, 0.2)
fBl.addColor(0, 0, 0, 0.2)
fBl.setCondition(3, "OVERLAY_ACTIVE", true)
fBl.setCondition(4, "OVERLAY_ACTIVE", true)
fBl.addTranslation(0, 15, 0)

fBr = _G.ar:addToOverlay("widgets_list_r", "Box2D")
fBr.setSize(_G.resolution.x - 70, 273)
fBr.addColor(0.1, 0.1, 0.1, 0.1)
fBr.addColor(0.1, 0.1, 0.1, 0.1)
fBr.addColor(0.1, 0.1, 0.1, 0.2)
fBr.addColor(0, 0, 0, 0.2)
fBr.setCondition(3, "OVERLAY_ACTIVE", true)
fBr.setCondition(4, "OVERLAY_ACTIVE", true)
fBr.addTranslation(0, 15, 0)

fMM = _G.ar:addToOverlay("mainmenue", "Box2D")
fMM.setSize(_G.resolution.x, 15)
fMM.addColor(0, 0, 0, 0.1)
fMM.addColor(0.01, 0.01, 0.01, 0.1)
fMM.addColor(0.01, 0.01, 0.01, 0.2)
fMM.addColor(0, 0, 0, 0.2)
fMM.setCondition(3, "OVERLAY_ACTIVE", true)
fMM.setCondition(4, "OVERLAY_ACTIVE", true)

fMMS = _G.ar:addToOverlay("mainmenue", "Text2D")
fMMS.setText("openGlasses Demo v2")
fMMS.addColor(1, 1, 1, 0.2)
fMMS.addColor(1, 1, 1, 0.8)
fMMS.setCondition(2, "OVERLAY_ACTIVE", true)
fMMS.addTranslation(2, 2, 0)

function addButton(x, y, w, h, text, cb, widget, r, g, b)
  alpha = 0.1
  i = #_G.buttons + 1
  _G.buttons[i] = {}  
  _G.buttons[i].el = {}    
  _G.buttons[i].el[1] = _G.ar:addToOverlay("buttons", "Box2D")
  _G.buttons[i].el[1].setSize(w, h)
  _G.buttons[i].el[1].addTranslation(x, y, 0)
  _G.buttons[i].el[1].addColor(r, g, b, alpha)
  _G.buttons[i].el[1].addColor(r, g, b, alpha+0.1)
  _G.buttons[i].el[1].addColor(r, g, b, alpha+0.3)
  _G.buttons[i].el[1].addColor(r, g, b, alpha+0.1)
  _G.buttons[i].el[1].setCondition(5, "OVERLAY_ACTIVE", true)
  _G.buttons[i].el[1].setCondition(6, "OVERLAY_ACTIVE", true)
  _G.buttons[i].el[2] = _G.ar:addToOverlay("buttons", "Text2D")
  _G.buttons[i].el[2].setText(text)
  _G.buttons[i].el[2].addTranslation(x+2, y+3, 0)
  _G.buttons[i].el[2].addScale(0.8, 0.8, 0.8)
  _G.buttons[i].r = r
  _G.buttons[i].g = g
  _G.buttons[i].b = b
  _G.buttons[i].x = x
  _G.buttons[i].y = y
  _G.buttons[i].w = w
  _G.buttons[i].h = h
  _G.buttons[i].widget = widget
  _G.buttons[i].text = text
  _G.buttons[i].cb = cb
  return _G.buttons[i]
end

function configWidget(i, status)
  if status == "active" then
	alpha = 0.5
  else
    alpha = 0.1
  end
  
  for j=1,4 do _G.buttons[i].el[1].removeModifier(3) end
  
  _G.buttons[i].el[1].addColor(_G.buttons[i].r, _G.buttons[i].g, _G.buttons[i].b, alpha)
  _G.buttons[i].el[1].addColor(_G.buttons[i].r, _G.buttons[i].g, _G.buttons[i].b, alpha+0.1)
  _G.buttons[i].el[1].addColor(_G.buttons[i].r, _G.buttons[i].g, _G.buttons[i].b, alpha+0.3)
  _G.buttons[i].el[1].addColor(_G.buttons[i].r, _G.buttons[i].g, _G.buttons[i].b, alpha+0.1)
  _G.buttons[i].el[1].setCondition(5, "OVERLAY_ACTIVE", true)
  _G.buttons[i].el[1].setCondition(6, "OVERLAY_ACTIVE", true)
end

_G.selectedWidget = false

function printTable(t, x)
	if type(t) ~= "table" then
		print("got something which isn't a table -.-")
		return
	end
	term = require("term")
	suffix = ""
	for f=1,x do
	  suffix = " "..suffix
	end
	
	output = false
	for i=1,#t do
		if type(t[i]) == "table" then
			printTable(t[i], (x+1))
		else
			term.write(suffix.." "..t[i])
			term.write("\t")
			output = true
		end		
	end 
	if(output == true) then term.write("\n") end
end

function dumpModifiers()
	if _G.selectedWidget == false then return; end
	ser = require("serialization")
	require("term").clear()
	print("")
	print("#".._G.buttons[_G.selectedWidget].text.." modifiers:")
	modifiers = _G.buttons[_G.selectedWidget].widget.getModifiers()
	printTable(modifiers, 1)	
end

_G.modifierList = {}
_G.toolsList = {}

function removeWidget(bar)
	bar = _G.selectedWidget
	selectWidget(_G.selectedWidget)       -- deselect the widget
	for i=1,#_G.buttons do
	  if _G.buttons[i].widget == _G.buttons[bar].widget then
		_G.buttons[i].el[1].removeWidget()  -- remove button in menue
		_G.buttons[i].el[2].removeWidget()  -- remove button in menue
	  end
	end
	
	_G.buttons[bar].widget.removeWidget() -- remove widget from world/overlay
	_G.buttons.remove(bar)
end

function deselectWidget()
	for i=1,#_G.toolsList do
		_G.toolsList[i].el[2].removeWidget()		
		_G.toolsList[i].el[1].removeWidget()
		_G.toolsList[i] = nil
	end	
	_G.toolsList = {}
	
	for j=1,#_G.modifierList do
		_G.modifierList[j].el[2].removeWidget()		
		_G.modifierList[j].el[1].removeWidget()
		_G.modifierList[j] = nil
	end	
	_G.modifierList = {}	
end

function selectWidget(i)
	if i == _G.selectedWidget then
		configWidget(_G.selectedWidget, "inactive")
		deselectWidget()
		_G.selectedWidget = false
		return
	elseif _G.selectedWidget ~= false then		
		configWidget(_G.selectedWidget, "inactive")
		deselectWidget()
	end
	
	_G.selectedWidget = i
	configWidget(i, "active")	

	modifiers = _G.buttons[i].widget.getModifiers()
	for m=1,#modifiers do
		_G.modifierList[m] = addButton(0, 144+(m*12), 70, 10, "#" .. modifiers[m][1] .. " " .. modifiers[m][2], function() print("clicked") end, _G.buttons[i].widget, 0, 1, 1)
	end
	_G.toolsList[1] = addButton(0, 132, 70, 10, "remove widget", function(foo) removeWidget(foo) end, _G.buttons[i].widget, 1, 0, 0)   
	_G.toolsList[2] = addButton(0, 144, 70, 10, "dump modifiers", function(foo) dumpModifiers() end, _G.buttons[i].widget, 0.5, 0.5, 1)   
end

_G.s = 0
function addWidgetWorld(i)
	w = _G.ar:addToWorld("world", _G.ar.WORLD_WIDGETS[i].name)
	addButton(0, 22 + _G.s * 12, 70, 10, _G.ar.WORLD_WIDGETS[i].name, function(foo) selectWidget(foo) end, w, 0, 0, 1)
    _G.s = _G.s + 1     
end

function addWidgetOverlay(i)
	w = _G.ar:addToOverlay("overlay", _G.ar.OVERLAY_WIDGETS[i].name)
	w.addTranslation(70, 30, 0)
	if _G.ar.OVERLAY_WIDGETS[i].name == "Item" then
		w.addTranslation(50, 50, 0)
		w.addScale(40, 40, 40)
		w.addRotation(180, 0, 0, 1)
	end
	addButton(0, 22 + _G.s * 12, 70, 10, _G.ar.OVERLAY_WIDGETS[i].name, function(foo) selectWidget(foo) end, w, 0, 0, 1)
    _G.s = _G.s + 1     
end

for i=1,#_G.ar.OVERLAY_WIDGETS do
  addButton(_G.resolution.x - 70, 10 + i * 12, 70, 10, _G.ar.OVERLAY_WIDGETS[i].name, function() addWidgetOverlay(i) end, nil, 0, 1, 0)
end

for i=1,#_G.ar.WORLD_WIDGETS do
  addButton(_G.resolution.x - 70, 10 + (1+i+#_G.ar.OVERLAY_WIDGETS) * 12, 70, 10, _G.ar.WORLD_WIDGETS[i].name, function() addWidgetWorld(i) end, nil, 0, 1, 0)
end

function clickEvent(id, device, user, x, y, button, maxX, maxY)
  for i=1,#_G.buttons do
    tmpX = math.floor(_G.buttons[i].x)
    tmpY = math.floor(_G.buttons[i].y)
    tmpXM = math.floor(tmpX + _G.buttons[i].w)
    tmpYM = math.floor(tmpY + _G.buttons[i].h)
       
    if tmpX <= x and tmpXM >= x and tmpY <= y and tmpYM >= y then
         _G.buttons[i].cb(i)
    end
  end
end

event.listen("interact_overlay", clickEvent)
event.pull("interrupted")
event.ignore("interact_overlay", clickEvent)
