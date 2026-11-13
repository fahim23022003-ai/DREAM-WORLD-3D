extends Node3D
const F=preload("res://scripts/forms.gd")
const G=preload("res://scripts/garden_rules.gd")
const S=preload("res://scripts/home_station.gd")
var stations: Dictionary={}
var plots: Array[Node3D]=[]
var soil: Array[MeshInstance3D]=[]
var surfaces: Dictionary={"arch":[],"lantern":[],"planter":[],"bench":[],"picnic":[],"photo":[]}
var upgrades: Dictionary={}
var keepsakes: Dictionary={}
var flowers: Node3D
var lost: Node3D
var moon: Node3D
var bulbs: Array[MeshInstance3D]=[]
var lights: Array[OmniLight3D]=[]
var butterflies: Array[Node3D]=[]
var drops: Node3D
var water_time:=0.0
var clock:=0.0
var period:=0.0
var state_cache: Array=[]
var bloom_materials: Dictionary={}
var moon_night:=false
func b(parent: Node3D,pos: Vector3,size: Vector3,color: String,kind: String="") -> MeshInstance3D:
 var node:=F.box(parent,pos,size,color,0.04)
 if not kind.is_empty(): F.finish(node,kind)
 return node
func tag(mesh: MeshInstance3D,slot: String) -> void:
 mesh.material_override=mesh.material_override.duplicate()
 mesh.set_meta("starter",mesh.material_override.albedo_color)
 surfaces[slot].append(mesh)
func station(id: String,pos: Vector3,text: String) -> void:
 var node:=S.new();node.interaction_id=id;node.position=pos;node.prompt="E   ·   "+text
 add_child(node);stations[id]=node
func _ready() -> void:
 # Decorative meadow beyond the safe fence grounds the distant trees.
 b(self,Vector3(16.5,-0.2,0),Vector3(21,0.36,30),"b8c9ac")
 b(self,Vector3(11.5,-0.12,0),Vector3(11.2,0.24,10),"b3c8a3")
 F.solid(self,Vector3(11.5,-0.18,0),Vector3(11.2,0.36,10))
 # Borders stop the player and camera, while the house doorway remains genuinely open.
 for z in [-5.0,5.0]:
  F.solid(self,Vector3(11.5,1.3,z),Vector3(11,2.6,0.16))
  for i in range(19):
   var x:=6.3+i*0.58
   b(self,Vector3(x,0.52,z),Vector3(0.13,1.04,0.12),"dec9ae","wood")
  for y in [0.3,0.78]: b(self,Vector3(11.5,y,z),Vector3(11,0.09,0.09),"dcc5a8","wood")
 F.solid(self,Vector3(17,1.3,0),Vector3(0.15,2.6,10))
 for i in range(18): b(self,Vector3(17,0.52,-4.8+i*0.56),Vector3(0.12,1.04,0.12),"dec9ae","wood")
 for y in [0.3,0.78]: b(self,Vector3(17,y,0),Vector3(0.1,0.09,10),"dcc5a8","wood")
 # Low patio deck and pastel stepping stones.
 b(self,Vector3(8.4,0.015,3.05),Vector3(4.6,0.04,3.5),"d7c3ae","wood")
 for i in range(11):
  var p:=Vector3(6.7+i*0.8,0.045,2.6-sin(i*0.5)*0.7)
  var stone:=F.cylinder(self,p,0.48,0.52,0.06,["d9c7d7","c8d8cf","e6d3bf"][i%3]);stone.scale.z=0.8
 # Curved lawn borders, blossoms and path branches soften the working beds.
 for i in range(9):
  var stone:=F.cylinder(self,Vector3(8.0+i,0.04,0.55+sin(i*0.6)*0.16),0.32,0.37,0.055,["d5c4d8","d2dfcc","e3cdb8"][i%3])
  stone.scale.z=0.75
 for i in range(26):
  var x:=6.7+fmod(i*1.91,9.7)
  var z: float=-3.5 if i%2==0 else 4.6
  F.ball(self,Vector3(x,0.045,z),Vector3(0.55,0.12,0.45),"a7bf9e")
  for j in range(3): F.leaf(self,Vector3(x+(j-1)*0.08,0.02,z),0.25,0.025,Vector3(0.2,j*1.7,0.15),"91ad8b")
 for base in [Vector3(7.1,0,-2.8),Vector3(16.3,0,-3.5),Vector3(16.2,0,0.1),Vector3(7.2,0,4.3)]:
  F.lathe(self,base,[Vector2(0.16,0),Vector2(0.23,0.34),Vector2(0.25,0.38),Vector2(0.2,0.4)],"d4b3c3")
  F.cylinder(self,base+Vector3(0,0.38,0),0.2,0.2,0.025,"8b7866")
  for j in range(4):
   var top: Vector3=base+Vector3(sin(j*2.4)*0.15,0.6+(j%2)*0.14,cos(j*2.4)*0.12)
   F.rod(self,base+Vector3(0,0.39,0),top,0.012,"8ba67b")
   for k in range(5): F.ball(self,top+Vector3(cos(k*TAU/5)*0.05,0,sin(k*TAU/5)*0.05),Vector3(0.08,0.035,0.08),"ecc2d5")
 for i in range(3): F.ball(self,Vector3(8+i*6,0.3,-10),Vector3(10,3.8+i%2,5),"b6c9b1")
 for i in range(3):
  var x:=9.0+i*3
  var base:=Vector3(x,0,-1.7)
  for side in [-1,1]:
   tag(b(self,base+Vector3(side*0.98,0.23,0),Vector3(0.14,0.46,1.8),"c5ae91","wood"),"planter")
   tag(b(self,base+Vector3(0,0.23,side*0.83),Vector3(2.1,0.46,0.14),"c5ae91","wood"),"planter")
  F.solid(self,base+Vector3(0,0.2,0),Vector3(2.1,0.4,1.8))
  var dirt:=b(self,base+Vector3(0,0.36,0),Vector3(1.83,0.05,1.5),"92775e")
  dirt.material_override=dirt.material_override.duplicate();soil.append(dirt)
  var crop:=Node3D.new();crop.position=base+Vector3(0,0.4,0);add_child(crop);plots.append(crop)
  station("garden.plot"+str(i),Vector3(x,0,-0.55),"Tend planting spot "+str(i+1))
 # Bench has a clear approach, with a solid base and wood slats.
 for x in [14.05,15.95]: b(self,Vector3(x,0.3,-4),Vector3(0.12,0.6,0.75),"9c8774")
 for z in [-4.3,-4.05,-3.8]: tag(b(self,Vector3(15,0.65,z),Vector3(2.35,0.13,0.21),"c6a98a","wood"),"bench")
 for y in [0.95,1.2]: tag(b(self,Vector3(15,y,-4.4),Vector3(2.35,0.2,0.1),"c6a98a","wood"),"bench")
 F.solid(self,Vector3(15,0.45,-4.05),Vector3(2.4,0.9,0.9))
 station("garden.rest",Vector3(14.5,0,-3.05),"Rest in the garden")
 # Patio table with watering can, picnic cloth and a frame upgrade.
 b(self,Vector3(8.2,0.72,3.6),Vector3(1.45,0.13,1),"dcc19f","wood")
 for x in [7.66,8.74]:
  for z in [3.25,3.95]: b(self,Vector3(x,0.35,z),Vector3(0.08,0.7,0.08),"bca281")
 tag(b(self,Vector3(8.2,0.8,3.6),Vector3(1.2,0.02,0.8),"c9d8d1","fabric"),"picnic")
 F.cylinder(self,Vector3(8,0.98,3.6),0.13,0.13,0.32,"a6c3ca")
 F.rod(self,Vector3(8.1,1.05,3.6),Vector3(8.4,1.2,3.6),0.045,"a6c3ca")
 var handle:=TorusMesh.new();handle.inner_radius=0.1;handle.outer_radius=0.13
 var h:=F.mesh(self,handle,Vector3(7.84,1.05,3.6),"a6c3ca");h.rotation.x=PI/2
 # Entrance arch upgrade, planter blossoms and warm lanterns.
 var arch:=Node3D.new();add_child(arch);upgrades.arch=arch
 for z in [2.4,4.9]: tag(b(arch,Vector3(6.6,1.3,z),Vector3(0.12,2.6,0.12),"ead5c4","wood"),"arch")
 tag(b(arch,Vector3(6.6,2.65,3.65),Vector3(0.18,0.16,2.65),"ead5c4"),"arch")
 for i in range(11):
  var p:=Vector3(6.6,2.75,2.45+i*0.24)
  F.ball(arch,p,Vector3.ONE*0.18,"dab0c6")
 arch.hide()
 var lantern:=Node3D.new();add_child(lantern);upgrades.lantern=lantern
 tag(b(lantern,Vector3(12.2,0.35,3.6),Vector3(0.3,0.65,0.3),"ead4a3"),"lantern")
 F.cylinder(lantern,Vector3(12.2,0.72,3.6),0.24,0.04,0.22,"b6a0bd")
 lantern.hide()
 var photo:=Node3D.new();add_child(photo);upgrades.photo=photo
 tag(b(photo,Vector3(8.55,1.02,3.8),Vector3(0.33,0.4,0.055),"b8ced9"),"photo")
 for dx in [-0.07,0.07]: F.ball(photo,Vector3(8.55+dx,1.04,3.76),Vector3(0.1,0.17,0.03),"e2bbce" if dx<0 else "abc4bd")
 photo.hide()
 # Fairy-light cable and softly luminous local bulbs.
 for x in [6.8,16.15]: b(self,Vector3(x,1.4,-3.9),Vector3(0.12,2.8,0.12),"c9b397","wood")
 for i in range(12):
  var p:=Vector3(6.8+i*0.85,2.7-sin(i/11.0*PI)*0.45,-3.9)
  if i>0: F.rod(self,Vector3(6.8+(i-1)*0.85,2.7-sin((i-1)/11.0*PI)*0.45,-3.9),p,0.012,"8e9c8c")
  var bulb:=F.ball(self,p-Vector3(0,0.09,0),Vector3.ONE*0.1,"fff0cb")
  bulb.material_override=bulb.material_override.duplicate();bulb.material_override.emission_enabled=true;bulb.material_override.emission=Color("ffe0a3");bulbs.append(bulb)
 for x in [8.2,12.1,15.5]:
  var light:=OmniLight3D.new();light.position=Vector3(x,2,-3.7);light.omni_range=3.8;light.light_color=Color("ffdfb1");add_child(light);lights.append(light)
 # Flowers, distant rolling garden scenery and gentle butterflies.
 flowers=Node3D.new();add_child(flowers)
 for i in range(20):
  var p:=Vector3(7.2+fmod(i*1.91,9),0.25,-4.3+sin(i)*0.25)
  F.rod(flowers,p-Vector3(0,0.2,0),p,0.015,"8fa878")
  for j in range(5):
   var color: String="e6afcb" if i%2 else "eee0b4"
   var petal:=F.ball(flowers,p+Vector3(cos(j*TAU/5)*0.08,0,sin(j*TAU/5)*0.08),Vector3(0.11,0.05,0.11),color)
   if not bloom_materials.has(color):
    bloom_materials[color]=petal.material_override.duplicate()
    bloom_materials[color].emission_enabled=true
    bloom_materials[color].emission=Color(color)
   petal.material_override=bloom_materials[color]
 station("garden.bloom",Vector3(10.4,0,-3.5),"Enjoy the flower patch")
 for i in range(7):
  var p:=Vector3(18.5+(i%2)*1.5,0, -7+i*2.4)
  F.rod(self,p,p+Vector3(0,2,0),0.16,"b6a389")
  F.ball(self,p+Vector3(0,2.2,0),Vector3(2.3,2.6,2.1),"a8bda2" if i%2 else "b6c8b0")
 for i in range(3):
  var butterfly:=Node3D.new();add_child(butterfly);butterflies.append(butterfly)
  for side in [-1,1]: F.ball(butterfly,Vector3(side*0.06,0,0),Vector3(0.13,0.03,0.18),"dab5d0" if i%2 else "ecd5a5")
 # A visiting board and optional event actors are all real world objects.
 b(self,Vector3(7.05,1.0,1.1),Vector3(0.12,2,0.12),"bda58c")
 b(self,Vector3(7.05,1.6,1.1),Vector3(0.9,0.6,0.1),"e8d5df")
 station("garden.board",Vector3(7.3,0,1.5),"Neighbors & garden journal")
 moon=Node3D.new();add_child(moon)
 F.cylinder(moon,Vector3(12.2,0.05,3.6),0.22,0.22,0.1,"b7c6bc")
 F.rod(moon,Vector3(12.2,0.1,3.6),Vector3(12.2,0.9,3.6),0.025,"c4b48c")
 F.ball(moon,Vector3(12.2,1,3.6),Vector3.ONE*0.25,"e2d4a2")
 station("garden.moon",Vector3(12.2,0,3.3),"Enjoy the moonlit patio")
 lost=Node3D.new();add_child(lost)
 for x in [-0.08,0.08]: F.ball(lost,Vector3(-5.35+x,0.905,0.6),Vector3(0.17,0.07,0.12),"c7a0c9")
 station("garden.lost",Vector3(-4.85,0,0.6),"Pick up the little ribbon")
 for id in ["first_harvest","first_chat","first_request","friend","close_friend","garden_event"]:
  var reward:=Node3D.new();add_child(reward);keepsakes[id]=reward
  var i: int=keepsakes.size()-1
  var p:=Vector3(7.3+i*0.4,0.10,-4.6)
  b(reward,p,Vector3(0.31,0.18,0.23),"dbc39f","wood")
  if id=="first_harvest":
   F.rod(reward,p,p+Vector3(0,0.6,0),0.025,"b5a58e")
   for j in range(3): F.rod(reward,p+Vector3(-0.12+j*0.12,0.5,0),p+Vector3(-0.12+j*0.12,0.2+j*0.05,0),0.018,"c3c9dc")
  elif id in ["first_chat","friend"]:
   b(reward,p+Vector3(0,0.26,0),Vector3(0.3,0.38,0.06),"d1b8d2")
   for x in [-0.07,0.07]: F.ball(reward,p+Vector3(x,0.28,0.05),Vector3(0.1,0.18,0.04),"edc2cc" if x<0 else "b5ccc4")
  elif id=="first_request":
   F.cylinder(reward,p+Vector3(0,0.13,0),0.12,0.12,0.08,"e8d3db")
   for x in [-0.08,0.08]: F.cylinder(reward,p+Vector3(x,0.21,0),0.045,0.06,0.12,"f3dfcc")
  else: F.ball(reward,p+Vector3(0,0.3,0),Vector3(0.22,0.4,0.2),"e5d0a2" if id=="garden_event" else "a8c5ca")
  reward.hide()
 drops=Node3D.new();add_child(drops)
 for i in range(9): F.ball(drops,Vector3.ZERO,Vector3(0.035,0.07,0.035),"a3d2df")
 drops.hide()
func water_at(index: int) -> void:
 drops.position=Vector3(9+index*3,0,-1.2);water_time=1.0;drops.show()
func apply(data: Dictionary,home: Dictionary,draft: Dictionary={}) -> void:
 var defs=preload("res://scripts/neighborhood_rules.gd").CATALOG
 var equipped: Dictionary=home.equipped if draft.is_empty() else draft
 for slot in surfaces:
  var id: String=equipped.get(slot,"starter")
  for mesh in surfaces[slot]: mesh.material_override.albedo_color=Color(defs[id].color) if defs.has(id) else mesh.get_meta("starter")
 for slot in upgrades: upgrades[slot].visible=equipped.get(slot,"starter")!="starter"
 for id in keepsakes: keepsakes[id].visible=id in data.achievements
 flowers.scale=Vector3(1,1.2 if data.event.id=="bloom" else 1.0,1)
 for material in bloom_materials.values(): material.emission_energy_multiplier=0.14 if data.event.id=="bloom" else 0.0
 stations["garden.bloom"].radius=1.55 if data.event.id=="bloom" and not data.event.done else 0.0
 stations["garden.moon"].radius=1.55 if data.event.id=="moon" and not data.event.done else 0.0
 moon_night=data.event.id=="moon" and home.period>=2
 lost.visible=data.event.id=="lost" and not data.event.done
 stations["garden.lost"].radius=1.55 if lost.visible else 0.0
 moon.visible=data.event.id=="moon" and home.period>=2 and not data.event.done
 for i in range(3):
  var p: Dictionary=data.plots[i]
  var text: String="Plant free seeds · Spot "+str(i+1)
  if p.stage>0:
   text=("Harvest " if p.stage==4 else ("Check " if p.water_day==home.day else "Water "))+G.CROPS[p.crop].name
  stations["garden.plot"+str(i)].prompt="E   ·   "+text
 period=float(home.period)
 if state_cache!=data.plots:
  state_cache=data.plots.duplicate(true)
  for i in range(3): rebuild(i,data.plots[i])
func rebuild(i: int,p: Dictionary) -> void:
 var parent: Node3D=plots[i]
 for child in parent.get_children(): parent.remove_child(child);child.queue_free()
 soil[i].material_override.albedo_color=Color("6d6154") if p.water_day>0 else Color("92775e")
 if p.stage==0: return
 for j in range(3):
  var base:=Vector3((j-1)*0.48,0,0)
  if p.stage==1:
   F.ball(parent,base+Vector3(0,0.025,0),Vector3(0.12,0.06,0.1),"d2b087");continue
  var height: float=0.18 if p.stage==2 else 0.46
  F.rod(parent,base,base+Vector3(0,height,0),0.017,"8aa178")
  for side in [-1,1]: F.leaf(parent,base+Vector3(side*0.05,height*0.6,0),height*0.8,0.075,Vector3(0.4,side*1.2,side*0.7),"9db890")
  if p.stage>=3:
   if p.crop=="lavender":
    for k in range(4): F.ball(parent,base+Vector3(0,height+k*0.07,0),Vector3(0.1,0.13,0.1),"b299ce" if p.stage==4 else "c4b6d1")
   elif p.crop=="strawberry":
    for side in [-1,1]: F.ball(parent,base+Vector3(side*0.14,height*0.65,0.07),Vector3(0.14,0.18,0.14),"db829d" if p.stage==4 else "b0c497")
   else:
    F.lathe(parent,base+Vector3(0,0,0.04),[Vector2(0.02,0),Vector2(0.09,0.14),Vector2(0.08,0.19)],"dfa171" if p.stage==4 else "b8bb87")
func _process(delta: float) -> void:
 clock+=delta
 for i in range(plots.size()): plots[i].rotation.z=sin(clock*0.9+i)*0.012
 for i in range(butterflies.size()):
  butterflies[i].position=Vector3(10+i*1.8+sin(clock*0.6+i)*0.8,1.4+sin(clock*1.1+i)*0.25,-2.9+cos(clock*0.5+i)*0.5)
  for wing in butterflies[i].get_children(): wing.rotation.z=sin(clock*9)*0.6
 for bulb in bulbs: bulb.material_override.emission_energy_multiplier=lerpf(0.1,0.8,period/3)
 for light in lights:
  light.light_energy=lerpf(0.02,0.32,period/3)
  light.light_color=Color("d8ccf2") if moon_night else Color("ffdfb1")
 if water_time>0:
  water_time-=delta
  for i in range(drops.get_child_count()): drops.get_child(i).position=Vector3(cos(i*2.4)*0.3,0.5+fmod(water_time*1.8+i*0.11,1.0)*0.7,sin(i*2.4)*0.25)
  if water_time<=0: drops.hide()
