extends Node
const N=preload("res://scripts/neighborhood_rules.gd")
const F=preload("res://scripts/friendship_rules.gd")
const G=preload("res://scripts/garden_rules.gd")
var life: Node
var home: Node
var game: Node3D
var world: Node3D
var actors: Dictionary={}
var speaking := ""
var message := ""
var entered := false
var audio_clock:=0.0
var invited_day: Dictionary={"mimi":0,"noah":0}
var last_day:=0
func setup(controller: Node) -> void:
 home=controller;game=home.game
 world=preload("res://scripts/garden_world.gd").new();game.add_child(world)
 game.player.collision_mask=3
 for id in F.PEOPLE:
  var npc:=preload("res://scripts/neighbor_actor.gd").new();npc.person=id;npc.game=game;game.add_child(npc);actors[id]=npc
 life=preload("res://scripts/cozy_life_controller.gd").new();add_child(life);life.setup(self)
 refresh()
func data() -> Dictionary: return home.rules.data.neighborhood
func refresh() -> void:
 if not is_instance_valid(world): return
 if last_day!=home.rules.data.day:
  if last_day>0:
   for npc in actors.values():
    if npc.mode!=npc.Mode.AWAY: npc.end_talk(true)
  last_day=home.rules.data.day
 world.apply(data(),home.rules.data)
 if life: life.refresh()
func handles(id: String) -> bool: return id.begins_with("neighbor.") or world.stations.has(id)
func activate(id: String) -> void:
 if id.begins_with("neighbor."):
  var person:=id.trim_prefix("neighbor.")
  actors[person].talk();speaking=person;conversation(person)
 elif id.begins_with("garden.plot"): plot_panel(int(id.trim_prefix("garden.plot")))
 elif id=="garden.board": journal()
 elif id=="garden.picnic": life.open_activities("mimi" if actors.mimi.visible else "noah")
 elif id=="garden.gathering": life.begin_activity("gathering","mimi","stories") if home.rules.data.life.arcs.warming>=3 else game.ui.show_notice("A future gathering · L → Stories of Rosewater")
 elif id=="garden.rest":
  home.record("rest");home.gesture("rest");game.audio.play("bedroom");game.ui.show_notice("A slow breath · "+home.rules.period())
 elif id=="garden.bloom": event_action("bloom")
 elif id=="garden.moon": event_action("moon")
 elif id=="garden.lost": event_action("lost")
func transact(kind: String,info: Dictionary={}) -> Dictionary:
 var result: Dictionary={}
 var ok: bool=home.commit(func():
  var crop: String=info.get("crop","")
  if kind in ["garden_water","harvest"] and info.get("plot",-1) in [0,1,2]: crop=data().plots[info.plot].crop
  result.merge(N.action(home.rules.data,kind,info),true)
  if result.get("ok",false):
   var detail:=info.duplicate();detail.crop=crop
   home.RULES.LIFE.observe(home.rules.data,kind,detail)
  if result.get("ok",false):
   for goal in result.matches:
    var token: String="%d:nb:%s:%s" % [home.rules.data.day,goal,info.get("npc",info.get("plot","event"))]
    home.rules.event(goal,token))
 if not ok: return {"ok":false,"message":"Not saved. Previous progress is safe. Retry this action; nothing was charged."}
 if result.get("reward",false): game.audio.play("friendship")
 refresh()
 return result
func plot_panel(i: int) -> void:
 var p: Dictionary=data().plots[i]
 home.open_shell("A little patch of possibility")
 home.panel.text("Spot %d · %s" % [i+1,G.STAGES[p.stage]],21)
 home.panel.text("Seeds are free. Water once, enjoy another activity, then sleep for harvest. Plants never die while you're away.",14)
 if p.stage==0:
  for id in G.CROPS:
   home.panel.button("Plant "+G.CROPS[id].name,func(): plot_action("plant",i,id),false,"leaf")
 else:
  home.panel.text(G.CROPS[p.crop].name+" · "+("Watered today ✓" if p.water_day==home.rules.data.day else "Ready for a little care"),17)
  if p.stage==4: home.panel.button("Harvest crop",func(): plot_action("harvest",i),true,"check")
  else:
   var button: Button=home.panel.button("Water crop",func(): plot_action("garden_water",i),true,"leaf")
   button.disabled=p.water_day==home.rules.data.day
 home.panel.footer()
func plot_action(kind: String,i: int,crop: String="") -> void:
 var result:=transact(kind,{"plot":i,"crop":crop})
 if not result.ok: home.panel.status.text=result.message;return
 home.close();home.gesture("garden")
 if kind=="garden_water": world.water_at(i)
 game.audio.play({"plant":"plant","garden_water":"garden_water","harvest":"harvest"}[kind])
 game.ui.show_notice(result.message)
func conversation(id: String) -> void:
 var p: Dictionary=data().people[id]
 home.open_shell(F.PEOPLE[id].name+" · "+F.title(p.xp,p.days.size()))
 home.panel.panel.position=Vector2(766,60)
 home.panel.text("Friendship %d / 12 · Level %d · %d/7 shared days" % [p.xp,F.level(p.xp,p.days.size()),mini(p.days.size(),7)],19)
 var words: String=message if not message.is_empty() else F.dialogue(id,p,home.rules.data.day,home.rules.data.period,data().last_meal_day==home.rules.data.day)
 if message.is_empty() and not data().event.done:
  var context: Dictionary={"surprise":"I have a small wish for this visit. Shall we make a plan?","bloom":"The flower patch by the fence has a little gift today.","baking":"It's a perfect day to bake berry cupcakes together!","lost":"I left my ribbon on the living-room console. Could you look for it?","friendship":"Later light is lovely for a quiet moment together.","moon":"The patio lantern has a different glow after sunset."}
  words+="\n"+context[data().event.id]
 home.panel.speech(words)
 var progress:=ProgressBar.new();progress.max_value=12;progress.value=p.xp;progress.show_percentage=false;progress.custom_minimum_size=Vector2(420,12);home.panel.col.add_child(progress)
 var topics:=HBoxContainer.new();home.panel.col.add_child(topics)
 for entry in [["Baking stories","baking"],["Garden stories","garden"]]:
  var topic: Button=game.ui.button(entry[0],func(): social_action("chat",id,{"choice":entry[1]}));topic.custom_minimum_size.x=205;topics.add_child(topic)
 var actions:=HBoxContainer.new();home.panel.col.add_child(actions)
 for entry in [["Share fresh food","share"],["Quiet moment","moment"]]:
  var b: Button=game.ui.button(entry[0],func(): social_action(entry[1],id));b.custom_minimum_size.x=205
  if entry[1]=="share": b.disabled=data().last_meal_day!=home.rules.data.day or p.share_day==home.rules.data.day
  else: b.disabled=data().event.id!="friendship" or data().event.done or home.rules.data.period<1
  actions.add_child(b)
 home.panel.button("Visitor request",func(): request_panel(id),true,"home")
 var plans:=HBoxContainer.new();home.panel.col.add_child(plans)
 for entry in [["Shared activities",0],["Our stories",1]]:
  var b: Button=game.ui.button(entry[0],func(): life.open_activities(id) if entry[1]==0 else life.open_stories(id));b.custom_minimum_size=Vector2(205,36);plans.add_child(b)
 home.panel.button("See you later",func(): home.close();actors[id].end_talk(true),false,"close")
 home.panel.footer()
 for button in home.panel.panel.find_children("*","Button",true,false):
  button.custom_minimum_size.y=34
  if button.text not in ["Visitor request","Shared activities"]: button.add_theme_stylebox_override("normal",game.ui.style("f6eff3",10))
 home.panel.col.add_theme_constant_override("separation",7)
 # Eye-level side framing keeps the player out of the foreground.
 var point: Vector3=(actors[id].global_position+game.player.global_position)*0.5+Vector3(0,1.05,0)
 var yaw: float=conversation_yaw(actors[id],point)
 point+=Vector3(cos(yaw),0,-sin(yaw))*0.85
 game.camera_rig.focus_offset=point-game.player.position-Vector3(0,1.25,0)
 game.camera_rig.yaw=yaw;game.camera_rig.pitch=0.10;game.camera_rig.distance=4.6
func conversation_yaw(npc: CharacterBody3D,point: Vector3) -> float:
 var delta: Vector3=game.player.global_position-npc.global_position
 var facing: float=atan2(delta.x,delta.z)
 var best: float=facing+PI/2
 var clearance:=-1.0
 for side in [-PI/2,PI/2]:
  var yaw: float=facing+side
  var desired: Vector3=point+Vector3(sin(yaw)*4.6,0.46,cos(yaw)*4.6)
  var query:=PhysicsRayQueryParameters3D.create(point,desired,3,[game.player.get_rid(),npc.get_rid()])
  var hit: Dictionary=game.player.get_world_3d().direct_space_state.intersect_ray(query)
  var room: float=point.distance_to(hit.position) if not hit.is_empty() else 4.6
  if room>clearance: clearance=room;best=yaw
 return best
func social_action(kind: String,id: String,extra: Dictionary={}) -> void:
 extra.npc=id
 var result:=transact(kind,extra)
 message=result.message
 game.audio.play("conversation")
 if result.ok: actors[id].avatar.home_action="present"
 conversation(id)
func request_panel(id: String) -> void:
 var p: Dictionary=data().people[id]
 var request: String=p.request if not p.request.is_empty() else F.available_request(id,p)
 var def: Dictionary=F.REQUESTS[request]
 home.open_shell(F.PEOPLE[id].name+"'s small wish")
 home.panel.panel.position.x=766
 var ready: bool=p.request_ready or (not def.produce.is_empty() and data().produce[def.produce]>0)
 home.panel.card(def.name,def.text,"On sharing: %d coins · +3 friendship (up to 12)" % def.reward,ready)
 home.panel.text("No deadline · one request reward per friend/day",14)
 if p.request.is_empty():
  var accept: Button=home.panel.button("Accept request",func():
   var result:=transact("accept",{"npc":id})
   message=result.message
   request_panel(id),true,"check")
  accept.disabled=p.claim_day==home.rules.data.day
 else:
  home.panel.text("Ready to share ✓" if ready else "In progress · your promise is safe",17)
  home.panel.button("Share & claim reward",func():
   var result:=transact("claim",{"npc":id})
   message=result.message
   if result.ok: actors[id].react("give");home.gesture("give");game.audio.play("friendship");conversation(id)
   else: home.panel.status.text=result.message,true,"check")
  home.panel.button("Maybe another time",func():
   transact("decline",{"npc":id});message="No worries. You can ask again whenever you're ready.";conversation(id))
 home.panel.button("Back to conversation",func(): conversation(id))
 home.panel.footer()
 home.panel.status.text=message
func end_talk() -> void:
 if life: life.cancel()
 if not speaking.is_empty() and actors.has(speaking): actors[speaking].end_talk()
 speaking="";message=""
func event_action(id: String) -> void:
 var result:=transact("event",{"id":id})
 if result.ok: game.audio.play("event")
 game.ui.show_notice(result.message)
func journal(section: String="friends",page: int=0) -> void:
 home.open_shell("Cozy Connections",true)
 home.panel.panel.custom_minimum_size=Vector2(900,0);home.panel.panel.size=Vector2(900,0)
 var navigation:=HBoxContainer.new();home.panel.col.add_child(navigation)
 for entry in [["Friends","friends"],["Stories","stories"],["Keepsakes","keepsakes"],["Discoveries","discoveries"]]:
  var tab: Button=game.ui.button(entry[0],func(): life.open_stories() if entry[1]=="stories" else journal(entry[1]),section==entry[1]);tab.custom_minimum_size=Vector2(205,38);navigation.add_child(tab)
 var event: Dictionary=data().event
 var today: Button=home.panel.button("Today's moment · "+N.E.DEFINITIONS[event.id].name+(" ✓" if event.done else ""),event_panel,false,"leaf");today.custom_minimum_size.y=38
 # Fixed-page collection keeps headings and complete cards inside the viewport.
 # Retain a ScrollContainer for keyboard focus traversal, with scrolling disabled.
 var scroll:=ScrollContainer.new();scroll.custom_minimum_size=Vector2(840,310 if section=="keepsakes" else 220 if section=="friends" else 140);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;home.panel.col.add_child(scroll)
 var col:=VBoxContainer.new();col.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(col)
 if section=="friends":
  var friends:=HBoxContainer.new();friends.add_theme_constant_override("separation",12);col.add_child(friends)
  for id in F.PEOPLE:
   var person: Dictionary=data().people[id]
   var card: PanelContainer=home.panel.card(F.PEOPLE[id].name+" · "+F.title(person.xp,person.days.size()),F.PEOPLE[id].preference,"%d/12 XP · %d/7 shared days" % [person.xp,mini(person.days.size(),7)],F.level(person.xp,person.days.size())>=2,400,person.xp/12.0)
   home.panel.col.remove_child(card);friends.add_child(card)
   var content: VBoxContainer=card.get_child(0)
   var invite: Button=game.ui.button("Invite "+F.PEOPLE[id].name,func(): invite_message(id));invite.custom_minimum_size=Vector2(330,36);content.add_child(invite)
   if not person.request.is_empty():
    var promise: Label=game.ui.label("Promise: "+F.REQUESTS[person.request].name,13);promise.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;promise.custom_minimum_size.x=350;content.add_child(promise)
  col.add_child(game.ui.label("Shared days grow through moments together, never through offline waiting.",14))
 elif section=="keepsakes":
  var ids: Array=N.ACHIEVEMENTS.keys().slice(page*4,page*4+4)
  var row: HBoxContainer
  for index in range(ids.size()):
   if index%2==0:
    row=HBoxContainer.new();row.add_theme_constant_override("separation",12);col.add_child(row)
   var id: String=ids[index]
   var earned: bool=id in data().achievements
   var reward_card: PanelContainer=home.panel.card(("✓ " if earned else "○ ")+N.ACHIEVEMENTS[id],"Earned and displayed" if earned else N.CONDITIONS[id],N.REWARDS[id],earned,400)
   home.panel.col.remove_child(reward_card);row.add_child(reward_card)
  var turn: Button=game.ui.button("More keepsakes →" if page==0 else "← First keepsakes",func(): journal("keepsakes",1-page));turn.custom_minimum_size.y=32;col.add_child(turn)
 else:
  for crop in G.CROPS:
   var l: Label=game.ui.label(("✓ " if crop in data().discoveries else "○ ")+G.CROPS[crop].name+" · basket %d/9" % data().produce[crop]+" · optional topping for "+home.RULES.RECIPES[G.CROPS[crop].recipe].name,17);col.add_child(l)
  col.add_child(game.ui.label("Free seeds. No wilting while you are away. Your first harvest is a discovery.",14))
 home.panel.text("Close friends: 10 XP + 7 shared in-game days. Memories are displayed in your world.",13)
 home.panel.footer()
func event_panel() -> void:
 var event: Dictionary=data().event
 var definition: Dictionary=N.E.DEFINITIONS[event.id]
 home.open_shell("Today's moment")
 home.panel.panel.position.x=766
 home.panel.card(definition.name,definition.hint,"Event bonus: %d Cozy Coins" % definition.reward,event.done)
 home.panel.text("Completed and saved ✓" if event.done else "A small optional activity · no claim button or deadline pressure",17)
 home.panel.button("Back to journal",journal,false,"home")
 home.panel.footer()
 var point:=Vector3(10.4,0.9,-3.9) if event.id=="bloom" else Vector3(12.2,1,3.6)
 if event.id=="lost": point=Vector3(-5.25,1.1,0.6)
 game.camera_rig.focus_offset=point-game.player.position-Vector3(0,1.25,0)
 game.camera_rig.yaw=0.3;game.camera_rig.pitch=0.18;game.camera_rig.distance=4.4
func invite(id: String) -> bool:
 if not actors[id].invite(): return false
 invited_day[id]=home.rules.data.day
 return true
func invite_message(id: String) -> void:
 if invite(id):
  game.audio.play("arrival")
  home.panel.status.text=F.PEOPLE[id].name+" is walking in from the gate."
 else: home.panel.status.text=F.PEOPLE[id].name+" is already here, or waiting for clear space by the gate."
func priority_hint() -> String:
 if home.meal.stage in ["ingredients","prepared","ready"]: return ""
 if game.player.position.x>6.2:
  if not data().engaged: return "Your garden → E at a planter · free seeds\nMimi is walking in from the gate."
  if data().plots.any(func(p): return p.stage==4): return "A crop is ready! E at its planting spot to harvest."
  if not data().people.mimi.met: return "A friendly hello → approach Mimi and press E"
  for arc in home.RULES.LIFE.ARCS:
   var chapter: int=home.rules.data.life.arcs[arc]
   if chapter>0 and chapter<=home.RULES.LIFE.ARCS[arc].steps.size(): return "Our stories · L → Stories\n"+home.RULES.LIFE.ARCS[arc].steps[chapter-1]
  return "Ask a friend → Shared activities or Our stories\nL keeps your memories and today's event"
 for id in data().people:
  var p: Dictionary=data().people[id]
  if not p.request.is_empty():
   var def: Dictionary=F.REQUESTS[p.request]
   var ready: bool=p.request_ready or (not def.produce.is_empty() and data().produce[def.produce]>0)
   if ready: return F.PEOPLE[id].name+"'s wish is ready → visit the garden\nL invites a friend back if they've left."
   if not def.recipe.is_empty():
    var wanted: String="a Good or Perfect meal" if def.recipe=="good" else home.RULES.RECIPES[def.recipe].name
    return "For "+F.PEOPLE[id].name+" → "+wanted+"\nKitchen: left rear arch → blue fridge"
   return "For Noah → "+def.name+"\nGarden seeds are free. L keeps your promise safe."
 if not data().engaged: return "A garden is waiting → right-side living-room doorway\nFree seeds, a first harvest, and a friendly hello · L"
 return ""
func _process(delta: float) -> void:
 if not game: return
 audio_clock+=delta
 if game.active and game.player.position.x>6.2:
  if not entered:
   entered=true;invite("mimi");game.audio.play("arrival")
  for id in actors:
   var ready: bool=id=="mimi" or data().people.mimi.met or home.rules.data.day>=2
   if ready and invited_day[id]!=home.rules.data.day and actors[id].mode==actors[id].Mode.AWAY: invite(id)
  if audio_clock>45: game.audio.play("garden");audio_clock=0
 if home.rules.data.period==3:
  for npc in actors.values():
   if not npc.activity_owned and npc.mode==npc.Mode.WAITING and npc.elapsed>18: npc.end_talk(true)
