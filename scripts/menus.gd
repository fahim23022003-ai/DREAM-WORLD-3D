extends CanvasLayer
signal start_requested
signal resume_requested
signal main_requested
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

func button(text: String, callback: Callable, primary: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(274,48)
	b.icon = load("res://assets/ui/home.svg" if primary else ("res://assets/ui/settings.svg" if text=="Settings" else "res://assets/ui/leaf.svg"))
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
	b.pressed.connect(callback)
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
	badge.add_child(label("✦   ROSEWATER HOUSE",13,"756578"))
	var legend := PanelContainer.new()
	legend.position = Vector2(258,660)
	legend.add_theme_stylebox_override("panel",style("fff8f0ed",18))
	legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(legend)
	var controls := label("WASD  Move    ·    SHIFT  Run    ·    MOUSE  Look    ·    SCROLL  Zoom    ·    ESC  Pause",13,"756578")
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
	show_page("main")

func show_page(page: String) -> void:
	mode = page
	hud.visible = page == "game"
	if is_instance_valid(panel):
		root.remove_child(panel)
		panel.queue_free()
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
		col.add_child(label("Settings save automatically on this PC.",13,"8b7569"))
		col.add_child(button("Done",func(): show_page("pause" if page == "settings_pause" else "main"),true))
	var first := col.find_children("*","Button",true,false)
	if not first.is_empty(): first[0].grab_focus()

func emit_settings() -> void:
	settings_changed.emit(sensitivity,fullscreen,shadows)

func set_prompt(text: String) -> void:
	prompt.text = text
	prompt.visible = not text.is_empty()
