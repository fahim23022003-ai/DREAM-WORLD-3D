extends "res://tests/phase1d_flow.gd"
const NOTE := "/tmp/dream-phase2a-savepath.txt"
func face_point(point: Vector3) -> void:
 var d: Vector3=point-game.player.position
 await face(atan2(-d.x,-d.z))
func photo(focus: Vector3,yaw: float,pitch: float,distance: float=5.8) -> void:
 game.camera_rig.focus_offset=focus-game.player.position-Vector3(0,1.25,0)
 game.camera_rig.distance=distance
 game.camera_rig.pitch=pitch
 await face(yaw)
 await create_timer(0.6).timeout
func world_use(id: String) -> void:
 var node: Node3D=game.home.rooms.stations[id]
 await face_point(node.global_position)
 await frames(4)
 if game.interaction_target!=node: print("TARGET DEBUG ",game.player.position," chosen=",game.interaction_target.interaction_id if game.interaction_target else "none")
 check(game.interaction_target==node,"one shared prompt resolves "+id)
 await key(KEY_E,true); await key(KEY_E,false)
func time_actions(count: int) -> void:
 for i in range(count):
  # Observe the visible target/cursor, then press the ordinary Space action.
  for frame in range(180):
   if absf(game.home.meal.cursor()-game.home.meal.target)<0.045: break
   await frames(1)
  await key(KEY_SPACE,true); await key(KEY_SPACE,false)
  await frames(2)
func resume_home() -> void:
 file=FileAccess.get_file_as_string(NOTE).strip_edges()
 await load_game()
 await click("Continue home  →")
 check(game.home.rules.data.day==2 and game.home.rules.data.coins==9,"new process Continue restores day two and coin balance")
 check(game.home.rules.data.owned==["bed.strawberry"] and game.home.rules.data.equipped.bedding=="bed.strawberry","permanent purchase survives actual Quit")
 check(game.home.meal.stage=="idle" and not game.home.rooms.steam.visible,"Continue restores no transient cooking or steam")
 check(game.home.rooms.quilt.material_override.albedo_color==Color("e9a1b5"),"Continue applies purchased quilt to actual bed")
 await key(KEY_Q,true);await key(KEY_Q,false)
 await shot("11_day_progression")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await photo(Vector3(3.2,1.2,11),PI+0.4,0.46,6)
 await shot("12_quit_continue_restored")
 print("PHASE 2A CONTINUE: ",checks-failures,"/",checks)
 await key(KEY_ESCAPE,true); await key(KEY_ESCAPE,false)
 await click("Save & main menu")
 if failures: quit(1);return
 await click("Quit")
func run() -> void:
 if DisplayServer.get_name()=="headless": quit(1);return
 output="res://docs/review/phase2a/"
 root.size=Vector2i(1280,720)
 DirAccess.make_dir_recursive_absolute(output)
 if "--resume" in OS.get_cmdline_user_args(): await resume_home();return
 file="user://phase2a_flow_"+str(Time.get_ticks_usec())+".cfg"
 FileAccess.open(NOTE,FileAccess.WRITE).store_string(file)
 await load_game()
 await click("Come on in  →")
 await photo(Vector3(0,1.4,-1.7),0.12,0.3,6.3)
 await shot("01_living_room_preserved")
 # A real daily action from the existing living room.
 await walk_to(Vector3(-4.2,0,1.8)); await walk_to(Vector3(-4.2,0,-3.4))
 await face_point(game.room.plant_control.global_position)
 await key(KEY_E,true);await key(KEY_E,false)
 await create_timer(1.35).timeout
 check("water" in game.home.rules.data.goals_done,"existing plant watering reaches today's real goal")
 await walk_to(Vector3(-3.2,0,2.7));await walk_to(Vector3(-3,0,6.15))
 check(game.player.position.z>5.5,"walk through physical kitchen doorway")
 await photo(Vector3(-3.1,1.3,10.5),PI-0.32,0.42,5.6)
 await shot("02_kitchen_wide")
 await walk_to(Vector3(-3.5,0,7))
 await world_use("kitchen.fridge")
 check(game.state==game.State.HOME,"fridge opens recipe panel")
 await shot("03_kitchen_interaction")
 await click("Cloud Pancakes")
 check(game.home.meal.stage=="ingredients" and game.home.rooms.ingredients.visible,"selected pantry recipe puts actual ingredients on prep board")
 await walk_to(Vector3(-3.55,0,9.25))
 await world_use("kitchen.prep")
 await shot("04_cooking_preparation")
 var pos: Vector3=game.player.position
 await key(KEY_W,true);await key(KEY_E,true);await frames(4);await key(KEY_E,false);await key(KEY_W,false)
 check(game.player.position==pos and game.state==game.State.HOME,"prep modal prevents movement and E leakage")
 await time_actions(3)
 check(game.home.meal.stage=="prepared" and game.active,"three actual timing inputs prepare ingredients")
 await walk_to(Vector3(-3.55,0,11.75))
 await world_use("kitchen.stove")
 await shot("05_cooking_active")
 check(game.home.rooms.cooking,"cooking emits contained stove steam")
 await time_actions(2)
 check(game.home.meal.stage=="ready" and not game.home.rooms.cooking,"two real flips finish pancakes and clean up steam")
 await walk_to(Vector3(-3.55,0,9.25))
 await world_use("kitchen.prep")
 check(game.home.meal.stage=="done" and game.home.rules.data.coins==12,"real plated meal and water goal earn twelve coins")
 await shot("06_finished_food")
 await click("Enjoy my meal")
 await walk_to(Vector3(-3,0,6.2));await walk_to(Vector3(-3,0,3));await walk_to(Vector3(3,0,3));await walk_to(Vector3(3,0,6.2))
 check(game.player.position.z>5.5 and game.player.position.x>0,"walk through real bedroom doorway")
 await photo(Vector3(3.3,1.25,10.8),PI+0.35,0.44,6.2)
 await shot("07_bedroom_wide")
 await walk_to(Vector3(3.8,0,8.25))
 await world_use("bedroom.make")
 check(game.home.rules.data.set_paid and game.home.rules.data.coins==21 and game.home.rooms.bed_made,"making bed finishes first legitimate daily set")
 await key(KEY_Q,true);await key(KEY_Q,false)
 await shot("09_daily_goals")
 check(game.state==game.State.HOME,"Q opens readable day and goals panel")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await key(KEY_J,true);await key(KEY_J,false)
 await tap("Preview_bed_strawberry")
 await shot("13_decor_preview")
 check(game.home.rules.data.coins==21 and game.home.rules.data.owned.is_empty(),"catalog preview never spends coins")
 var good_save:=FileAccess.get_file_as_bytes(file)
 DirAccess.make_dir_absolute(file+".tmp")
 await tap("Buy_bed_strawberry")
 check(game.home.rules.data.coins==21 and game.home.rules.data.owned.is_empty() and FileAccess.get_file_as_bytes(file)==good_save,"real failed purchase save preserves coins ownership and prior file")
 DirAccess.remove_absolute(file+".tmp")
 await tap("Buy_bed_strawberry")
 check(game.home.rules.data.coins==9 and game.home.rules.data.owned==["bed.strawberry"],"real catalog purchase owns and equips for exact cost")
 await shot("10_decor_unlock")
 root.size=Vector2i(1920,1080)
 await frames(8);await RenderingServer.frame_post_draw
 var high:=root.get_texture().get_image()
 check(high.get_size()==Vector2i(1920,1080) and game.home.panel.panel.get_global_rect().end.y<root.get_visible_rect().size.y,"1920x1080 catalog remains in bounds")
 high.save_png("/tmp/phase2a-catalog-1080p.png")
 root.size=Vector2i(1280,720)
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await walk_to(Vector3(1.5,0,8.5));await walk_to(Vector3(2.0,0,10.5))
 await world_use("bedroom.bed")
 await shot("08_bedroom_sleep")
 await click("Sleep until morning")
 await create_timer(1.6).timeout
 check(game.active and game.home.rules.data.day==2 and game.home.rules.data.period==0,"actual bed transition starts a saved new morning")
 check(game.home.rules.data.goals_done.is_empty() and game.home.rules.data.coins==9,"next day refreshes goals and retains earned purchased balance")
 await key(KEY_Q,true);await key(KEY_Q,false)
 await shot("11_day_progression")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await click("Save & main menu")
 print("PHASE 2A FLOW: ",checks-failures,"/",checks)
 if failures: quit(1);return
 await click("Quit")
