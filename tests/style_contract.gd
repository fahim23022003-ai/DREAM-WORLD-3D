extends "res://tests/phase_one.gd"
const S = preload("res://scripts/save_data.gd")
func channel_node(parent: Node, id: String) -> MeshInstance3D:
	for node in parent.find_children("*","MeshInstance3D",true,false):
		if node.get_meta("style_channel","")==id: return node
	return null
func run() -> void:
	root.size = Vector2i(1280,720)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.save.path = "user://style_contract_"+str(Time.get_ticks_usec())+".cfg"
	await frames(3)
	game.start_game()
	var hair := channel_node(game.player.avatar,"hair")
	var rug := channel_node(game.room,"decor.rug")
	var curtain := channel_node(game.room,"decor.curtains")
	check(hair!=null and rug!=null and curtain!=null,"explicit avatar and room channels registered")
	var hair_color: Color = hair.material_override.albedo_color
	var rug_color: Color = rug.material_override.albedo_color
	var rug_texture: Texture2D = rug.material_override.albedo_texture
	var rug_roughness: float = rug.material_override.roughness
	var fixed_surfaces: Dictionary = {}
	for node in game.player.avatar.find_children("*","MeshInstance3D",true,false):
		if not node.has_meta("style_channel"): fixed_surfaces[node] = node.material_override.albedo_color
	var other_avatar = load("res://scenes/avatar.tscn").instantiate()
	game.add_child(other_avatar)
	var other_hair := channel_node(other_avatar,"hair")
	var other_color: Color = other_hair.material_override.albedo_color
	var cache_color: Color = load("res://scripts/forms.gd").material("77574f").albedo_color
	var yaw: float = game.camera_rig.yaw
	game.open_style(game.State.PERSONALIZE)
	game.feature.set_color(Color("b67c8e"))
	check(hair.material_override.albedo_color!=hair_color and rug.material_override.albedo_color==rug_color,"live appearance preview changes only avatar channel")
	check(load("res://scripts/forms.gd").material("77574f").albedo_color==cache_color,"shared material cache untouched")
	var untouched := true
	for node in fixed_surfaces: untouched = untouched and node.material_override.albedo_color==fixed_surfaces[node]
	check(untouched,"skin, eyes, buttons and all untagged avatar surfaces remain unchanged")
	check(other_hair.material_override.albedo_color==other_color,"appearance cannot leak to another avatar instance")
	check(not game.active and not game.player.enabled and not game.camera_rig.enabled,"style UI blocks movement and camera")
	game.persist()
	var saved = S.new()
	saved.path = game.save.path
	saved.load_local()
	check(saved.appearance.hair==Color("805c52"),"autosave boundary excludes appearance preview")
	game.cancel_feature()
	check(game.active and hair.material_override.albedo_color==hair_color and game.camera_rig.yaw==yaw,"Cancel restores appearance, camera and gameplay")
	game.open_style(game.State.PERSONALIZE)
	game.feature.set_color(Color("bb8e63"))
	game.feature.appearance.display_name = "   Meadow   "
	game.confirm_feature()
	saved = S.new()
	saved.path = game.save.path
	saved.load_local()
	check(saved.appearance.display_name=="Meadow" and saved.appearance.hair==Color("bb8e63"),"Apply trims name and persists appearance")
	game.open_style(game.State.DECOR)
	game.feature.decor.rug="mint"
	game.feature.decor.curtains="mint"
	game.feature.decor_preview.emit(game.feature.decor)
	check(rug.material_override.albedo_color!=rug_color,"decor previews real rug material")
	check(rug.material_override.albedo_texture==rug_texture and rug.material_override.roughness==rug_roughness,"decor retains original pattern texture and roughness")
	check(game.feature.find_child("rug_lavender_dream",true,false).disabled,"locked decor cannot be selected")
	game.persist()
	saved.load_local()
	check(saved.decor.rug=="rosewater","preview decor excluded from writes")
	game.cancel_feature()
	check(rug.material_override.albedo_color==rug_color,"Cancel restores room")
	game.open_style(game.State.DECOR)
	game.feature.decor.rug="mint"
	game.confirm_feature()
	saved.load_local()
	check(saved.decor.rug=="mint" and saved.decor.cushions=="rosewater","per-surface Apply persists stable IDs")
	game.pause_game()
	game.open_style(game.State.PERSONALIZE)
	game.cancel_feature()
	check(game.state==game.State.PAUSE and not game.active,"pause-launched panel returns to pause")
	game.resume_game()
	game.open_style(game.State.PERSONALIZE)
	game.feature.set_color(Color.RED)
	game.save.write_blocked = ERR_CANT_CREATE
	game.confirm_feature()
	check(game.state==game.State.PERSONALIZE and game.save.appearance.hair==Color("bb8e63") and not game.feature.status.text.is_empty(),"failed Apply keeps preview open and confirmed data unchanged")
	game.cancel_feature()
	print("STYLE CONTRACT: ",checks-failures,"/",checks)
	quit(0 if failures==0 else 1)
