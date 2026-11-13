extends Node
## Integrates physical stations and modals; all economic mutations pass through commit().
const RULES=preload("res://scripts/home_rules.gd")
const COOKING=preload("res://scripts/cooking_rules.gd")
const PANEL=preload("res://scripts/home_panel.gd")
var neighborhood: Node
var game: Node3D
var rooms: Node3D
var rules: RefCounted
var meal:=COOKING.new()
var panel: Control
var strip: Label
var hint: Label
var draft: Dictionary={}
var last_gain := 0
var sleep_busy := false
var view_backup: Dictionary={}
var hint_panel: PanelContainer
var hint_clock := 0.0
var return_to_pause := false
func setup(owner_game: Node3D) -> void:
 game=owner_game
 rules=RULES.new(game.save.home)
 game.save.home=rules.data
 rooms=preload("res://scripts/home_rooms.gd").new()
 game.add_child(rooms)
 rooms.living_room=game.room
 for child in game.room.get_children():
  if child is WorldEnvironment: rooms.env=child.environment
  if child is DirectionalLight3D: rooms.sun=child
 rooms.period_blend=float(rules.data.period)
 rooms.apply_home(rules.data)
 strip=game.ui.label("",13,"756578")
 var badge:=PanelContainer.new()
 badge.position=Vector2(420,22)
 badge.add_theme_stylebox_override("panel",game.ui.style("fff8f0ed",18))
 badge.mouse_filter=Control.MOUSE_FILTER_IGNORE
 game.ui.hud.add_child(badge)
 strip.mouse_filter=Control.MOUSE_FILTER_IGNORE
 badge.add_child(strip)
 hint=game.ui.label("",14,"796179")
 hint_panel=PanelContainer.new()
 hint_panel.position=Vector2(26,90)
 hint_panel.add_theme_stylebox_override("panel",game.ui.style("fff8f0d9",16))
 hint_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
 game.ui.hud.add_child(hint_panel)
 hint.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var guidance_row:=HBoxContainer.new();hint_panel.add_child(guidance_row);guidance_row.add_child(hint)
 var dismiss: Button=game.ui.button("Hide tips",func(): game.ui.guidance_changed.emit(true))
 dismiss.custom_minimum_size=Vector2(84,26);dismiss.add_theme_font_size_override("font_size",12);dismiss.icon=null;dismiss.size_flags_vertical=Control.SIZE_SHRINK_CENTER;guidance_row.add_child(dismiss)
 refresh()
func refresh() -> void:
 strip.text="Day %d · %s · %d Cozy Coins   |   Q Goals · J Catalog · L Journal" % [rules.data.day,rules.period(),rules.data.coins]
 update_hint()
 rooms.apply_home(rules.data)
 if neighborhood: neighborhood.refresh()
 rooms.show_meal(meal.recipe,meal.stage) if meal.stage!="done" else rooms.show_meal(meal.recipe,"ready")
func _process(delta: float) -> void:
 hint_clock+=delta
 if hint_clock>0.5:
  hint_clock=0
  update_hint()
func update_hint() -> void:
 var next:=""
 match meal.stage:
  "ingredients": next="Next: prep counter · flour board in the kitchen"
  "prepared": next="Next: stove · cook your prepared ingredients"
  "ready": next="Next: prep counter · plate your finished dish"
 if next=="" and not rules.data.introduced:
  next="Your first meal → blue fridge · E to choose a recipe" if game.player.position.z>5 and game.player.position.x<0 else "Your first cozy day\nKitchen: left arch behind the living room → fridge"
 elif next=="" and rules.data.day==1:
  next="Q: today's goals · J: room finishes\nBed: E at foot to make · E by pillows to sleep" if game.player.position.z>5 and game.player.position.x>0 else "Q: today's goals · J: room finishes\nBedroom: right arch · bed starts the next day"
 if neighborhood:
  var priority: String=neighborhood.priority_hint()
  if not priority.is_empty(): next=priority
 # One guidance surface owns automatic hints; H still explicitly opens the cozy checklist.
 if is_instance_valid(game.ui.guide) and game.ui.guidance_mode!="cozy":
  game.ui.guide.hide()
  for button in game.ui.guide.find_children("*","Button",true,false): button.text="";button.hide()
 hint.text=next
 hint_panel.visible=not next.is_empty() and not game.save.onboarding.dismissed and not (game.ui.guidance_mode=="cozy" and is_instance_valid(game.ui.guide) and game.ui.guide.visible)
func commit(mutate: Callable) -> bool:
 var before: Dictionary=rules.data.duplicate(true)
 if rules.data.life.morning_friends.is_empty():
  for id in rules.data.neighborhood.people: rules.data.life.morning_friends[id]=rules.data.neighborhood.people[id].xp
 mutate.call()
 rules.data.life.earned+=maxi(0,rules.data.coins-before.coins)
 game.save.home=rules.data
 if game.persist(true)!=OK:
  rules.data=before
  game.save.home=rules.data
  refresh()
  return false
 refresh()
 if rules.data.life.rewards.size()>before.life.rewards.size(): game.audio.play("story")
 return true
func record(kind: String,detail: Dictionary={}) -> bool:
 var token: String="%d:%s" % [rules.data.day,kind]
 if kind=="rest": token+=":"+str(rules.data.period)
 var before: int=rules.data.coins
 var success:=commit(func(): rules.event(kind,token,detail))
 if success:
  if rules.data.coins>before: game.audio.play("goal")
  if kind in ["water","lamp","curtains","bed","explore"] and kind in rules.data.goals_done:
   game.ui.show_notice("Cozy goal recorded · Q to view today's progress")
 return success
func stage_puzzle_goal() -> void:
 # The existing reward screen retains pending progression on a failed write.
 # Include the daily receipt in that same save so its Retry recovers both once.
 rules.event("pairs","%d:pairs" % rules.data.day)
 game.save.home=rules.data
 refresh()
func handles(id: String) -> bool: return rooms.stations.has(id)
func activate(id: String) -> void:
 var toward: Vector3=rooms.stations[id].global_position-game.player.global_position
 game.player.avatar.rotation.y=atan2(toward.x,toward.z)
 match id:
  "kitchen.fridge":
   rooms.open_fridge()
   game.audio.play("fridge")
   record("explore")
   open_recipes()
  "kitchen.prep":
   if meal.stage=="ingredients": open_timing(false)
   elif meal.stage=="ready": serve()
   elif meal.stage=="prepared": game.ui.show_notice("Prepared! Take your ingredients to the stove.")
   else: game.ui.show_notice("Choose a recipe at the blue refrigerator first.")
  "kitchen.stove":
   if meal.stage=="prepared": open_timing(true)
   else: game.ui.show_notice("Prepare ingredients at the wooden board first.")
  "bedroom.make":
   if record("bed"):
    game.audio.play("bedroom")
    gesture("make")
    game.ui.show_notice("Bedding smoothed. A little care for your home.")
  "bedroom.rest":
   if record("rest"):
    game.audio.play("bedroom")
    gesture("rest")
    game.ui.show_notice("A quiet moment · "+rules.period())
  "bedroom.lamp":
   if commit(func(): rules.data.bedside_on=not rules.data.bedside_on): game.audio.play("switch")
  "bedroom.bed": open_sleep()
func gesture(action: String) -> void:
 game.player.avatar.home_action=action
 var timer:=get_tree().create_timer(0.6)
 timer.timeout.connect(func():
  if is_instance_valid(game.player) and game.state!=game.State.HOME: game.player.avatar.home_action="")
func open_shell(title: String,wide: bool=false) -> void:
 if game.state!=game.State.HOME:
  return_to_pause=game.state==game.State.PAUSE
  view_backup={"yaw":game.camera_rig.yaw,"pitch":game.camera_rig.pitch,"distance":game.camera_rig.distance,"focus_offset":game.camera_rig.focus_offset}
 if is_instance_valid(panel): game.ui.root.remove_child(panel); panel.queue_free()
 game.feature_return=game.State.PLAY
 game.set_active(false)
 game.state=game.State.HOME
 game.ui.show_page("game")
 game.ui.hud.hide()
 panel=PANEL.new()
 panel.ui=game.ui
 game.ui.root.add_child(panel)
 panel.build(title,wide)
 panel.exit_requested.connect(close)
func close() -> void:
 if sleep_busy: return
 if neighborhood: neighborhood.end_talk()
 rooms.cooking=false
 game.player.avatar.home_action=""
 if is_instance_valid(panel): game.ui.root.remove_child(panel); panel.queue_free()
 panel=null
 draft.clear()
 rooms.apply_home(rules.data)
 for key in view_backup: game.camera_rig.set(key,view_backup[key])
 view_backup.clear()
 refresh()
 if return_to_pause:
  game.set_active(false)
  game.ui.show_page("pause")
 else: game.resume_game()
func station_view(point: Vector3) -> void:
 panel.panel.position.x=766
 game.camera_rig.focus_offset=point-game.player.position-Vector3(0,1.25,0)
 game.camera_rig.yaw=0.85
 game.camera_rig.pitch=0.24
 game.camera_rig.distance=4.2
func open_recipes() -> void:
 open_shell("The recipe pantry")
 panel.text("Choose ingredients here, then walk to the prep board and stove. Supplies are free.")
 if meal.stage not in ["idle","done"]:
  panel.text("In progress: "+RULES.RECIPES[meal.recipe].name+"\nClose to continue, or choose another recipe to start over.",14)
 var topping:=CheckButton.new()
 topping.text="Use harvest topping if available (+2 coins)"
 topping.add_theme_font_size_override("font_size",13)
 topping.button_pressed=rules.data.neighborhood.bonus_enabled
 topping.toggled.connect(func(value): commit(func(): rules.data.neighborhood.bonus_enabled=value))
 panel.col.add_child(topping)
 for id in RULES.RECIPES:
  panel.text(RULES.RECIPES[id].ingredients,13)
  panel.button(RULES.RECIPES[id].name,func():
   meal.begin(id,"%d:meal:%d" % [rules.data.day,rules.data.cook_serial])
   game.audio.play("fridge")
   close()
   gesture("reach")
   refresh())
 panel.footer()
func open_timing(cook: bool) -> void:
 var recipe: Dictionary=RULES.RECIPES[meal.recipe]
 open_shell(recipe.name+ (" · Cook" if cook else " · Prepare"))
 station_view(Vector3(-5,1.25,11.65 if cook else 9.25))
 panel.text(recipe.cook if cook else recipe.prep,19)
 panel.text("Press 1/2/3 or click the next ingredient when purple meets mint. Every attempt counts." if not cook and not recipe.prep_inputs.is_empty() else "Press Space or click when purple meets mint. Every attempt counts; no ingredients are lost.",14)
 panel.text("Close / Esc pauses this step. Return to the same station to continue.",13)
 game.player.avatar.home_action="cook" if cook else "prepare"
 rooms.cooking=cook
 panel.timing(meal,func(): timing_hit(cook))
 if not cook and not recipe.prep_inputs.is_empty():
  panel.action_button.hide()
  var ingredient_row:=HBoxContainer.new()
  ingredient_row.add_theme_constant_override("separation",4)
  panel.col.add_child(ingredient_row)
  for i in range(3):
   var item: String=recipe.prep_inputs[i]
   var b: Button=game.ui.button(str(i+1)+" · "+item,func(): timing_hit(false,item))
   b.icon=null
   b.custom_minimum_size=Vector2(136,42)
   b.add_theme_font_size_override("font_size",14)
   ingredient_row.add_child(b)
   b.shortcut=Shortcut.new()
   var shortcut_event:=InputEventKey.new()
   shortcut_event.keycode=KEY_1+i
   b.shortcut.events=[shortcut_event]
 else: panel.action_button.text=(recipe.cook_steps[meal.hits] if cook else "Whisk the batter")+" · Space"

 update_step_status(cook)
 panel.footer()
func update_step_status(cook: bool) -> void:
 var recipe: Dictionary=RULES.RECIPES[meal.recipe]
 var next: String=recipe.cook_steps[meal.hits] if cook else ("Whisk the batter" if recipe.prep_inputs.is_empty() else "Add "+recipe.prep_inputs[meal.hits])
 panel.status.text="Next: %s · %d actions remaining" % [next,(recipe.beats if cook else 3)-meal.hits]
 if cook: panel.action_button.text=next+" · Space"
func timing_hit(cook: bool,ingredient: String="") -> void:
 if not is_instance_valid(panel) or game.state!=game.State.HOME: return
 game.audio.play("cook" if cook else "prepare")
 var finished: bool=meal.hit(ingredient)
 if finished:
  rooms.cooking=false
  close()
  refresh()
  game.ui.show_notice("Cooked! Return to the board to plate your dish." if cook else "Prepared! Walk to the stove next.")
 else:
  update_step_status(cook)
func serve() -> void:
 var before: int=rules.data.coins
 var ok:=commit(func(): rules.event("meal",meal.serial,{"recipe":meal.recipe,"quality":meal.quality(),"garden_bonus":rules.data.neighborhood.bonus_enabled}))
 last_gain=rules.data.coins-before
 open_shell(RULES.RECIPES[meal.recipe].name+" · "+meal.quality())
 station_view(Vector3(-5,1.25,9.25))
 panel.text("Your finished dish is on the preparation board.")
 if ok:
  meal.stage="done"
  panel.text("+%d Cozy Coins · balance %d" % [last_gain,rules.data.coins],21)
  panel.text("First meal per recipe/day: 6 coins; second: 2. Further practice is free. Goals pay 3 each; the full set pays 6.",14)
  panel.button("Enjoy my meal",close,true,"check")
  game.audio.play("complete")
  game.player.avatar.home_action="present"
 else:
  panel.text("Not saved. Your previous balance is safe. Retry plating to save this result.")
  panel.button("Retry plating",serve,true,"restart")
 panel.footer()
func open_goals() -> void:
 open_shell("Daily cozy goals",true)
 panel.text("Day %d · %s · %d Cozy Coins" % [rules.data.day,rules.period(),rules.data.coins],20)
 var cards:=HBoxContainer.new()
 cards.add_theme_constant_override("separation",12)
 panel.col.add_child(cards)
 for id in rules.goals():
  var done: bool=id in rules.data.goals_done
  var card: PanelContainer=panel.card(("✓  " if done else "○  ")+rules.goal_definitions()[id],"Completed and saved" if done else "One small, real activity", "3 coins",done,260)
  panel.col.remove_child(card);cards.add_child(card)
 var section: PanelContainer=panel.card("MY FIRST COZY WEEK","%d / 7 cozy days completed · 3 days: bedside keepsake · 7 days: commemorative frame" % rules.data.completed_days.size(),"Set bonus: 6 coins"+(" ✓" if rules.data.set_paid else ""),rules.data.set_paid,840)
 panel.text("Optional today: "+(RULES.NB.E.DEFINITIONS[rules.data.neighborhood.event.id].name)+(" ✓" if rules.data.neighborhood.event.done else " · L for details"),14)
 var extras:=HBoxContainer.new();extras.add_theme_constant_override("separation",12);panel.col.add_child(extras)
 var journal: Button=game.ui.button("Cozy Connections · L",func(): neighborhood.journal() if neighborhood else close(),false,"home")
 journal.custom_minimum_size.x=410;extras.add_child(journal)
 var hints: Button=game.ui.button("Hints: "+("Off" if game.save.onboarding.dismissed else "On")+" · T",func(): game.toggle_hints();open_goals())
 hints.custom_minimum_size.x=410;extras.add_child(hints)
 panel.footer()
func open_catalog() -> void:
 draft=rules.data.equipped.duplicate()
 catalog_page()
func catalog_page() -> void:
 open_shell("Finishes for your growing home",true)
 panel.text("%d Cozy Coins · Preview is free. Buy & equip saves both cost and ownership together." % rules.data.coins,15)
 var scroll:=ScrollContainer.new()
 scroll.custom_minimum_size=Vector2(840,335)
 scroll.follow_focus=true
 panel.col.add_child(scroll)
 var list:=VBoxContainer.new()
 list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 scroll.add_child(list)
 for id in rules.catalog():
  var def: Dictionary=rules.catalog()[id]
  var row:=HBoxContainer.new()
  row.add_theme_constant_override("separation",12)
  list.add_child(row)
  var state: String="Equipped ✓" if rules.data.equipped[def.slot]==id else ("Owned" if id in rules.data.owned else ("Affordable" if rules.data.coins>=def.cost else "Locked"))
  var label: Label=game.ui.label(def.name+" · "+def.room+"\n"+state+" · "+str(def.cost)+" coins",15)
  label.custom_minimum_size=Vector2(360,50)
  row.add_child(label)
  var preview: Button=game.ui.button("Preview",func(): preview_finish(id))
  preview.name="Preview_"+id.replace(".","_")
  preview.custom_minimum_size.x=140
  row.add_child(preview)
  var buy: Button=game.ui.button("Equip" if id in rules.data.owned else "Buy & equip",func(): buy_finish(id),false,"check")
  buy.name="Buy_"+id.replace(".","_")
  buy.custom_minimum_size.x=190
  buy.disabled=not id in rules.data.owned and rules.data.coins<def.cost
  row.add_child(buy)
 panel.text("Preview color appears on the physical furnishings. Ownership is permanent; equipping an owned finish is free.",14)
 panel.footer()
func buy_finish(id: String) -> void:
 if not id in rules.data.owned and rules.data.coins<rules.catalog()[id].cost: return
 var ok:=commit(func():
  if not id in rules.data.owned: rules.purchase(id)
  rules.equip(id))
 if ok:
  game.audio.play("purchase")
  draft=rules.data.equipped.duplicate()
  catalog_page()
 else: panel.status.text="Not saved. No coins deducted and no ownership changed. Retry or close."
func preview_finish(id: String) -> void:
 var def: Dictionary=rules.catalog()[id]
 draft[def.slot]=id
 open_shell(def.name+" · Preview")
 panel.panel.position.x=766
 rooms.apply_home(rules.data,draft)
 if neighborhood: neighborhood.world.apply(rules.data.neighborhood,rules.data,draft)
 var point:=Vector3(3.5,1.15,11.15) if def.room=="Bedroom" else Vector3(-4.8,1.4,10.1)
 if def.room=="Garden": point=Vector3(12,1.0,-0.8)
 game.camera_rig.focus_offset=point-game.player.position-Vector3(0,1.25,0)
 game.camera_rig.yaw=PI+0.4 if def.room=="Bedroom" else 1.0
 game.camera_rig.pitch=0.42
 game.camera_rig.distance=5.2 if def.room=="Bedroom" else 3.8
 if def.room=="Garden":
  game.camera_rig.yaw=0.45;game.camera_rig.pitch=0.24;game.camera_rig.distance=5.6
 panel.text("%d coins · %s" % [def.cost,"Permanently owned" if id in rules.data.owned else "Locked until purchased"],20)
 panel.text("This is a free preview on the actual furnishing. Close / Esc restores your saved home. No coins have been spent.",15)
 var b: Button=panel.button("Equip" if id in rules.data.owned else "Buy & equip",func(): buy_finish(id),true,"check")
 b.name="Buy_"+id.replace(".","_")
 b.disabled=not id in rules.data.owned and rules.data.coins<def.cost
 panel.button("Back to finishes",catalog_page,false,"home")
 panel.footer()
func open_sleep() -> void:
 open_shell("A softer tomorrow")
 panel.text("Sleep until morning and begin Day %d?" % (rules.data.day+1),22)
 panel.text("Your coins, owned finishes and keepsakes stay. Tomorrow brings three new goals. Unfinished cooking will be put away.",15)
 panel.text("Today's set: "+("complete" if rules.data.set_paid else "still open — you can keep exploring before bed"),15)
 panel.button("Sleep until morning",sleep,true,"play")
 panel.footer()
func sleep() -> void:
 if sleep_busy: return
 if not commit(func(): rules.sleep_next_day()):
  panel.status.text="Could not save the new day. Previous day and balance kept. Try again."
  return
 meal.abort()
 sleep_busy=true
 rooms.cooking=false
 game.player.avatar.home_action="sleep"
 game.audio.play("sleep")
 panel.build("Rest well…")
 panel.text("A quiet breath. Morning is on its way.",20)
 var veil:=ColorRect.new()
 veil.name="SleepFade"
 veil.color=Color(0.18,0.16,0.26,0)
 veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 veil.mouse_filter=Control.MOUSE_FILTER_IGNORE
 panel.add_child(veil)
 var tween:=create_tween()
 tween.tween_property(veil,"color:a",0.92,0.5)
 tween.tween_interval(0.35)
 tween.tween_property(veil,"color:a",0,0.55)
 tween.finished.connect(func():
  sleep_busy=false
  close()
  refresh()
  game.ui.show_notice("Good morning · Day %d · three fresh cozy goals" % rules.data.day)
  if rules.data.life.engaged and neighborhood: neighborhood.life.summary())
