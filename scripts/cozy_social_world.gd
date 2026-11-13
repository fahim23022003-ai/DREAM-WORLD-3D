extends Node3D
const F=preload("res://scripts/forms.gd")
var cloth: MeshInstance3D
var tea_colors: Array[MeshInstance3D]=[]
var tea: Node3D
var picnic: Node3D
var confetti: Node3D
var memories: Dictionary={}
var clock:=0.0
var sparkle:=0.0
func chair(p: Vector3,facing: float) -> void:
 var pivot:=Node3D.new();pivot.position=p;pivot.rotation.y=facing;add_child(pivot)
 F.finish(F.box(pivot,Vector3(0,0.48,0),Vector3(0.7,0.1,0.62),"c6ad96"),"wood")
 for x in [-0.27,0.27]:
  for z in [-0.23,0.23]: F.box(pivot,Vector3(x,0.22,z),Vector3(0.07,0.44,0.07),"b39a82")
  F.box(pivot,Vector3(x,0.77,-0.25),Vector3(0.07,0.6,0.07),"b39a82")
 F.box(pivot,Vector3(0,0.92,-0.25),Vector3(0.6,0.22,0.07),"c6ad96")
 F.finish(F.box(pivot,Vector3(0,0.545,0),Vector3(0.62,0.03,0.52),"d6bdcf"),"fabric")
 F.box(pivot,Vector3(0,0.1,0.45),Vector3(0.65,0.06,0.25),"b39a82")
 for x in [-0.27,0.27]: F.rod(pivot,Vector3(x,0.18,0.23),Vector3(x,0.1,0.45),0.025,"b39a82")
func cup(parent: Node3D,p: Vector3,color: String) -> void:
 F.finish(F.cylinder(parent,p,0.15,0.15,0.018,"efddcb"),"ceramic")
 F.finish(F.lathe(parent,p+Vector3(0,0.02,0),[Vector2(0.065,0),Vector2(0.09,0.13),Vector2(0.085,0.15)],color),"ceramic")
 F.cylinder(parent,p+Vector3(0,0.165,0),0.075,0.075,0.008,"a98268")
 var shape:=TorusMesh.new();shape.inner_radius=0.036;shape.outer_radius=0.052
 var handle:=F.mesh(parent,shape,p+Vector3(0.11,0.1,0),color);handle.rotation.x=PI/2
func _ready() -> void:
 F.solid(self,Vector3(8.2,0.4,3.6),Vector3(1.3,0.8,1.0))
 chair(Vector3(8.2,0,2.75),0);chair(Vector3(8.2,0,4.45),PI)
 F.rod(self,Vector3(14.4,0,2.9),Vector3(14.4,1.2,2.9),0.035,"ad9277")
 F.rod(self,Vector3(14.4,1.2,2.9),Vector3(14.6,1.2,2.9),0.025,"ad9277")
 F.finish(F.lathe(self,Vector3(14.6,0.92,2.9),[Vector2(0.17,0),Vector2(0.13,0.12),Vector2(0.05,0.2)],"d7b77c"),"brass")
 F.ball(self,Vector3(14.6,0.92,2.9),Vector3.ONE*0.05,"b19566")
 # Small foot rails meet the dolls' feet under the taller bench.
 F.finish(F.box(self,Vector3(15,0.2,-3.35),Vector3(2.35,0.08,0.25),"c6ad96"),"wood")
 tea=Node3D.new();add_child(tea)
 for z in [3.18,4.03]: cup(tea,Vector3(8.27,0.825,z),"c7b0ce")
 F.finish(F.lathe(tea,Vector3(8.5,0.83,3.6),[Vector2(0.09,0),Vector2(0.16,0.13),Vector2(0.12,0.27),Vector2(0.06,0.3)],"e7c7cd"),"ceramic")
 for node in tea.find_children("*","MeshInstance3D",true,false):
  if node.material_override.albedo_color.to_html(false)=="c7b0ce":
   node.material_override=node.material_override.duplicate();tea_colors.append(node)
 tea.hide()
 picnic=Node3D.new();add_child(picnic)
 cloth=F.finish(F.box(self,Vector3(12,0.025,3.9),Vector3(2.8,0.035,1.7),"d9becd"),"fabric");cloth.material_override=cloth.material_override.duplicate()
 for x in [10.7,13.3]: F.box(self,Vector3(x,0.046,3.9),Vector3(0.08,0.008,1.65),"f0dfcf")
 for x in [11.65,12.25]: cup(picnic,Vector3(x,0.06,3.9),"d7c4df")
 F.finish(F.box(picnic,Vector3(12,0.17,3.8),Vector3(0.44,0.24,0.3),"be9c7a"),"wood")
 for x in [11.8,12,12.2]: F.ball(picnic,Vector3(x,0.33,3.8),Vector3(0.13,0.13,0.12),"e3a5b8")
 picnic.hide()
 confetti=Node3D.new();add_child(confetti)
 for i in range(18): F.box(confetti,Vector3.ZERO,Vector3(0.055,0.09,0.012),["dfb5c9","e6cf9b","b1c9bd"][i%3],0.005)
 confetti.hide()
 for id in ["baking","garden","warming"]:
  var memory:=Node3D.new();add_child(memory);memories[id]=memory
  if id=="baking":
   F.cylinder(memory,Vector3(-3.35,1.12,13.25),0.27,0.27,0.04,"cfb2cd")
   F.cylinder(memory,Vector3(-3.35,1.23,13.25),0.13,0.16,0.18,"d9ab8d")
   for i in range(5): F.ball(memory,Vector3(-3.35+cos(i*TAU/5)*0.09,1.34,13.25+sin(i*TAU/5)*0.09),Vector3(0.12,0.09,0.12),"f1d5da")
   var glass:=F.ball(memory,Vector3(-3.35,1.37,13.25),Vector3(0.52,0.52,0.52),"e8e6e5");glass.material_override=glass.material_override.duplicate();glass.material_override.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;glass.material_override.albedo_color.a=0.32
   F.cylinder(memory,Vector3(-3.35,1.15,13.25),0.27,0.27,0.025,"dce5dd")
   F.ball(memory,Vector3(-3.35,1.65,13.25),Vector3.ONE*0.08,"c5aa76")
   F.box(memory,Vector3(-3.35,1.12,12.9),Vector3(0.5,0.1,0.025),"eee1cf",0.012)
   var caption:=Label3D.new();caption.text="Baked with Mimi";caption.font_size=20;caption.pixel_size=0.003;caption.position=Vector3(-3.35,1.12,12.88);caption.billboard=BaseMaterial3D.BILLBOARD_ENABLED;caption.outline_size=0;caption.modulate=Color("816877");memory.add_child(caption)
  elif id=="garden":
   F.finish(F.box(memory,Vector3(16.3,0.16,-2.9),Vector3(0.65,0.32,0.5),"b9a2c4"),"wood")
   for i in range(5): preload("res://scripts/cozy_art.gd").flower(memory,Vector3(16.1+i*0.1,0.32,-2.9),i)
   F.box(memory,Vector3(16.3,0.57,-3.15),Vector3(0.5,0.2,0.04),"e8d5bd")
  else:
   for x in [10.4,13.6]: F.finish(F.box(memory,Vector3(x,1.5,4.75),Vector3(0.09,3.0,0.09),"c2a183"),"wood")
   F.rod(memory,Vector3(10.4,3.0,4.7),Vector3(13.6,3.0,4.7),0.014,"b09a80")
   for i in range(3):
    F.rod(memory,Vector3(10.8+i*1.2,3.0,4.7),Vector3(10.8+i*1.2,2.6,4.7),0.012,"b09a80")
    var lantern:=F.ball(memory,Vector3(10.8+i*1.2,2.5,4.7),Vector3(0.28,0.36,0.28),"edd8ad");lantern.material_override=lantern.material_override.duplicate();lantern.material_override.emission_enabled=true;lantern.material_override.emission=Color("e5bb87");lantern.material_override.emission_energy_multiplier=0.3
  memory.hide()
func apply(data: Dictionary) -> void:
 for node in tea_colors: node.material_override.albedo_color=Color("dba8bd" if data.tea_choice=="berry" else "b8a7d0")
 cloth.material_override.albedo_color=Color("b9cedd" if data.picnic_choice=="clouds" else "d9becd")
 for id in memories: memories[id].visible=id in data.rewards
func celebrate() -> void: sparkle=3.5;confetti.show()
func _process(delta: float) -> void:
 if sparkle<=0: return
 sparkle-=delta;clock+=delta
 for i in range(confetti.get_child_count()):
  var n: Node3D=confetti.get_child(i);n.position=Vector3(11+fmod(i*0.47,2.5),0.3+fmod(3-clock*0.8+i*0.18,2.8),3+sin(i)*0.8);n.rotation=Vector3(clock,i,clock*0.7)
 if sparkle<=0: confetti.hide()
