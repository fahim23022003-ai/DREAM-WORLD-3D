extends CanvasLayer
signal start_requested
signal resume_requested
signal main_requested
signal sound_requested(kind: String)
signal audio_changed(volume: float, muted: bool)
signal guidance_changed(dismissed: bool)
signal cozy_guidance_changed(dismissed: bool)
signal personalize_requested
signal decor_requested
signal quit_requested
signal settings_changed(sensitivity: float, fullscreen: bool, shadows: bool)
var root: Control
var panel: PanelContainer
var hud: Control
var prompt: Label
var notice: Label
var mode := "main"
var saved := false
var sensitivity := 1.0
var fullscreen := false
var shadows := true
var ui_volume := 0.55
var muted := false
var home_label: Label
var guide: PanelContainer
var notice_timer: Timer
var guidance_kind := "intro"
var guidance_mode := "auto"
var cozy_context: Dictionary = {}
var cozy_completed := false
var cozy_dismissed := false

func style(color: String, radius: int = 18) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(color)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 22
	s.content_margin_right = 22
	s.content_margin_top = 13
	s.content_margin_bottom = 13
	s.border_color = Color("ffffff80")
	s.set_border_width_all(1)
	s.shadow_color = Color("674c6220")
	s.shadow_size = 5
	s.shadow_offset = Vector2(0,3)
	return s

func label(text: String, size: int, color: String = "554c48") -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size",size)
	l.add_theme_color_override("font_color",Color(color))
	return l

func button(text: String, callback: Callable, primary: bool = false, action_icon: String = "") -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(274,48)
	var icon_id := action_icon
	if icon_id.is_empty():
		if text.begins_with("Apply"): icon_id="check"
		elif text in ["Cancel","Exit","Quit","Save & quit","Done"]: icon_id="close"
		elif text in ["Restart","Retry save"]: icon_id="restart"
		elif text in ["Play again","Resume  →","Come on in  →","Continue home  →"]: icon_id="play"
		elif text=="Save & main menu": icon_id="home"
		elif text=="Settings": icon_id="gear"
		else: icon_id="leaf"
	b.icon = load("res://assets/ui/"+icon_id+".svg")
	for icon_state in ["icon_normal_color","icon_hover_color","icon_pressed_color","icon_focus_color"]:
		b.add_theme_color_override(icon_state,Color.WHITE if primary else Color("796179"))
	b.add_theme_constant_override("h_separation",12)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size",16)
	b.add_theme_color_override("font_color",Color("fff5e7" if primary else "64504e"))
	b.add_theme_color_override("font_hover_color",Color("fff5e7" if primary else "64504e"))
	b.add_theme_color_override("font_focus_color",Color("fff5e7" if primary else "64504e"))
	b.add_theme_stylebox_override("normal",style("a77f99" if primary else "eee8f0",14))
	b.add_theme_stylebox_override("hover",style("b58aa8" if primary else "e0e9e4",14))
	b.add_theme_stylebox_override("pressed",style("926881" if primary else "d7e1dc",14))
	var focus := style("00000000",14)
	focus.border_color = Color("d2a56c")
	focus.set_border_width_all(2)
	b.add_theme_stylebox_override("focus",focus)
	b.pressed.connect(func(): sound_requested.emit("click"); callback.call())
	return b

func style_toggle(toggle: CheckButton) -> void:
	for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_hover_pressed_color"]:
		toggle.add_theme_color_override(state,Color("66566d"))
	toggle.add_theme_icon_override("checked",load("res://assets/ui/toggle_on.svg"))
	toggle.add_theme_icon_override("unchecked",load("res://assets/ui/toggle_off.svg"))
	toggle.add_theme_stylebox_override("normal",style("f5eef4",10))
	toggle.add_theme_stylebox_override("hover",style("e6eee8",10))

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font_size = 16
	theme.set_color("font_color","CheckButton",Color("66566d"))
	theme.set_color("font_hover_color","CheckButton",Color("876279"))
	root.theme = theme
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)
	var badge := PanelContainer.new()
	badge.position = Vector2(26,22)
	badge.add_theme_stylebox_override("panel",style("fff8f0ed",18))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(badge)
	home_label = label("✦   ROSEWATER HOUSE",13,"756578")
	badge.add_child(home_label)
	var legend := PanelContainer.new()
	legend.position = Vector2(216,660)
	legend.add_theme_stylebox_override("panel",style("fff8f0ed",18))
	legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(legend)
	var controls := label("WASD Move · SHIFT Run · MOUSE Look · SCROLL Zoom · C Personalize · B Decor · H Cozy hint · ESC Pause",13,"756578")
	controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	legend.add_child(controls)
	prompt = label("",17,"fff8ef")
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.position = Vector2(474,594)
	prompt.size = Vector2(332,46)
	prompt.add_theme_stylebox_override("normal",style("987b98ed",20))
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(prompt)
	notice = label("",13,"66586e")
	notice.position = Vector2(970,26)
	hud.add_child(notice)
	notice_timer = Timer.new()
	notice_timer.one_shot = true
	notice_timer.timeout.connect(func(): notice.text="")
	add_child(notice_timer)
	show_page("main")

func show_page(page: String) -> void:
	mode = page
	hud.visible = page == "game"
	if is_instance_valid(panel):
		root.remove_child(panel)
		panel.queue_free()
		panel = null
	if page == "game": return
	panel = PanelContainer.new()
	panel.position = Vector2(48,98) if page == "main" else Vector2(438,130)
	panel.custom_minimum_size = Vector2(334 if page == "main" else 404,0)
	panel.add_theme_stylebox_override("panel",style("fff8f0f5",24))
	root.add_child(panel)
	panel.modulate.a = 0
	create_tween().tween_property(panel,"modulate:a",1.0,0.16)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",10)
	panel.add_child(col)
	if page == "main":
		col.add_child(label("A LITTLE PLACE TO BELONG",12,"a27275"))
		col.add_child(label("Dream World",32,"796179"))
		col.add_child(label("3 D   /   R O S E W A T E R",15,"a78069"))
		var space := Control.new()
		space.custom_minimum_size.y = 12
		col.add_child(space)
		col.add_child(label("Slow mornings. Soft light.\nA little world to call your own.",15,"867383"))
		col.add_child(HSeparator.new())
		col.add_child(button("Continue home  →" if saved else "Come on in  →",func(): start_requested.emit(),true))
		col.add_child(button("Settings",func(): show_page("settings_main")))
		col.add_child(button("Quit",func(): quit_requested.emit()))
		col.add_child(label("THE LIVING ROOM     /     01",11,"9a8694"))
	elif page == "pause":
		col.add_child(label("Take a little breath",27,"73505a"))
		col.add_child(label("Your corner of the world can wait.",15,"8b7569"))
		col.add_child(button("Resume  →",func(): resume_requested.emit(),true))
		col.add_child(button("Personalize  ·  C",func(): personalize_requested.emit()))
		col.add_child(button("Decorate  ·  B",func(): decor_requested.emit()))
		col.add_child(button("Settings",func(): show_page("settings_pause")))
		col.add_child(button("Save & main menu",func(): main_requested.emit()))
		col.add_child(button("Save & quit",func(): quit_requested.emit()))
	else:
		col.add_child(label("Make yourself at home",26,"73505a"))
		col.add_child(label("Mouse sensitivity",17))
		var slider := HSlider.new()
		slider.min_value = 0.4
		slider.max_value = 2.0
		slider.step = 0.1
		slider.value = sensitivity
		slider.custom_minimum_size.y = 32
		slider.value_changed.connect(func(value): sensitivity=value; emit_settings())
		col.add_child(slider)
		var full := CheckButton.new()
		style_toggle(full)
		full.text = "Fullscreen"
		full.button_pressed = fullscreen
		full.toggled.connect(func(value): fullscreen=value; emit_settings())
		col.add_child(full)
		var shadow := CheckButton.new()
		style_toggle(shadow)
		shadow.text = "Sunlight shadows"
		shadow.button_pressed = shadows
		shadow.toggled.connect(func(value): shadows=value; emit_settings())
		col.add_child(shadow)
		col.add_child(label("UI sound volume",15))
		var volume := HSlider.new()
		volume.name = "UiVolume"
		volume.min_value = 0
		volume.max_value = 1
		volume.step = 0.05
		volume.value = ui_volume
		volume.custom_minimum_size.y = 24
		volume.value_changed.connect(func(value): ui_volume=value; audio_changed.emit(ui_volume,muted))
		col.add_child(volume)
		var mute := CheckButton.new()
		mute.text = "Mute UI sounds"
		style_toggle(mute)
		mute.button_pressed = muted
		mute.toggled.connect(func(value): muted=value; audio_changed.emit(ui_volume,muted))
		col.add_child(mute)
		col.add_child(label("Settings save automatically on this PC.",13,"8b7569"))
		col.add_child(button("Done",func(): show_page("pause" if page == "settings_pause" else "main"),true))
	var first := col.find_children("*","Button",true,false)
	if not first.is_empty(): first[0].grab_focus()

func emit_settings() -> void:
	settings_changed.emit(sensitivity,fullscreen,shadows)

func set_prompt(text: String) -> void:
	prompt.text = text
	prompt.visible = not text.is_empty()

func show_notice(text: String) -> void:
	notice.text = text
	notice_timer.start(3.5)

func update_guidance(data: Dictionary, room_data: Dictionary = {}, completed: bool = false, dismissed: bool = false) -> void:
	if not room_data.is_empty():
		cozy_context=room_data.duplicate()
		cozy_completed=completed
		cozy_dismissed=dismissed
	if is_instance_valid(guide):
		hud.remove_child(guide)
		guide.queue_free()
	guide=PanelContainer.new()
	guide.position=Vector2(830,78)
	guide.add_theme_stylebox_override("panel",style("fff8f0ed",16))
	hud.add_child(guide)
	var col:=VBoxContainer.new()
	guide.add_child(col)
	var intro: bool=not data.dismissed and not data.reward_applied
	if not cozy_context.is_empty() and (guidance_mode=="cozy" or not intro):
		if cozy_completed:
			guidance_kind="cozy_complete"
			guide.hide()
			return
		if cozy_dismissed:
			guidance_kind="cozy_collapsed"
			guide.position.x=1050
			var expand:=button("Cozy corner · H",func(): guidance_mode="cozy"; cozy_guidance_changed.emit(false))
			expand.custom_minimum_size=Vector2(150,30)
			col.add_child(expand)
			return
		guidance_kind="cozy"
		col.add_child(label("Make a cozy corner  ·  H to hide",15,"796179"))
		for entry in [["living_room.floor_lamp","Lamp on"],["living_room.curtains","Curtains closed"],["living_room.houseplant","Plant watered once"]]:
			col.add_child(label(("✓  " if cozy_context.get(entry[0],false) else "○  ")+entry[1],13,"756578"))
		var actions:=HBoxContainer.new()
		var hide:=button("Hide tips",func(): cozy_guidance_changed.emit(true))
		hide.custom_minimum_size=Vector2(110,30)
		actions.add_child(hide)
		if intro:
			var back:=button("Home tips",func(): guidance_mode="auto"; update_guidance(data))
			back.custom_minimum_size=Vector2(115,30)
			actions.add_child(back)
		col.add_child(actions)
		return
	if not intro:
		guidance_kind="collapsed"
		var b:=button("Tips",func(): guidance_changed.emit(false))
		b.custom_minimum_size=Vector2(80,30)
		col.add_child(b)
		guide.position.x=1120
		if data.reward_applied: guide.hide()
		return
	guidance_kind="intro"
	var text:="C  ·  Make your avatar your own"
	if data.personalized: text="B  ·  Preview a palette for your room"
	if data.personalized and data.decorated: text="E  ·  Try the card box on the coffee table"
	if data.played: text="B  ·  Your Lavender Dream theme is unlocked"
	col.add_child(label(text,14,"796179"))
	var actions:=HBoxContainer.new()
	var hide:=button("Hide tips",func(): guidance_changed.emit(true))
	hide.custom_minimum_size=Vector2(110,30)
	actions.add_child(hide)
	if not cozy_context.is_empty() and not cozy_completed:
		var cozy:=button("Cozy corner",func(): guidance_mode="cozy"; cozy_guidance_changed.emit(false))
		cozy.custom_minimum_size=Vector2(145,30)
		actions.add_child(cozy)
	col.add_child(actions)
