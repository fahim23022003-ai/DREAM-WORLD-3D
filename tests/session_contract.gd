extends "res://tests/phase_one.gd"
const S = preload("res://scripts/save_data.gd")
const I = preload("res://scripts/interaction.gd")
func finish_round(extra: int = 0) -> void:
	var rules = game.feature.rules
	for attempt in range(extra):
		var other := 1
		while rules.deck[other]==rules.deck[0]: other += 1
		rules.select(0)
		rules.select(other)
		rules.settle()
	for id in range(6):
		var pair: Array[int] = []
		for index in range(12):
			if rules.deck[index]==id: pair.append(index)
		rules.select(pair[0])
		rules.select(pair[1])
		rules.settle()
func run() -> void:
	root.size = Vector2i(1280,720)
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://session_contract_"+str(Time.get_ticks_usec())+".cfg"
	root.add_child(game)
	game.start_game()
	game.player.position = Vector3(0,0,0.55)
	game.camera_rig.yaw = 0
	await frames(5)
	check(game.interaction_target!=null and game.interaction_target.interaction_id=="cozy_pairs_box" and game.ui.prompt.text==game.interaction_target.prompt,"one card-box target agrees with HUD")
	game.camera_rig.yaw = PI
	check(I.resolve(game.player,game.camera_rig)==null,"target behind camera is not usable")
	game.camera_rig.yaw = 0
	var blocker = load("res://scripts/forms.gd").solid(game.room,Vector3(0,1.1,0.1),Vector3(1,2,0.08))
	await frames(4)
	check(I.resolve(game.player,game.camera_rig)==null,"occluded card box is not usable")
	blocker.queue_free()
	await frames(3)
	game.player.position = Vector3(0,0,-1.8)
	await frames(4)
	check(game.interaction_target!=null and game.interaction_target.interaction_id=="sofa","sofa is selected instead of box when facing it")
	await key(KEY_E,true)
	await key(KEY_E,false)
	check(game.player.seated and game.state==game.State.PLAY,"one E action seats without opening puzzle")
	await key(KEY_C,true)
	await key(KEY_C,false)
	await key(KEY_E,true)
	await key(KEY_E,false)
	check(game.player.seated and game.state==game.State.PERSONALIZE,"opening seated panel preserves seat and blocks E")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	await key(KEY_E,true)
	await key(KEY_E,false)
	check(not game.player.seated and game.active,"Esc restores play; E still stands")
	game.open_puzzle()
	var r = game.feature.rules
	var other := 1
	while r.deck[other]==r.deck[0]: other += 1
	game.feature.choose(0)
	game.feature.choose(other)
	game.cancel_feature()
	await create_timer(0.9).timeout
	check(game.save.unlocks.is_empty() and game.active,"Exit cancels real mismatch timer without award or input lock")
	game.open_puzzle()
	finish_round(2)
	check(game.feature.completion_handled and game.save.unlocks==["lavender_dream"] and game.save.best_moves==8,"first legitimate win unlocks once and records moves")
	game.puzzle_completed({"puzzle_id":"cozy_pairs","moves":8})
	check(game.save.unlocks.size()==1,"repeated completion cannot duplicate reward")
	game.cancel_feature()
	check(game.save.decor.rug=="rosewater" and "lavender_dream" in game.save.unlocks,"deferring preserves current decor and permanent unlock")
	game.open_puzzle()
	finish_round()
	check(game.save.best_moves==6 and game.save.unlocks.size()==1,"later better win updates personal best without another unlock")
	game.cancel_feature()
	game.open_puzzle()
	finish_round(1)
	check(game.save.best_moves==6,"worse replay does not replace best")
	game.apply_reward()
	check(game.active and game.save.decor.values()==["lavender_dream","lavender_dream","lavender_dream"],"Apply reward returns to play and changes all surfaces")
	var saved = S.new()
	saved.path=game.save_path
	saved.load_local()
	check(saved.best_moves==6 and saved.unlocks.size()==1 and saved.decor.rug=="lavender_dream" and saved.onboarding.reward_applied,"progression, theme and onboarding survive reload")
	var audio_ok: bool = game.audio.players.size()==4
	for player in game.audio.players.values(): audio_ok=audio_ok and player.stream is AudioStreamWAV and player.stream.get_length()>0
	check(audio_ok,"all four original PCM cues decode")
	game.save.ui_volume=0.2
	game.save.muted=true
	game.persist()
	saved.load_local()
	check(is_equal_approx(saved.ui_volume,0.2) and saved.muted,"UI volume/mute persist")
	game.audio.stop_all()
	await frames(3)
	print("SESSION CONTRACT: ",checks-failures,"/",checks)
	quit(0 if failures==0 else 1)
