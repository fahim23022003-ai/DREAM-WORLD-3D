extends Control
signal appearance_preview(data: Dictionary)
signal decor_preview(data: Dictionary)
signal apply_requested
signal home_catalog_requested
signal cancel_requested
const Styles = preload("res://scripts/style_data.gd")
var ui: CanvasLayer
var kind := "personalize"
var appearance: Dictionary
var decor: Dictionary
var unlocks: Array[String] = []
var picker: ColorPickerButton
var swatches: HBoxContainer
var channel := "hair"
var panel: PanelContainer
var theme_choice: OptionButton
var selected_labels: Dictionary = {}
var status: Label
var decor_buttons: Dictionary = {}
var whole_preview: Button

func open(which: String, looks: Dictionary, room: Dictionary, unlocked: Array[String]) -> void:
	kind = which
	appearance = looks.duplicate(true)
	decor = room.duplicate(true)
	unlocks = unlocked.duplicate()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel = PanelContainer.new()
	panel.position = Vector2(30,60 if kind=="decor" else 76)
	panel.custom_minimum_size = Vector2(400,0)
	panel.add_theme_stylebox_override("panel",ui.style("fff8f0fa",24))
	add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation",6)
	panel.add_child(col)
	col.add_child(ui.label("MAKE IT MINE" if kind=="personalize" else "A ROOM OF YOUR OWN",12,"a27287"))
	col.add_child(ui.label("Hello, "+preload("res://scripts/save_data.gd").clean_name(appearance.display_name) if kind=="personalize" else "Coordinated corners",26,"796179"))
	if kind=="personalize": build_personal(col)
	else: build_decor(col)
	var actions := HBoxContainer.new()
	var apply_button: Button = ui.button("Apply",func(): apply_requested.emit(),true,"check")
	var cancel_button: Button = ui.button("Cancel",func(): cancel_requested.emit(),false,"close")
	for b in [apply_button,cancel_button]:
		b.custom_minimum_size.x = 163
		actions.add_child(b)
	col.add_child(actions)
	status = ui.label("",12,"9c6277")
	col.add_child(status)
	col.add_child(ui.label("Preview only until you choose Apply. Esc cancels.",12,"8b7588"))

func build_personal(col: VBoxContainer) -> void:
	col.add_child(ui.label("Display name (optional)",15))
	var name_edit := LineEdit.new()
	name_edit.name = "DisplayName"
	name_edit.text = appearance.display_name
	name_edit.max_length = 24
	name_edit.custom_minimum_size.y = 38
	name_edit.add_theme_color_override("font_color",Color("66566d"))
	name_edit.add_theme_stylebox_override("normal",ui.style("eee8f0",10))
	name_edit.text_changed.connect(func(text): appearance.display_name=text; appearance_preview.emit(appearance.duplicate(true)))
	col.add_child(name_edit)
	var choice := OptionButton.new()
	choice.name = "AppearanceChannel"
	choice.add_item("Hair color")
	choice.add_item("Outfit accent")
	choice.add_theme_color_override("font_color",Color("66566d"))
	choice.add_theme_color_override("font_focus_color",Color("66566d"))
	choice.add_theme_stylebox_override("normal",ui.style("eee8f0",10))
	choice.custom_minimum_size.y = 38
	choice.item_selected.connect(func(index): channel="hair" if index==0 else "accent"; refresh_swatches())
	col.add_child(choice)
	swatches = HBoxContainer.new()
	col.add_child(swatches)
	col.add_child(ui.label("Or choose your own color",15))
	picker = ColorPickerButton.new()
	picker.name = "CustomColor"
	picker.custom_minimum_size = Vector2(200,38)
	picker.edit_alpha = false
	picker.get_picker().picker_shape = ColorPicker.SHAPE_HSV_WHEEL
	picker.color_changed.connect(set_color)
	col.add_child(picker)
	refresh_swatches()

func refresh_swatches() -> void:
	for node in swatches.get_children():
		swatches.remove_child(node)
		node.queue_free()
	for i in range(6):
		var color: Color = Styles.SWATCHES[channel][i]
		var b := Button.new()
		b.name = channel+"_swatch_"+str(i)
		b.tooltip_text = ("Hair" if channel=="hair" else "Outfit")+" palette "+str(i+1)
		b.custom_minimum_size = Vector2(49,35)
		b.add_theme_stylebox_override("normal",ui.style(color.to_html(),12))
		var focus = ui.style(color.lightened(0.1).to_html(),12)
		focus.border_color = Color("8d667f")
		focus.set_border_width_all(3)
		b.add_theme_stylebox_override("hover",focus)
		b.add_theme_stylebox_override("focus",focus)
		b.pressed.connect(func(): set_color(color))
		swatches.add_child(b)
	picker.set_block_signals(true)
	picker.color = appearance[channel]
	picker.set_block_signals(false)

func set_color(color: Color) -> void:
	appearance[channel] = Color(color.r,color.g,color.b,1)
	picker.set_block_signals(true)
	picker.color = appearance[channel]
	picker.set_block_signals(false)
	appearance_preview.emit(appearance.duplicate(true))

func build_decor(col: VBoxContainer) -> void:
	for surface in ["rug","cushions","curtains"]:
		var heading: Label = ui.label(surface.capitalize(),16)
		col.add_child(heading)
		var row := HBoxContainer.new()
		col.add_child(row)
		for id in Styles.PRESETS:
			var b := Button.new()
			b.name = surface+"_"+id
			b.custom_minimum_size = Vector2(107,40)
			b.text = "Rosewater" if id=="rosewater" else ("Mint" if id=="mint" else "Lavender")
			b.add_theme_font_size_override("font_size",13)
			b.add_theme_color_override("font_color",Color("584b61"))
			b.add_theme_color_override("font_hover_color",Color("584b61"))
			b.add_theme_color_override("font_focus_color",Color("584b61"))
			b.add_theme_color_override("font_disabled_color",Color("867b8c"))
			b.add_theme_stylebox_override("disabled",ui.style("e8e1eb",12))
			b.add_theme_stylebox_override("normal",ui.style(Styles.PRESETS[id].cushions.to_html(),12))
			b.add_theme_stylebox_override("hover",ui.style("f0e6f3",12))
			b.disabled = id=="lavender_dream" and not id in unlocks
			b.tooltip_text = "Win Cozy Pairs to unlock" if b.disabled else Styles.PRESETS[id].name
			b.pressed.connect(func(): decor[surface]=id; update_labels(); decor_preview.emit(decor.duplicate(true)))
			decor_buttons[surface+"_"+id] = b
			row.add_child(b)
		selected_labels[surface] = heading
	col.add_child(ui.label("Whole-room preview",15))
	theme_choice = OptionButton.new()
	theme_choice.name = "WholeTheme"
	for id in Styles.PRESETS:
		theme_choice.add_item(Styles.PRESETS[id].name)
		theme_choice.set_item_metadata(theme_choice.item_count-1,id)
		theme_choice.set_item_disabled(theme_choice.item_count-1,id=="lavender_dream" and not id in unlocks)
	theme_choice.add_item("Mixed")
	theme_choice.set_item_metadata(3,"mixed")
	theme_choice.set_item_disabled(3,true)
	theme_choice.item_selected.connect(func(_index): preview_whole_theme())
	theme_choice.add_theme_color_override("font_color",Color("66566d"))
	theme_choice.add_theme_color_override("font_focus_color",Color("66566d"))
	theme_choice.add_theme_stylebox_override("normal",ui.style("eee8f0",10))
	theme_choice.custom_minimum_size.y = 35
	col.add_child(theme_choice)
	whole_preview = ui.button("Preview whole theme",preview_whole_theme)
	col.add_child(whole_preview)
	if not "lavender_dream" in unlocks: col.add_child(ui.label("Lavender Dream is locked. Win Cozy Pairs to unlock.",12,"8b7588"))
	var catalog: Button=ui.button("Kitchen & bedroom catalog",func(): home_catalog_requested.emit(),false,"home")
	catalog.custom_minimum_size.y=32
	col.add_child(catalog)
	update_labels()

func update_labels() -> void:
	for surface in selected_labels: selected_labels[surface].text = surface.capitalize()+"  ·  "+Styles.PRESETS[decor[surface]].name
	for surface in decor:
		for id in Styles.PRESETS:
			var b: Button = decor_buttons[surface+"_"+id]
			var selected: bool = decor[surface]==id
			b.set_meta("selected",selected)
			b.text = ("Rosewater" if id=="rosewater" else ("Mint" if id=="mint" else "Lavender"))+(" ✓" if selected else "")
			var normal = ui.style(Styles.PRESETS[id].cushions.to_html(),12)
			normal.content_margin_left=8
			normal.content_margin_right=8
			if selected:
				normal.border_color=Color("896181")
				normal.set_border_width_all(3)
			b.add_theme_stylebox_override("normal",normal)
			b.add_theme_stylebox_override("hover",normal)
			var focus = ui.style("00000000",12)
			focus.border_color=Color("c1934e")
			focus.set_border_width_all(2)
			focus.set_expand_margin_all(3)
			b.add_theme_stylebox_override("focus",focus)
			if b.disabled:
				b.icon=load("res://assets/ui/lock.svg")
				b.add_theme_constant_override("icon_max_width",13)
				b.add_theme_color_override("icon_disabled_color",Color("867b8c"))
	var id: String = decor.rug
	var mixed: bool = decor.cushions!=id or decor.curtains!=id
	theme_choice.select(3 if mixed else Styles.PRESETS.keys().find(id))
	whole_preview.disabled = mixed

func preview_whole_theme() -> void:
	var id: String = theme_choice.get_item_metadata(theme_choice.selected)
	if id=="mixed" or (id=="lavender_dream" and not id in unlocks): return
	for surface in decor: decor[surface]=id
	update_labels()
	decor_preview.emit(decor.duplicate(true))

func dismiss_popup() -> bool:
	if is_instance_valid(picker) and picker.get_popup().visible:
		picker.get_popup().hide()
		return true
	return false
