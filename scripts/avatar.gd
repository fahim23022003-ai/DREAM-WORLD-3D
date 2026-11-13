extends Node3D
## Swappable original sculpted bob, layered pinafore and articulated doll limbs.
const F = preload("res://scripts/forms.gd")
var body: Node3D
var head: Node3D
var skirt: Node3D
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var clock := 0.0
var idle_clock := 0.0
var sit_blend := 0.0
var gait := 0.0
var run_blend := 0.0

func _ready() -> void:
	body = Node3D.new()
	add_child(body)
	var outfit := Node3D.new()
	outfit.name = "Outfit_PeriwinklePinafore"
	body.add_child(outfit)
	F.finish(F.ball(outfit,Vector3(0,1.07,0),Vector3(0.43,0.48,0.31),"fff1e3"),"fabric")
	F.finish(F.box(outfit,Vector3(0,1.02,0.15),Vector3(0.32,0.31,0.07),"b7c4df",0.065),"fabric")
	skirt = Node3D.new()
	skirt.name = "Skirt"
	skirt.position.y = 0.98
	outfit.add_child(skirt)
	F.finish(F.lathe(skirt,Vector3.ZERO,[Vector2(0.32,-0.43),Vector2(0.345,-0.4),Vector2(0.33,-0.34),Vector2(0.285,-0.18),Vector2(0.215,0.02),Vector2(0.2,0.04)],"b7c4df"),"fabric")
	F.finish(F.lathe(skirt,Vector3.ZERO,[Vector2(0.324,-0.43),Vector2(0.347,-0.4),Vector2(0.345,-0.375)],"e8e5f0"),"fabric")
	for x in [-0.11,0.11]:
		F.finish(F.box(outfit,Vector3(x,1.17,0.12),Vector3(0.05,0.28,0.045),"a2b2d2",0.02),"fabric")
		F.finish(F.ball(outfit,Vector3(x,1.08,0.197),Vector3.ONE*0.038,"d7bc87"),"brass")
	for x in [-0.055,0.055]:
		var collar := F.ball(outfit,Vector3(x,1.225,0.14),Vector3(0.14,0.1,0.06),"fff9ee")
		collar.rotation.z = x*3
	F.finish(F.box(outfit,Vector3(0,0.982,0.197),Vector3(0.15,0.12,0.02),"c6cfe5",0.035),"fabric")
	for i in range(5): F.ball(outfit,Vector3(cos(i*TAU/5)*0.026,0.99+sin(i*TAU/5)*0.026,0.212),Vector3(0.033,0.033,0.008),"fff6df")
	F.ball(outfit,Vector3(0,0.99,0.22),Vector3(0.023,0.023,0.008),"d9b77b")
	F.finish(F.ball(body,Vector3(0,1.3,0),Vector3(0.16,0.22,0.16),"edc6b0"),"skin")
	head = Node3D.new()
	head.name = "Head"
	head.position.y = 1.62
	body.add_child(head)
	F.finish(F.ball(head,Vector3(0,-0.025,0.015),Vector3(0.65,0.63,0.57),"f4cfb8"),"skin")
	for x in [-0.32,0.32]:
		F.finish(F.ball(head,Vector3(x,-0.025,0.015),Vector3(0.12,0.16,0.1),"efbfa9"),"skin")
		F.ball(head,Vector3(x,-0.07,0.067),Vector3.ONE*0.027,"dcc093")
	var hair := Node3D.new()
	hair.name = "Hair_ChestnutBob"
	head.add_child(hair)
	F.finish(F.ball(hair,Vector3(0,0.045,-0.095),Vector3(0.73,0.67,0.58),"77574f"),"hair")
	F.finish(F.ball(head,Vector3(0,-0.055,0.105),Vector3(0.59,0.5,0.455),"f4cfb8"),"skin")
	for i in range(5):
		var x := -0.225+i*0.108
		var fall := 0.035+absf(i-2)*0.025
		lock(hair,[Vector3(x-0.07,0.3,0.13),Vector3(x-0.03,0.27,0.25),Vector3(x+0.015,0.18,0.303),Vector3(x+0.03,fall,0.31)],"886356" if i%2==0 else "805c52",0.105)
	for side in [-1,1]:
		lock(hair,[Vector3(side*0.25,0.24,0.08),Vector3(side*0.323,0.06,0.13),Vector3(side*0.325,-0.17,0.1),Vector3(side*0.26,-0.28,0.06)],"77574f",0.095)
	for x in [-0.118,0.118]:
		F.ball(head,Vector3(x,-0.034,0.327),Vector3(0.088,0.106,0.018),"fff8ed")
		F.ball(head,Vector3(x,-0.038,0.342),Vector3(0.061,0.083,0.014),"6f554b")
		F.ball(head,Vector3(x,-0.042,0.352),Vector3(0.033,0.057,0.01),"433e40")
		F.ball(head,Vector3(x-0.013,-0.017,0.36),Vector3(0.022,0.027,0.009),"fff9f1")
		F.ball(head,Vector3(x+0.014,-0.062,0.361),Vector3(0.01,0.012,0.007),"e7c795")
		F.rod(head,Vector3(x-0.037,0.052,0.31),Vector3(x+0.025,0.064,0.312),0.011,"8b6658")
		F.ball(head,Vector3(x*1.62,-0.115,0.302),Vector3(0.095,0.043,0.012),"ebb2ad")
	F.finish(F.ball(head,Vector3(0,-0.096,0.344),Vector3(0.044,0.035,0.033),"e8b9a0"),"skin")
	for i in range(5):
		var a := Vector3(-0.032+i*0.013,-0.151-0.013*sin(i*PI/4),0.328)
		var b := Vector3(-0.032+(i+1)*0.013,-0.151-0.013*sin((i+1)*PI/4),0.328)
		F.rod(head,a,b,0.005,"a67671")
	for x in [-0.06,0.06]:
		var bow := F.ball(hair,Vector3(0.305+x,0.19,0.13),Vector3(0.15,0.12,0.075),"d9cade")
		bow.rotation.z = x*5
	F.ball(hair,Vector3(0.305,0.19,0.17),Vector3.ONE*0.06,"eee3eb")
	for side in [-1,1]:
		var ribbon := F.box(hair,Vector3(0.3+side*0.035,0.11,0.13),Vector3(0.048,0.12,0.022),"d9cade",0.01)
		ribbon.rotation.z = side*0.25
	left_leg = limb(Vector3(-0.13,0.59,0),true)
	right_leg = limb(Vector3(0.13,0.59,0),true)
	left_arm = limb(Vector3(-0.27,1.17,0),false)
	right_arm = limb(Vector3(0.27,1.17,0),false)

func lock(parent: Node3D, points: Array[Vector3], color: String, width: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var widths := [width*0.2,width,width*0.92,0.005]
	var centers: Array[Vector3] = []
	var radii: Array[float] = []
	for ring in range(13):
		var segment := mini(ring/4,2)
		var t := (ring-segment*4)/4.0
		centers.append(points[segment].cubic_interpolate(points[segment+1],points[maxi(0,segment-1)],points[mini(3,segment+2)],t))
		radii.append(lerpf(widths[segment],widths[segment+1],smoothstep(0,1,t)))
	for row in range(12):
		for i in range(20):
			for c in [Vector2(i,row),Vector2(i+1,row+1),Vector2(i+1,row),Vector2(i,row),Vector2(i,row+1),Vector2(i+1,row+1)]:
				var a: float = c.x*TAU/20
				var ring := int(c.y)
				st.add_vertex(centers[ring]+Vector3(cos(a)*radii[ring],0,sin(a)*radii[ring]*0.6))
	st.generate_normals()
	F.finish(F.mesh(parent,st.commit(),Vector3.ZERO,color),"hair")

func limb(pos: Vector3, leg: bool) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pos
	body.add_child(pivot)
	if leg:
		F.finish(F.ball(pivot,Vector3(0,-0.15,0),Vector3(0.15,0.32,0.16),"f1cfb9"),"skin")
		var knee := Node3D.new()
		knee.name = "Knee"
		knee.position.y = -0.27
		pivot.add_child(knee)
		F.finish(F.ball(knee,Vector3(0,-0.075,0),Vector3(0.145,0.22,0.15),"f1cfb9"),"skin")
		F.finish(F.cylinder(knee,Vector3(0,-0.09,0),0.077,0.079,0.15,"fff2e6"),"fabric")
		F.cylinder(knee,Vector3(0,-0.02,0),0.081,0.081,0.035,"e6ddeb")
		F.box(knee,Vector3(0,-0.2,0.055),Vector3(0.2,0.15,0.32),"8c7069",0.065)
		F.box(knee,Vector3(0,-0.267,0.055),Vector3(0.21,0.028,0.33),"d4c0ad",0.013)
		F.box(knee,Vector3(0,-0.13,0.064),Vector3(0.2,0.035,0.046),"6f5a56",0.015)
		F.finish(F.ball(knee,Vector3(0.073,-0.13,0.09),Vector3(0.028,0.028,0.02),"d7bc87"),"brass")
	else:
		F.finish(F.ball(pivot,Vector3(0,-0.07,0),Vector3(0.2,0.24,0.23),"fff1e3"),"fabric")
		F.finish(F.ball(pivot,Vector3(0,-0.25,0),Vector3(0.115,0.29,0.13),"f4cfb8"),"skin")
		F.finish(F.cylinder(pivot,Vector3(0,-0.16,0),0.074,0.078,0.055,"f0e0dd"),"fabric")
		F.finish(F.ball(pivot,Vector3(0,-0.375,0.01),Vector3(0.13,0.155,0.14),"f4cfb8"),"skin")
	return pivot

func animate(delta: float, speed: float, running: bool, seated: bool) -> void:
	idle_clock += delta
	clock += delta*speed/0.22
	sit_blend = move_toward(sit_blend,1.0 if seated else 0.0,delta*4)
	gait = lerpf(gait,minf(speed/2.3,1.0)*(1-sit_blend),1-exp(-10*delta))
	run_blend = lerpf(run_blend,1.0 if running and speed>2.5 else 0.0,1-exp(-8*delta))
	var amplitude := lerpf(0.66,0.88,run_blend)
	left_leg.rotation.x = sin(clock)*amplitude*gait - sit_blend*1.48
	right_leg.rotation.x = -sin(clock)*amplitude*gait - sit_blend*1.48
	left_leg.get_node("Knee").rotation.x = maxf(0,-sin(clock))*0.7*gait + sit_blend*0.92
	right_leg.get_node("Knee").rotation.x = maxf(0,sin(clock))*0.7*gait + sit_blend*0.92
	left_arm.rotation.x = -sin(clock)*0.55*gait - sit_blend*0.38
	right_arm.rotation.x = sin(clock)*0.55*gait - sit_blend*0.38
	left_arm.rotation.z = 0.06 + sin(idle_clock*1.6)*0.018
	right_arm.rotation.z = -0.06 - sin(idle_clock*1.6)*0.018
	body.position.y = -absf(sin(clock))*0.018*gait + sin(idle_clock*2)*0.005*(1-gait)
	body.rotation.x = lerpf(body.rotation.x,-0.09*run_blend*gait,1-exp(-10*delta))
	skirt.rotation.x = -sit_blend*0.8
	head.rotation.z = sin(idle_clock*1.5)*0.018*(1-gait)
