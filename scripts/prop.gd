extends Node3D
## Small reusable catalogue. Each object is original geometry in a coherent palette.
@export_enum("sofa", "table", "plant", "shelf", "lamp", "ottoman") var kind := "plant"
const F = preload("res://scripts/forms.gd")

func _ready() -> void:
	call(kind)

func sofa() -> void:
	for x in [-1.48, 1.48]:
		for z in [-0.43, 0.43]: F.finish(F.cylinder(self,Vector3(x,0.16,z),0.065,0.045,0.32,"ba987d"),"wood")
	F.box(self,Vector3(0,0.42,0),Vector3(3.65,0.44,1.28),"d28e9c",0.19)
	F.box(self,Vector3(0,1.02,-0.46),Vector3(3.5,1.04,0.36),"edb0b9",0.17)
	for x in [-1.7,1.7]: F.box(self,Vector3(x,0.83,0.04),Vector3(0.36,0.78,1.32),"e7a2af",0.17)
	for x in [-1.08,0.0,1.08]:
		F.channel(F.box(self,Vector3(x,0.71,0.12),Vector3(1.02,0.24,0.98),"f4c4c8",0.11),"decor.cushions")
		F.channel(F.box(self,Vector3(x,1.1,-0.23),Vector3(1.02,0.72,0.27),"f1bdc5",0.13),"decor.cushions")
		# Tailored cushion piping and hand-covered buttons.
		F.channel(F.box(self,Vector3(x,0.687,0.125),Vector3(1.025,0.026,0.98),"e5aebb",0.012),"decor.cushions")
		for bx in [-0.25,0.25]: F.channel(F.ball(self,Vector3(x+bx,1.18,-0.078),Vector3(0.043,0.043,0.02),"d79ba9"),"decor.cushions")
	for x in [-1.19,1.17]:
		var pillow := F.channel(F.box(self,Vector3(x,1.06,0.12),Vector3(0.56,0.56,0.2),"d7c9e5" if x < 0 else "bdd6cb",0.13),"decor.cushions")
		pillow.rotation.z = -0.18 if x < 0 else 0.2
	# Cream knitted throw drapes over one arm rather than floating above it.
	F.box(self,Vector3(-1.69,1.23,0.17),Vector3(0.41,0.035,0.7),"eee7d9",0.016)
	F.box(self,Vector3(-1.9,0.9,0.17),Vector3(0.035,0.68,0.7),"eee7d9",0.016)
	for i in range(7): F.rod(self,Vector3(-1.91,0.56,-0.1+i*0.09),Vector3(-1.91,0.48,-0.1+i*0.09),0.012,"eee7d9")
	for child in get_children():
		if child is MeshInstance3D and child.position.y>0.3:
			F.finish(child,"fabric")
			if child.has_meta("style_channel"): child.material_override = child.material_override.duplicate()
	F.solid(self,Vector3(0,0.62,0),Vector3(3.9,1.24,1.3))

func table() -> void:
	for x in [-0.7,0.7]:
		for z in [-0.35,0.35]: F.rod(self,Vector3(x*1.1,0.06,z*1.1),Vector3(x,0.65,z),0.055,"b28d6b")
	F.finish(F.box(self,Vector3(0,0.24,0),Vector3(1.56,0.08,0.79),"d9c4ab",0.038),"wood")
	F.finish(F.box(self,Vector3(0,0.65,0),Vector3(2.05,0.16,1.16),"d9bda0",0.075),"wood")
	F.finish(F.box(self,Vector3(0,0.738,0),Vector3(1.99,0.025,1.1),"ecdbc3",0.012),"wood")
	F.box(self,Vector3(-0.48,0.78,0.12),Vector3(0.55,0.07,0.39),"84a99e")
	F.box(self,Vector3(-0.45,0.83,0.1),Vector3(0.48,0.04,0.34),"f4ead8")
	F.cylinder(self,Vector3(0.35,0.77,-0.1),0.29,0.29,0.035,"d8a783")
	F.cylinder(self,Vector3(0.4,0.88,-0.1),0.085,0.105,0.17,"ffeddb")
	F.cylinder(self,Vector3(0.4,0.967,-0.1),0.083,0.083,0.005,"795b48")
	var handle := TorusMesh.new()
	handle.inner_radius = 0.043
	handle.outer_radius = 0.066
	var h := F.mesh(self,handle,Vector3(0.5,0.89,-0.1),"ffeddb")
	h.rotation.x = PI/2
	F.finish(h,"ceramic")
	F.finish(F.lathe(self,Vector3(0.68,0.75,0.22),[Vector2(0.06,0),Vector2(0.09,0.04),Vector2(0.085,0.13),Vector2(0.03,0.18),Vector2(0.028,0.25)],"d6b9c5"),"ceramic")
	for i in range(3):
		F.rod(self,Vector3(0.68,0.95,0.22),Vector3(0.65+i*0.04,1.16+i*0.02,0.22),0.007,"899c7d")
		F.ball(self,Vector3(0.65+i*0.04,1.16+i*0.02,0.22),Vector3(0.1,0.075,0.1),"fff1d9")
	F.solid(self,Vector3(0,0.36,0),Vector3(2.05,0.72,1.16))

func plant() -> void:
	F.finish(F.lathe(self,Vector3.ZERO,[Vector2(0,0.01),Vector2(0.21,0.01),Vector2(0.23,0.06),Vector2(0.27,0.4),Vector2(0.29,0.44),Vector2(0.29,0.49),Vector2(0.26,0.49),Vector2(0.25,0.44)],"e9dfd3"),"ceramic")
	F.cylinder(self,Vector3(0,0.525,0),0.26,0.26,0.01,"74654b")
	for i in range(9):
		var angle := i*2.399
		var h := 0.72 + (i%3)*0.27
		var end := Vector3(cos(angle)*0.3,h,sin(angle)*0.3)
		F.rod(self,Vector3(0,0.5,0),end,0.016,"6c8c65")
		F.leaf(self,end-Vector3(0,0.08,0),0.46+(i%2)*0.12,0.13,Vector3(0.45,angle,-0.6),"89ac9a" if i%2 == 0 else "b0c8aa")

func shelf() -> void:
	F.box(self,Vector3(0,1.27,-0.21),Vector3(2.03,2.47,0.08),"bdcfd2",0.035)
	for x in [-0.97,0.97]: F.box(self,Vector3(x,1.24,0),Vector3(0.13,2.48,0.49),"d4e1df",0.05)
	for y in [0.18,0.9,1.62,2.34]: F.finish(F.box(self,Vector3(0,y,0),Vector3(2.08,0.11,0.55),"eadcc7",0.045),"wood")
	F.box(self,Vector3(0,2.48,-0.01),Vector3(2.13,0.16,0.57),"d4e1df",0.075)
	var colors := ["dab2be","9dbeb5","f1d6a1","b8accb","e7b49b"]
	for i in range(5):
		F.box(self,Vector3(-0.7+i*0.16,1.17,-0.01),Vector3(0.12,0.46+(i%2)*0.07,0.32),colors[i],0.015)
		F.box(self,Vector3(-0.7+i*0.16,1.07,0.157),Vector3(0.085,0.025,0.01),"fff2d9",0.002)
	F.ball(self,Vector3(0.5,1.85,0),Vector3(0.4,0.42,0.37),"e3a597")
	F.cylinder(self,Vector3(0.5,2.08,0),0.1,0.11,0.15,"e3a597")
	F.box(self,Vector3(-0.43,1.97,0.06),Vector3(0.48,0.55,0.07),"fff0d8")
	F.box(self,Vector3(-0.43,1.97,0.103),Vector3(0.36,0.43,0.01),"b4c3b0")
	F.ball(self,Vector3(-0.43,1.98,0.115),Vector3(0.21,0.21,0.012),"f5dbb0")
	for i in range(2): F.box(self,Vector3(0.4,0.3+i*0.12,0),Vector3(0.78,0.105,0.37),colors[i+2])
	F.finish(F.box(self,Vector3(-0.51,0.52,0.04),Vector3(0.73,0.48,0.41),"cdb7a0",0.065),"fabric")
	F.box(self,Vector3(-0.51,0.54,0.255),Vector3(0.18,0.06,0.025),"9a8675",0.02)
	F.solid(self,Vector3(0,1.25,0),Vector3(2.1,2.5,0.55))

func lamp() -> void:
	F.cylinder(self,Vector3(0,0.045,0),0.31,0.31,0.09,"c4a176")
	F.cylinder(self,Vector3(0,1.0,0),0.03,0.03,1.94,"b28b58")
	F.finish(F.lathe(self,Vector3(0,1.6,0),[Vector2(0.46,0),Vector2(0.47,0.03),Vector2(0.46,0.07),Vector2(0.31,0.53),Vector2(0.29,0.58),Vector2(0.27,0.58)],"f4e7d6"),"fabric")
	for i in range(24):
		var a := i*TAU/24
		F.rod(self,Vector3(cos(a)*0.465,1.64,sin(a)*0.465),Vector3(cos(a)*0.29,2.15,sin(a)*0.29),0.005,"ded1c1")
	F.cylinder(self,Vector3(0,1.61,0),0.46,0.46,0.035,"dbb987")
	var light := OmniLight3D.new()
	light.position = Vector3(0,1.63,0)
	light.light_color = Color("ffd5a4")
	light.light_energy = 0.12
	light.omni_range = 3.0
	add_child(light)

func ottoman() -> void:
	F.cylinder(self,Vector3(0,0.2,0),0.47,0.47,0.34,"769e94")
	F.ball(self,Vector3(0,0.46,0),Vector3(1.03,0.3,1.03),"a5c8ba")
	F.cylinder(self,Vector3(0,0.35,0),0.488,0.488,0.024,"c2dacb")
	F.ball(self,Vector3(0,0.609,0),Vector3(0.065,0.016,0.065),"7da99c")
	for child in get_children():
		if child is MeshInstance3D: F.finish(child,"fabric")
	F.solid(self,Vector3(0,0.26,0),Vector3(1,0.52,1))
