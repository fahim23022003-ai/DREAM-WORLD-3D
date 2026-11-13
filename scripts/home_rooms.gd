extends Node3D
## Two furnished rooms sharing physical doorway openings with Rosewater's living room.
const F=preload("res://scripts/forms.gd")
const STATION=preload("res://scripts/home_station.gd")
var surfaces: Dictionary={"bedding":[],"lamp":[],"cabinets":[],"ceramics":[]}
var stations: Dictionary={}
var ingredients: Node3D
var prepared: Node3D
var finished: Node3D
var cookware: Node3D
var steam: Node3D
var fridge_door: Node3D
var quilt: MeshInstance3D
var bedside_light: OmniLight3D
var window_lights: Array[OmniLight3D]=[]
var window_skies: Array[MeshInstance3D]=[]
var milestone_three: Node3D
var milestone_seven: Node3D
var clock := 0.0
var cooking := false
var fridge_tween: Tween
var env: Environment
var sun: DirectionalLight3D
var period_blend := 0.0
var period_target := 0.0
var bed_made := false
var bedside_on := true
var living_room: Node3D
var kitchen_light: OmniLight3D
func box(pos: Vector3,size: Vector3,color: String,kind: String="",solid: bool=false) -> MeshInstance3D:
 var n:=F.box(self,pos,size,color,0.035)
 if kind!="": F.finish(n,kind)
 if solid: F.solid(self,pos,size)
 return n
func tint(n: MeshInstance3D,slot: String) -> void:
 n.material_override=n.material_override.duplicate()
 n.set_meta("starter_color",n.material_override.albedo_color)
 surfaces[slot].append(n)
func station(id: String,pos: Vector3,text: String) -> void:
 var n:=STATION.new()
 n.interaction_id=id
 n.position=pos
 n.prompt="E   ·   "+text
 add_child(n)
 stations[id]=n
func label3(text: String,pos: Vector3,size: int=36) -> Label3D:
 var l:=Label3D.new()
 l.text=text
 l.font_size=size
 l.pixel_size=0.008
 l.modulate=Color("756578")
 l.position=pos
 add_child(l)
 return l
func _ready() -> void:
 for x in [-3.0,3.0]:
  box(Vector3(x,-0.14,9.5),Vector3(6,0.28,9),"dec8ad","wood")
  F.solid(self,Vector3(x,-0.18,9.5),Vector3(6,0.36,9))
  for row in range(12):
   box(Vector3(x,0.015,5.375+row*0.75),Vector3(5.98,0.035,0.735),"efe6da" if x<0 else "e5dcd6","wood")
  box(Vector3(x,1.9,14),Vector3(6,3.8,0.2),"e9e2ed" if x>0 else "f1e6df","",true)
  box(Vector3(x,0.48,13.86),Vector3(5.85,0.9,0.08),"cfdde0" if x<0 else "d8cce4")
  box(Vector3(x,3.65,13.82),Vector3(5.9,0.14,0.18),"fff0dc")
 for x in [-6.0,0.0,6.0]:
  box(Vector3(x,1.9,9.5),Vector3(0.18,3.8,9),"eee6e9","",true)
  box(Vector3(x+(-0.11 if x==6 else 0.11),0.14,9.5),Vector3(0.08,0.28,8.9),"fff1df")
 for x in [-3.0,3.0]:
  for side in [-1,1]: box(Vector3(x+side*1.16,1.4,5),Vector3(0.13,2.8,0.28),"fff0db")
  box(Vector3(x,2.83,5),Vector3(2.45,0.16,0.28),"fff0db")
  # Doorway plaques face the living room (negative Z).
  var sign_label:=label3("KITCHEN" if x<0 else "BEDROOM",Vector3(x,3.12,4.84),25)
  sign_label.rotation.y=PI
 kitchen()
 bedroom()
 for x in [-3.1,3.3]: window(Vector3(x,2.35,13.82))
func window(pos: Vector3) -> void:
 var sky:=box(pos,Vector3(2.55,1.55,0.07),"c8e1e8")
 sky.material_override=sky.material_override.duplicate()
 sky.material_override.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 window_skies.append(sky)
 for side in [-1,1]:
  box(pos+Vector3(side*1.34,0,-0.07),Vector3(0.11,1.75,0.13),"fff3df")
  var fabric:=box(pos+Vector3(side*1.51,0,-0.16),Vector3(0.44,1.9,0.18),"c6b6d6" if pos.x>0 else "b2cdbf","fabric")
  fabric.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 for y in [-0.84,0.84]: box(pos+Vector3(0,y,-0.07),Vector3(2.8,0.11,0.16),"fff3df")
 box(pos+Vector3(0,0,-0.12),Vector3(0.07,1.6,0.1),"fff3df")
 box(pos+Vector3(0,-0.9,-0.13),Vector3(2.95,0.12,0.4),"dcc4a7","wood")
 var light:=OmniLight3D.new()
 light.position=pos+Vector3(0,0,-1)
 light.light_color=Color("ffe7c9")
 light.light_energy=0.3
 light.omni_range=5
 add_child(light)
 window_lights.append(light)
func kitchen() -> void:
 # Refrigerated pantry, hinged actual door, vent and memo.
 box(Vector3(-5.25,1.16,7),Vector3(1.15,2.3,1.45),"c3d9df","",true)
 fridge_door=Node3D.new()
 fridge_door.position=Vector3(-4.63,0,6.29)
 add_child(fridge_door)
 F.box(fridge_door,Vector3(0,1.16,0.71),Vector3(0.12,2.19,1.39),"d6e6e8",0.08)
 F.box(fridge_door,Vector3(0.09,1.55,1.25),Vector3(0.07,0.49,0.07),"be9d72",0.025)
 F.box(fridge_door,Vector3(0.075,1.7,0.52),Vector3(0.04,0.36,0.34),"fff0cf",0.02)
 for i in range(5): box(Vector3(-4.64,0.2,6.62+i*0.17),Vector3(0.02,0.025,0.09),"a4babd")
 station("kitchen.fridge",Vector3(-4.43,0,7),"Open recipe pantry")
 for z in [9.25,11.75]:
  box(Vector3(-5.31,0.48,z),Vector3(1.08,0.94,2.05),"c7d8ce","",true)
  for dz in [-0.49,0.49]:
   var face:=box(Vector3(-4.75,0.49,z+dz),Vector3(0.07,0.79,0.92),"c3d6c9")
   tint(face,"cabinets")
   box(Vector3(-4.68,0.67,z+dz),Vector3(0.07,0.06,0.34),"b29a74")
   box(Vector3(-4.705,0.44,z+dz),Vector3(0.025,0.46,0.64),"dce7dc")
  box(Vector3(-5.25,1.0,z),Vector3(1.29,0.13,2.18),"fff0df","ceramic")
 # Preparation board, bowl, rolling pin and a contained chopping area.
 box(Vector3(-5.0,1.09,9.1),Vector3(0.7,0.06,0.86),"c9a985","wood")
 F.rod(self,Vector3(-4.81,1.15,8.74),Vector3(-4.81,1.15,9.39),0.035,"ddba8e")
 station("kitchen.prep",Vector3(-4.39,0,9.25),"Prepare / plate meal")
 # Hob with rings and oven face; steam is a reusable pool.
 box(Vector3(-5.15,1.09,11.65),Vector3(0.85,0.055,1.04),"6b737e")
 for z in [11.37,11.96]:
  F.cylinder(self,Vector3(-5.15,1.13,z),0.23,0.23,0.025,"b3b1b1")
  F.cylinder(self,Vector3(-5.15,1.15,z),0.15,0.15,0.025,"4d5966")
 box(Vector3(-4.68,0.5,11.75),Vector3(0.06,0.5,1.16),"5e6976")
 box(Vector3(-4.63,0.7,11.75),Vector3(0.07,0.05,0.88),"d8b987")
 for z in [11.36,11.65,11.94,12.23]: F.ball(self,Vector3(-4.61,0.88,z),Vector3(0.07,0.07,0.07),"d8b987")
 cookware=Node3D.new(); add_child(cookware)
 station("kitchen.stove",Vector3(-4.39,0,11.75),"Cook at the stove")
 steam=Node3D.new()
 add_child(steam)
 for i in range(6):
  var puff:=F.ball(steam,Vector3(-5.15,1.6+i*0.1,11.38),Vector3.ONE*0.12,"e1e6e9")
  puff.material_override=puff.material_override.duplicate()
  puff.material_override.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
  puff.material_override.albedo_color=Color(0.88,0.91,0.93,0.35)
  puff.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 steam.hide()
 # Small back-wall sink with basin and upright curved faucet.
 box(Vector3(-4.4,0.48,13.25),Vector3(2.8,0.94,1.05),"c9dcd5","",true)
 box(Vector3(-4.4,1.0,13.25),Vector3(2.9,0.13,1.13),"fff1df")
 box(Vector3(-4.4,1.075,13.23),Vector3(0.96,0.025,0.68),"91aeb6")
 F.rod(self,Vector3(-4.4,1.05,13.61),Vector3(-4.4,1.53,13.61),0.035,"b5a88f")
 F.rod(self,Vector3(-4.4,1.53,13.61),Vector3(-4.4,1.53,13.3),0.035,"b5a88f")
 # Shelves, plates, jars and herb pots sit on their supporting surfaces.
 for y in [2.1,2.85]:
  box(Vector3(-5.65,y,10.1),Vector3(0.48,0.09,3.15),"ddc3a3","wood")
  for i in range(4):
   var jar:=F.finish(F.cylinder(self,Vector3(-5.59,y+0.19,8.95+i*0.75),0.15,0.15,0.29,"edc7c7" if i%2 else "c6d8e3"),"ceramic")
   tint(jar,"ceramics")
   F.cylinder(self,Vector3(-5.59,y+0.355,8.95+i*0.75),0.16,0.16,0.04,"c8aa85")
 # A warm pendant balances the evening window light.
 F.rod(self,Vector3(-1.3,3.65,10.1),Vector3(-1.3,2.95,10.1),0.018,"b59a77")
 F.lathe(self,Vector3(-1.3,2.65,10.1),[Vector2(0.48,0),Vector2(0.35,0.25),Vector2(0.1,0.35)],"e6c8c7")
 kitchen_light=OmniLight3D.new()
 kitchen_light.position=Vector3(-1.3,2.6,10.1)
 kitchen_light.light_color=Color("ffe2ba")
 kitchen_light.omni_range=4.5
 add_child(kitchen_light)
 # Breakfast nook, chairs, vase and folded cloth.
 box(Vector3(-1.3,0.77,10.1),Vector3(1.5,0.15,1.65),"dfc29f","wood",true)
 for dx in [-0.53,0.53]:
  for dz in [-0.6,0.6]: box(Vector3(-1.3+dx,0.37,10.1+dz),Vector3(0.09,0.72,0.09),"c1a27e")
 for z in [8.75,11.45]:
  box(Vector3(-1.3,0.43,z),Vector3(0.8,0.13,0.76),"b7cfc2","",true)
  box(Vector3(-1.3,0.82,z+(-0.3 if z<10 else 0.3)),Vector3(0.8,0.75,0.09),"c6dcd0")
  for x in [-1.59,-1.01]: box(Vector3(x,0.2,z),Vector3(0.07,0.4,0.55),"c6ad90")
 box(Vector3(-1.3,0.86,10.1),Vector3(0.8,0.02,1.2),"eac4cb","fabric")
 for z in [9.7,10.5]: F.cylinder(self,Vector3(-1.3,0.89,z),0.24,0.24,0.035,"fff2df")
 var herb: Node3D=load("res://scenes/prop.tscn").instantiate()
 herb.kind="plant"
 herb.position=Vector3(-1.3,0.89,10.1)
 herb.scale=Vector3.ONE*0.4
 add_child(herb)
 ingredients=Node3D.new(); add_child(ingredients)
 prepared=Node3D.new(); add_child(prepared)
 finished=Node3D.new(); add_child(finished)
 ingredients.hide(); prepared.hide(); finished.hide()
func bedroom() -> void:
 box(Vector3(3.8,0.34,11.25),Vector3(2.45,0.52,3.45),"c5a98f","wood",true)
 box(Vector3(3.8,0.69,11.25),Vector3(2.32,0.25,3.28),"fff1e6","fabric")
 box(Vector3(3.8,1.03,12.94),Vector3(2.55,1.46,0.18),"b3a3be","fabric")
 quilt=box(Vector3(3.8,0.88,10.78),Vector3(2.37,0.16,2.3),"c2cddd","fabric")
 tint(quilt,"bedding")
 box(Vector3(3.8,0.96,11.64),Vector3(2.39,0.08,0.43),"e8d9e6","fabric")
 for x in [3.23,4.37]:
  var p:=box(Vector3(x,0.99,12.25),Vector3(0.95,0.21,0.65),"fff0df","fabric")
  p.rotation.x=-0.13
  var small:=box(Vector3(x,1.1,12.51),Vector3(0.68,0.42,0.2),"d7becf","fabric")
  tint(small,"bedding")
 for x in [2.73,4.87]:
  for z in [9.7,12.75]: F.cylinder(self,Vector3(x,0.18,z),0.075,0.075,0.36,"c7a985")
 station("bedroom.bed",Vector3(2.16,0,11.05),"Sleep until morning")
 station("bedroom.make",Vector3(3.8,0,9.1),"Make the bed")
 # Bedside cabinet and independently switched lamp.
 box(Vector3(1.53,0.49,12.15),Vector3(1.02,0.95,0.9),"d9c5d7","",true)
 for y in [0.32,0.68]:
  box(Vector3(1.53,y,11.68),Vector3(0.89,0.27,0.04),"e9dce3")
  F.ball(self,Vector3(1.53,y,11.63),Vector3.ONE*0.07,"c8a778")
 F.cylinder(self,Vector3(1.53,1.0,12.15),0.19,0.19,0.06,"bfa47f")
 F.rod(self,Vector3(1.53,1,12.15),Vector3(1.53,1.44,12.15),0.025,"bfa47f")
 var shade:=F.finish(F.lathe(self,Vector3(1.53,1.38,12.15),[Vector2(0.3,0),Vector2(0.22,0.38),Vector2(0.2,0.4)],"f2d9bd"),"fabric")
 tint(shade,"lamp")
 bedside_light=OmniLight3D.new()
 bedside_light.position=Vector3(1.53,1.5,12.15)
 bedside_light.light_color=Color("ffe0ba")
 bedside_light.omni_range=3.8
 add_child(bedside_light)
 station("bedroom.lamp",Vector3(1.53,0,11.52),"Switch bedside lamp")
 # Wardrobe and a framed polished mirror.
 box(Vector3(1.3,1.4,13.4),Vector3(1.9,2.8,0.95),"c3b7ca","",true)
 for x in [0.84,1.76]:
  box(Vector3(x,1.42,12.89),Vector3(0.87,2.57,0.07),"dfd4e0")
  F.rod(self,Vector3(x+(-0.24 if x>1.3 else 0.24),1.2,12.82),Vector3(x+(-0.24 if x>1.3 else 0.24),1.58,12.82),0.025,"b99c77")
 box(Vector3(0.2,1.9,9.55),Vector3(0.15,1.75,1.05),"c7ab86","wood")
 var mirror:=box(Vector3(0.3,1.9,9.55),Vector3(0.025,1.56,0.86),"b9d1db")
 mirror.material_override=mirror.material_override.duplicate()
 mirror.material_override.metallic=0.6
 mirror.material_override.roughness=0.15
 # Layered bedroom rug; clear circulation on the bed's left and foot.
 box(Vector3(3.5,0.06,10.3),Vector3(4.3,0.05,5.2),"bcabc9","fabric")
 var rug:=F.picture(self,Vector3(3.5,0.091,10.3),Vector2(4.05,4.9),"res://assets/textures/rug.svg")
 rug.rotation.x=-PI/2
 rug.material_override.albedo_color=Color("d7c7e4")
 box(Vector3(1.15,0.45,7.25),Vector3(1.4,0.18,0.85),"b5c6d5","fabric",true)
 box(Vector3(1.15,0.22,7.25),Vector3(1.2,0.4,0.65),"c6ac93")
 station("bedroom.rest",Vector3(1.3,0,7.95),"Rest and watch the light")
 for z in [7.2,8.35]:
  box(Vector3(5.82,2.35,z),Vector3(0.08,0.8,0.62),"d8b795","wood")
  box(Vector3(5.76,2.35,z),Vector3(0.025,0.68,0.5),"f2e6db")
  F.ball(self,Vector3(5.73,2.35,z),Vector3(0.025,0.35,0.3),"d9b1c7" if z<8 else "dcc998")
 # Journal and slippers; milestone rewards are separate permanent physical objects.
 box(Vector3(1.66,1,11.94),Vector3(0.23,0.07,0.3),"9eaec7")
 for x in [3.35,3.68]: box(Vector3(x,0.12,9.23),Vector3(0.21,0.14,0.42),"d5afc1","fabric")
 milestone_three=Node3D.new(); add_child(milestone_three)
 F.cylinder(milestone_three,Vector3(1.38,1.02,12.45),0.14,0.14,0.05,"c8a776")
 F.ball(milestone_three,Vector3(1.38,1.22,12.45),Vector3(0.2,0.35,0.17),"e6c588")
 milestone_seven=Node3D.new(); add_child(milestone_seven)
 F.box(milestone_seven,Vector3(5.5,2.45,13.73),Vector3(0.66,0.84,0.11),"c9a772",0.04)
 F.box(milestone_seven,Vector3(5.5,2.45,13.65),Vector3(0.53,0.69,0.03),"e4d5e8",0.01)
 for i in range(7): F.ball(milestone_seven,Vector3(5.33+(i%3)*0.17,2.25+(i/3)*0.17,13.61),Vector3.ONE*0.075,"eed29d")
 milestone_three.hide(); milestone_seven.hide()
func open_fridge() -> void:
 if fridge_tween: fridge_tween.kill()
 fridge_tween=create_tween()
 fridge_tween.tween_property(fridge_door,"rotation:y",-0.65,0.28)
 fridge_tween.tween_interval(0.7)
 fridge_tween.tween_property(fridge_door,"rotation:y",0.0,0.35)
func apply_home(data: Dictionary, draft: Dictionary={}) -> void:
 var defs=preload("res://scripts/home_rules.gd").CATALOG
 var equipped: Dictionary=data.equipped if draft.is_empty() else draft
 for slot in surfaces:
  var id: String=equipped.get(slot,"starter")
  for mesh in surfaces[slot]: mesh.material_override.albedo_color=Color(defs[id].color) if defs.has(id) else mesh.get_meta("starter_color")
 bed_made=data.bed_made
 quilt.rotation.z=0 if bed_made else 0.045
 quilt.position.y=0.88 if bed_made else 0.92
 bedside_on=data.bedside_on
 milestone_three.visible="three_days" in data.milestones
 milestone_seven.visible="seven_days" in data.milestones
 period_target=float(data.period)
func _process(delta: float) -> void:
 clock+=delta
 steam.visible=cooking
 if cooking:
  for i in range(steam.get_child_count()):
   var drop: Node3D=steam.get_child(i)
   drop.position.y=1.6+fmod(clock*0.6+i*0.13,0.8)
   drop.scale=Vector3.ONE*0.12*(0.8+sin(clock*2+i)*0.18)
 period_blend=move_toward(period_blend,period_target,delta*1.3)
 var colors: Array[Color]=[Color("e5e9f6"),Color("f1e6d9"),Color("d9bdcf"),Color("8999bd")]
 var skies: Array[Color]=[Color("c8e1e8"),Color("d6e2e3"),Color("dfb9c8"),Color("717eac")]
 var lo:=clampi(int(period_blend),0,3)
 var hi:=mini(lo+1,3)
 var t:=period_blend-lo
 if env:
  env.ambient_light_color=colors[lo].lerp(colors[hi],t)
  env.ambient_light_energy=lerpf(0.48,0.32,period_blend/3)
 if sun: sun.light_energy=lerpf(0.22,0.045,period_blend/3)
 if is_instance_valid(living_room):
  living_room.window_sky.material_override.albedo_color=skies[lo].lerp(skies[hi],t)
  living_room.curtain_control.day_factor=lerpf(1,0.3,period_blend/3)
  living_room.curtain_control.update_visuals()
 bedside_light.light_energy=lerpf(0.25,0.4,period_blend/3) if bedside_on else 0.0
 kitchen_light.light_energy=lerpf(0.22,0.48,period_blend/3)
 for sky in window_skies: sky.material_override.albedo_color=skies[lo].lerp(skies[hi],t)
 for light in window_lights:
  light.light_energy=lerpf(0.3,0.06,period_blend/3)
func clear_children(node: Node3D) -> void:
 for child in node.get_children(): node.remove_child(child); child.queue_free()
func show_meal(recipe: String,stage: String) -> void:
 for node in [ingredients,prepared,finished,cookware]: clear_children(node); node.hide()
 if stage=="idle": return
 if stage in ["prepared","ready"]:
  cookware.show()
  if recipe=="cloud_pancakes":
   F.cylinder(cookware,Vector3(-5.15,1.19,11.38),0.31,0.31,0.08,"737987")
   F.rod(cookware,Vector3(-4.9,1.2,11.38),Vector3(-4.65,1.2,11.38),0.025,"8f7994")
   F.cylinder(cookware,Vector3(-5.15,1.24,11.38),0.23,0.23,0.04,"e5bc82")
  elif recipe=="berry_cupcakes":
   F.box(cookware,Vector3(-5.12,1.2,11.6),Vector3(0.58,0.06,0.72),"9ca7b4",0.03)
   for i in range(3): F.cylinder(cookware,Vector3(-5.12,1.3,11.38+i*0.2),0.085,0.1,0.13,"ddb5c3")
  else:
   F.cylinder(cookware,Vector3(-5.15,1.29,11.38),0.25,0.25,0.26,"b2b9d0")
   F.rod(cookware,Vector3(-4.96,1.37,11.38),Vector3(-4.67,1.37,11.38),0.035,"8a819d")
 var root_node: Node3D=ingredients if stage=="ingredients" else (prepared if stage=="prepared" else finished)
 root_node.show()
 var center:=Vector3(-5.0,1.14,9.25)
 if stage=="ingredients":
  if recipe=="starry_soup":
   F.lathe(root_node,center+Vector3(0,0.04,-0.2),[Vector2(0.02,0),Vector2(0.065,0.21),Vector2(0.06,0.25)],"e6aa75")
   for i in range(3): F.leaf(root_node,center+Vector3(0,0.1,i*0.08),0.22,0.06,Vector3(0.8,i,0.4),"9bb78d")
   for i in range(5): F.ball(root_node,center+Vector3(0,0.04,0.22)+Vector3(cos(i*TAU/5)*0.05,0,sin(i*TAU/5)*0.05),Vector3.ONE*0.08,"f2dba3")
  else:
   F.box(root_node,center+Vector3(0,0.14,-0.23),Vector3(0.22,0.28,0.18),"f2dfbc",0.025)
   if recipe=="cloud_pancakes":
    F.cylinder(root_node,center+Vector3(0,0.14,0),0.075,0.075,0.28,"d9e6e9")
    F.ball(root_node,center+Vector3(0,0.08,0.23),Vector3(0.12,0.16,0.12),"fff0de")
   else:
    F.box(root_node,center+Vector3(0,0.05,0),Vector3(0.2,0.09,0.14),"f1d898",0.015)
    for i in range(5): F.ball(root_node,center+Vector3(sin(i)*0.07,0.06,0.23+cos(i)*0.07),Vector3.ONE*0.07,"b47f9a")
 elif stage=="prepared":
  if recipe=="cloud_pancakes":
   F.cylinder(root_node,center+Vector3(0,0.1,0),0.27,0.21,0.2,"c7bed8")
   F.cylinder(root_node,center+Vector3(0,0.21,0),0.25,0.25,0.015,"eccd98")
  elif recipe=="berry_cupcakes":
   for i in range(3): F.cylinder(root_node,center+Vector3(0,0.1,-0.2+i*0.2),0.085,0.1,0.17,"e8c2ce")
  else:
   for i in range(8): F.box(root_node,center+Vector3(sin(i*2.4)*0.2,0.05,cos(i*2.4)*0.2),Vector3(0.09,0.07,0.07),"dfa078" if i%2 else "a8be96",0.015)
 else:
  F.cylinder(root_node,center,0.38,0.38,0.04,"fff0df")
  if recipe=="cloud_pancakes":
   for i in range(3): F.cylinder(root_node,center+Vector3(0,0.065+i*0.065,0),0.27,0.28,0.065,"e9be81")
   F.box(root_node,center+Vector3(0,0.24,0),Vector3(0.12,0.04,0.11),"fff0ad",0.015)
   for i in range(3): F.ball(root_node,center+Vector3(0.16,0.25,i*0.07-0.07),Vector3.ONE*0.065,"ab789a")
  elif recipe=="berry_cupcakes":
   for i in range(3):
    var p:=center+Vector3(cos(i*TAU/3)*0.18,0.09,sin(i*TAU/3)*0.18)
    F.cylinder(root_node,p,0.09,0.11,0.14,"e5afc0")
    F.ball(root_node,p+Vector3(0,0.1,0),Vector3(0.23,0.15,0.23),"fff0df")
    F.ball(root_node,p+Vector3(0,0.2,0),Vector3.ONE*0.065,"b47d9c")
  else:
   F.cylinder(root_node,center+Vector3(0,0.09,0),0.23,0.32,0.17,"c3d7dc")
   F.cylinder(root_node,center+Vector3(0,0.18,0),0.29,0.29,0.02,"d5b87b")
   for i in range(5):
    var p:=center+Vector3(cos(i*2.4)*0.17,0.2,sin(i*2.4)*0.17)
    F.box(root_node,p,Vector3(0.055,0.025,0.11),"e2a075" if i%2 else "a9be8f",0.01)
    for j in range(5): F.ball(root_node,p+Vector3(cos(j*TAU/5)*0.027,0.013,sin(j*TAU/5)*0.027),Vector3.ONE*0.04,"f6dfab")
