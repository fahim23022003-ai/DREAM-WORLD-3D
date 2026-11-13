extends RefCounted
const F=preload("res://scripts/forms.gd")
static func tree(parent: Node3D,p: Vector3,index: int) -> void:
 var h: float=2.8+(index%3)*0.35
 F.rod(parent,p,p+Vector3(0.16,h,0),0.12,"aa927d")
 for i in range(4):
  var a: float=i*2.3+index
  var tip: Vector3=p+Vector3(sin(a)*0.85,h-0.35+i*0.24,cos(a)*0.65)
  F.rod(parent,p+Vector3(0,h*0.58,0),tip,0.055,"b69c82")
  var crown:=F.ball(parent,tip,Vector3(1.5+i%2*0.3,1.15+i%3*0.22,1.3),["a4ba9c","b6c7a5","91ae9c","b8c6ad"][(i+index)%4])
  crown.rotation=Vector3(i*0.12,a,0.16)
 F.ball(parent,p+Vector3(0.1,h+0.65,0),Vector3(1.7,1.45,1.5),"a9c0a3")
static func flower(parent: Node3D,p: Vector3,i: int) -> void:
 var h: float=0.2+(i%4)*0.09
 F.rod(parent,p,p+Vector3(0,h,0),0.009,"849f79")
 F.leaf(parent,p+Vector3(0,h*0.3,0),h*0.8,0.055,Vector3(0.3,i,0.7),"96b38b")
 for j in range(4): F.ball(parent,p+Vector3(cos(j*PI/2)*0.065,h,sin(j*PI/2)*0.065),Vector3(0.12,0.055,0.1),["e7b5c6","e7cf9c","c5b4d8"][i%3])
 F.ball(parent,p+Vector3(0,h+0.018,0),Vector3(0.05,0.04,0.05),"e1b575")
static func interiors(room: Node3D,rooms: Node3D) -> void:
 # Purposeful details stay on existing supporting surfaces and outside walking paths.
 for i in range(6):
  F.finish(F.box(room,Vector3(-5.36,0.905,-0.2+i*0.12),Vector3(0.25,0.035,0.08),["c8b5cc","e1c397","9fbeb0"][i%3]),"fabric")
 for x in [-1.45,1.45]:
  for z in [-3.7,-2.8]: F.ball(room,Vector3(x,0.025,z),Vector3(0.28,0.025,0.3),"c2b4ab")
 # Kitchen backsplash tiles and framed cabinet edges.
 for z in [9.25,11.75]:
  for j in range(5):
   F.box(rooms,Vector3(-5.875,1.38,z-0.82+j*0.4),Vector3(0.02,0.42,0.38),"e4e9df" if j%2 else "f0e4d8",0.012)
  for dz in [-0.49,0.49]:
   for dy in [-0.29,0.29]: F.box(rooms,Vector3(-4.693,0.49+dy,z+dz),Vector3(0.025,0.025,0.7),"f2e7d4",0.009)
 for i in range(3):
  var p:=Vector3(-3.65+i*0.32,1.13,13.35)
  F.finish(F.lathe(rooms,p,[Vector2(0.09,0),Vector2(0.12,0.02),Vector2(0.13,0.16),Vector2(0.1,0.19)],"d2c1d9"),"ceramic")
 # Quilt stitching follows the actual customizable quilt, including make-bed movement.
 for x in [-0.8,0,0.8]: F.box(rooms.quilt,Vector3(x,0.086,0),Vector3(0.018,0.006,2.18),"e8e4e6",0.003)
 for z in [-0.8,0,0.8]: F.box(rooms.quilt,Vector3(0,0.087,z),Vector3(2.2,0.006,0.018),"eee8e3",0.003)
 F.finish(F.box(rooms,Vector3(1.5,1.0,11.95),Vector3(0.26,0.035,0.24),"a6b9b3"),"fabric")
 F.finish(F.lathe(rooms,Vector3(1.48,1.02,11.96),[Vector2(0.045,0),Vector2(0.08,0.04),Vector2(0.065,0.16)],"e8d4d8"),"ceramic")
 for i in range(3): F.rod(rooms,Vector3(1.48,1.16,11.96),Vector3(1.4+i*0.065,1.4,11.96),0.008,"899d82")
static func batch_static(parent: Node3D,excluded: Array=[],cell_size: float=6.0) -> Dictionary:
 # Batch only direct, settled, uncustomizable meshes. All animated children remain independent.
 var groups: Dictionary={}
 for node in parent.get_children():
  if not node is MeshInstance3D or node in excluded or node.has_meta("style_channel") or not node.visible or not node.mesh or (node.mesh is ArrayMesh and node.mesh.get_blend_shape_count()>0): continue
  var key: Material=node.material_override
  if not key: continue
  if key is StandardMaterial3D and key.albedo_texture and not key.uv1_triplanar: continue
  if node.position.y<0.06: node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  var cell:=Vector3i(floori(node.position.x/cell_size),0,floori(node.position.z/cell_size)) if cell_size>0 else Vector3i.ZERO
  var bucket: String=str(key.get_instance_id())+str(cell)+str(node.cast_shadow)
  if not groups.has(bucket): groups[bucket]={"material":key,"nodes":[],"shadow":node.cast_shadow}
  groups[bucket].nodes.append(node)
 var saved:=0
 for group in groups.values():
  var material: Material=group.material
  if group.nodes.size()<3: continue
  var vertices:=PackedVector3Array();var normals:=PackedVector3Array();var indices:=PackedInt32Array()
  for node in group.nodes:
   for surface in range(node.mesh.get_surface_count()):
    var a: Array=node.mesh.surface_get_arrays(surface)
    var offset:=vertices.size()
    for i in range(a[Mesh.ARRAY_VERTEX].size()):
     vertices.append(node.transform*a[Mesh.ARRAY_VERTEX][i]);normals.append((node.basis.inverse().transposed()*a[Mesh.ARRAY_NORMAL][i]).normalized())
    if a[Mesh.ARRAY_INDEX]!=null and a[Mesh.ARRAY_INDEX].size()>0:
     for index in a[Mesh.ARRAY_INDEX]: indices.append(offset+index)
    else:
     for index in range(a[Mesh.ARRAY_VERTEX].size()): indices.append(offset+index)
   node.hide()
  var arrays: Array=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_NORMAL]=normals;arrays[Mesh.ARRAY_INDEX]=indices
  var combined:=ArrayMesh.new();combined.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
  var batch:=F.mesh(parent,combined,Vector3.ZERO,"ffffff");batch.material_override=material;batch.cast_shadow=group.shadow
  saved+=group.nodes.size()-1
 return {"saved_draws":saved}
