extends "res://tests/phase1c_flow.gd"
const SAVE_NOTE := "/tmp/dream-phase1d-savepath.txt"

func face(yaw: float) -> void:
	var event:=InputEventMouseMotion.new()
	event.relative=Vector2(wrapf(game.camera_rig.yaw-yaw,-PI,PI)/game.camera_rig.sensitivity,0)
	root.push_input(event,true)
	await frames(2)

func walk_to(point: Vector3) -> void:
	game.camera_rig.focus_offset=Vector3.ZERO
	var start: Vector3=game.player.position
	await key(KEY_W,true)
	for i in range(600):
		var delta: Vector3=point-game.player.position
		delta.y=0
		if delta.length()<0.18: break
		var yaw:=atan2(-delta.x,-delta.z)
		var event:=InputEventMouseMotion.new()
		event.relative=Vector2(wrapf(game.camera_rig.yaw-yaw,-PI,PI)/game.camera_rig.sensitivity,0)
		root.push_input(event,true)
		await frames(1)
	await key(KEY_W,false)
	await frames(8)
	check(Vector2(point.x-game.player.position.x,point.z-game.player.position.z).length()<0.4,"actual movement reaches waypoint "+str(point))
	if game.player.position.distance_to(start)<0.1 and point.distance_to(start)>0.5:
		push_error("Walking route blocked")

func photo_room() -> void:
	game.camera_rig.focus_offset=Vector3(0,0,-1.4)-Vector3(game.player.position.x,0,game.player.position.z)
	game.camera_rig.distance=6.3
	game.camera_rig.pitch=0.34
	game.camera_rig.camera.fov=56
	await face(0.08)
	await create_timer(0.7).timeout

func press_world_fast(code: Key) -> void:
	for down in [true,false]:
		var event:=InputEventKey.new()
		event.keycode=code
		event.physical_keycode=code
		event.pressed=down
		root.push_input(event,true)

func immediate_shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image:=root.get_texture().get_image()
	check(image.get_size()==Vector2i(1280,720) and image.save_png(output+name+".png")==OK,"genuine capture: "+name)

func resume_saved() -> void:
	file=FileAccess.get_file_as_string(SAVE_NOTE).strip_edges()
	await load_game()
	check(game.save.has_save and game.save.cozy_corner_completed,"new process loads completed cozy-corner save")
	await click("Continue home  →")
	check(game.room.keepsake.visible and game.room.lamp_control.on and game.room.curtain_control.closed and game.room.plant_control.has_watered,"Continue restores all settled states and physical keepsake")
	check(not game.room.plant_control.busy and not game.room.plant_control.effect.visible,"Continue does not replay temporary watering")
	check(game.save.unlocks==["lavender_dream"] and game.save.best_moves==6,"unrelated puzzle progress survives new room saves")
	await photo_room()
	await shot("continued_room")
	print("PHASE 1D CONTINUE: ",checks-failures,"/",checks)
	if failures: quit(1); return
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	await click("Save & main menu")
	await click("Quit")

func run() -> void:
	if DisplayServer.get_name()=="headless": quit(1); return
	output="res://docs/review/phase1d/"
	root.size=Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(output)
	if "--resume" in OS.get_cmdline_user_args():
		await resume_saved()
		return
	file="user://phase1d_flow_"+str(Time.get_ticks_usec())+".cfg"
	FileAccess.open(SAVE_NOTE,FileAccess.WRITE).store_string(file)
	await load_game()
	await click("Come on in  →")
	# Water first, before opening the optional goal hint, using a real walk around the table.
	await walk_to(Vector3(-4.2,0,1.8))
	await walk_to(Vector3(-4.2,0,-3.4))
	game.camera_rig.focus_offset=Vector3(-3,0,-3.9)-Vector3(game.player.position.x,0,game.player.position.z)+Vector3(0,-0.35,0)
	game.camera_rig.distance=2.6
	game.camera_rig.pitch=0.35
	await face(-0.3)
	await create_timer(0.6).timeout
	await frames(4)
	check(game.interaction_target==game.room.plant_control and game.ui.prompt.text==game.room.plant_control.prompt,"water prompt selects only existing plant")
	press_world_fast(KEY_E)
	check(game.room.plant_control.busy and game.room.plant_control.effect.visible,"actual E starts visible watering")
	await immediate_shot("watering")
	press_world_fast(KEY_E)
	press_world_fast(KEY_E)
	check(game.room.plant_control.drops.size()==9 and game.active,"rapid watering cannot stack effects or open puzzle")
	await create_timer(1.35).timeout
	check(game.room.plant_control.has_watered and not game.room.plant_control.effect.visible,"watering completes and cleans up")
	await key(KEY_H,true)
	await key(KEY_H,false)
	check(game.ui.guidance_kind=="cozy" and game.ui.cozy_context["living_room.houseplant"],"optional H hint recognizes watering performed before discovery")
	await key(KEY_H,true)
	await key(KEY_H,false)
	check(game.save.cozy_hint_dismissed and game.ui.guidance_kind=="cozy_collapsed","cozy hint collapses without blocking free play")
	await walk_to(Vector3(-3,0,-1.8))
	await walk_to(Vector3(2.55,0,-1.8))
	await walk_to(Vector3(3.45,0,-3))
	await photo_room()
	check(game.interaction_target==game.room.lamp_control,"real walk reaches floor-lamp switch")
	await key(KEY_E,true)
	await key(KEY_E,false)
	await create_timer(0.4).timeout
	check(not game.room.lamp_control.on and game.active,"E turns lamp off without launching puzzle")
	await shot("lamp_off")
	await key(KEY_E,true)
	await key(KEY_E,false)
	await create_timer(0.4).timeout
	check(game.room.lamp_control.on and game.room.lamp_control.light.light_energy>0,"E restores warm local light")
	await shot("lamp_on")
	for code in [KEY_C,KEY_B,KEY_ESCAPE]:
		await key(code,true)
		await key(code,false)
		var state: int=game.state
		await key(KEY_E,true)
		await key(KEY_E,false)
		check(game.state==state and game.room.lamp_control.on,"rendered modal blocks lamp E: "+str(code))
		await key(KEY_ESCAPE,true)
		await key(KEY_ESCAPE,false)
	await walk_to(Vector3(3.95,0,-3.05))
	await photo_room()
	check(game.interaction_target==game.room.curtain_control,"curtain anchor is reachable with one matching prompt")
	await shot("curtains_open")
	await key(KEY_E,true)
	await key(KEY_E,false)
	await create_timer(0.75).timeout
	check(game.room.curtain_control.closed and game.room.curtain_control.is_settled(),"E closes existing curtain meshes")
	await shot("curtains_closed")
	check(game.save.cozy_corner_completed and game.room.keepsake.visible,"three actual interactions complete arrangement once")
	await key(KEY_B,true)
	await key(KEY_B,false)
	await tap("rug_mint")
	check(game.feature.theme_choice.get_item_text(game.feature.theme_choice.selected)=="Mixed" and game.feature.decor_buttons.rug_mint.get_meta("selected") and game.feature.decor_buttons.rug_lavender_dream.disabled,"Decor exposes selected, Mixed and locked states")
	game.feature.decor_buttons.curtains_rosewater.grab_focus()
	await shot("decor_selected_locked")
	root.size=Vector2i(1920,1080)
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	var high:=root.get_texture().get_image()
	check(high.get_size()==Vector2i(1920,1080) and game.feature.panel.get_global_rect().end.y<root.get_visible_rect().size.y,"selected/focus/locked layout fits 1920x1080")
	high.save_png("/tmp/phase1d-decor-1080p.png")
	root.size=Vector2i(1280,720)
	await click("Cancel")
	check(game.save.decor.rug=="rosewater" and game.room.curtain_control.closed,"Cancel restores palette without reopening curtains")
	await photo_room()
	await shot("cozy_corner")
	# Change the arrangement after completion; the same keepsake remains owned.
	await key(KEY_E,true)
	await key(KEY_E,false)
	await create_timer(0.75).timeout
	check(not game.room.curtain_control.closed and game.room.keepsake.visible,"reopening does not revoke keepsake")
	await key(KEY_E,true)
	await key(KEY_E,false)
	await create_timer(0.75).timeout
	await walk_to(Vector3(2.6,0,-1.8))
	await walk_to(Vector3(0,0,0.55))
	await face(0)
	await frames(5)
	check(game.interaction_target!=null and game.interaction_target.interaction_id=="cozy_pairs_box","card-box interaction still resolves explicitly")
	await key(KEY_E,true)
	await key(KEY_E,false)
	if game.state!=game.State.PUZZLE: check(false,"puzzle opens"); quit(1); return
	var good_bytes:=FileAccess.get_file_as_bytes(file)
	DirAccess.make_dir_absolute(file+".tmp")
	var rules=game.feature.rules
	for id in range(6):
		var pair: Array[int]=[]
		for index in range(12):
			if rules.deck[index]==id: pair.append(index)
		await tap("Card_"+str(pair[0]))
		await tap("Card_"+str(pair[1]))
		await wait_pair()
	check(rules.finished and game.feature.retry_button.visible and not game.feature.result_saved,"real filesystem failure exposes Retry Save after legitimate card win")
	await click("Retry save")
	check(not game.feature.result_saved and game.feature.retry_button.visible and FileAccess.get_file_as_bytes(file)==good_bytes,"continued failure keeps truthful status and original file")
	game.feature.retry_button.grab_focus()
	DirAccess.remove_absolute(file+".tmp")
	await click("Retry save")
	check(game.feature.result_saved and not game.feature.retry_button.visible and root.gui_get_focus_owner()==game.feature.result_apply,"successful actual retry hides action and transfers focus")
	check(game.save.unlocks.size()==1 and game.save.best_moves==6,"retry cannot duplicate puzzle progression")
	await shot("puzzle_reward_saved")
	await click("Keep My Current Style")
	await walk_to(Vector3(-3,0,1.8))
	await walk_to(Vector3(-4.2,0,-2.8))
	game.camera_rig.focus_offset=Vector3(-4.65,1.4,-3.2)-Vector3(game.player.position.x,0,game.player.position.z)
	game.camera_rig.distance=2.0
	game.camera_rig.pitch=0.05
	await face(0)
	await create_timer(0.6).timeout
	await shot("keepsake_detail")
	await walk_to(Vector3(-3,0,1.8))
	await walk_to(Vector3(0,0,1.8))
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	await click("Save & main menu")
	check(game.state==game.State.MENU,"return home preserves confirmed interactions")
	print("PHASE 1D FLOW: ",checks-failures,"/",checks)
	if failures: quit(1); return
	await click("Quit")
