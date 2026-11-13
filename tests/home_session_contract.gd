extends "res://tests/phase_one.gd"
const S=preload("res://scripts/save_data.gd")
const H=preload("res://scripts/home_rules.gd")
func run() -> void:
 for version in [1,2,3]:
  var path:="user://home_migration_%d_%d.cfg" % [version,Time.get_ticks_usec()]
  var cfg:=ConfigFile.new()
  cfg.set_value("meta","schema_version",version)
  cfg.set_value("appearance","display_name","Meadow")
  cfg.set_value("progress","lavender_dream",true)
  cfg.set_value("progress","first_cozy_corner",true)
  cfg.set_value("room","living_room.curtains",true)
  cfg.set_value("future","keep_me",42)
  cfg.save(path)
  var bytes:=FileAccess.get_file_as_bytes(path)
  var data:=S.new()
  data.path=path
  data.load_local()
  check(FileAccess.get_file_as_bytes(path+".v%d.bak" % version)==bytes,"schema %d gets exact migration backup" % version)
  check(data.appearance.display_name=="Meadow" and data.unlocks==["lavender_dream"] and data.cozy_corner_completed and data.room_state["living_room.curtains"] and data.home.introduced,"schema %d retains existing progress and skips new-player guidance" % version)
  data.home.coins=21
  check(data.write_local(Vector3(-3,0,8))==OK,"schema %d saves expanded home position" % version)
  var reloaded:=S.new()
  reloaded.path=path
  reloaded.load_local()
  check(reloaded.player_position==Vector3(-3,0,8),"expanded room position survives schema %d reload" % version)
  cfg.load(path)
  check(cfg.get_value("future","keep_me")==42 and cfg.get_value("meta","schema_version")==S.VERSION,"schema %d retains unknown data" % version)
 root.size=Vector2i(1280,720)
 game=load("res://scenes/main.tscn").instantiate()
 game.save_path="user://home_session_"+str(Time.get_ticks_usec())+".cfg"
 root.add_child(game)
 game.start_game()
 check(game.home.rooms.stations.size()==7 and game.home.rules.data.day==1,"all seven physical new stations and fresh home exist")
 check(game.home.rooms.surfaces.values().all(func(nodes): return not nodes.is_empty()),"six catalog finishes map to actual furnished surfaces")
 game.player.position=Vector3(1.13,0,11.15)
 var lamp_target: Node3D=game.home.rooms.stations["bedroom.lamp"]
 var direction: Vector3=lamp_target.global_position-game.player.position
 game.camera_rig.yaw=atan2(-direction.x,-direction.z)
 await frames(6)
 for down in [true,false]:
  var key_event:=InputEventKey.new()
  key_event.keycode=KEY_E
  key_event.physical_keycode=KEY_E
  key_event.pressed=down
  root.push_input(key_event,true)
 await create_timer(0.1).timeout
 check(not game.home.rules.data.bedside_on and is_zero_approx(game.home.rooms.bedside_light.light_energy),"real E switches actual bedside light off")
 var lamp_save:=S.new()
 lamp_save.path=game.save_path
 lamp_save.load_local()
 check(not lamp_save.home.bedside_on,"bedside light state persists independently of decor")
 # Legitimate rules events in isolated fixture earn the first daily set.
 game.home.record("meal",{"recipe":"cloud_pancakes","quality":"Good"})
 game.home.record("water")
 game.home.record("bed")
 check(game.home.rules.data.coins==21 and game.home.rules.data.set_paid,"controller persists genuine daily events together")
 var good:=FileAccess.get_file_as_bytes(game.save_path)
 game.save.write_blocked=ERR_CANT_CREATE
 var ok: bool=game.home.commit(func(): game.home.rules.purchase("bed.strawberry"); game.home.rules.equip("bed.strawberry"))
 check(not ok and game.home.rules.data.coins==21 and game.home.rules.data.owned.is_empty() and game.home.rules.data.equipped.bedding=="starter" and FileAccess.get_file_as_bytes(game.save_path)==good,"failed purchase rolls back cost ownership and equipment together")
 game.save.write_blocked=OK
 ok=game.home.commit(func(): game.home.rules.purchase("bed.strawberry"); game.home.rules.equip("bed.strawberry"))
 check(ok and game.home.rules.data.coins==9 and game.home.rules.data.owned==["bed.strawberry"],"retry purchase charges exactly once")
 var owned: Dictionary=game.home.rules.data.duplicate(true)
 game.home.open_catalog()
 game.home.rooms.apply_home(game.home.rules.data,{"bedding":"bed.lavender"})
 game.home.close()
 check(game.home.rules.data==owned and game.home.rooms.quilt.material_override.albedo_color==Color("e9a1b5"),"preview and Cancel change no coins ownership or saved equipment")
 game.pause_game()
 game.open_style(game.State.DECOR)
 game.feature.home_catalog_requested.emit()
 game.home.close()
 check(game.state==game.State.PAUSE and not game.player.enabled,"catalog opened from paused Decor restores Pause without leaking world input")
 game.resume_game()
 game.home.open_goals()
 var pos: Vector3=game.player.position
 await key(KEY_E,true); await key(KEY_E,false)
 await key(KEY_W,true); await frames(10); await key(KEY_W,false)
 check(game.state==game.State.HOME and not game.activate_interaction() and game.player.position==pos,"new modal blocks E and movement")
 game.home.close()
 game.home.meal.begin("starry_soup","fixture-cook")
 game.home.open_timing(false)
 game.home.close()
 check(game.home.meal.stage=="ingredients" and not game.home.rooms.cooking,"closing prep preserves retryable session stage and stops effects")
 game.home.open_sleep()
 game.save.write_blocked=ERR_CANT_CREATE
 game.home.sleep()
 check(game.home.rules.data.day==1 and not game.home.sleep_busy,"failed sleep keeps previous day and remains retryable")
 game.save.write_blocked=OK
 game.home.close()
 var data:=S.new()
 data.path=game.save_path
 data.load_local()
 check(data.home.coins==9 and data.home.owned==["bed.strawberry"] and data.home.set_paid,"reload retains transaction daily claim and equipped purchase")
 var other=load("res://scenes/main.tscn").instantiate()
 other.save_path=game.save_path
 root.add_child(other)
 check(other.home.meal.stage=="idle" and not other.home.rooms.steam.visible and other.home.rules.data.equipped.bedding=="bed.strawberry","reload never restores transient cooking and keeps equipment")
 game.home.rules.data.milestones=["three_days","seven_days"]
 game.home.refresh()
 check(game.home.rooms.milestone_three.visible and game.home.rooms.milestone_seven.visible,"milestone records map to distinct physical rewards")
 other.start_game()
 other.home.rules.data.day=4
 other.home.rules.data.goals_done=[]
 other.home.rules.data.set_paid=false
 other.home.rules.data.receipts=[]
 other.open_puzzle()
 other.save.write_blocked=ERR_CANT_CREATE
 var puzzle=other.feature.rules
 for id in range(6):
  var pair: Array[int]=[]
  for index in range(12):
   if puzzle.deck[index]==id: pair.append(index)
  puzzle.select(pair[0]);puzzle.select(pair[1]);puzzle.settle()
 check("pairs" in other.home.rules.data.goals_done and other.home.rules.data.coins==12 and other.feature.retry_button.visible,"pending puzzle reward includes its daily goal receipt after save failure")
 other.save.write_blocked=OK
 other.feature.retry_save_requested.emit()
 other.feature.retry_save_requested.emit()
 var retried:=S.new()
 retried.path=other.save_path
 retried.load_local()
 check(retried.home.coins==12 and "pairs" in retried.home.goals_done and not other.feature.retry_button.visible,"puzzle retry saves both rewards once without duplicating coins")
 game.audio.stop_all();other.audio.stop_all()
 print("HOME SESSION: ",checks-failures,"/",checks)
 quit(0 if failures==0 else 1)
