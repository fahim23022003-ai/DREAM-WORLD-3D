extends Node3D
const SaveData = preload("res://scripts/save_data.gd")
var save = SaveData.new()
var player: CharacterBody3D
var camera_rig: Node3D
var ui: CanvasLayer
var active := false
var in_game := false
var autosave_time := 0.0

func _ready() -> void:
	setup_input()
	save.load_local()
	add_child(preload("res://scenes/room.tscn").instantiate())
	player = preload("res://scenes/player.tscn").instantiate()
	player.position = save.player_position
	add_child(player)
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
	ui.start_requested.connect(start_game)
	ui.resume_requested.connect(resume_game)
	ui.main_requested.connect(main_menu)
	ui.quit_requested.connect(quit_game)
	ui.settings_changed.connect(apply_settings)
	apply_settings(save.sensitivity,save.fullscreen,save.shadows,false)
	get_tree().auto_accept_quit = false

func setup_input() -> void:
	var bindings := {"forward":KEY_W,"back":KEY_S,"left":KEY_A,"right":KEY_D,"run":KEY_SHIFT,"interact":KEY_E,"pause":KEY_ESCAPE}
	for action in bindings:
		InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = bindings[action]
		InputMap.action_add_event(action,event)

func set_active(value: bool) -> void:
	active = value
	player.enabled = value
	camera_rig.enabled = value
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if value else Input.MOUSE_MODE_VISIBLE

func start_game() -> void:
	in_game = true
	resume_game()

func resume_game() -> void:
	ui.show_page("game")
	set_active(true)

func pause_game() -> void:
	set_active(false)
	persist()
	ui.show_page("pause")

func main_menu() -> void:
	persist()
	in_game = false
	set_active(false)
	ui.saved = save.has_save
	ui.show_page("main")

func persist() -> void:
	var pos: Vector3 = player.current_seat.stand_position() if player.seated else player.global_position
	var result: Error = save.write_local(pos)
	ui.notice.text = "Home saved  ✓" if result == OK else "Save unavailable"
	if result != OK: push_warning("Could not write local save: " + error_string(result))

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
	if event.is_action_pressed("pause") and in_game:
		if active: pause_game()
		else: resume_game()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not active: return
	ui.set_prompt("E   ·   Stand up" if player.seated else ("E   ·   Settle into the sofa" if player.nearby_seat else ""))
	autosave_time += delta
	if autosave_time>20:
		persist()
		autosave_time = 0

func quit_game() -> void:
	persist()
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: quit_game()
