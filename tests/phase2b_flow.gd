extends "res://tests/phase2a_flow.gd"
const BNOTE:="/tmp/dream-phase2b-savepath.txt"
func nb() -> Node: return game.home.neighborhood
func look(point: Vector3) -> void: await face_point(point)
func garden_photo() -> void: await photo(Vector3(11.8,1.0,-0.6),0.0,0.38,7.0)
func use_garden(id: String) -> void:
 await look(nb().world.stations[id].global_position)
 await frames(4)
 check(game.interaction_target==nb().world.stations[id],"shared E resolver reaches "+id)
 await key(KEY_E,true);await key(KEY_E,false)
func meet(id: String) -> void:
 for i in range(600):
  if nb().actors[id].mode in [nb().actors[id].Mode.WAITING,nb().actors[id].Mode.VISITING]: break
  await frames(2)
 # Approach moving visitors through the real shared prompt, keeping the planter corridor clear.
 if game.player.position.z< -0.5:
  await walk_to(Vector3(13.55,0,-3.2));await walk_to(Vector3(13.55,0,-0.2))
 var npc: Node3D=nb().actors[id]
 await key(KEY_W,true)
 for frame in range(300):
  await look(npc.position)
  if game.interaction_target==npc and Vector2(npc.position.x-game.player.position.x,npc.position.z-game.player.position.z).length()<1.4: break
  await frames(1)
 await key(KEY_W,false)
 await look(npc.position);await frames(4)
 var distance: float=Vector2(npc.position.x-game.player.position.x,npc.position.z-game.player.position.z).length()
 check(distance>0.5 and distance<1.65,"genuine movement approaches visitor without crossing their collision")
 check(game.interaction_target==npc,"normal social prompt selects "+id)
 await key(KEY_E,true);await key(KEY_E,false)
 check(game.state==game.State.HOME and nb().speaking==id,"real E opens authored conversation with "+id)
func to_kitchen() -> void:
 await walk_to(Vector3(7.2,0,3.6));await walk_to(Vector3(3.0,0,3.6));await walk_to(Vector3(-3.0,0,3.0));await walk_to(Vector3(-3.0,0,6.2))
func to_garden() -> void:
 await walk_to(Vector3(-3,0,6.2));await walk_to(Vector3(-3,0,3.2));await walk_to(Vector3(3,0,3.6));await walk_to(Vector3(7.2,0,3.6))
func resume_garden() -> void:
 file=FileAccess.get_file_as_string(BNOTE).strip_edges()
 await load_game();await click("Continue home  →")
 var data: Dictionary=nb().data()
 check(game.home.rules.data.coins==26,"new process preserves the exact earned and spent Cozy Coin balance")
 check(game.home.rules.data.day==2 and data.harvested,"new process restores garden progress and day")
 check(data.produce.strawberry==1 and data.produce.carrot==1 and data.produce.lavender==1,"produce inventory survives actual Quit and Continue")
 check(data.people.mimi.days==[1],"meaningful shared-day friendship record persists without duplicate conversation days")
 check(data.people.mimi.requests_done==1 and data.people.mimi.xp>=4 and "friend" in data.achievements,"friendship completed request and physical reward records persist")
 check("garden.picnic" in game.home.rules.data.owned and game.home.rules.data.equipped.picnic=="garden.picnic","garden purchase retains permanent ownership and equipment")
 check(not nb().world.drops.visible and nb().actors.mimi.mode!=nb().actors.mimi.Mode.TALKING,"Continue restores safe actors without transient watering or dialogue")
 await garden_photo();await shot("16_quit_continue_restored")
 await photo(Vector3(6.1,1.35,3.65),PI/2,0.2,5.2);await shot("18_house_garden_entrance")
 print("PHASE 2B CONTINUE: ",checks-failures,"/",checks)
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false);await click("Save & main menu")
 if failures: quit(1);return
 await click("Quit")
func run() -> void:
 output="/tmp/dream-phase2b-review/"
 root.size=Vector2i(1280,720)
 DirAccess.make_dir_recursive_absolute(output)
 if "--resume" in OS.get_cmdline_user_args(): await resume_garden();return
 file="user://phase2b_flow_"+str(Time.get_unix_time_from_system())+".cfg"
 FileAccess.open(BNOTE,FileAccess.WRITE).store_string(file)
 await load_game();await click("Come on in  →")
 await walk_to(Vector3(3,0,3.6));await walk_to(Vector3(7.2,0,3.6))
 check(game.player.position.x>6.5,"genuine physical house-to-garden entrance traverses safely")
 await photo(nb().actors.mimi.position+Vector3(0,0.9,0),nb().actors.mimi.avatar.rotation.y+1.05,0.18,5.2);await shot("05_mimi_arrival")
 check(nb().actors.mimi.mode!=nb().actors.mimi.Mode.AWAY,"Mimi really walks in from the gate")
 await garden_photo();await shot("01_garden_wide")
 for i in range(3):
  await walk_to(Vector3(9+i*3,0,0.25))
  await use_garden("garden.plot"+str(i))
  await click("Plant "+nb().G.CROPS[nb().G.CROPS.keys()[i]].name)
  check(nb().data().plots[i].stage==1,"real GUI seed selection plants spot "+str(i))
  await use_garden("garden.plot"+str(i));await click("Water crop")
  check(nb().data().plots[i].stage==2 and nb().world.drops.visible,"actual watering produces sprout and reusable drops")
  if i==0:
   await photo(Vector3(9,0.9,-1.1),-0.85,0.32,5.2);await shot("02_garden_planting")
 await meet("mimi")
 await click("Baking stories")
 check(nb().data().people.mimi.met and nb().data().people.mimi.xp==1,"genuine conversation earns one capped friendship point")
 await shot("07_visitor_conversation")
 await click("Visitor request");await click("Accept request")
 check(nb().data().people.mimi.request=="mimi.pancakes","actual request acceptance records Mimi's pancake promise")
 await shot("08_visitor_request")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await to_kitchen();await walk_to(Vector3(-3.5,0,7));await world_use("kitchen.fridge");await click("Cloud Pancakes")
 await walk_to(Vector3(-3.55,0,9.25));await world_use("kitchen.prep");await time_actions(3)
 await walk_to(Vector3(-3.55,0,11.75));await world_use("kitchen.stove")
 await shot("15_camera_improvement")
 await time_actions(2)
 await walk_to(Vector3(-3.55,0,9.25));await world_use("kitchen.prep");await click("Enjoy my meal")
 check(nb().data().people.mimi.request_ready,"real completed cooking satisfies visitor condition")
 check(nb().data().plots.all(func(p): return p.stage==3),"cooking advances watered sprouts into growing plants")
 await to_garden();await garden_photo();await shot("03_garden_growing")
 await meet("mimi");await click("Visitor request");await click("Share & claim reward")
 check(nb().data().people.mimi.requests_done==1 and nb().F.level(nb().data().people.mimi.xp)==2,"real request claim increases friendship to Friend")
 check(nb().data().event.done and "first_request" in nb().data().achievements,"surprise visit completes through actual request with a durable receipt")
 await shot("09_friendship_reward")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await meet("noah")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await photo(nb().actors.noah.position+Vector3(0,1,0),0.45,0.15,3.5);await shot("06_noah_garden")
 await key(KEY_Q,true);await key(KEY_Q,false);await shot("11_new_daily_goals");await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await key(KEY_L,true);await key(KEY_L,false);await shot("10_dynamic_event");await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await key(KEY_J,true);await key(KEY_J,false)
 # Garden row is below the original catalog: ordinary scroll-to-focus navigation.
 var buy: Button=game.ui.root.find_child("Buy_garden_picnic",true,false)
 buy.grab_focus();await frames(6)
 await tap("Buy_garden_picnic")
 check("garden.picnic" in game.home.rules.data.owned and game.home.rules.data.equipped.picnic=="garden.picnic","earned coins buy and equip a real garden furnishing")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await photo(Vector3(8.2,1.0,3.6),0.8,0.25,3.2);await shot("13_garden_decor")
 await walk_to(Vector3(7.2,0,3.6));await walk_to(Vector3(3,0,3.6));await walk_to(Vector3(3,0,6.2));await walk_to(Vector3(2,0,10.5))
 await world_use("bedroom.bed");await click("Sleep until morning");await create_timer(1.6).timeout
 check(game.home.rules.data.day==2 and nb().data().plots.all(func(p): return p.stage==4),"actual sleep advances crops to safe harvest without real-world waiting")
 await walk_to(Vector3(3,0,6.2));await walk_to(Vector3(3,0,3.6));await walk_to(Vector3(7.2,0,3.6))
 for i in range(3):
  await walk_to(Vector3(9+i*3,0,0.25));await use_garden("garden.plot"+str(i));await click("Harvest crop")
 check(nb().data().produce.values()==[1,1,1] and nb().data().plots.all(func(p): return p.stage==0),"legitimate harvesting fills bounded basket and empties all plots once")
 await garden_photo();await shot("04_garden_harvest")
 await key(KEY_L,true);await key(KEY_L,false);await shot("12_progress_journal")
 root.size=Vector2i(1920,1080);await frames(10);await RenderingServer.frame_post_draw
 check(game.ui.root.get_global_rect().encloses(game.home.panel.panel.get_global_rect()),"journal UI fits rendered 1920x1080")
 root.get_texture().get_image().save_png(output+"17_journal_1920x1080.png")
 root.size=Vector2i(1280,720);await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 # A real bloom event on Day 2, then evening rest and patio atmosphere.
 await walk_to(Vector3(10.4,0,-2.75));await use_garden("garden.bloom")
 check(nb().data().event.done and "garden_event" in nb().data().achievements,"real flower-patch interaction completes next-day bloom event")
 await walk_to(Vector3(14.5,0,-2.7))
 for i in range(2): await use_garden("garden.rest")
 await garden_photo();await shot("14_evening_garden")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false);await click("Save & main menu")
 print("PHASE 2B FLOW: ",checks-failures,"/",checks)
 if failures: quit(1);return
 await click("Quit")
