extends Node
## Quiet original PCM cues; missing optional resources never interrupt gameplay.
var volume := 0.55
var muted := false
var players: Dictionary = {}
func _ready() -> void:
	for kind in ["click","flip","match","reward","switch","water","fridge","prepare","cook","complete","purchase","bedroom","sleep","goal","plant","garden_water","harvest","arrival","conversation","friendship","event","garden"]:
		var player := AudioStreamPlayer.new()
		var file: String = "res://assets/audio/"+kind+".wav"
		if ResourceLoader.exists(file): player.stream = load(file)
		add_child(player)
		players[kind] = player
func configure(value: float, silent: bool) -> void:
	volume = clampf(value,0,1)
	muted = silent
	for player in players.values():
		player.volume_db = linear_to_db(maxf(volume*0.35,0.001))
		if muted or volume==0: player.stop()
func play(kind: String) -> void:
	# Headless rule/save tests have no audio device or audible output to validate.
	if DisplayServer.get_name()=="headless": return
	if muted or volume<=0 or not players.has(kind) or not players[kind].stream: return
	var player: AudioStreamPlayer = players[kind]
	player.volume_db = linear_to_db(maxf(volume*0.35,0.001))
	player.play()

func stop_all() -> void:
	for player in players.values():
		player.stop()
		player.stream = null
	players.clear()

func _exit_tree() -> void:
	stop_all()
