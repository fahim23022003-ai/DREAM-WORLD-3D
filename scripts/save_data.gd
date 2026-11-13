extends RefCounted
const PATH := "user://rosewater.cfg"
var sensitivity := 1.0
var fullscreen := false
var shadows := true
var player_position := Vector3(0,0,1.8)
var has_save := false

func load_local() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK: return
	sensitivity = clampf(float(cfg.get_value("settings","sensitivity",1.0)),0.4,2.0)
	fullscreen = bool(cfg.get_value("settings","fullscreen",false))
	shadows = bool(cfg.get_value("settings","shadows",true))
	var p: Variant = cfg.get_value("player","position",player_position)
	if p is Vector3 and p.is_finite() and absf(p.x)<5.7 and p.y>=-0.15 and p.y<1 and absf(p.z)<4.5:
		player_position = p
		has_save = true

func write_local(pos: Vector3) -> Error:
	var cfg := ConfigFile.new()
	cfg.set_value("settings","sensitivity",sensitivity)
	cfg.set_value("settings","fullscreen",fullscreen)
	cfg.set_value("settings","shadows",shadows)
	cfg.set_value("player","position",pos)
	var result := cfg.save(PATH+".tmp")
	if result != OK: return result
	result = DirAccess.rename_absolute(PATH+".tmp",PATH)
	if result == OK:
		player_position = pos
		has_save = true
	return result
