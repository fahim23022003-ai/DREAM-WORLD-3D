extends "res://tests/phase_one.gd"
func key(code: Key, pressed: bool) -> void:
	var event:=InputEventKey.new()
	event.keycode=code
	event.physical_keycode=code
	event.pressed=pressed
	Input.parse_input_event(event)
	await frames(3)
	await RenderingServer.frame_post_draw
func run() -> void:
	root.size=Vector2i(1280,720)
	game=load("res://scenes/main.tscn").instantiate()
	game.save_path="user://focus_"+str(Time.get_ticks_usec())+".cfg"
	root.add_child(game)
	await frames(10)
	await RenderingServer.frame_post_draw
	check(root.gui_get_focus_owner() is Button,"main menu exposes ordinary initial keyboard focus")
	await key(KEY_TAB,true)
	await key(KEY_TAB,false)
	check(root.gui_get_focus_owner() is Button and root.gui_get_focus_owner().text=="Settings","Tab navigates main menu")
	await key(KEY_ENTER,true)
	await key(KEY_ENTER,false)
	check(game.ui.mode=="settings_main" and game.state==game.State.MENU,"Enter opens Settings without world input")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(game.ui.mode=="main","Esc returns from menu Settings")
	await key(KEY_ENTER,true)
	await key(KEY_ENTER,false)
	check(game.active,"Enter starts game from focused Start/Continue")
	await key(KEY_C,true)
	await key(KEY_C,false)
	var edit: LineEdit=game.feature.find_child("DisplayName",true,false)
	edit.grab_focus()
	check(root.gui_get_focus_owner()==edit,"name field supports keyboard focus")
	for b in game.feature.find_children("*","Button",true,false):
		if b.text=="Cancel": b.grab_focus()
	await key(KEY_ENTER,true)
	await key(KEY_ENTER,false)
	check(game.active and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED,"keyboard Cancel restores gameplay and cursor")
	game.audio.stop_all()
	await frames(3)
	print("UI FOCUS: ",checks-failures,"/",checks)
	quit(0 if failures==0 else 1)
