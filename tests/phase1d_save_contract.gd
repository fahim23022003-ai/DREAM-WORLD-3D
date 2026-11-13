extends "res://tests/save_contract.gd"
func _initialize() -> void:
	var file:="user://phase1c_migration_"+str(Time.get_ticks_usec())+".cfg"
	var cfg:=ConfigFile.new()
	cfg.set_value("meta","schema_version",2)
	cfg.set_value("player","position",Vector3(-2,0,1))
	cfg.set_value("settings","sensitivity",1.3)
	cfg.set_value("settings","muted",true)
	cfg.set_value("appearance","display_name","Luna")
	cfg.set_value("appearance","hair",Color("bb8e63"))
	cfg.set_value("decor","curtains","lavender_dream")
	cfg.set_value("progress","lavender_dream",true)
	cfg.set_value("progress","cozy_pairs_best",8)
	cfg.set_value("onboarding","dismissed",true)
	cfg.set_value("future","retained",123)
	cfg.save(file)
	var before:=FileAccess.get_file_as_bytes(file)
	var save=S.new()
	save.path=file
	save.load_local()
	check(FileAccess.get_file_as_bytes(file+".v2.bak")==before,"schema-2 migration preserves exact backup")
	check(save.player_position==Vector3(-2,0,1) and is_equal_approx(save.sensitivity,1.3) and save.muted,"legacy position and settings preserved")
	check(save.appearance.display_name=="Luna" and save.appearance.hair==Color("bb8e63") and save.decor.curtains=="lavender_dream","appearance and decor survive schema-3 migration")
	check(save.unlocks==["lavender_dream"] and save.best_moves==8 and save.onboarding.dismissed,"old rewards/score/onboarding preserved")
	check(save.room_state.values()==[true,false,false] and not save.cozy_corner_completed and save.cozy_hint_dismissed,"new defaults preserve lamp state and dismissed guidance intent")
	save.room_state["living_room.curtains"]=true
	save.room_state["living_room.houseplant"]=true
	save.cozy_corner_completed=true
	check(save.write_local(save.player_position)==OK,"schema-3 room state writes atomically")
	cfg.load(file)
	check(cfg.get_value("meta","schema_version")==S.VERSION and cfg.get_value("future","retained")==123,"new version retains unknown fields")
	check(FileAccess.get_file_as_bytes(file+".last_good")==before,"last-good phase-1C file survives migration")
	var loaded=S.new()
	loaded.path=file
	loaded.load_local()
	check(loaded.cozy_corner_completed and loaded.room_state.values()==[true,true,true],"room and keepsake flags persist")
	cfg.set_value("room","living_room.floor_lamp","bad")
	cfg.set_value("room","living_room.curtains",999)
	cfg.set_value("room","living_room.houseplant",{"bad":true})
	cfg.set_value("progress","first_cozy_corner","bad")
	cfg.save(file)
	loaded=S.new()
	loaded.path=file
	loaded.load_local()
	check(loaded.room_state.values()==[true,false,false] and not loaded.cozy_corner_completed and loaded.appearance.display_name=="Luna" and loaded.best_moves==8,"malformed room flags cannot wipe valid phase-1C data")
	print("PHASE 1D SAVE: ",checks-failures,"/",checks)
	quit(0 if failures==0 else 1)
