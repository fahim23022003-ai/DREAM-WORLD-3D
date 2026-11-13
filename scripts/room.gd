extends Node3D
const F = preload("res://scripts/forms.gd")
const PROP = preload("res://scenes/prop.tscn")
signal state_changed
var lamp_control: Node3D
var curtain_control: Node3D
var plant_control: Node3D
var keepsake: Node3D
var curtain_panels: Array[MeshInstance3D] = []
var curtain_ties: Array[MeshInstance3D] = []
var window_fill: OmniLight3D
var window_sky: MeshInstance3D

func prop(kind: String, pos: Vector3, angle: float = 0.0) -> Node3D:
	var p := PROP.instantiate()
	p.kind = kind
	p.position = pos
	p.rotation.y = angle
	add_child(p)
	return p

func _ready() -> void:
	F.box(self,Vector3(0,-0.17,0),Vector3(12.3,0.3,10.3),"c6ac91")
	F.solid(self,Vector3(0,-0.18,0),Vector3(12.3,0.36,10.3))
	for row in range(20):
		for col in range(6):
			var x := -5.0+col*2.0
			F.finish(F.box(self,Vector3(x,0.006,-4.75+row*0.5),Vector3(1.985,0.025,0.485),["e8dfd4","e2d6c5","ece2d6","e0d3c0"][(row*3+col)%4],0.007),"wood")
	# Back wall with a real opening for the large window.
	wall(Vector3(-3.55,1.9,-5),Vector3(4.9,3.8,0.2))
	wall(Vector3(5.05,1.9,-5),Vector3(1.9,3.8,0.2))
	wall(Vector3(1.5,0.48,-5),Vector3(5.2,0.96,0.2))
	wall(Vector3(1.5,3.5,-5),Vector3(5.2,0.6,0.2))
	wall(Vector3(-6,1.9,0),Vector3(0.2,3.8,10))
	wall(Vector3(6,1.9,-1.2),Vector3(0.2,3.8,7.6))
	wall(Vector3(6,1.9,4.85),Vector3(0.2,3.8,0.3))
	wall(Vector3(6,3.3,3.65),Vector3(0.2,1,2.1))
	# Cream jambs make the new garden entrance read as part of the house.
	for z in [2.55,4.75]: F.box(self,Vector3(5.91,1.4,z),Vector3(0.26,2.8,0.12),"fff0dc")
	F.box(self,Vector3(5.91,2.84,3.65),Vector3(0.26,0.16,2.3),"fff0dc")
	F.finish(F.box(self,Vector3(6.0,0.02,3.65),Vector3(0.4,0.03,2.0),"d6bfa0"),"wood")
	# Two genuine 2.2m doorways lead into the kitchen and bedroom.
	wall(Vector3(-5.05,1.9,5),Vector3(1.9,3.8,0.2))
	wall(Vector3(0,1.9,5),Vector3(3.8,3.8,0.2))
	wall(Vector3(5.05,1.9,5),Vector3(1.9,3.8,0.2))
	wall(Vector3(0,3.3,5),Vector3(12,1.0,0.2))
	# Painted lower panels bring mint and lavender into the architectural palette.
	F.box(self,Vector3(0,0.58,-4.865),Vector3(11.85,0.9,0.035),"d9e5df",0.015)
	for x in [-5.87,5.87]:
		for segment in ([[0.0,9.8]] if x<0 else [[-1.2,7.6],[4.85,0.3]]):
			F.box(self,Vector3(x,0.58,segment[0]),Vector3(0.035,0.9,segment[1]),"d9e5df",0.015)
	for x in [-5.87,5.87]:
		for segment in ([[0.0,9.9]] if x<0 else [[-1.2,7.6],[4.85,0.3]]):
			F.box(self,Vector3(x,0.15,segment[0]),Vector3(0.08,0.3,segment[1]),"fff0dc")
			F.box(self,Vector3(x,1.05,segment[0]),Vector3(0.07,0.05,segment[1]),"e3d5c1")
	F.box(self,Vector3(0,0.15,-4.86),Vector3(11.9,0.3,0.08),"fff0dc")
	# Shallow wainscot panels and a cornice give the shell a finished silhouette.
	for x in [-5.3,-4.0,-2.7,-1.4,0.0,1.4,2.8,4.2,5.4]:
		F.box(self,Vector3(x,0.61,-4.87),Vector3(0.045,0.75,0.04),"e0ceba",0.01)
	F.box(self,Vector3(0,1.04,-4.85),Vector3(11.9,0.065,0.09),"e4d0b7")
	F.box(self,Vector3(0,3.65,-4.82),Vector3(11.9,0.15,0.18),"fff1de")
	window()
	# Layered woven rug with stitched border, petal motif and tassels.
	F.box(self,Vector3(0,0.043,-0.5),Vector3(5.5,0.035,4.2),"b9c5bb",0.016)
	F.box(self,Vector3(0,0.064,-0.5),Vector3(5.24,0.012,3.94),"eee2cc",0.005)
	var rug := F.picture(self,Vector3(0,0.083,-0.5),Vector2(5.24,3.94),"res://assets/textures/rug.svg")
	rug.rotation.x = -PI/2
	F.channel(rug,"decor.rug")
	for i in range(17):
		for z in [-2.7,1.7]: F.rod(self,Vector3(-2.5+i*0.31,0.045,z),Vector3(-2.5+i*0.31,0.045,z+(-0.12 if z<0 else 0.12)),0.012,"f5ead9")
	prop("sofa",Vector3(0,0,-3.25))
	prop("table",Vector3(0,0,-0.8))
	var cards := preload("res://scripts/card_box.gd").new()
	cards.position = Vector3(0,0.835,-0.4)
	add_child(cards)
	prop("shelf",Vector3(-4.65,0,-4.52))
	var floor_lamp := prop("lamp",Vector3(2.55,0,-3.55))
	prop("plant",Vector3(4.85,0,-3.85)).scale = Vector3.ONE*1.6
	var chosen_plant := prop("plant",Vector3(-3,0,-3.9))
	prop("ottoman",Vector3(3.5,0,0.3))
	# Console and framed botanical print on the left wall.
	F.box(self,Vector3(-5.52,0.79,0.0),Vector3(0.65,0.16,2.5),"d7b389",0.07)
	for z in [-1,1]:
		F.box(self,Vector3(-5.55,0.39,z),Vector3(0.12,0.77,0.12),"c59e76")
	var little_plant := prop("plant",Vector3(-5.5,0.88,-0.7))
	little_plant.scale = Vector3.ONE*0.6
	F.box(self,Vector3(-5.84,2.05,0),Vector3(0.09,1.6,1.2),"c89a70",0.025)
	F.box(self,Vector3(-5.78,2.05,0),Vector3(0.025,1.42,1.02),"fff0d4",0.01)
	for i in range(5):
		var leaf := F.ball(self,Vector3(-5.755,1.7+i*0.15,0.13*sin(i*2)),Vector3(0.015,0.31,0.2),"8da58e")
		leaf.rotation.x = i*0.7
	F.solid(self,Vector3(-5.5,0.5,0),Vector3(0.9,1,2.6))
	# Original art lives on the wall, leaving the daylight opening unobstructed.
	F.finish(F.box(self,Vector3(-2.66,2.43,-4.85),Vector3(1.28,1.55,0.1),"c5aa8f",0.04),"wood")
	F.box(self,Vector3(-2.66,2.43,-4.78),Vector3(1.15,1.42,0.03),"fff7ed",0.01)
	F.picture(self,Vector3(-2.66,2.43,-4.755),Vector2(0.98,1.23),"res://assets/textures/meadow_print.svg")
	# Two slim drawer fronts and satin brass handles finish the existing console.
	for z in [-0.56,0.56]:
		F.box(self,Vector3(-5.17,0.66,z),Vector3(0.05,0.2,1.01),"d6c9de",0.025)
		F.finish(F.ball(self,Vector3(-5.127,0.66,z),Vector3(0.06,0.05,0.12),"c9aa77"),"brass")
	# A small side table and flower arrangement balance the tall foliage.
	F.finish(F.cylinder(self,Vector3(3.7,0.63,-2.4),0.4,0.4,0.08,"e8d8c2"),"wood")
	for x in [-0.23,0.23]:
		for z in [-0.23,0.23]: F.rod(self,Vector3(3.7+x,0.05,-2.4+z),Vector3(3.7+x*0.8,0.61,-2.4+z*0.8),0.025,"c7aa88")
	F.finish(F.lathe(self,Vector3(3.7,0.68,-2.4),[Vector2(0.08,0),Vector2(0.14,0.08),Vector2(0.13,0.2),Vector2(0.055,0.28),Vector2(0.06,0.32)],"b9cddd"),"ceramic")
	for i in range(5):
		var end := Vector3(3.7+cos(i*2.4)*0.15,1.2+(i%2)*0.09,-2.4+sin(i*2.4)*0.12)
		F.rod(self,Vector3(3.7,0.96,-2.4),end,0.008,"8fa690")
		for petal in range(5):
			F.ball(self,end+Vector3(cos(petal*TAU/5)*0.055,0,sin(petal*TAU/5)*0.055),Vector3(0.08,0.05,0.08),"edd7e3")
		F.ball(self,end,Vector3.ONE*0.045,"e2c991")
	var seat := preload("res://scenes/sofa_interaction.tscn").instantiate()
	seat.position = Vector3(0,0,-3.25)
	add_child(seat)
	lighting()
	lamp_control=preload("res://scripts/lamp_control.gd").new()
	floor_lamp.add_child(lamp_control)
	lamp_control.bind(floor_lamp.lamp_shade,floor_lamp.lamp_light)
	curtain_control=preload("res://scripts/curtain_control.gd").new()
	curtain_control.position=Vector3(3.9,0,-4.3)
	add_child(curtain_control)
	curtain_control.bind(curtain_panels,curtain_ties,window_fill)
	plant_control=preload("res://scripts/plant_control.gd").new()
	chosen_plant.add_child(plant_control)
	plant_control.bind(chosen_plant.plant_leaves)
	for control in [lamp_control,curtain_control]:
		control.changed.connect(func(): state_changed.emit())
		control.settled.connect(func(): state_changed.emit())
	keepsake=preload("res://scripts/cozy_keepsake.gd").new()
	keepsake.position=Vector3(-4.65,2.56,-4.47)
	add_child(keepsake)
	keepsake.hide()

func wall(pos: Vector3, size: Vector3) -> void:
	F.box(self,pos,size,"f2e9e7",0.015)
	F.solid(self,pos,size)

func window() -> void:
	# Opaque sky panel beyond the opening; garden forms create parallax depth.
	var sky := F.box(self,Vector3(1.5,2.08,-5.3),Vector3(5.25,2.3,0.05),"cde6ed",0.01)
	window_sky=sky
	var sky_material := F.material("cde6ed").duplicate() as StandardMaterial3D
	sky_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sky.material_override = sky_material
	sky.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in range(6): F.ball(self,Vector3(-0.7+i*0.9,1.0,-5.15),Vector3(1.6,0.9+(i%2)*0.5,0.12),"a1bfa6")
	for x in [-1.1,1.5,4.1]: F.box(self,Vector3(x,2.1,-4.92),Vector3(0.1,2.35,0.18),"fff4df")
	for y in [0.96,2.1,3.23]: F.box(self,Vector3(1.5,y,-4.91),Vector3(5.35,0.11,0.2),"fff4df")
	F.box(self,Vector3(1.5,0.91,-4.77),Vector3(5.6,0.13,0.48),"e1c8a5")
	F.rod(self,Vector3(-1.65,3.4,-4.57),Vector3(4.65,3.4,-4.57),0.035,"ad885c")
	for side in [-1,1]:
		curtain(-1.13 if side<0 else 4.12)
		curtain_ties.append(F.box(self,Vector3(-1.13 if side<0 else 4.12,1.25,-4.42),Vector3(0.95,0.09,0.12),"d2a66f"))
	# Window collision remains even across the opening.
	F.solid(self,Vector3(1.5,2.1,-5),Vector3(5.2,2.3,0.15))
	var glass := F.picture(self,Vector3(1.5,2.08,-4.97),Vector2(5.1,2.2),"res://assets/textures/linen.svg")
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.8,0.93,0.98,0.055)
	gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.roughness = 0.08
	glass.material_override = gm
	glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func curtain(center: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var closed_st := SurfaceTool.new()
	closed_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(30):
		for y in range(16):
			for p in [Vector2(x,y),Vector2(x+1,y+1),Vector2(x+1,y),Vector2(x,y),Vector2(x,y+1),Vector2(x+1,y+1)]:
				var u: float = p.x/30.0
				var t: float = p.y/16.0
				var pinch := 1.0-0.4*exp(-pow((t-0.32)/0.16,2))
				st.add_vertex(Vector3(center+(u-0.5)*1.1*pinch,0.36+t*2.95,-4.53+cos(u*TAU*5)*0.075*pinch))
				var closed_x := (-1.12 if center<0 else 1.47)+u*2.65
				closed_st.add_vertex(Vector3(closed_x,0.36+t*2.95,-4.53+(0.025 if center>0 else 0.0)+cos(u*TAU*5)*0.075))
	st.generate_normals()
	closed_st.generate_normals()
	var blend_mesh := ArrayMesh.new()
	blend_mesh.blend_shape_mode=Mesh.BLEND_SHAPE_MODE_NORMALIZED
	blend_mesh.add_blend_shape("Closed")
	blend_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,st.commit().surface_get_arrays(0),[closed_st.commit().surface_get_arrays(0)])
	var n := F.finish(F.mesh(self,blend_mesh,Vector3.ZERO,"e4bfcc"),"fabric")
	var m := n.material_override.duplicate() as StandardMaterial3D
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	n.material_override = m
	F.channel(n,"decor.curtains")
	curtain_panels.append(n)

func lighting() -> void:
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("c6d9dd")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("e5e9f6")
	env.environment.ambient_light_energy = 0.48
	env.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-54,-18,0)
	sun.light_color = Color("fff1e5")
	sun.light_energy = 0.22
	sun.shadow_enabled = true
	sun.shadow_blur = 3.0
	sun.shadow_normal_bias = 0.4
	sun.directional_shadow_max_distance = 24
	add_child(sun)
	var fill := OmniLight3D.new()
	window_fill=fill
	fill.position = Vector3(1.4,3,-3.5)
	fill.light_color = Color("fff0e1")
	fill.light_energy = 0.12
	fill.omni_range = 11
	add_child(fill)

func apply_decor(data: Dictionary) -> void:
	var presets = preload("res://scripts/style_data.gd").PRESETS
	for node in find_children("*","MeshInstance3D",true,false):
		var channel: String = node.get_meta("style_channel","")
		if not channel.begins_with("decor."): continue
		var surface := channel.trim_prefix("decor.")
		var preset: String = data.get(surface,"rosewater")
		if not presets.has(preset): preset = "rosewater"
		var base: Color = node.get_meta("style_base")
		node.material_override.albedo_color = base if preset=="rosewater" else presets[preset][surface]
		node.set_meta("object_id",preload("res://scripts/style_data.gd").SURFACE_IDS[surface])

func apply_state(data: Dictionary, completed: bool) -> void:
	lamp_control.set_state(data.get("living_room.floor_lamp",true),false)
	curtain_control.set_state(data.get("living_room.curtains",false),false)
	plant_control.has_watered=data.get("living_room.houseplant",false)
	keepsake.visible=completed

func capture_state() -> Dictionary:
	return {"living_room.floor_lamp":lamp_control.on,"living_room.curtains":curtain_control.closed,"living_room.houseplant":plant_control.has_watered}

func is_cozy() -> bool:
	return lamp_control.on and curtain_control.closed and plant_control.has_watered and lamp_control.is_settled() and curtain_control.is_settled()
