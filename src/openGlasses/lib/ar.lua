local openglasses = {
  widgets_overlay = {},
  widgets_world = {},
  
  OVERLAY_WIDGETS = {},
  WORLD_WIDGETS = {}
}

function openglasses:init()
  self.OVERLAY_WIDGETS = {}
  self.OVERLAY_WIDGETS[1] = { name = "Box2D" }
  self.OVERLAY_WIDGETS[2] = { name = "Custom2D" }
  self.OVERLAY_WIDGETS[3] = { name = "Item2D" }
  self.OVERLAY_WIDGETS[4] = { name = "OBJModel2D" }  
  self.OVERLAY_WIDGETS[5] = { name = "Text2D" }
  
  self.WORLD_WIDGETS = {}
  self.WORLD_WIDGETS[1] = { name = "Cube3D" }
  self.WORLD_WIDGETS[2] = { name = "Custom3D" }
  self.WORLD_WIDGETS[3] = { name = "Item3D" }
  self.WORLD_WIDGETS[4] = { name = "OBJModel3D" }
  self.WORLD_WIDGETS[5] = { name = "Text3D" }
end

function openglasses:addToWorld(group, name)	
	i = #self.WORLD_WIDGETS + 1
	g = require("component").glasses
	
	if name == "Cube3D" then
		self.widgets_world[i] = g.addCube3D()
		self.widgets_world[i].addColor(1, 0, 0, 0.8)
		self.widgets_world[i].addColor(1, 0, 0, 0.1)		
		self.widgets_world[i].setCondition(2, "OVERLAY_ACTIVE", true)
		self.widgets_world[i].addTranslation(-0.05, -0.05, -0.05)
		self.widgets_world[i].addScale(1.1, 1.1, 1.1)		
	elseif name == "Text3D" then
		self.widgets_world[i] = g.addText2D()
		self.widgets_world[i].addColor(1, 0, 0, 0.8)
		self.widgets_world[i].addColor(1, 0, 0, 0.1)
		self.widgets_world[i].setCondition(2, "OVERLAY_ACTIVE", true)
		self.widgets_world[i].addColor(0, 0, 1, 1)
		self.widgets_world[i].setCondition(3, "IS_SWIMMING", true)
		self.widgets_world[i].addColor(0, 1, 1, 0.8)
		self.widgets_world[i].setCondition(4, "IS_WEATHER_RAIN", true)
		self.widgets_world[i].addColor(1, 1, 1, 0.5)
		self.widgets_world[i].setCondition(5, "IS_SNEAKING", true)
		self.widgets_world[i].setText("Hello World!")
	elseif name == "Item3D" then
		self.widgets_world[i] = g.addItem3D()		
		self.widgets_world[i].setItem("minecraft:diamond_helmet", 0)
		self.widgets_world[i].setFaceWidgetToPlayer(true)
	elseif name == "Custom3D" then
		self.widgets_world[i] = g.addCustom3D()		
	elseif name == "OBJModel3D" then
		self.widgets_world[i] = g.addOBJModel3D()		
	else
		print("invalid widget name: '"..name.."'")
		return nil
	end
	self.widgets_world[i].addTranslation(0, 2, 0)	
	self.widgets_world[i].group = group
	return self.widgets_world[i]	
end	

function openglasses:addToOverlay(group, name)
	i = #self.widgets_overlay + 1
	g = require("component").glasses
	
	if name == "Box2D" then
		self.widgets_overlay[i] = g.addBox2D()
		self.widgets_overlay[i].setSize(80, 40)
		self.widgets_overlay[i].addColor(1, 1, 1, 0.5)
	elseif name == "Text2D" then
		self.widgets_overlay[i] = g.addText2D()
		self.widgets_overlay[i].setText("Hello World!")
	elseif name == "Item2D" then
		self.widgets_overlay[i] = g.addItem2D()
		self.widgets_overlay[i].setItem("minecraft:diamond_helmet", 0)
	elseif name == "Custom2D" then
		self.widgets_overlay[i] = g.addCustom2D()		
	elseif name == "OBJModel2D" then
		self.widgets_overlay[i] = g.addOBJModel2D()		
	else
		print("invalid widget name: '"..name.."'")
		return nil
	end	
		
	self.widgets_overlay[i].group = group
	return self.widgets_overlay[i]
end	

openglasses:init()

return openglasses
