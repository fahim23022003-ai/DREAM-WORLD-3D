extends SceneTree
## Focused integration pass: real input events, physics and GUI callbacks.
var game: Node3D
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition: print("PASS ", description)
	else:
		failures += 1
		push_error("FAIL " + description)

func frames(count: int = 4) -> void:
	for i in range(count): await physics_frame

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	await frames(2)

func click(text: String) -> void:
	for node in game.ui.root.find_children("*","Button",true,false):
		if node.text == text:
			var point: Vector2 = node.get_global_rect().get_center()
			var move := InputEventMouseMotion.new()
			move.position = point
			move.global_position = point
			root.push_input(move,true)
			for state in [true,false]:
				var event := InputEventMouseButton.new()
				event.position = point
				event.global_position = point
				event.button_index = MOUSE_BUTTON_LEFT
				event.pressed = state
				root.push_input(event,true)
				if text == "Quit" and not state: return
				await frames(2)
			return
	check(false,"button exists: "+text)

func snapshot(filename: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/dream-"+filename+".png")

func run() -> void:
	root.size = Vector2i(1280,720)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(12)
	check(not game.active and game.ui.mode=="main","main scene opens to menu")
	await snapshot("menu")
	await click("Settings")
	check(game.ui.mode=="settings_main","settings opens through GUI")
	game.ui.sensitivity = 1.3
	game.ui.emit_settings()
	check(is_equal_approx(game.camera_rig.sensitivity,0.00312),"sensitivity applies")
	await click("Done")
	await click("Continue home  →" if game.ui.saved else "Come on in  →")
	check(game.active and game.ui.mode=="game","start button enters game")
	var p: CharacterBody3D = game.player
	p.position = Vector3(0,0,2.5)
	game.camera_rig.yaw = 0
	await frames(8)
	var start: Vector3 = p.position
	await key(KEY_W,true)
	await frames(24)
	await key(KEY_W,false)
	var walk := start.distance_to(p.position)
	check(walk>0.6 and p.position.z<start.z,"W moves forward relative to camera")
	p.position = start
	p.velocity = Vector3.ZERO
	await key(KEY_SHIFT,true)
	await key(KEY_W,true)
	await frames(24)
	await key(KEY_W,false)
	await key(KEY_SHIFT,false)
	check(start.distance_to(p.position)>walk*1.3,"Shift runs faster than walking")
	p.velocity = Vector3.ZERO
	await key(KEY_S,true)
	await frames(10)
	await key(KEY_S,false)
	check(p.velocity.z>0,"S moves backward")
	await key(KEY_A,true)
	await frames(10)
	await key(KEY_A,false)
	check(p.velocity.x<0,"A moves left")
	p.position = Vector3(5.2,0,2)
	p.velocity = Vector3.ZERO
	await key(KEY_D,true)
	await frames(40)
	await key(KEY_D,false)
	check(p.position.x<5.7 and p.position.x>5.3,"D moves right and solid wall blocks movement")
	p.position = Vector3(0,0,-1.7)
	p.velocity = Vector3.ZERO
	await key(KEY_W,true)
	await frames(40)
	await key(KEY_W,false)
	check(p.position.z>-2.4,"sofa collision blocks walking through furniture")
	check(p.nearby_seat!=null,"sofa proximity detects usable seat")
	await key(KEY_E,true)
	await key(KEY_E,false)
	await frames(35)
	check(p.seated and p.position.distance_to(p.pose_target)<0.03,"E seats player with visible pose transition")
	check(p.avatar.sit_blend>0.95,"avatar legs transition into seated pose")
	await snapshot("seated")
	await key(KEY_E,true)
	await key(KEY_E,false)
	check(not p.seated and p.position.z>-2.0,"E stands at clear exit point")
	var yaw: float = game.camera_rig.yaw
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(100,10000)
	root.push_input(motion,true)
	await frames(2)
	check(game.camera_rig.yaw!=yaw and game.camera_rig.pitch<=0.82,"mouse orbit responds and clamps pitch")
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	var distance: float = game.camera_rig.distance
	root.push_input(wheel,true)
	await frames(2)
	check(game.camera_rig.distance<distance,"scroll changes zoom")
	p.position = Vector3(0,0,4.1)
	game.camera_rig.yaw = 0
	game.camera_rig.pitch = 0.2
	await frames(50)
	check(game.camera_rig.arm.get_hit_length()<game.camera_rig.arm.spring_length-0.2,"SpringArm retracts at back wall")
	p.position = Vector3(0,0,1.8)
	p.velocity = Vector3.ZERO
	game.camera_rig.pitch = 0.34
	game.camera_rig.yaw = 0.24
	await frames(40)
	await snapshot("play")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(not game.active and game.ui.mode=="pause","Escape opens pause")
	var paused_position: Vector3 = p.position
	await key(KEY_W,true)
	await frames(10)
	await key(KEY_W,false)
	check(p.position.is_equal_approx(paused_position),"pause prevents movement")
	await click("Resume  →")
	check(game.active,"Resume button restores play")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	await click("Save & main menu")
	check(not game.in_game and game.ui.mode=="main","main-menu button returns home")
	var saved = load("res://scripts/save_data.gd").new()
	saved.load_local()
	check(saved.has_save and saved.player_position.distance_to(p.position)<0.01 and is_equal_approx(saved.sensitivity,1.3),"local position and settings survive reload")
	print("PHASE ONE: ",checks-failures,"/",checks," checks passed")
	if failures:
		quit(1)
	else:
		print("Invoking Quit button; expect process exit 0")
		await click("Quit")
