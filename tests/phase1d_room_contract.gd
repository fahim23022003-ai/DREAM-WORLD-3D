extends "res://tests/phase_one.gd"
const S=preload("res://scripts/save_data.gd")
class UnknownTarget extends Node3D:
	var interaction_id:="unsupported_test_id"
	var prompt:="E · Unknown fixture"
	func available(_pos: Vector3) -> bool: return true
	func interaction_position() -> Vector3: return global_position

func pose(pos: Vector3, yaw: float = 0) -> void:
	game.player.position=pos
	game.player.velocity=Vector3.ZERO
	game.camera_rig.yaw=yaw
	await frames(4)

func run() -> void:
	root.size=Vector2i(1280,720)
	game=load("res://scenes/main.tscn").instantiate()
	game.save_path="user://room_contract_"+str(Time.get_ticks_usec())+".cfg"
	root.add_child(game)
	game.start_game()
	check(game.room.lamp_control.on and not game.room.curtain_control.closed and not game.room.plant_control.has_watered and not game.room.keepsake.visible,"fresh room has safe settled defaults and no unearned keepsake")
	await pose(Vector3(0,0,0.55))
	var unknown:=UnknownTarget.new()
	unknown.position=Vector3(0,1.4,0.3)
	game.add_child(unknown)
	unknown.add_to_group("interactables")
	await frames(3)
	check(not game.activate_interaction() and game.active and game.feature==null,"unknown resolved ID never launches Cozy Pairs")
	unknown.queue_free()
	await frames(3)
	await pose(Vector3(2.55,0,-2.1))
	check(game.interaction_target==game.room.lamp_control and game.ui.prompt.text==game.room.lamp_control.prompt,"reachable lamp target and prompt agree")
	await key(KEY_E,true)
	await key(KEY_E,false)
	check(not game.room.lamp_control.on and game.active and game.feature==null,"one E switches lamp without opening puzzle")
	await create_timer(0.4).timeout
	check(is_zero_approx(game.room.lamp_control.light.light_energy) and game.room.lamp_control.is_settled(),"lamp off reaches zero local light")
	var lamp=game.room.lamp_control
	for i in range(21): lamp.toggle()
	await create_timer(0.4).timeout
	check(lamp.on and is_equal_approx(lamp.light.light_energy,lamp.ON_ENERGY) and lamp.shade.material_override.emission_energy_multiplier>0,"rapid lamp reversals settle at fixed on energy and warm emission")
	for i in range(20): lamp.toggle()
	await create_timer(0.4).timeout
	check(is_equal_approx(lamp.light.light_energy,lamp.ON_ENERGY),"repeated toggles cannot accumulate brightness")
	await pose(Vector3(2.55,0,-2.1),PI)
	check(not game.activate_interaction() and lamp.on,"facing away cannot switch lamp")
	await pose(Vector3(0,0,3))
	check(not game.activate_interaction() and lamp.on,"across-room activation rejected")
	await pose(Vector3(2.55,0,-2.1))
	var blocker=load("res://scripts/forms.gd").solid(game.room,Vector3(2.55,1.3,-2.8),Vector3(0.7,2.5,0.06))
	await frames(3)
	check(not game.activate_interaction() and lamp.on,"wall occlusion blocks lamp")
	blocker.queue_free()
	await frames(3)
	for panel in [game.State.PAUSE,game.State.PERSONALIZE,game.State.DECOR,game.State.PUZZLE]:
		game.resume_game()
		if panel==game.State.PAUSE: game.pause_game()
		elif panel==game.State.PUZZLE: game.open_puzzle()
		else: game.open_style(panel)
		await key(KEY_E,true)
		await key(KEY_E,false)
		check(not game.activate_interaction() and lamp.on and game.state==panel,"world E blocked in modal state "+str(panel))
		if game.feature: game.cancel_feature()
		else: game.resume_game()
	await pose(Vector3(3.9,0,-3))
	var curtains=game.room.curtain_control
	check(curtains.panels.all(func(panel): return panel.mesh.blend_shape_mode==Mesh.BLEND_SHAPE_MODE_NORMALIZED),"curtain targets use absolute positions instead of adding world coordinates")
	check(game.interaction_target==curtains and game.ui.prompt.text==curtains.prompt,"curtain pull is reachable and wins one target")
	var collision_count: int=game.room.find_children("*","StaticBody3D",true,false).size()
	await key(KEY_E,true)
	await key(KEY_E,false)
	await create_timer(0.75).timeout
	check(curtains.closed and curtains.is_settled() and is_equal_approx(curtains.panels[0].get_blend_shape_value(0),1) and not curtains.ties[0].visible,"curtains visibly unfold and tiebacks retract")
	check(curtains.fill.light_energy<curtains.baseline_fill and collision_count==game.room.find_children("*","StaticBody3D",true,false).size(),"closed window fill is restrained and collision remains intact")
	for id in ["rosewater","mint","lavender_dream"]:
		game.room.apply_decor({"rug":id,"cushions":id,"curtains":id})
		var color: Color=curtains.panels[0].material_override.albedo_color
		curtains.set_state(false,false)
		curtains.set_state(true,false)
		check(curtains.panels[0].material_override.albedo_color==color,"curtain motion preserves palette "+id)
	game.open_style(game.State.DECOR)
	game.feature.decor.curtains="mint"
	game.feature.decor_preview.emit(game.feature.decor)
	game.cancel_feature()
	check(curtains.closed and is_equal_approx(curtains.amount,1),"Decor Cancel does not reopen curtains")
	game.open_style(game.State.DECOR)
	game.feature.decor.curtains="mint"
	game.confirm_feature()
	check(curtains.closed and game.save.decor.curtains=="mint","Decor Apply preserves curtain position state")
	for i in range(21): curtains.toggle()
	await create_timer(0.75).timeout
	check(not curtains.closed and is_zero_approx(curtains.amount) and is_equal_approx(curtains.fill.light_energy,curtains.baseline_fill) and curtains.ties[0].visible,"rapid curtain reversals reopen to exact baseline light and ties")
	curtains.set_state(true,false)
	lamp.set_state(false,false)
	game.room_state_changed()
	await pose(Vector3(-3,0,-2.6))
	var plant=game.room.plant_control
	check(game.interaction_target==plant,"chosen existing plant is reachable")
	var nodes_before: int=plant.get_child_count()
	await key(KEY_E,true)
	await key(KEY_E,false)
	check(plant.busy and plant.effect.visible and not game.save.room_state[plant.interaction_id],"watering shows drops; first-watering flag waits for completion")
	check(not game.activate_interaction() and plant.drops.size()==9,"watering anti-spam cannot stack effects")
	await create_timer(1.35).timeout
	check(plant.has_watered and not plant.busy and not plant.effect.visible and plant.get_child_count()==nodes_before,"water response completes and reuses hidden effect pool")
	check(not game.save.cozy_corner_completed and not game.room.keepsake.visible,"watering with lamp off cannot complete goal")
	await pose(Vector3(2.55,0,-2.1))
	await key(KEY_E,true)
	await key(KEY_E,false)
	await create_timer(0.4).timeout
	check(game.save.cozy_corner_completed and game.room.keepsake.visible,"correct settled combination earns keepsake through E")
	var keepsake_nodes: int=game.room.keepsake.get_child_count()
	lamp.set_state(false,false)
	curtains.set_state(false,false)
	game.room_state_changed()
	await pose(Vector3(-3,0,-2.6))
	game.activate_interaction()
	await create_timer(1.35).timeout
	check(game.save.cozy_corner_completed and game.room.keepsake.visible and game.room.keepsake.get_child_count()==keepsake_nodes and plant.get_child_count()==nodes_before,"later changes and repeat watering neither revoke nor duplicate reward/effects")
	var data=S.new()
	data.path=game.save_path
	data.load_local()
	check(data.cozy_corner_completed and data.room_state[plant.interaction_id] and not data.room_state[lamp.interaction_id] and not data.room_state[curtains.interaction_id],"settled room state and permanent goal survive reload")
	var other=load("res://scenes/main.tscn").instantiate()
	other.save_path=game.save_path
	root.add_child(other)
	check(other.room.keepsake.visible and not other.room.lamp_control.on and other.room.lamp_control.is_settled() and other.room.curtain_control.is_settled() and not other.room.plant_control.effect.visible,"new instance restores a settled room without replaying water effects")
	var bytes:=FileAccess.get_file_as_bytes(game.save_path)
	game.save.write_blocked=ERR_CANT_CREATE
	lamp.toggle()
	check(FileAccess.get_file_as_bytes(game.save_path)==bytes and game.ui.notice.text.begins_with("Save unavailable"),"failed interaction save reports error and preserves last good file")
	game.audio.stop_all()
	other.audio.stop_all()
	await frames(3)
	print("PHASE 1D ROOM: ",checks-failures,"/",checks)
	quit(0 if failures==0 else 1)
