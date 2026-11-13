extends SceneTree
## Genuine game-viewport captures. Uses isolated review save data; never edits real saves.
var game: Node3D
var output := "res://docs/review/phase1b/after/"

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	await create_timer(0.65).timeout
	await RenderingServer.frame_post_draw

func snap(file: String) -> void:
	await settle()
	var image := root.get_texture().get_image()
	var result := image.save_png(output+file+".png")
	if result != OK:
		push_error("Capture failed: "+file)
		quit(1)
	print("CAPTURE ",file," ",image.get_size())

func input_key(code: Key, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = down
	Input.parse_input_event(event)
	await physics_frame
	await physics_frame

func run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Rendered display required for genuine review captures")
		quit(1)
		return
	root.size = Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.player.position = Vector3(0,0,1.8)
	await snap("main_menu")
	game.ui.show_page("settings_main")
	await snap("settings")
	game.start_game()
	# Same player/camera pose as the before image for a fair room comparison.
	game.camera_rig.pitch = 0.34
	game.camera_rig.yaw = 0.24
	game.camera_rig.distance = 5.2
	game.camera_rig.camera.fov = 62
	await snap("room_comparison")
	game.camera_rig.camera.fov = 56
	game.player.position = Vector3(0,0,-1.75)
	game.player.velocity = Vector3.ZERO
	game.camera_rig.pitch = 0.36
	game.camera_rig.yaw = 0.18
	game.camera_rig.distance = 6.5
	await snap("room_wide")
	await input_key(KEY_E,true)
	await input_key(KEY_E,false)
	await snap("sofa_interaction")
	if not game.player.seated:
		push_error("Review seat interaction failed")
		quit(1)
		return
	await input_key(KEY_E,true)
	await input_key(KEY_E,false)
	await settle()
	game.player.position = Vector3(1.9,0,0.9)
	game.player.velocity = Vector3.ZERO
	game.camera_rig.pitch = 0.05
	game.camera_rig.yaw = 0.08
	game.camera_rig.distance = 2.0
	await snap("avatar_closeup")
	await input_key(KEY_ESCAPE,true)
	await input_key(KEY_ESCAPE,false)
	await snap("pause")
	quit(0)
