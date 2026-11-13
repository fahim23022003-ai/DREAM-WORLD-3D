extends "res://tests/phase2b_flow.gd"
const CNOTE:="/tmp/dream-phase2c-savepath.txt"
const LEDGER:="/tmp/dream-phase2c-ledger.json"
func life() -> Node: return nb().life
func close_panel() -> void: await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
func speak(id: String) -> void:
 for i in range(1000):
  if nb().actors[id].mode in [nb().actors[id].Mode.AWAY,nb().actors[id].Mode.WAITING,nb().actors[id].Mode.VISITING]: break
  await frames(1)
 if nb().actors[id].mode==nb().actors[id].Mode.AWAY:
  await key(KEY_L,true);await key(KEY_L,false);await click("Invite "+id.capitalize());await close_panel()
 for i in range(1000):
  if nb().actors[id].mode in [nb().actors[id].Mode.WAITING,nb().actors[id].Mode.VISITING]: break
  await frames(1)
 if nb().actors[id].position.z< -0.5:
  # Stop at the real social prompt if the visitor is returning through the corridor.
  var npc: Node3D=nb().actors[id]
  var waypoints: Array[Vector3]=[Vector3(13.55,0,0.25),Vector3(13.55,0,-3.2)]
  for target in waypoints:
   await key(KEY_W,true)
   for i in range(500):
    await look(npc.position)
    if game.interaction_target==npc and game.player.position.distance_to(npc.position)<1.4: break
    await look(target)
    if Vector2(target.x-game.player.position.x,target.z-game.player.position.z).length()<0.18: break
    await frames(1)
   await key(KEY_W,false)
   await look(npc.position);await frames(3)
   if game.interaction_target==npc and game.player.position.distance_to(npc.position)<1.4: break
  await key(KEY_W,true)
  for i in range(400):
   await look(npc.position)
   if game.interaction_target==npc and game.player.position.distance_to(npc.position)<1.4: break
   await frames(1)
  await key(KEY_W,false);await look(npc.position);await frames(3)
  check(game.interaction_target==npc and game.player.position.distance_to(npc.position)>0.5,"genuine movement safely reaches a seated or returning visitor")
  await key(KEY_E,true);await key(KEY_E,false)
  check(game.state==game.State.HOME and nb().speaking==id,"real E interrupts a seated visitor safely")
 else: await meet(id)
func to_kitchen() -> void:
 # Walk around the physical patio table, retaining all ordinary doorway movement.
 await walk_to(Vector3(10.2,0,1.8));await walk_to(Vector3(7.2,0,1.8))
 await super.to_kitchen()
func activity_ready() -> void:
 for i in range(1500):
  if life().phase=="seated": break
  await frames(1)
 check(life().phase=="seated","participants physically reach their assigned activity places")
 await create_timer(0.8).timeout
func shared(kind: String,id: String,selected: String) -> void:
 await speak(id);await click("Shared activities");await click(kind);await click(selected)
 if life().active_kind.is_empty():
  await create_timer(12).timeout;await click(selected)
 await activity_ready()
func finish_shared() -> void:
 await click("Keep this memory")
 check(life().phase=="complete","actual activity claims its saved result")
 var coins: int=game.home.rules.data.coins
 await click("Keep this memory")
 check(game.home.rules.data.coins==coins,"repeated GUI claim cannot duplicate a shared reward")
 await click("Back to the garden");await create_timer(0.5).timeout
func begin_story(id: String,npc: String="") -> void:
 if npc.is_empty(): await key(KEY_L,true);await key(KEY_L,false);await click("Stories")
 else: await speak(npc);await click("Baking stories" if npc=="mimi" else "Garden stories");await click("Our stories")
 var title: String=game.home.RULES.LIFE.ARCS[id].name
 await click(title);await click("Begin "+title)
 check(game.home.rules.data.life.arcs[id]==1,"real story choice begins "+title)
 await close_panel()
func plant_crop(i: int,crop: String,water: bool=true) -> void:
 if game.player.position.z< -0.5: await walk_to(Vector3(13.55,0,-3.2));await walk_to(Vector3(13.55,0,0.25))
 await walk_to(Vector3(9+i*3,0,0.25));await use_garden("garden.plot"+str(i));await click("Plant "+nb().G.CROPS[crop].name)
 if water: await use_garden("garden.plot"+str(i));await click("Water crop")
func cook_recipe(id: String) -> void:
 if game.player.position.x>6: await to_kitchen()
 await walk_to(Vector3(-3.5,0,7));await world_use("kitchen.fridge");await click(game.home.RULES.RECIPES[id].name)
 await walk_to(Vector3(-3.55,0,9.25));await world_use("kitchen.prep")
 if id=="cloud_pancakes": await time_actions(3)
 else:
  for code in [KEY_1,KEY_2,KEY_3]:
   for i in range(180):
    if absf(game.home.meal.cursor()-game.home.meal.target)<0.045: break
    await frames(1)
   await key(code,true);await key(code,false)
 await walk_to(Vector3(-3.55,0,11.75));await world_use("kitchen.stove")
 await shot("16_camera_comparison")
 await time_actions(game.home.RULES.RECIPES[id].beats)
 await walk_to(Vector3(-3.55,0,9.25));await world_use("kitchen.prep");await click("Enjoy my meal")
 check(game.home.meal.stage=="done","legitimate station sequence plates "+id)
func sleep_and_review() -> void:
 if game.player.position.x>6:
  await walk_to(Vector3(7.2,0,3.6));await walk_to(Vector3(3,0,3.6))
 else: await walk_to(Vector3(-3,0,6.2));await walk_to(Vector3(-3,0,3.6));await walk_to(Vector3(3,0,3.6))
 await walk_to(Vector3(3,0,6.2));await walk_to(Vector3(2,0,10.5));await world_use("bedroom.bed");await click("Sleep until morning")
 await create_timer(1.8).timeout
 check(game.state==game.State.HOME and game.home.panel.panel.find_children("*","Button",true,false).any(func(b): return b.text=="Start the morning"),"sleep presents the real compact end-of-day summary")
 await shot("15_end_of_day_summary");await click("Start the morning")
 await walk_to(Vector3(3,0,6.2));await walk_to(Vector3(3,0,3.6));await walk_to(Vector3(7.2,0,3.6))
func continued() -> void:
 file=FileAccess.get_file_as_string(CNOTE).strip_edges();await load_game();await click("Continue home  →")
 var expected: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(LEDGER))
 check(game.home.rules.data.day==3 and game.home.rules.data.coins==int(expected.coins),"real process restart preserves exact day and earned/spent balance")
 check(game.home.rules.data.life.rewards==["garden","baking","warming"],"all three completed multi-step stories survive actual Quit/Continue")
 check(game.home.rules.data.life.receipts.size()==10,"ten ordered chapter receipts survive without duplicates")
 for id in ["mimi","noah"]:
  check(nb().data().people[id].xp==int(expected[id]) and nb().actors[id].avatar.position==Vector3.ZERO,"friendship persists without transient seated pose for "+id)
 check(life().active_kind.is_empty() and life().world.memories.values().all(func(n): return n.visible),"Continue restores all physical memories and no half-finished activity")
 check(game.home.rules.data.life.last_summary.stories.size()==3,"end-of-day memory summary persists")
 await garden_photo();await shot("17_quit_continue")
 await key(KEY_L,true);await key(KEY_L,false)
 root.size=Vector2i(1920,1080);await frames(8);await RenderingServer.frame_post_draw
 check(game.ui.root.get_global_rect().encloses(game.home.panel.panel.get_global_rect()),"important journal layout fits genuine 1920x1080")
 root.get_texture().get_image().save_png(output+"21_journal_1920x1080.png")
 await close_panel();await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false);await click("Save & main menu")
 print("PHASE 2C CONTINUE: ",checks-failures,"/",checks)
 if failures: quit(1);return
 await click("Quit")
func run() -> void:
 output="res://docs/review/phase2c/";root.size=Vector2i(1280,720);DirAccess.make_dir_recursive_absolute(output)
 if "--resume" in OS.get_cmdline_user_args(): await continued();return
 file="user://phase2c_journey_"+str(Time.get_unix_time_from_system())+".cfg";FileAccess.open(CNOTE,FileAccess.WRITE).store_string(file)
 await load_game();await click("Come on in  →")
 await photo(game.player.position+Vector3(0,1.25,0),0.2,0.1,3.5);await shot("05_avatar_closeup")
 await walk_to(Vector3(-3,0,3.6));await walk_to(Vector3(-3,0,6.2));await walk_to(Vector3(-3.5,0,7));await world_use("kitchen.fridge");await close_panel()
 await to_garden();await begin_story("baking","mimi")
 await shared("Cozy tea time","mimi","Berry tea · a cheerful toast")
 check(life().world.tea.visible and game.player.avatar.sit_blend>0.8,"tea has visible cups and a seated player")
 await shot("09_shared_tea_time");await finish_shared()
 await speak("mimi");await shot("06_mimi_expressions");await close_panel()
 await begin_story("garden","noah")
 await speak("noah");await shot("07_noah_expressions");await click("Shared activities");await click("Rest on the garden bench")
 await walk_to(Vector3(11,0,1.0))
 for i in range(1500):
  if nb().actors.noah.seated_requested: break
  await frames(1)
 check(nb().actors.noah.seated_requested,"Noah actually walks to and sits on the garden bench")
 await create_timer(0.8).timeout
 await photo(nb().actors.noah.avatar.global_position+Vector3(0,0.9,0),0.15,0.15,4.6);await shot("08_actual_seated_npc")
 await plant_crop(0,"strawberry");await plant_crop(1,"lavender");await plant_crop(2,"carrot")
 check(game.home.rules.data.life.arcs.garden==3,"real planting and watering advance two Noah chapters")
 await cook_recipe("cloud_pancakes");await sleep_and_review()
 check(game.home.rules.data.day==2 and nb().data().plots.all(func(p): return p.stage==4),"sleep grows the three cared-for crops without real-world waiting")
 for i in range(3):
  await walk_to(Vector3(9+i*3,0,0.25));await use_garden("garden.plot"+str(i));await click("Harvest crop")
 check(game.home.rules.data.life.arcs.baking==2 and game.home.rules.data.life.arcs.garden==4,"genuine harvest advances both personal stories")
 await plant_crop(1,"lavender",false)
 await shared("Garden help","noah","Tend a dry crop together");await finish_shared()
 check("garden" in game.home.rules.data.life.rewards and nb().data().plots[1].water_day==2,"Noah's complete story earns its physical garden memory through real care")
 await cook_recipe("berry_cupcakes");await to_garden()
 await shared("Cozy tea time","mimi","Lavender tea · a quiet thank-you");await finish_shared()
 check("baking" in game.home.rules.data.life.rewards,"Mimi's full ingredient, cooking and celebration story concludes legitimately")
 await begin_story("warming")
 await cook_recipe("cloud_pancakes");await to_garden()
 await shared("Garden picnic","mimi","Trade funny stories")
 check(life().active_both and life().world.picnic.visible,"both friends physically join the housewarming picnic with visible food")
 await shot("10_garden_picnic");await finish_shared()
 check(game.home.rules.data.life.arcs.warming==3,"real group picnic completes gathering preparation")
 await walk_to(Vector3(14.4,0,2.1));await use_garden("garden.gathering");await activity_ready();await click("Keep this memory")
 check("warming" in game.home.rules.data.life.rewards and life().world.memories.warming.visible,"group toast concludes the complete housewarming story with permanent lanterns")
 await shot("12_housewarming_gathering");await click("Back to the garden")
 await key(KEY_Q,true);await key(KEY_Q,false);await shot("13_improved_daily_ui");await close_panel()
 await key(KEY_L,true);await key(KEY_L,false);await shot("14_improved_journal");await click("Keepsakes");await click("More keepsakes →");await shot("20_future_keepsakes");await close_panel()
 await to_kitchen();await photo(Vector3(-3.35,1.3,13.25),PI-0.8,0.16,2.7);await shot("11_story_event")
 await sleep_and_review()
 check(game.home.rules.data.life.last_summary.stories.size()==3,"sleep summary records all completed stories")
 var ledger:={"coins":game.home.rules.data.coins,"mimi":nb().data().people.mimi.xp,"noah":nb().data().people.noah.xp}
 FileAccess.open(LEDGER,FileAccess.WRITE).store_string(JSON.stringify(ledger))
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false);await click("Save & main menu")
 print("PHASE 2C FLOW: ",checks-failures,"/",checks)
 if failures: quit(1);return
 await click("Quit")
