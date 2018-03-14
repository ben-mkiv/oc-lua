ar = {
  g = require("component").glasses,
  
  widgets_overlay = {},
  widget_overlay_cnt = 0,
  widgets_world = {},
  widget_world_cnt = 0,
  
  OVERLAY_WIDGETS = {},
  WORLD_WIDGETS = {}
}


function ar:init()
  ar.OVERLAY_WIDGETS[1] = { name = "Textlabel" }
  ar.OVERLAY_WIDGETS[2] = { name = "Item" }
  ar.OVERLAY_WIDGETS[3] = { name = "Triangle" }
  ar.OVERLAY_WIDGETS[4] = { name = "Quad" }
  ar.OVERLAY_WIDGETS[5] = { name = "Box2D" }
  ar.OVERLAY_WIDGETS[6] = { name = "Dot" }
  ar.OVERLAY_WIDGETS[7] = { name = "Square" }
  
  ar.WORLD_WIDGETS[1] = { name = "Cube3D" }
  ar.WORLD_WIDGETS[2] = { name = "FloatingText" }
  ar.WORLD_WIDGETS[3] = { name = "Triangle3D" }
  ar.WORLD_WIDGETS[4] = { name = "Quad3D" }
  ar.WORLD_WIDGETS[5] = { name = "Dot3D" }
  ar.WORLD_WIDGETS[6] = { name = "Line3D" }
  ar.WORLD_WIDGETS[7] = { name = "Item3D" }  
end


function ar:addToWorld(name)	
	if name == "Cube3D" then
		print("add to world: "..name)	
		i = ar.widget_world_cnt + 1
		ar.widgets_world[i] = require("component").glasses.addCube3D()
		ar.widgets_world[i].addColor(1, 0, 0, 0.9)
		ar.widgets_world[i].addScale(1.2, 1.2, 1.2)
		ar.widget_world_cnt = i;
		return i
	end
end	

function ar:addToOverlay(el)
	 
    return i
end	
