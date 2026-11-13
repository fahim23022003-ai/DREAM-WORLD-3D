extends Control
## Small reusable modal shell. HomeController owns transitions, HomeRules owns rewards.
signal exit_requested
var ui: CanvasLayer
var panel: PanelContainer
var col: VBoxContainer
var status: Label
var bar: Control
var cooking_rules: RefCounted
var action_button: Button
var target_mark: ColorRect
var cursor_mark: ColorRect
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter=Control.MOUSE_FILTER_IGNORE
func build(title: String,wide: bool=false) -> void:
 if is_instance_valid(panel): remove_child(panel); panel.queue_free()
 panel=PanelContainer.new()
 panel.position=Vector2(190,74) if wide else Vector2(34,106)
 panel.custom_minimum_size=Vector2(900,550) if wide else Vector2(480,460)
 panel.add_theme_stylebox_override("panel",ui.style("fff8f0f5",22))
 add_child(panel)
 col=VBoxContainer.new()
 col.add_theme_constant_override("separation",10)
 panel.add_child(col)
 col.add_child(ui.label(title,26,"796179"))
 status=ui.label("",14,"8b7588")
 status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 status.custom_minimum_size.x=430 if not wide else 840
 col.add_child(status)
func text(value: String,size: int=15) -> Label:
 var l: Label=ui.label(value,size)
 l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 l.custom_minimum_size.x=430
 col.add_child(l)
 return l
func button(value: String,callback: Callable,primary: bool=false,icon: String="") -> Button:
 var b: Button=ui.button(value,callback,primary,icon)
 b.name=value.validate_node_name()
 col.add_child(b)
 return b
func footer() -> void:
 col.move_child(status,col.get_child_count()-1)
 button("Close · Esc",func(): exit_requested.emit(),false,"close")
 var first:=col.find_children("*","Button",true,false)
 if not first.is_empty(): first[0].grab_focus()
func timing(rules: RefCounted,callback: Callable) -> void:
 cooking_rules=rules
 bar=Control.new()
 bar.custom_minimum_size=Vector2(420,68)
 col.add_child(bar)
 var track:=ColorRect.new()
 track.color=Color("e6dce8")
 track.position=Vector2(0,24)
 track.size=Vector2(420,20)
 bar.add_child(track)
 target_mark=ColorRect.new()
 target_mark.color=Color("a3c4b0")
 target_mark.position.y=19
 target_mark.size=Vector2(72,30)
 bar.add_child(target_mark)
 cursor_mark=ColorRect.new()
 cursor_mark.color=Color("986d8d")
 cursor_mark.position.y=12
 cursor_mark.size=Vector2(5,44)
 bar.add_child(cursor_mark)
 action_button=button("Action · Space / click",callback,true,"check")
 action_button.shortcut=Shortcut.new()
 var event:=InputEventKey.new()
 event.keycode=KEY_SPACE
 action_button.shortcut.events=[event]
func _process(delta: float) -> void:
 if not cooking_rules or not is_instance_valid(bar) or not bar.is_inside_tree(): return
 cooking_rules.tick(delta)
 target_mark.position.x=cooking_rules.target*420-36
 cursor_mark.position.x=cooking_rules.cursor()*420-2

func card(title: String,body: String,reward: String,done: bool=false,width: float=430,progress_value: float=-1.0) -> PanelContainer:
 var frame:=PanelContainer.new()
 frame.custom_minimum_size.x=width
 frame.add_theme_stylebox_override("panel",ui.style("e2eee5" if done else "eee7f0",16))
 col.add_child(frame)
 var content:=VBoxContainer.new();content.add_theme_constant_override("separation",8);frame.add_child(content)
 for entry in [[title,17,"796179"],[body,13,"756578"],[reward,14,"8e6b8a"]]:
  var l: Label=ui.label(entry[0],entry[1],entry[2]);l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.custom_minimum_size.x=width-44;content.add_child(l)
 var progress:=ProgressBar.new();progress.max_value=1;progress.value=progress_value if progress_value>=0 else (1 if done else 0);progress.show_percentage=false;progress.custom_minimum_size.y=7;content.add_child(progress)
 return frame

func speech(words: String) -> void:
 var scroll:=ScrollContainer.new()
 scroll.custom_minimum_size=Vector2(430,80)
 col.add_child(scroll)
 var line: Label=ui.label(words,14)
 line.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 line.custom_minimum_size.x=416
 scroll.add_child(line)
