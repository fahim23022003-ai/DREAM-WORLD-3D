extends Control
signal completed(result: Dictionary)
signal exit_requested
signal apply_theme_requested
signal keep_style_requested
signal retry_save_requested
signal sound_requested(kind: String)
const Rules = preload("res://scripts/pairs_rules.gd")
const ICONS := ["teacup","flower","ribbon","cloud","cake","star"]
var rules = Rules.new()
var ui: CanvasLayer
var panel: PanelContainer
var col: VBoxContainer
var counter: Label
var timer: Timer
var scheduled_round := 0
var cards: Array[Button] = []
var completion_handled := false
var result_status: Label
var retry_button: Button
var result_apply: Button
var result_saved := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.24,0.19,0.28,0.28)
	add_child(dim)
	panel = PanelContainer.new()
	panel.position = Vector2(278,34)
	panel.custom_minimum_size = Vector2(724,0)
	panel.add_theme_stylebox_override("panel",ui.style("fff8f0fc",24))
	add_child(panel)
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(resolve_pair)
	rules.completed.connect(func(result): completed.emit(result))
	restart()

func new_column() -> void:
	if is_instance_valid(col):
		panel.remove_child(col)
		col.queue_free()
	col = VBoxContainer.new()
	col.add_theme_constant_override("separation",10)
	panel.add_child(col)

func restart() -> void:
	timer.stop()
	rules.abort()
	rules.start()
	completion_handled = false
	cards.clear()
	new_column()
	col.add_child(ui.label("THE LITTLE CARD BOX",12,"9f7e94"))
	col.add_child(ui.label("Cozy Pairs",30,"796179"))
	col.add_child(ui.label("Turn over two cards. Find the six matching pairs. Take your time.",15))
	counter = ui.label("",16,"796179")
	col.add_child(counter)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation",12)
	grid.add_theme_constant_override("v_separation",10)
	col.add_child(grid)
	for i in range(12):
		var b := Button.new()
		b.name = "Card_"+str(i)
		b.custom_minimum_size = Vector2(160,107)
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width",69)
		b.add_theme_color_override("font_color",Color("5c736a"))
		b.add_theme_color_override("font_disabled_color",Color("5c736a"))
		b.tooltip_text = "Face-down card"
		b.pressed.connect(func(): choose(i))
		grid.add_child(b)
		cards.append(b)
	var actions := HBoxContainer.new()
	actions.add_child(ui.button("Restart",restart,false,"restart"))
	actions.add_child(ui.button("Exit",func(): abort(); exit_requested.emit(),false,"close"))
	col.add_child(actions)
	refresh()

func choose(index: int) -> void:
	var result: String = rules.select(index)
	if result=="ignored": return
	sound_requested.emit("flip")
	var b := cards[index]
	var tween := b.create_tween()
	tween.tween_property(b,"modulate:a",0.35,0.055)
	tween.tween_callback(refresh)
	tween.tween_property(b,"modulate:a",1.0,0.09)
	if result in ["match","mismatch"]:
		scheduled_round = rules.generation
		timer.start(0.35 if result=="match" else 0.8)
		if result=="match": sound_requested.emit("match")
	counter.text = "Moves  %d     ·     Pairs found  %d / 6" % [rules.moves,rules.pairs]

func resolve_pair() -> void:
	if scheduled_round!=rules.generation: return
	rules.settle()
	if not rules.finished: refresh()

func refresh() -> void:
	if not is_instance_valid(counter): return
	counter.text = "Moves  %d     ·     Pairs found  %d / 6" % [rules.moves,rules.pairs]
	for i in range(cards.size()):
		var b := cards[i]
		if not is_instance_valid(b): continue
		var face_up: bool = rules.matched[i] or i in rules.revealed
		b.icon = load("res://assets/pairs/"+(ICONS[rules.deck[i]] if face_up else "back")+".svg")
		b.text = "Found" if rules.matched[i] else ""
		b.tooltip_text = ICONS[rules.deck[i]].capitalize() if face_up else "Face-down card"
		b.disabled = rules.matched[i]
		for state in ["normal","disabled","hover","focus","pressed"]:
			var style = ui.style("d7e8dd" if rules.matched[i] else ("fff4e6" if face_up else "e3d5e8"),16)
			if state in ["hover","focus"]:
				style.border_color = Color("af8aa4")
				style.set_border_width_all(3)
			b.add_theme_stylebox_override(state,style)

func show_result(moves: int, best: int, first: bool, saved: bool) -> void:
	timer.stop()
	cards.clear()
	new_column()
	col.add_child(ui.label("A LITTLE SOMETHING FOR YOUR HOME",12,"9f7e94"))
	col.add_child(ui.label("Lavender Dream unlocked!" if first else "A lovely little round",28,"796179"))
	col.add_child(ui.label("%d moves  ·  Personal best: %d" % [moves,best],20))
	col.add_child(ui.label("Your first win unlocks this theme forever. Replays improve your own record.",14))
	var preview := TextureRect.new()
	preview.texture = load("res://assets/textures/rug.svg")
	preview.modulate = Color("c3abea")
	preview.custom_minimum_size = Vector2(550,180)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	col.add_child(preview)
	col.add_child(ui.label("LAVENDER DREAM    ·    Rug + sofa cushions + curtains",16,"8b719b"))
	result_status = ui.label("",14,"8b7588")
	col.add_child(result_status)
	result_apply = ui.button("Apply to My Room",func(): apply_theme_requested.emit(),true,"check")
	col.add_child(result_apply)
	col.add_child(ui.button("Keep My Current Style",func(): keep_style_requested.emit(),false,"close"))
	var row := HBoxContainer.new()
	row.add_child(ui.button("Play again",restart,false,"play"))
	retry_button = ui.button("Retry save",func(): retry_save_requested.emit(),false,"restart")
	row.add_child(retry_button)
	col.add_child(row)
	set_save_status(saved)
	result_apply.grab_focus()

func abort() -> void:
	timer.stop()
	rules.abort()

func _exit_tree() -> void:
	if is_instance_valid(timer): timer.stop()
	rules.abort()

func set_save_status(saved: bool, failure_text: String = "Not saved yet. Previous file is safe; please retry.") -> void:
	result_saved = saved
	result_status.text = "Unlocked and saved." if saved else failure_text
	var had_focus := retry_button.has_focus()
	retry_button.visible = not saved
	if saved and had_focus: result_apply.grab_focus()
