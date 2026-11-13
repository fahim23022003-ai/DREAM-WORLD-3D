extends Node
const L=preload("res://scripts/cozy_story_rules.gd")
var nb: Node
var home: Node
var game: Node3D
var world: Node3D
var reservations: Dictionary={}
var active_kind:=""
var active_npc:=""
var active_both:=false
var active_plot:=-1
var phase:=""
var routes: Dictionary={}
var poses: Dictionary={}
var phase_clock:=0.0
var choice:="berry"
var ambience_clock:=0.0
func setup(neighborhood: Node) -> void:
 nb=neighborhood;home=nb.home;game=nb.game
 world=preload("res://scripts/cozy_social_world.gd").new();game.add_child(world)
 nb.world.station("garden.picnic",Vector3(11.2,0,2.8),"Share a garden picnic")
 nb.world.station("garden.gathering",Vector3(14.4,0,2.3),"Ring the gathering bell")
 preload("res://scripts/cozy_art.gd").interiors(game.room,home.rooms)
 var exclude: Array=nb.world.soil.duplicate();exclude.append_array(nb.world.bulbs)
 for values in nb.world.surfaces.values(): exclude.append_array(values)
 preload("res://scripts/cozy_art.gd").batch_static(nb.world,exclude)
 preload("res://scripts/cozy_art.gd").batch_static(nb.world.flowers)
 for prop in game.room.get_children():
  if prop.get_script()==load("res://scripts/prop.gd") and prop.kind in ["sofa","table","shelf","ottoman","console"]: preload("res://scripts/cozy_art.gd").batch_static(prop,[],0)
 var interior_exclude: Array=home.rooms.window_skies.duplicate()
 for values in home.rooms.surfaces.values(): interior_exclude.append_array(values)
 preload("res://scripts/cozy_art.gd").batch_static(home.rooms,interior_exclude)
 preload("res://scripts/cozy_art.gd").batch_static(game.room,[game.room.window_sky])
 refresh()
func refresh() -> void:
 if world: world.apply(home.rules.data.life)
func open_activities(id: String) -> void:
 home.open_shell("A little time together")
 home.panel.text("With "+id.capitalize()+" · one shared-activity friendship bonus per day",15)
 for kind in L.ACTIVITIES:
  home.panel.button(L.ACTIVITIES[kind].name,func(): activity_choice(kind,id),kind=="tea","leaf")
 home.panel.button("Rest on the garden bench",func(): home.close();try_relax(nb.actors[id]);game.ui.show_notice("A little room, please — I’ll meet you on the bench."))
 home.panel.text("These moments have no deadline. A finished activity may advance your story even when today's friendship bonus is already used.",14)
 home.panel.footer()
func activity_choice(kind: String,id: String) -> void:
 home.open_shell(L.ACTIVITIES[kind].name)
 home.panel.text(L.ACTIVITIES[kind].hint,17)
 if kind=="tea":
  home.panel.button("Berry tea · a cheerful toast",func(): begin_activity(kind,id,"berry"),true)
  home.panel.button("Lavender tea · a quiet thank-you",func(): begin_activity(kind,id,"lavender"))
 elif kind=="picnic":
  home.panel.button("Trade funny stories",func(): begin_activity(kind,id,"stories"),true)
  home.panel.button("Watch cloud shapes",func(): begin_activity(kind,id,"clouds"))
 else: home.panel.button("Tend a dry crop together",func(): begin_activity(kind,id,"care"),true)
 home.panel.footer()
func open_stories(id: String="",selected: String="") -> void:
 home.open_shell("Stories of Rosewater",true)
 home.panel.panel.custom_minimum_size=Vector2(900,0);home.panel.panel.size=Vector2(900,0)
 var tabs:=HBoxContainer.new();home.panel.col.add_child(tabs)
 var available: Array=L.ARCS.keys().filter(func(arc): return id.is_empty() or L.ARCS[arc].npc in [id,"both"])
 if selected.is_empty() or not selected in available: selected=available[0]
 for arc in available:
  var tab: Button=game.ui.button(L.ARCS[arc].name,func(): open_stories(id,arc),arc==selected);tab.custom_minimum_size=Vector2(270,42);tab.add_theme_font_size_override("font_size",14);tabs.add_child(tab)
 var stage: int=home.rules.data.life.arcs[selected]
 var def: Dictionary=L.ARCS[selected]
 var done: bool=selected in home.rules.data.life.rewards
 var words: String=def.steps[maxi(0,stage-1)] if stage<=def.steps.size() else "A memory that stays with your home."
 home.panel.card(def.name,words,def.reward,done,840)
 var friend: bool=nb.data().people.mimi.xp>=4 if def.npc=="both" else nb.data().people[def.npc].xp>=4
 home.panel.text(("We already have a little rhythm together. Shall we make something worth remembering?" if friend else "I'd like to make a small corner of this world a little warmer. Will you help?") if not done else "No need to begin again. We made this memory together.",17)
 home.panel.text("Optional · no deadline · chapters and one-time rewards survive Continue.",14)
 if selected=="baking" and stage<=1: home.panel.text("One freshly harvested strawberry will be set aside for Mimi's special treat.",14)
 if stage==0:
  var arc: String=selected
  home.panel.button("Begin "+def.name,func():
   var started:={"ok":false}
   if home.commit(func(): started.ok=L.begin(home.rules.data,arc)):
    if not started.ok: home.panel.status.text="Meet both friends and finish one personal story first. Your gathering will wait."
    else: open_stories(id,arc),true)
 home.panel.footer()
func try_relax(npc: Node3D) -> bool:
 var key: String="bench."+npc.person
 if reservations.has(key) or not active_kind.is_empty(): return false
 reservations[key]=npc.person
 var x: float=14.25 if npc.person=="mimi" else 15.65
 npc.seat_key=key;npc.seat_point=Vector3(x,0.65-0.59*npc.avatar.scale.y,-4.02);npc.seat_facing=0
 npc.route.assign([Vector3(13.55,0,0.2),Vector3(13.55,0,-3.2),Vector3(x,0,-3.18)])
 npc.mode=npc.Mode.WANDERING;npc.elapsed=0
 return true
func release(npc: Node) -> void:
 if reservations.get(npc.seat_key)==npc.person: reservations.erase(npc.seat_key)
 npc.seat_key="";npc.seated_requested=false
 npc.collider.position=Vector3(0,0.84,0);npc.collider.shape.height=1.65
func begin_activity(kind: String,id: String,selected: String="berry") -> void:
 if not active_kind.is_empty(): return
 var people: Array=[id]
 var both: bool=kind in ["picnic","gathering"] and home.rules.data.life.arcs.warming>=2
 if both: people=["mimi","noah"]
 var missing: Array[String]=[]
 for person in people:
  if nb.actors[person].mode==nb.actors[person].Mode.AWAY:
   nb.invite(person);missing.append(person.capitalize())
 if not missing.is_empty():
  var notice: String=", ".join(missing)+" walking in. Start when your friends reach the patio."
  if is_instance_valid(home.panel): home.panel.status.text=notice
  else: game.ui.show_notice(notice)
  return
 active_plot=-1
 if kind=="help":
  for i in range(3):
   var p: Dictionary=nb.data().plots[i]
   if p.stage in [1,2,3] and p.water_day!=home.rules.data.day: active_plot=i;break
  if active_plot<0: home.panel.status.text="Plant a seed, or choose an unwatered crop first. No care or harvest can be duplicated.";return
 game.player.social_owned=true
 active_kind=kind;active_npc=id;active_both=both;choice=selected;phase="approach";phase_clock=0;routes.clear();poses.clear()
 nb.speaking=""
 home.open_shell("A moment together")
 home.panel.text("Walking to our places…",18);home.panel.text("Esc safely cancels. Progress is saved only after the activity.",13);home.panel.footer()
 for person in people:
  var npc: Node=nb.actors[person];release(npc);npc.route.clear();npc.activity_owned=true;npc.avatar.home_action="";npc.avatar.expression="happy" if person=="mimi" else "shy"
 var destinations: Dictionary={}
 if kind=="tea": destinations={"player":Vector3(8.2,0,2.75),id:Vector3(8.2,0,4.45)}
 elif kind in ["picnic","gathering"]:
  destinations={"player":Vector3(11.0,0,3.45),id:Vector3(12.8,0,3.45)}
  if both: destinations={"player":Vector3(11,0,3.45),"mimi":Vector3(12.8,0,3.45),"noah":Vector3(12,0,4.5)}
 else: destinations={"player":Vector3(9+active_plot*3-0.6,0,-0.4),id:Vector3(9+active_plot*3+0.6,0,-0.4)}
 for who in destinations:
  var body: CharacterBody3D=game.player if who=="player" else nb.actors[who]
  var path: Array[Vector3]=[]
  if body.position.z< -0.5:
   if absf(body.position.x-13.55)>0.35: path.append(Vector3(13.55,0,-3.2))
   path.append(Vector3(13.55,0,0.25))
  if kind=="tea": path.append(Vector3(9.35,0,2.1));path.append(Vector3(9.35,0,2.75 if who=="player" else 4.45))
  else: path.append(Vector3(destinations[who].x,0,1.8 if kind=="help" else 2.2))
  path.append(destinations[who]);routes[who]=path
  var yaw: float=PI if kind=="help" else 0 if who=="player" else PI
  var offset:=Vector3.ZERO
  if kind=="tea": offset.y=0.53-0.59*body.avatar.scale.y
  elif kind in ["picnic","gathering"]:
   offset.y=-0.31*body.avatar.scale.y if kind=="picnic" else 0.0;body.avatar.social_pose="picnic" if kind=="picnic" else "";yaw=atan2(12-destinations[who].x,3.9-destinations[who].z)
  poses[who]={"offset":offset,"yaw":yaw}
 game.camera_rig.focus_offset=Vector3(10.3,1,3.5)-game.player.position-Vector3(0,1.25,0)
 game.camera_rig.yaw=0.15;game.camera_rig.pitch=0.22;game.camera_rig.distance=6.5
func show_ready() -> void:
 phase="seated";phase_clock=0
 world.tea.visible=active_kind=="tea";world.picnic.visible=active_kind in ["picnic","gathering"]
 if active_kind=="gathering": world.celebrate()
 game.audio.play("sit" if active_kind in ["tea","picnic"] else "social")
 home.open_shell(L.ACTIVITIES[active_kind].name if active_kind in L.ACTIVITIES else "Rosewater housewarming")
 home.panel.panel.position=Vector2(766,330);home.panel.panel.custom_minimum_size=Vector2(420,0);home.panel.panel.size=Vector2(480,0)
 var close_friend: bool=nb.data().people[active_npc].xp>=4
 home.panel.text(("Same friends, a new little moment. Our lanterns still remember." if active_kind=="gathering" and "warming" in home.rules.data.life.rewards else "It feels like our little tradition now." if close_friend else "I wasn't sure what to bring. I'm glad I came.")+ (" Mimi raises her berry cup with a grin." if choice=="berry" else " The lavender blend makes room for an easy silence." if choice=="lavender" else " We point out a funny cloud." if choice=="clouds" else " A shared laugh settles over the garden."),15)
 home.panel.button("Keep this memory",finish_activity,true,"check")
 home.panel.footer()
func finish_activity() -> void:
 if phase!="seated": return
 var result: Dictionary={"ok":false}
 var ok: bool=home.commit(func():
  if active_kind=="help":
   var crop: String=nb.data().plots[active_plot].crop
   var watered: Dictionary=nb.N.action(home.rules.data,"garden_water",{"plot":active_plot})
   if not watered.ok: return
   L.observe(home.rules.data,"garden_water",{"crop":crop})
   home.rules.event("garden_water","%d:shared:water:%d" % [home.rules.data.day,active_plot])
  if active_kind=="gathering":
   var remembered: bool="warming" in home.rules.data.life.rewards
   L.observe(home.rules.data,"toast",{"both":active_both});result.merge({"ok":true,"message":"Our lanterns remember. There is room for another little gathering." if remembered else "A house becomes home through the people we welcome."},true)
  else: result.merge(L.activity(home.rules.data,active_kind,active_npc,choice,active_both),true)
  if result.ok:
   nb.N.achieve(home.rules.data)
   home.rules.event("friendship","%d:shared:%s" % [home.rules.data.day,active_npc]))
 if not ok: home.panel.status.text="Not saved. Your progress is safe. Keep this memory again to retry.";return
 if not result.ok: home.panel.status.text="That crop is already cared for. Choose a new dry crop.";return
 if not result.get("levelups",[]).is_empty(): game.audio.play("friendship")
 if active_kind=="help": nb.world.water_at(active_plot);game.audio.play("garden_water")
 game.audio.play("story" if active_kind=="gathering" else "shared")
 world.celebrate();home.panel.status.text=result.message
 for who in poses:
  var body: Node3D=game.player if who=="player" else nb.actors[who];body.avatar.home_action="happy";body.avatar.expression="happy"
 phase="complete";phase_clock=0
 home.panel.button("Back to the garden",func(): home.close(),true,"home")
func cancel() -> void:
 if active_kind.is_empty(): return
 for who in poses:
  var body: Node3D=game.player if who=="player" else nb.actors[who]
  body.avatar.social_pose="";body.avatar.home_action="";create_tween().tween_property(body.avatar,"position",Vector3.ZERO,0.4);body.velocity=Vector3.ZERO
  if who!="player": body.activity_owned=false;body.end_talk()
 game.player.social_owned=false
 world.tea.hide();world.picnic.hide();active_kind="";phase="";routes.clear();poses.clear();game.audio.play("stand")
func _physics_process(delta: float) -> void:
 if active_kind.is_empty(): return
 phase_clock+=delta
 if phase=="approach" and phase_clock<0.55:
  for who in poses:
   var actor: CharacterBody3D=game.player if who=="player" else nb.actors[who]
   actor.avatar.position=actor.avatar.position.lerp(Vector3.ZERO,1-exp(-8*delta));actor.avatar.animate(delta,0,false,false)
  return
 var point: Vector3=Vector3(8.2,1,3.05) if active_kind=="tea" else Vector3(11.6,0.9,3.9) if active_kind in ["picnic","gathering"] else Vector3(9+active_plot*3,1,-0.8)
 game.camera_rig.focus_offset=point-game.player.position-Vector3(0,1.25,0)
 game.camera_rig.yaw=PI/2 if active_kind=="tea" else PI if active_kind in ["picnic","gathering"] else 0.65
 game.camera_rig.pitch=0.18;game.camera_rig.distance=5.8
 var arrived:=true
 for who in poses:
  var body: CharacterBody3D=game.player if who=="player" else nb.actors[who]
  var path: Array=routes[who]
  if phase=="approach" and not path.is_empty():
   var d: Vector3=path[0]-body.position;d.y=0
   if d.length()<0.12:
    path.pop_front()
    if not path.is_empty(): arrived=false
   else:
    arrived=false;body.velocity=d.normalized()*1.7;body.velocity.y=-0.1;body.move_and_slide();body.avatar.rotation.y=lerp_angle(body.avatar.rotation.y,atan2(d.x,d.z),1-exp(-8*delta));body.avatar.animate(delta,1.7,false,false)
   continue
  body.velocity=Vector3.ZERO
  var sitting: bool=active_kind in ["tea","picnic"]
  body.avatar.position=body.avatar.position.lerp(poses[who].offset,1-exp(-4*delta))
  body.avatar.rotation.y=lerp_angle(body.avatar.rotation.y,poses[who].yaw,1-exp(-5*delta))
  body.avatar.animate(delta,0,false,sitting)
  body.avatar.home_action=("give" if phase_clock<1.2 else "happy") if phase=="complete" else "reach" if active_kind=="help" else ""
 if phase=="approach" and arrived: show_ready()
 # No timed rewards. Player can cancel a blocked approach and try again without loss.
func summary() -> void:
 var s: Dictionary=home.rules.data.life.last_summary
 if s.is_empty(): return
 home.open_shell("A day worth keeping",true)
 home.panel.text("Day %d · +%d Cozy Coins earned" % [s.day,s.earned],21)
 var moments: Array=s.get("moments",[])
 home.panel.card("Little moments", " · ".join(moments.slice(-4)) if not moments.is_empty() else "A quiet day at home is a day too.","Your pace, your home",true,840)
 home.panel.card("Friends & growing things","Mimi %d/12 (+%d) · Noah %d/12 (+%d) · %d planted beds" % [s.friends.mimi,s.get("friendship_gains",{}).get("mimi",0),s.friends.noah,s.get("friendship_gains",{}).get("noah",0),s.garden],"Memories kept: %d" % s.stories.size(),true,840)
 home.panel.text("Tomorrow: "+" · ".join(home.rules.goals().map(func(id): return home.rules.goal_definitions()[id])),14)
 home.panel.button("Start the morning",func(): home.close(),true,"play");home.panel.footer();game.audio.play("day_end")
func _process(delta: float) -> void:
 ambience_clock+=delta
 if game.active and ambience_clock>35:
  game.audio.play("evening" if home.rules.data.period>=2 else "interior" if game.player.position.x<6 else "garden");ambience_clock=0
