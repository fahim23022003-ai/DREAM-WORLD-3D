extends Node
## Four short locally synthesized PCM cues; no soundtrack or external assets.
var volume := 0.55
var muted := false
var players: Dictionary = {}
func _ready() -> void:
	for kind in ["click","flip","match","reward","switch","water"]:
		var player := AudioStreamPlayer.new()
		player.stream = load("res://assets/audio/"+kind+".wav")
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
	if muted or volume<=0 or not players.has(kind): return
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
