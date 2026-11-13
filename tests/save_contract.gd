extends SceneTree
const S = preload("res://scripts/save_data.gd")
var checks := 0
var failures := 0
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",text)
func _initialize() -> void:
	var dir := "user://contract_"+str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(dir)
	var file := dir+"/legacy.cfg"
	var cfg := ConfigFile.new()
	cfg.set_value("player","position",Vector3(2,0,1))
	cfg.set_value("settings","sensitivity",1.4)
	cfg.set_value("settings","fullscreen",true)
	cfg.set_value("future","preserved",42)
	cfg.save(file)
	var original := FileAccess.get_file_as_bytes(file)
	var save = S.new()
	save.path = file
	save.load_local()
	check(save.has_save and save.player_position==Vector3(2,0,1) and is_equal_approx(save.sensitivity,1.4) and save.fullscreen,"legacy position/settings preserved")
	check(FileAccess.get_file_as_bytes(file+".v1.bak")==original,"migration backed up exact legacy bytes")
	check(save.appearance.display_name=="Dreamer" and save.decor.rug=="rosewater" and save.unlocks.is_empty(),"migration new fields safely default")
	check(save.write_local(save.player_position)==OK,"versioned atomic save succeeds")
	cfg.load(file)
	check(cfg.get_value("meta","schema_version")==S.VERSION and cfg.get_value("future","preserved")==42,"schema and unknown fields retained")
	check(FileAccess.get_file_as_bytes(file+".last_good")==original,"last good save retained")
	var good_bytes := FileAccess.get_file_as_bytes(file)
	DirAccess.make_dir_absolute(file+".tmp")
	check(save.write_local(Vector3(3,0,1))!=OK and FileAccess.get_file_as_bytes(file)==good_bytes and FileAccess.get_file_as_bytes(file+".last_good")==original,"real temporary-write failure leaves current and last-good saves intact")
	DirAccess.remove_absolute(file+".tmp")
	cfg.set_value("appearance","hair","bad")
	cfg.set_value("appearance","display_name","    ")
	cfg.set_value("decor","rug","invalid")
	cfg.set_value("decor","curtains","lavender_dream")
	cfg.set_value("settings","sensitivity",{"bad":true})
	cfg.set_value("progress","cozy_pairs_best","oops")
	cfg.set_value("onboarding","played",123)
	cfg.save(file)
	var bad = S.new()
	bad.path = file
	bad.load_local()
	check(bad.appearance.hair is Color and bad.appearance.display_name=="Dreamer" and bad.decor.rug=="rosewater" and bad.decor.curtains=="rosewater","malformed appearance/decor and locked IDs sanitized")
	check(bad.sensitivity==1 and bad.best_moves==0 and not bad.onboarding.played and bad.player_position==Vector3(2,0,1),"malformed new fields do not wipe old position")
	check(S.clean_name("  <Dreamer>abcdefghijklmnopqrstuvwxyz  ").length()==24,"trimmed plain-text name limited to 24")
	var missing = S.new()
	missing.path = dir+"/absent/blocked.cfg"
	check(missing.write_local(Vector3.ZERO)!=OK and not missing.has_save,"failed save reports error without claiming success")
	FileAccess.open(file,FileAccess.WRITE).store_string("[broken\n")
	var corrupt = S.new()
	corrupt.path = file
	corrupt.load_local()
	check(corrupt.has_save and corrupt.player_position==Vector3(2,0,1) and corrupt.write_local(Vector3.ZERO)!=OK,"corrupt save recovers last good and blocks destructive overwrite")
	print("SAVE CONTRACT: ",checks-failures,"/",checks)
	quit(0 if failures==0 else 1)
