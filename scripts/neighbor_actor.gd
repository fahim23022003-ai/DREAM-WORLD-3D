extends CharacterBody3D
const F=preload("res://scripts/forms.gd")
var collider: CollisionShape3D
var gift: Node3D
var talk_facing:=0.0
var gesture_until:=0.0
var gesture_kind:=""
var activity_owned:=false
var seat_key:=""
var seat_point:=Vector3.ZERO
var seat_facing:=0.0
var seated_requested:=false
var stand_clock:=0.0
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
 var collision:=CollisionShape3D.new();collider=collision;var capsule:=CapsuleShape3D.new();capsule.radius=0.25;capsule.height=1.65;collision.shape=capsule;collision.position.y=0.84;add_child(collision)
 avatar=load("res://scripts/avatar.gd").new();add_child(avatar)
 avatar.scale=Vector3.ONE*(0.88 if person=="mimi" else 0.95)
 avatar.apply_appearance({"hair":Color("a07860" if person=="mimi" else "665e56"),"accent":Color("e2a7bf" if person=="mimi" else "a5c3b4")})
 if person=="mimi":
  F.finish(F.box(avatar.body,Vector3(0,1.025,0.2),Vector3(0.25,0.26,0.025),"f4e4cf"),"fabric")
  F.finish(F.box(avatar.skirt,Vector3(0,-0.19,0.29),Vector3(0.32,0.28,0.03),"f4e4cf"),"fabric")
  F.rod(avatar.body,Vector3(-0.18,0.9,0.25),Vector3(0.18,0.9,0.25),0.022,"c4a17d")
  avatar.expression="happy"
  for side in [-1,1]:
   F.finish(F.ball(avatar.head,Vector3(side*0.36,0.21,-0.04),Vector3(0.31,0.31,0.28),"a07860"),"hair")
   F.ball(avatar.head,Vector3(side*0.36,0.2,0.1),Vector3(0.14,0.08,0.04),"e7c1d5")
 else:
  avatar.skirt.hide()
  avatar.expression="shy"
  for ribbon in avatar.find_children("RibbonAccessory*","MeshInstance3D",true,false): ribbon.hide()
  avatar.head.get_node("Hair_ChestnutBob").scale=Vector3(0.91,0.76,0.92)
  for x in [-0.13,0.13]: F.box(avatar.left_leg if x<0 else avatar.right_leg,Vector3(0,-0.15,0),Vector3(0.18,0.32,0.2),"9caaa5",0.04)
  F.cylinder(avatar.head,Vector3(0,0.3,-0.03),0.36,0.31,0.12,"aac1ae")
  F.box(avatar.head,Vector3(0,0.25,0.22),Vector3(0.5,0.05,0.35),"aac1ae",0.07)
  F.box(avatar.body,Vector3(0,1.1,0.15),Vector3(0.42,0.33,0.06),"bdcdbf",0.03)
 gift=Node3D.new();avatar.right_arm.add_child(gift)
 F.box(gift,Vector3(0,-0.36,0.09),Vector3(0.22,0.16,0.2),"e6bdd0" if person=="mimi" else "b1c9b7")
 F.box(gift,Vector3(0,-0.27,0.09),Vector3(0.035,0.012,0.2),"f5e1bf");gift.hide()
 var nameplate:=Label3D.new();nameplate.text=person.capitalize();nameplate.font_size=28;nameplate.pixel_size=0.0045;nameplate.outline_size=3;nameplate.outline_modulate=Color("fff5ed");nameplate.position.y=2.05;nameplate.billboard=BaseMaterial3D.BILLBOARD_ENABLED;nameplate.modulate=Color("78627d");avatar.add_child(nameplate)
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
 if not seat_key.is_empty(): game.home.neighborhood.life.release(self)
 stand_clock=0.5 if avatar.position.length()>0.01 else 0.0
 mode=Mode.TALKING;velocity=Vector3.ZERO
 var d: Vector3=game.player.global_position-global_position
 talk_facing=atan2(d.x,d.z)
 elapsed=0
 avatar.home_action="wave" if person=="mimi" else "reach"
func react(kind: String) -> void:
 gesture_kind=kind;gesture_until=clock+1.8;avatar.expression="happy"
func end_talk(leave: bool=false) -> void:
 if not seat_key.is_empty(): game.home.neighborhood.life.release(self)
 seated_requested=false;stand_clock=0.65
 avatar.home_action="";elapsed=0
 var exit_path: Array[Vector3]=[]
 if position.z< -0.5:
  if absf(position.x-13.55)>0.35: exit_path.append(Vector3(13.55,0,-3.2))
  exit_path.append(Vector3(13.55,0,0.25))
 elif position.x<9.3 and position.z>3.1: exit_path.assign([Vector3(9.35,0,4.45),Vector3(9.35,0,2.15)])
 if leave:
  mode=Mode.LEAVING;exit_path.append_array([Vector3(13.3,0,2.7),Vector3(15.8,0,3.6),start]);route.assign(exit_path)
 elif not exit_path.is_empty():
  mode=Mode.WANDERING;exit_path.append(social);route.assign(exit_path)
 else: mode=Mode.WAITING;route.clear()
func sync_seat_collision() -> void:
 var blend: float=avatar.sit_blend if seated_requested else 0.0
 collider.position=Vector3(avatar.position.x,lerpf(0.84,1.4,blend),avatar.position.z)
 collider.shape.height=lerpf(1.65,1.0,blend)
func _physics_process(delta: float) -> void:
 if mode==Mode.AWAY or activity_owned: return
 if stand_clock>0:
  stand_clock-=delta;avatar.position=avatar.position.lerp(Vector3.ZERO,1-exp(-8*delta));avatar.animate(delta,0,false,false)
  if stand_clock<=0: avatar.position=Vector3.ZERO
  sync_seat_collision()
  return
 clock+=delta;elapsed+=delta
 gift.visible=clock<gesture_until and gesture_kind=="give"
 if mode==Mode.TALKING:
  avatar.rotation.y=lerp_angle(avatar.rotation.y,talk_facing,1-exp(-7*delta))
  avatar.home_action=gesture_kind if clock<gesture_until else "wave" if elapsed<1.2 and person=="mimi" else "present" if person=="mimi" else "reach"
  avatar.animate(delta,0,false,false);return
 if not route.is_empty():
  var d: Vector3=route[0]-position;d.y=0
  if d.length()<0.16:
   route.pop_front()
   if route.is_empty():
    elapsed=0
    if mode==Mode.LEAVING: mode=Mode.AWAY;collision_layer=0;hide();return
    mode=Mode.VISITING if not seat_key.is_empty() else Mode.WAITING
    seated_requested=not seat_key.is_empty()
  else:
   var to_player: Vector3=game.player.position-position;to_player.y=0
   var blocked: bool=to_player.length()<0.85 and d.normalized().dot(to_player.normalized())>0.0
   var desired:=d.normalized()*0.9 if not blocked else Vector3.ZERO
   velocity.x=desired.x;velocity.z=desired.z;velocity.y=-0.2
   move_and_slide()
   if desired.length()>0.1: avatar.rotation.y=lerp_angle(avatar.rotation.y,atan2(desired.x,desired.z),1-exp(-6*delta))
   avatar.animate(delta,Vector2(velocity.x,velocity.z).length(),false,false)
   return
 avatar.animate(delta,0,false,seated_requested)
 if seated_requested:
  avatar.position=avatar.position.lerp(seat_point-position,1-exp(-5*delta));avatar.rotation.y=lerp_angle(avatar.rotation.y,seat_facing,1-exp(-5*delta))
 sync_seat_collision()
 avatar.home_action="wave" if elapsed<1.6 else ""
 avatar.head.rotation.y=sin(clock*0.7)*(0.09 if person=="noah" else 0.16)
 if mode==Mode.WAITING and elapsed>18:
  if position.z< -0.5 or (position.x<9.3 and position.z>3.1): end_talk()
  else:
   mode=Mode.WANDERING;elapsed=0
   route.assign([social+Vector3(0.6,0,0.6),social])
 if mode==Mode.WAITING and visits%2==0 and elapsed>7:
  game.home.neighborhood.life.try_relax(self)
 if mode==Mode.VISITING and elapsed>12 and position.distance_to(game.player.position)>1.35: end_talk()
