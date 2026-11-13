class_name Forms
extends RefCounted
## Original shared rounded geometry. Metres, Y-up; no imported art.
static var materials: Dictionary = {}
static var meshes: Dictionary = {}

static func channel(node: MeshInstance3D, id: String, shade: float = 1.0) -> MeshInstance3D:
	# Only explicitly opted-in surfaces become customizable. Never mutate the shared cache.
	node.material_override = node.material_override.duplicate()
	node.set_meta("style_channel",id)
	node.set_meta("style_base",node.material_override.albedo_color)
	node.set_meta("style_shade",shade)
	return node

static func finish(node: MeshInstance3D, kind: String) -> MeshInstance3D:
	var base: StandardMaterial3D = node.material_override
	var key := base.albedo_color.to_html() + kind
	if not materials.has(key):
		var m := base.duplicate() as StandardMaterial3D
		m.metallic_specular = 0.25
		match kind:
			"fabric":
				m.roughness = 0.98
				m.metallic_specular = 0.08
				m.albedo_texture = load("res://assets/textures/linen.svg")
				m.uv1_triplanar = true
				m.uv1_scale = Vector3.ONE * 6
			"wood":
				m.roughness = 0.65
				m.albedo_texture = load("res://assets/textures/ash_wood.svg")
				m.uv1_triplanar = true
				m.uv1_scale = Vector3.ONE * 0.7
			"ceramic": m.roughness = 0.24
			"brass":
				m.roughness = 0.35
				m.metallic = 0.55
			"skin":
				m.roughness = 0.72
				m.metallic_specular = 0.12
			"hair":
				m.roughness = 0.46
				m.metallic_specular = 0.35
		materials[key] = m
	node.material_override = materials[key]
	return node

static func picture(parent: Node3D, pos: Vector3, size: Vector2, texture_path: String) -> MeshInstance3D:
	var q := QuadMesh.new()
	q.size = size
	var n := mesh(parent,q,pos,"ffffff")
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(texture_path)
	m.roughness = 1
	m.metallic_specular = 0
	n.material_override = m
	return n

static func material(hex: String, roughness: float = 0.8) -> StandardMaterial3D:
	var key := hex + str(roughness)
	if materials.has(key): return materials[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(hex)
	m.roughness = roughness
	materials[key] = m
	return m

static func mesh(parent: Node3D, shape: Mesh, pos: Vector3, hex: String) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = shape
	n.material_override = material(hex)
	n.position = pos
	parent.add_child(n)
	return n

static func box(parent: Node3D, pos: Vector3, size: Vector3, hex: String, radius: float = 0.04) -> MeshInstance3D:
	var key := str(size) + str(radius)
	if not meshes.has(key):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var half := size * 0.5
		var r := minf(radius, minf(half.x, minf(half.y, half.z)) * 0.95)
		var inner := half - Vector3.ONE * r
		for axis in range(3):
			for sign_value in [-1.0, 1.0]:
				var u := (axis + 1) % 3
				var v := (axis + 2) % 3
				var us := [-half[u],-inner[u]-r*0.7,-inner[u]-r*0.3,-inner[u],0.0,inner[u],inner[u]+r*0.3,inner[u]+r*0.7,half[u]]
				var vs := [-half[v],-inner[v]-r*0.7,-inner[v]-r*0.3,-inner[v],0.0,inner[v],inner[v]+r*0.3,inner[v]+r*0.7,half[v]]
				for a in range(8):
					for b in range(8):
						var corners: Array[Vector2] = [Vector2(a,b),Vector2(a+1,b),Vector2(a+1,b+1),Vector2(a,b),Vector2(a+1,b+1),Vector2(a,b+1)]
						if sign_value > 0: corners.reverse()
						for c in corners:
							var p := Vector3.ZERO
							p[axis] = half[axis] * sign_value
							p[u] = us[int(c.x)]
							p[v] = vs[int(c.y)]
							var q := p.clamp(-inner, inner)
							var normal := (p-q).normalized()
							st.set_normal(normal)
							st.add_vertex(q + normal * r)
		meshes[key] = st.commit()
	return mesh(parent, meshes[key], pos, hex)

static func ball(parent: Node3D, pos: Vector3, size: Vector3, hex: String) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radial_segments = 24
	s.rings = 12
	s.radius = 0.5
	s.height = 1.0
	var n := mesh(parent, s, pos, hex)
	n.scale = size
	return n

static func cylinder(parent: Node3D, pos: Vector3, bottom: float, top: float, height: float, hex: String) -> MeshInstance3D:
	var c := CylinderMesh.new()
	c.bottom_radius = bottom
	c.top_radius = top
	c.height = height
	c.radial_segments = 32
	return mesh(parent, c, pos, hex)

static func solid(parent: Node3D, pos: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
	return body

static func rod(parent: Node3D, a: Vector3, b: Vector3, radius: float, hex: String) -> void:
	var n := cylinder(parent,(a+b)*0.5,radius,radius,a.distance_to(b),hex)
	var direction := (b-a).normalized()
	if absf(direction.dot(Vector3.UP)) < 0.999:
		n.quaternion = Quaternion(Vector3.UP,direction)

static func lathe(parent: Node3D, pos: Vector3, profile: Array[Vector2], hex: String) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(profile.size()-1):
		for i in range(40):
			for c in [Vector2(i,row),Vector2(i+1,row),Vector2(i+1,row+1),Vector2(i,row),Vector2(i+1,row+1),Vector2(i,row+1)]:
				var a: float = c.x*TAU/40.0
				var p := profile[int(c.y)]
				st.add_vertex(Vector3(cos(a)*p.x,p.y,sin(a)*p.x))
	st.generate_normals()
	return mesh(parent,st.commit(),pos,hex)

static func leaf(parent: Node3D, pos: Vector3, length: float, width: float, angles: Vector3, hex: String) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(8):
		for side in [-1.0,1.0]:
			for c in [Vector2(i,0),Vector2(i+1,side),Vector2(i,side),Vector2(i,0),Vector2(i+1,0),Vector2(i+1,side)]:
				var t: float = c.x/8.0
				st.add_vertex(Vector3(sin(PI*t)*width*c.y,length*t,sin(PI*t)*length*0.19*(1-absf(c.y)*0.6)))
	st.generate_normals()
	var n := mesh(parent,st.commit(),pos,hex)
	n.rotation = angles
	var m := material(hex).duplicate() as StandardMaterial3D
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.roughness = 0.75
	n.material_override = m
	return n
