extends CharacterBody3D
const F=preload("res://scripts/forms.gd")
var person := "mimi"
var game: Node3D
var avatar: Node3D
var interaction_id: String:
 get: return "neighbor."+person
var prompt: String:
 get: return "E   ·   Talk with "+person.capitalize()
enum Mode { AWAY, ARRIVING, WANDERING, WAITING, TALKING, VISITING, LEAVING }
var mode:=Mode.AWAY
var route: Array[Vector3]=[]
var elapsed:=0.0
var visits:=0
var clock:=0.0
var start: Vector3:
 get: return Vector3(16 if person=="mimi" else 16.5,0,4.2)
var social: Vector3:
 get: return Vector3(9.8,0,1.1) if person=="mimi" else Vector3(13.3,0,0.9)
func _ready() -> void:
 add_to_group("camera_characters")
 collision_layer=2;collision_mask=3
 var collision:=CollisionShape3D.new();var capsule:=CapsuleShape3D.new();capsule.radius=0.25;capsule.height=1.65;collision.shape=capsule;collision.position.y=0.84;add_child(collision)
 avatar=load("res://scripts/avatar.gd").new();add_child(avatar)
 avatar.scale=Vector3.ONE*(0.88 if person=="mimi" else 0.95)
 avatar.apply_appearance({"hair":Color("a07860" if person=="mimi" else "665e56"),"accent":Color("e2a7bf" if person=="mimi" else "a5c3b4")})
 if person=="mimi":
  for side in [-1,1]:
   F.finish(F.ball(avatar.head,Vector3(side*0.36,0.21,-0.04),Vector3(0.31,0.31,0.28),"a07860"),"hair")
   F.ball(avatar.head,Vector3(side*0.36,0.2,0.1),Vector3(0.14,0.08,0.04),"e7c1d5")
 else:
  avatar.skirt.hide()
  avatar.head.get_node("Hair_ChestnutBob").scale=Vector3(0.91,0.76,0.92)
  for x in [-0.13,0.13]: F.box(avatar.body,Vector3(x,0.63,0),Vector3(0.21,0.48,0.23),"9caaa5",0.04)
  F.cylinder(avatar.head,Vector3(0,0.3,-0.03),0.36,0.31,0.12,"aac1ae")
  F.box(avatar.head,Vector3(0,0.25,0.22),Vector3(0.5,0.05,0.35),"aac1ae",0.07)
  F.box(avatar.body,Vector3(0,1.1,0.15),Vector3(0.42,0.33,0.06),"bdcdbf",0.03)
 var nameplate:=Label3D.new();nameplate.text=person.capitalize();nameplate.font_size=28;nameplate.pixel_size=0.0045;nameplate.outline_size=3;nameplate.outline_modulate=Color("fff5ed");nameplate.position.y=2.05;nameplate.billboard=BaseMaterial3D.BILLBOARD_ENABLED;nameplate.modulate=Color("78627d");add_child(nameplate)
 add_to_group("interactables")
 add_to_group("neighbors")
 position=start
 collision_layer=0
 hide()
func invite() -> bool:
 if mode!=Mode.AWAY: return false
 var safe:=false
 var arrival:=start
 for candidate in [start,Vector3(15.2,0,4.2),Vector3(16.5,0,3.5)]:
  if Vector2(candidate.x-game.player.position.x,candidate.z-game.player.position.z).length()<0.85: continue
  var occupied:=false
  for other in get_tree().get_nodes_in_group("neighbors"):
   if other!=self and other.visible and other.position.distance_to(candidate)<0.6: occupied=true
  if not occupied: arrival=candidate;safe=true;break
 if not safe: return false
 show();collision_layer=2;position=arrival;mode=Mode.ARRIVING;elapsed=0;visits+=1
 route.assign([Vector3(15.8,0,3.6),Vector3(13.3,0,2.7),social])
 return true
func available(pos: Vector3) -> bool: return mode not in [Mode.AWAY,Mode.LEAVING] and Vector2(pos.x-position.x,pos.z-position.z).length()<1.65
func interaction_position() -> Vector3: return global_position+Vector3(0,1.35,0)
func talk() -> void:
 mode=Mode.TALKING;velocity=Vector3.ZERO
 var d: Vector3=game.player.global_position-global_position
 avatar.rotation.y=atan2(d.x,d.z)
 avatar.home_action="reach"
func end_talk(leave: bool=false) -> void:
 avatar.home_action="";elapsed=0
 if leave:
  mode=Mode.LEAVING;route.assign([Vector3(13.3,0,2.7),Vector3(15.8,0,3.6),start])
 else: mode=Mode.WAITING;route.clear()
func _physics_process(delta: float) -> void:
 if mode==Mode.AWAY: return
 clock+=delta;elapsed+=delta
 if mode==Mode.TALKING:
  avatar.animate(delta,0,false,false);return
 if not route.is_empty():
  var d: Vector3=route[0]-position;d.y=0
  if d.length()<0.16:
   route.pop_front()
   if route.is_empty():
    elapsed=0
    if mode==Mode.LEAVING: mode=Mode.AWAY;collision_layer=0;hide();return
    mode=Mode.WAITING
  else:
   var blocked: bool=Vector2(game.player.position.x-position.x,game.player.position.z-position.z).length()<0.85
   var desired:=d.normalized()*0.9 if not blocked else Vector3.ZERO
   velocity.x=desired.x;velocity.z=desired.z;velocity.y=-0.2
   move_and_slide()
   if desired.length()>0.1: avatar.rotation.y=lerp_angle(avatar.rotation.y,atan2(desired.x,desired.z),1-exp(-6*delta))
   avatar.animate(delta,Vector2(velocity.x,velocity.z).length(),false,false)
   return
 avatar.animate(delta,0,false,false)
 avatar.home_action="rest" if mode==Mode.VISITING else ""
 avatar.head.rotation.y=sin(clock*0.7)*(0.09 if person=="noah" else 0.16)
 if mode==Mode.WAITING and elapsed>18:
  mode=Mode.WANDERING;elapsed=0
  route.assign([social+Vector3(0.6,0,0.6),social])
 if mode==Mode.WAITING and visits%2==0 and elapsed>7:
  mode=Mode.VISITING;elapsed=0
 if mode==Mode.VISITING and elapsed>6: mode=Mode.WAITING;elapsed=0
