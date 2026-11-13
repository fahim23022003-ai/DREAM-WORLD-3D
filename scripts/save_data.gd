extends RefCounted
const PATH := "user://rosewater.cfg"
const VERSION := 2
const SURFACES := ["rug", "cushions", "curtains"]
var path := PATH
var sensitivity := 1.0
var fullscreen := false
var shadows := true
var ui_volume := 0.55
var muted := false
var player_position := Vector3(0,0,1.8)
var has_save := false
var appearance := {"display_name":"Dreamer", "hair":Color("805c52"), "accent":Color("b7c4df")}
var decor := {"rug":"rosewater", "cushions":"rosewater", "curtains":"rosewater"}
var unlocks: Array[String] = []
var best_moves := 0
var onboarding := {"personalized":false,"decorated":false,"played":false,"reward_applied":false,"dismissed":false}
var load_error: Error = OK
var write_blocked: Error = OK

static func clean_name(value: Variant) -> String:
	if not value is String: return "Dreamer"
	var text: String = value.strip_edges().replace("\n"," ").replace("\r"," ").replace("\t"," ").left(24)
	return "Dreamer" if text.is_empty() else text

static func safe_color(value: Variant, fallback: Color) -> Color:
	if value is Color and is_finite(value.r) and is_finite(value.g) and is_finite(value.b):
		return Color(clampf(value.r,0,1),clampf(value.g,0,1),clampf(value.b,0,1),1)
	return fallback

static func number(value: Variant, fallback: float, low: float, high: float) -> float:
	if (value is float or value is int) and is_finite(float(value)): return clampf(float(value),low,high)
	return fallback

func load_local() -> void:
	var cfg := ConfigFile.new()
	load_error = cfg.load(path)
	if load_error == ERR_FILE_NOT_FOUND: return
	if load_error != OK:
		# Never overwrite a corrupt file with defaults. Recover from the retained good copy if possible.
		write_blocked = load_error
		if cfg.load(path+".last_good") != OK: return
	has_save = true
	var schema: Variant = cfg.get_value("meta","schema_version",1)
	if schema is int and schema>VERSION: write_blocked = ERR_UNAVAILABLE
	if not schema is int or schema<VERSION:
		var backup := path+".v1.bak"
		if not FileAccess.file_exists(backup):
			var result := DirAccess.copy_absolute(path,backup)
			if result != OK: write_blocked = result
	sensitivity = number(cfg.get_value("settings","sensitivity",1.0),1,0.4,2)
	fullscreen = read_bool(cfg,"settings","fullscreen",false)
	shadows = read_bool(cfg,"settings","shadows",true)
	ui_volume = number(cfg.get_value("settings","ui_volume",0.55),0.55,0,1)
	muted = read_bool(cfg,"settings","muted",false)
	var pos: Variant = cfg.get_value("player","position",player_position)
	if pos is Vector3 and pos.is_finite() and absf(pos.x)<5.7 and pos.y>=-0.15 and pos.y<1 and absf(pos.z)<4.5: player_position = pos
	appearance.display_name = clean_name(cfg.get_value("appearance","display_name","Dreamer"))
	for key in ["hair","accent"]: appearance[key] = safe_color(cfg.get_value("appearance",key,appearance[key]),appearance[key])
	var unlocked: Variant = cfg.get_value("progress","lavender_dream",false)
	if unlocked is bool and unlocked: unlocks.assign(["lavender_dream"])
	var best: Variant = cfg.get_value("progress","cozy_pairs_best",0)
	if best is int and best>=6 and best<=1000000: best_moves = best
	for surface in SURFACES:
		var preset: Variant = cfg.get_value("decor",surface,"rosewater")
		if preset in ["rosewater","mint"] or (preset=="lavender_dream" and "lavender_dream" in unlocks): decor[surface] = preset
	for key in onboarding: onboarding[key] = read_bool(cfg,"onboarding",key,false)

func read_bool(cfg: ConfigFile, section: String, key: String, fallback: bool) -> bool:
	var value: Variant = cfg.get_value(section,key,fallback)
	return value if value is bool else fallback

func write_local(pos: Vector3) -> Error:
	if write_blocked != OK: return write_blocked
	if not pos.is_finite(): return ERR_INVALID_DATA
	var cfg := ConfigFile.new()
	# Retain unknown fields for forward-compatible additive changes.
	if FileAccess.file_exists(path) and cfg.load(path)!=OK: return ERR_FILE_CORRUPT
	cfg.set_value("meta","schema_version",VERSION)
	cfg.set_value("settings","sensitivity",sensitivity)
	cfg.set_value("settings","fullscreen",fullscreen)
	cfg.set_value("settings","shadows",shadows)
	cfg.set_value("settings","ui_volume",ui_volume)
	cfg.set_value("settings","muted",muted)
	cfg.set_value("player","position",pos)
	appearance.display_name = clean_name(appearance.display_name)
	for key in appearance: cfg.set_value("appearance",key,appearance[key])
	for key in decor: cfg.set_value("decor",key,decor[key])
	cfg.set_value("progress","lavender_dream","lavender_dream" in unlocks)
	cfg.set_value("progress","cozy_pairs_best",best_moves)
	for key in onboarding: cfg.set_value("onboarding",key,onboarding[key])
	var result := cfg.save(path+".tmp")
	if result != OK: return result
	if FileAccess.file_exists(path):
		result = DirAccess.copy_absolute(path,path+".last_good.tmp")
		if result != OK: return result
		result = DirAccess.rename_absolute(path+".last_good.tmp",path+".last_good")
		if result != OK: return result
	result = DirAccess.rename_absolute(path+".tmp",path)
	if result == OK:
		player_position = pos
		has_save = true
	return result
