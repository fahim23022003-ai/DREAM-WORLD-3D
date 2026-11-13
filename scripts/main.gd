extends Node3D
const SaveData = preload("res://scripts/save_data.gd")
@export var save_path := SaveData.PATH
var save = SaveData.new()
var player: CharacterBody3D
var camera_rig: Node3D
var ui: CanvasLayer
enum State { MENU, PLAY, PAUSE, PERSONALIZE, DECOR, PUZZLE, HOME }
var state := State.MENU
var active: bool:
	get: return state == State.PLAY
var in_game: bool:
	get: return state != State.MENU
var autosave_time := 0.0
var room: Node3D
var feature: Control
var feature_return := State.PLAY
var camera_backup: Dictionary = {}
var interaction_target: Node3D
var audio: Node
var home: Node

func _ready() -> void:
	setup_input()
	save.path = save_path
	save.load_local()
	room = preload("res://scenes/room.tscn").instantiate()
	add_child(room)
	room.apply_decor(save.decor)
	room.apply_state(save.room_state,save.cozy_corner_completed)
	player = preload("res://scenes/player.tscn").instantiate()
	player.position = save.player_position
	add_child(player)
	player.avatar.apply_appearance(save.appearance)
	camera_rig = preload("res://scenes/camera.tscn").instantiate()
	add_child(camera_rig)
	camera_rig.target = player
	camera_rig.position = player.position+Vector3(0,1.25,0)
	camera_rig.arm.add_excluded_object(player.get_rid())
	player.camera_rig = camera_rig
	ui = preload("res://scenes/menus.tscn").instantiate()
	ui.saved = save.has_save
	ui.sensitivity = save.sensitivity
	ui.fullscreen = save.fullscreen
	ui.shadows = save.shadows
	add_child(ui)
	ui.personalize_requested.connect(func(): open_style(State.PERSONALIZE))
	ui.decor_requested.connect(func(): open_style(State.DECOR))
	ui.guidance_changed.connect(func(dismissed):
		save.onboarding.dismissed=dismissed
		if dismissed: save.cozy_hint_dismissed=true
		persist()
		refresh_guidance())
	ui.cozy_guidance_changed.connect(func(dismissed): save.cozy_hint_dismissed=dismissed; persist(); refresh_guidance())
	ui.audio_changed.connect(func(volume,muted): save.ui_volume=volume; save.muted=muted; audio.configure(volume,muted); persist())
	ui.sound_requested.connect(func(kind): audio.play(kind))
	ui.start_requested.connect(start_game)
	ui.resume_requested.connect(resume_game)
	ui.main_requested.connect(main_menu)
	ui.quit_requested.connect(quit_game)
	ui.settings_changed.connect(apply_settings)
	audio = preload("res://scripts/ui_audio.gd").new()
	add_child(audio)
	audio.configure(save.ui_volume,save.muted)
	ui.ui_volume = save.ui_volume
	ui.muted = save.muted
	apply_settings(save.sensitivity,save.fullscreen,save.shadows,false)
	room.state_changed.connect(room_state_changed)
	room.plant_control.watered.connect(func(_first): room_state_changed("A little drink. Your plant looks happy."))
	home=preload("res://scripts/home_controller.gd").new()
	add_child(home)
	home.setup(self)
	get_tree().auto_accept_quit = false

func setup_input() -> void:
	var bindings := {"forward":KEY_W,"back":KEY_S,"left":KEY_A,"right":KEY_D,"run":KEY_SHIFT,"interact":KEY_E,"pause":KEY_ESCAPE,"personalize":KEY_C,"decorate":KEY_B,"cozy_hint":KEY_H,"daily_goals":KEY_Q,"home_catalog":KEY_J}
	for action in bindings:
		if InputMap.has_action(action): continue
		InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = bindings[action]
		InputMap.action_add_event(action,event)

func set_active(value: bool) -> void:
	state = State.PLAY if value else State.PAUSE
	player.enabled = value
	camera_rig.enabled = value
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if value else Input.MOUSE_MODE_VISIBLE

func start_game() -> void:
	if not save.cozy_corner_completed and room.is_cozy(): room_state_changed()
	resume_game()

func resume_game() -> void:
	ui.show_page("game")
	refresh_guidance()
	ui.home_label.text = save.appearance.display_name+"  ·  ROSEWATER HOUSE"
	# Bound long display names before the adjacent day/coins badge.
	ui.home_label.clip_text=true
	ui.home_label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	ui.home_label.custom_minimum_size.x=minf(310,ui.home_label.get_theme_font("font").get_string_size(ui.home_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,ui.home_label.get_theme_font_size("font_size")).x)
	set_active(true)

func pause_game() -> void:
	set_active(false)
	persist()
	ui.show_page("pause")

func main_menu() -> void:
	persist()
	set_active(false)
	ui.saved = save.has_save
	state = State.MENU
	ui.show_page("main")

func persist(silent: bool = false) -> Error:
	var pos: Vector3 = player.current_seat.stand_position() if player.seated else player.global_position
	var result: Error = save.write_local(pos)
	if not silent or result!=OK: ui.show_notice("Home saved  ✓" if result == OK else "Save unavailable — previous save retained")
	if result != OK: push_warning("Could not write local save: " + error_string(result))
	return result

func apply_settings(sense: float, full: bool, shadow: bool, write: bool = true) -> void:
	save.sensitivity = sense
	save.fullscreen = full
	save.shadows = shadow
	camera_rig.sensitivity = 0.0024*sense
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if full else DisplayServer.WINDOW_MODE_WINDOWED)
	for child in get_child(0).get_children():
		if child is DirectionalLight3D: child.shadow_enabled = shadow
	if write: persist()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if state in [State.PERSONALIZE,State.DECOR]:
			if not feature.dismiss_popup(): cancel_feature()
		elif state==State.PLAY: pause_game()
		elif state==State.PAUSE: resume_game()
		elif state==State.PUZZLE: cancel_feature()
		elif state==State.HOME: home.close()
		elif ui.mode=="settings_main": ui.show_page("main")
		get_viewport().set_input_as_handled()
	elif state==State.PLAY:
		if event.is_action_pressed("daily_goals"): home.open_goals()
		elif event.is_action_pressed("home_catalog"): home.open_catalog()
		elif event.is_action_pressed("cozy_hint"):
			ui.guidance_mode="cozy"
			save.cozy_hint_dismissed=ui.guidance_kind=="cozy"
			persist()
			refresh_guidance()
		elif event.is_action_pressed("personalize"): open_style(State.PERSONALIZE)
		elif event.is_action_pressed("decorate"): open_style(State.DECOR)
		elif event.is_action_pressed("interact"): activate_interaction()

func activate_interaction() -> bool:
	if state!=State.PLAY: return false
	if player.seated:
		player.interact()
		return true
	interaction_target = preload("res://scripts/interaction.gd").resolve(player,camera_rig)
	if not interaction_target: return false
	match interaction_target.interaction_id:
		"sofa":
			player.nearby_seat = interaction_target
			player.interact()
		"cozy_pairs_box": open_puzzle()
		"living_room.floor_lamp":
			room.lamp_control.toggle()
			audio.play("switch")
			if room.lamp_control.on: home.record("lamp")
		"living_room.curtains":
			room.curtain_control.toggle()
			audio.play("switch")
			home.record("curtains")
		"living_room.houseplant":
			if not room.plant_control.water(): return false
			audio.play("water")
		_:
			if home.handles(interaction_target.interaction_id): home.activate(interaction_target.interaction_id)
			else: return false
	return true

func open_style(which: State) -> void:
	if not state in [State.PLAY,State.PAUSE]: return
	feature_return = state
	camera_backup = {"yaw":camera_rig.yaw,"pitch":camera_rig.pitch,"distance":camera_rig.distance,"focus_offset":camera_rig.focus_offset,"position":camera_rig.position,"rotation":camera_rig.rotation,"spring":camera_rig.arm.spring_length,"fov":camera_rig.camera.fov,"avatar_rotation":player.avatar.rotation}
	set_active(false)
	state = which
	ui.show_page("game")
	ui.hud.hide()
	feature = preload("res://scripts/personal_decor.gd").new()
	feature.ui = ui
	ui.root.add_child(feature)
	feature.open("personalize" if which==State.PERSONALIZE else "decor",save.appearance,save.decor,save.unlocks)
	feature.home_catalog_requested.connect(func(): cancel_feature(); home.open_catalog())
	feature.appearance_preview.connect(func(data): player.avatar.apply_appearance(data))
	feature.decor_preview.connect(func(data): room.apply_decor(data))
	feature.apply_requested.connect(confirm_feature)
	feature.cancel_requested.connect(cancel_feature)
	camera_rig.pitch = 0.08 if which==State.PERSONALIZE else 0.36
	camera_rig.distance = 2.6 if which==State.PERSONALIZE else 6.5
	camera_rig.yaw = 0.06
	camera_rig.focus_offset = Vector3(0,0.13,0) if which==State.PERSONALIZE else Vector3(1.4,0,-3.3)
	if which==State.PERSONALIZE: player.avatar.rotation.y = camera_rig.yaw

func confirm_feature() -> void:
	if state==State.DECOR:
		for id in feature.decor.values():
			if not id in preload("res://scripts/style_data.gd").PRESETS or (id=="lavender_dream" and not id in save.unlocks):
				feature.status.text="Win Cozy Pairs to unlock Lavender Dream."
				return
	var old_appearance: Dictionary = save.appearance.duplicate(true)
	var old_decor: Dictionary = save.decor.duplicate(true)
	var old_hints: Dictionary = save.onboarding.duplicate()
	if state==State.PERSONALIZE:
		save.appearance = feature.appearance.duplicate(true)
		save.appearance.display_name = SaveData.clean_name(save.appearance.display_name)
		save.onboarding.personalized = true
	else:
		save.decor = feature.decor.duplicate(true)
		save.onboarding.decorated = true
		if "lavender_dream" in save.decor.values(): save.onboarding.reward_applied = true
	if persist()!=OK:
		save.appearance=old_appearance
		save.decor=old_decor
		save.onboarding=old_hints
		feature.status.text="Could not save. Your previous save is safe. Retry or Cancel."
		return
	close_feature()

func cancel_feature() -> void:
	if state==State.PUZZLE:
		feature.abort()
		close_feature()
		return
	player.avatar.apply_appearance(save.appearance)
	room.apply_decor(save.decor)
	close_feature()

func close_feature() -> void:
	if feature.has_method("abort"): feature.abort()
	ui.root.remove_child(feature)
	feature.queue_free()
	feature = null
	if not camera_backup.is_empty():
		for key in ["yaw","pitch","distance","focus_offset","position","rotation"]: camera_rig.set(key,camera_backup[key])
		camera_rig.arm.spring_length = camera_backup.spring
		camera_rig.camera.fov = camera_backup.fov
		player.avatar.rotation = camera_backup.avatar_rotation
	camera_backup.clear()
	if feature_return==State.PAUSE:
		set_active(false)
		ui.show_page("pause")
	else: resume_game()

func _physics_process(_delta: float) -> void:
	interaction_target = preload("res://scripts/interaction.gd").resolve(player,camera_rig) if active and not player.seated else null
	if active: ui.set_prompt("E   ·   Stand up" if player.seated else (interaction_target.prompt if interaction_target else ""))

func open_puzzle() -> void:
	if state!=State.PLAY or player.seated: return
	feature_return = State.PLAY
	set_active(false)
	state = State.PUZZLE
	ui.show_page("game")
	ui.hud.hide()
	feature = preload("res://scripts/cozy_pairs.gd").new()
	feature.ui = ui
	ui.root.add_child(feature)
	feature.completed.connect(puzzle_completed)
	feature.exit_requested.connect(cancel_feature)
	feature.keep_style_requested.connect(cancel_feature)
	feature.apply_theme_requested.connect(apply_reward)
	feature.retry_save_requested.connect(func():
		var result := persist()
		feature.set_save_status(result==OK))
	feature.sound_requested.connect(func(kind): audio.play(kind))

func puzzle_completed(result: Dictionary) -> void:
	if state!=State.PUZZLE or feature.completion_handled or not feature.rules.finished: return
	if result.get("puzzle_id")!="cozy_pairs" or result.get("moves")!=feature.rules.moves or feature.rules.pairs!=6: return
	feature.completion_handled = true
	var first: bool = not "lavender_dream" in save.unlocks
	if first: save.unlocks.append("lavender_dream")
	var moves: int = result.moves
	if save.best_moves==0 or moves<save.best_moves: save.best_moves=moves
	save.onboarding.played = true
	home.stage_puzzle_goal()
	var written := persist()==OK
	feature.show_result(moves,save.best_moves,first,written)
	audio.play("reward")

func apply_reward() -> void:
	if state!=State.PUZZLE or not feature.completion_handled or not "lavender_dream" in save.unlocks: return
	var old: Dictionary = save.decor.duplicate()
	var old_hint: bool = save.onboarding.reward_applied
	for surface in save.decor: save.decor[surface]="lavender_dream"
	save.onboarding.reward_applied = true
	if persist()!=OK:
		save.decor=old
		save.onboarding.reward_applied=old_hint
		feature.set_save_status(false,"Theme not saved yet. Previous room kept. Retry Apply or save the reward.")
		return
	room.apply_decor(save.decor)
	close_feature()
	ui.show_notice("Lavender Dream is yours. Welcome home!")

func _process(delta: float) -> void:
	if not active: return
	autosave_time += delta
	if autosave_time>20:
		persist()
		autosave_time = 0

func quit_game() -> void:
	if state==State.HOME:
		home.sleep_busy=false
		home.close()
	if state in [State.PERSONALIZE,State.DECOR,State.PUZZLE]: cancel_feature()
	persist()
	audio.stop_all()
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: quit_game()

func refresh_guidance() -> void:
	ui.update_guidance(save.onboarding,room.capture_state(),save.cozy_corner_completed,save.cozy_hint_dismissed)

func room_state_changed(message: String = "") -> void:
	save.room_state=room.capture_state()
	var first: bool = not save.cozy_corner_completed and room.is_cozy()
	if first:
		save.cozy_corner_completed=true
		room.keepsake.show()
	var written := persist()==OK
	refresh_guidance()
	if first:
		audio.play("reward")
		ui.show_notice("Cozy corner made! Shelf keepsake saved." if written else "Cozy corner made — not saved yet.")
	elif written and not message.is_empty(): ui.show_notice(message)
	if not message.is_empty() and home: home.record("water")
