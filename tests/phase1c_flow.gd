extends "res://tests/phase_one.gd"
const S = preload("res://scripts/save_data.gd")
var legacy := false
var file := ""
var output := "res://docs/review/phase1c/after/"

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode=code
	event.keycode=code
	event.pressed=pressed
	Input.parse_input_event(event)
	await frames(3)
	await RenderingServer.frame_post_draw

func node_named(name: String) -> Control:
	return game.ui.root.find_child(name,true,false)

func tap_fast(node: Control) -> void:
	var point := node.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position=point
	motion.global_position=point
	root.push_input(motion,true)
	for down in [true,false]:
		var event := InputEventMouseButton.new()
		event.position=point
		event.global_position=point
		event.button_index=MOUSE_BUTTON_LEFT
		event.pressed=down
		root.push_input(event,true)

func tap(name: String) -> void:
	# Containers sort at idle; click the presented control, not its pre-layout rectangle.
	await process_frame
	await RenderingServer.frame_post_draw
	var node := node_named(name)
	if not node:
		check(false,"control exists: "+name)
		return
	tap_fast(node)
	await frames(3)
	await RenderingServer.frame_post_draw

func type_name(text: String) -> void:
	await tap("DisplayName")
	var select := InputEventKey.new()
	select.keycode=KEY_A
	select.physical_keycode=KEY_A
	select.ctrl_pressed=true
	select.pressed=true
	root.push_input(select,true)
	for character in text:
		var event := InputEventKey.new()
		event.unicode=character.unicode_at(0)
		event.keycode=character.to_upper().unicode_at(0)
		event.pressed=true
		root.push_input(event,true)
	await frames(3)

func shot(name: String) -> void:
	if legacy and name!="continued_legacy": return
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image.get_width()>=1280 and image.get_height()>=720 and image.save_png(output+name+".png")==OK,"genuine capture: "+name)

func wait_pair() -> void:
	for i in range(240):
		if not is_instance_valid(game.feature) or not game.feature.rules.locked: return
		await frames(1)
	check(false,"pair timer resolves within expected frames")

func load_game() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	game.save_path=file
	root.add_child(game)
	await frames(10)
	await RenderingServer.frame_post_draw

func run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("This flow requires a rendered display")
		quit(1)
		return
	legacy = "--legacy" in OS.get_cmdline_user_args()
	file="user://phase1c_flow_"+("legacy_" if legacy else "fresh_")+str(Time.get_ticks_usec())+".cfg"
	root.size=Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(output)
	if legacy:
		var cfg:=ConfigFile.new()
		cfg.set_value("player","position",Vector3(0,0,1.8))
		cfg.set_value("settings","sensitivity",1.3)
		cfg.set_value("settings","shadows",true)
		cfg.save(file)
	await load_game()
	check(game.state==game.State.MENU and game.save.has_save==legacy,"fresh/legacy session starts at truthful Start/Continue")
	if legacy: check(FileAccess.file_exists(file+".v1.bak") and is_equal_approx(game.save.sensitivity,1.3),"legacy backup and settings migration visible in real session")
	await click("Continue home  →" if legacy else "Come on in  →")
	check(game.active and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED,"Start enters play and captures cursor")
	var original_yaw: float=game.camera_rig.yaw
	var original_distance: float=game.camera_rig.distance
	var original_color: Color=game.save.appearance.hair
	await key(KEY_C,true)
	await key(KEY_C,false)
	check(game.state==game.State.PERSONALIZE and Input.mouse_mode==Input.MOUSE_MODE_VISIBLE,"C opens actual personalization UI")
	if game.state!=game.State.PERSONALIZE:
		print("Unexpected state after C: ",game.state,"; UI: ",game.ui.mode)
		quit(1)
		return
	await tap("hair_swatch_3")
	await type_name("  Meadow b  ")
	check(game.feature.appearance.display_name.contains("b") and game.state==game.State.PERSONALIZE,"typing B stays in name field; no gameplay shortcut")
	var position: Vector3=game.player.position
	var yaw: float=game.camera_rig.yaw
	await key(KEY_W,true)
	var motion:=InputEventMouseMotion.new()
	motion.relative=Vector2(140,30)
	root.push_input(motion,true)
	var wheel:=InputEventMouseButton.new()
	wheel.button_index=MOUSE_BUTTON_WHEEL_UP
	wheel.pressed=true
	root.push_input(wheel,true)
	await frames(8)
	await key(KEY_W,false)
	check(game.player.position.is_equal_approx(position) and game.camera_rig.yaw==yaw,"movement and orbit blocked while typing/previewing")
	game.persist()
	var saved=S.new()
	saved.path=file
	saved.load_local()
	check(saved.appearance.hair==original_color and saved.appearance.display_name=="Dreamer","preview is absent from actual disk save")
	await click("Cancel")
	check(game.active and game.camera_rig.yaw==original_yaw and game.camera_rig.distance==original_distance,"Cancel restores entire camera and gameplay")
	await key(KEY_C,true)
	await key(KEY_C,false)
	await type_name("  Meadow  ")
	await tap("hair_swatch_2")
	var choice: OptionButton=node_named("AppearanceChannel")
	choice.select(1)
	choice.item_selected.emit(1)
	await tap("accent_swatch_3")
	await tap("CustomColor")
	check(game.feature.picker.get_popup().visible and game.feature.picker.get_picker().picker_shape==ColorPicker.SHAPE_HSV_WHEEL,"built-in HSV wheel opens on actual avatar preview")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(game.state==game.State.PERSONALIZE,"first Esc closes topmost picker without resuming world")
	await shot("personalization")
	await click("Apply")
	saved.load_local()
	check(game.active and saved.appearance.display_name=="Meadow" and saved.appearance.accent.is_equal_approx(Color("c3a9db")),"actual Apply saves name and outfit selection")
	await key(KEY_B,true)
	await key(KEY_B,false)
	check(game.state==game.State.DECOR and node_named("rug_lavender_dream").disabled,"B opens decor with honest locked reward")
	await tap("rug_mint")
	await tap("cushions_mint")
	await tap("curtains_mint")
	await shot("decor_preview")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(game.active and game.save.decor.rug=="rosewater","Esc cancels decor preview")
	await key(KEY_B,true)
	await key(KEY_B,false)
	var theme: OptionButton=node_named("WholeTheme")
	theme.select(1)
	await click("Preview whole theme")
	await click("Apply")
	saved.load_local()
	check(saved.decor.values()==["mint","mint","mint"],"whole-theme preview and Apply persist all surfaces")
	await click("Hide tips")
	check(game.save.onboarding.dismissed,"guidance can be dismissed and saved")
	# Use actual movement and facing to reach the box from the initial play area.
	motion=InputEventMouseMotion.new()
	motion.relative=Vector2(game.camera_rig.yaw/game.camera_rig.sensitivity,0)
	root.push_input(motion,true)
	await key(KEY_W,true)
	for i in range(120):
		if game.player.position.z<0.65: break
		await frames(1)
	await key(KEY_W,false)
	await frames(4)
	check(game.interaction_target!=null and game.interaction_target.interaction_id=="cozy_pairs_box" and game.ui.prompt.text==game.interaction_target.prompt,"walk to card box; single prompt agrees with E")
	await key(KEY_E,true)
	await key(KEY_E,false)
	check(game.state==game.State.PUZZLE and not game.player.seated,"E launches puzzle without triggering sofa")
	if game.state!=game.State.PUZZLE: quit(1); return
	position=game.player.position
	yaw=game.camera_rig.yaw
	await key(KEY_W,true)
	await key(KEY_C,true)
	await key(KEY_C,false)
	root.push_input(motion,true)
	await key(KEY_W,false)
	check(game.player.position.is_equal_approx(position) and game.camera_rig.yaw==yaw and game.state==game.State.PUZZLE,"puzzle exclusively owns world input")
	var rules=game.feature.rules
	var other:=1
	while rules.deck[other]==rules.deck[0]: other+=1
	tap_fast(node_named("Card_0"))
	tap_fast(node_named("Card_0"))
	check(rules.moves==0 and rules.revealed.size()==1,"real same-card clicks ignored")
	tap_fast(node_named("Card_"+str(other)))
	var locked_moves: int=rules.moves
	tap_fast(node_named("Card_11"))
	check(rules.locked and rules.moves==locked_moves,"real rapid third click ignored while mismatch resolves")
	await wait_pair()
	check(rules.revealed.is_empty() and rules.moves==1 and rules.pairs==0,"real mismatch timer closes cards")
	await tap("Card_0")
	await shot("puzzle_in_progress")
	# Restart with an active mismatch timer, then wait past the old callback's due time.
	tap_fast(node_named("Card_"+str(other)))
	var generation: int=rules.generation
	await click("Restart")
	await create_timer(0.9).timeout
	check(rules.generation!=generation and rules.moves==0 and not rules.locked and rules.pairs==0,"Restart cancels delayed resolution and resets input lock")
	for id in range(6):
		var pair: Array[int]=[]
		for index in range(12):
			if rules.deck[index]==id: pair.append(index)
		await tap("Card_"+str(pair[0]))
		await tap("Card_"+str(pair[1]))
		await wait_pair()
	check(rules.finished and game.save.best_moves==6 and game.save.unlocks==["lavender_dream"],"real twelve-card completion earns one permanent theme and best")
	await shot("earned_reward")
	if legacy:
		await click("Keep My Current Style")
		check(game.save.decor.rug=="mint" and "lavender_dream" in game.save.unlocks,"actual deferral keeps unlock without replacing current style")
		await key(KEY_B,true)
		await key(KEY_B,false)
		check(not node_named("rug_lavender_dream").disabled,"deferred theme is available in Decor")
		theme=node_named("WholeTheme")
		theme.select(2)
		await click("Preview whole theme")
		await click("Apply")
	else: await click("Apply to My Room")
	check(game.active and game.save.decor.values()==["lavender_dream","lavender_dream","lavender_dream"],"earned theme applies immediately to actual room")
	await key(KEY_S,true)
	await frames(10)
	await key(KEY_S,false)
	await frames(8)
	await shot("applied_room")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	await click("Save & main menu")
	check(game.state==game.State.MENU,"save and return to menu")
	root.remove_child(game)
	game.queue_free()
	await frames(4)
	await load_game()
	await click("Continue home  →")
	check(game.active and game.save.appearance.display_name=="Meadow" and game.save.decor.rug=="lavender_dream" and game.save.best_moves==6,"new instance Continue reloads appearance, room and record")
	check(game.save.onboarding.dismissed and game.save.onboarding.reward_applied and not game.ui.guide.visible,"Continue does not repeat introductory guidance")
	await shot("continued_legacy" if legacy else "continued_room")
	# Verify scaled layout and genuine high-resolution rendering without adding a second UI pipeline.
	root.size=Vector2i(1920,1080)
	await key(KEY_C,true)
	await key(KEY_C,false)
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	var high:=root.get_texture().get_image()
	check(high.get_size()==Vector2i(1920,1080) and game.feature.panel.get_global_rect().end.y<root.get_visible_rect().size.y,"1920x1080 personalization layout is in bounds")
	high.save_png("/tmp/phase1c-1080p.png")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	root.size=Vector2i(1280,720)
	print("PHASE 1C ","LEGACY" if legacy else "FRESH",": ",checks-failures,"/",checks)
	game.audio.stop_all()
	await frames(3)
	quit(0 if failures==0 else 1)
