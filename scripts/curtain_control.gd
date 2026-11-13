extends Node3D
signal changed
signal settled
var interaction_id := "living_room.curtains"
var closed := false
var amount := 0.0:
	set(value):
		amount=value
		update_visuals()
var prompt: String:
	get: return "E   ·   Open curtains" if closed else "E   ·   Close curtains"
var panels: Array[MeshInstance3D] = []
var ties: Array[MeshInstance3D] = []
var fill: OmniLight3D
var baseline_fill := 0.12
var transition: Tween
func bind(meshes: Array[MeshInstance3D], tiebacks: Array[MeshInstance3D], window_fill: OmniLight3D) -> void:
	panels=meshes
	ties=tiebacks
	fill=window_fill
	baseline_fill=fill.light_energy
	add_to_group("interactables")
	set_state(closed,false)
func available(pos: Vector3) -> bool:
	return Vector2(pos.x-global_position.x,pos.z-global_position.z).length()<1.5
func interaction_position() -> Vector3:
	return global_position+Vector3(0,1.5,0)
func is_settled() -> bool:
	return is_equal_approx(amount,1.0 if closed else 0.0)
func toggle() -> void:
	set_state(not closed,true)
	changed.emit()
func set_state(value: bool, animate: bool) -> void:
	if transition: transition.kill()
	closed=value
	if animate:
		transition=create_tween()
		transition.tween_property(self,"amount",1.0 if closed else 0.0,0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		transition.finished.connect(func(): settled.emit())
	else: amount=1.0 if closed else 0.0
func update_visuals() -> void:
	for panel in panels: panel.set_blend_shape_value(0,amount)
	for tie in ties: tie.visible=amount<0.02
	if is_instance_valid(fill): fill.light_energy=baseline_fill*lerpf(1,0.25,amount)
func _exit_tree() -> void:
	if transition: transition.kill()
