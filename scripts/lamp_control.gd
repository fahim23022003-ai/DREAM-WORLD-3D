extends Node3D
signal changed
signal settled
const ON_ENERGY := 0.55
var interaction_id := "living_room.floor_lamp"
var on := true
var blend := 1.0:
	set(value):
		blend = value
		update_visuals()
var prompt: String:
	get: return "E   ·   Turn lamp off" if on else "E   ·   Turn lamp on"
var shade: MeshInstance3D
var light: OmniLight3D
var transition: Tween

func bind(mesh: MeshInstance3D, local_light: OmniLight3D) -> void:
	shade=mesh
	light=local_light
	shade.material_override=shade.material_override.duplicate()
	shade.material_override.emission_enabled=true
	shade.material_override.emission=Color("ffd7a1")
	light.omni_range=3.6
	add_to_group("interactables")
	set_state(on,false)

func available(pos: Vector3) -> bool:
	return Vector2(pos.x-global_position.x,pos.z-global_position.z).length()<1.65
func interaction_position() -> Vector3:
	return global_position+Vector3(0,1.6,0.13)
func is_settled() -> bool:
	return is_equal_approx(blend,1.0 if on else 0.0)
func toggle() -> void:
	set_state(not on,true)
	changed.emit()
func set_state(value: bool, animate: bool) -> void:
	if transition: transition.kill()
	on=value
	if animate:
		transition=create_tween()
		transition.tween_property(self,"blend",1.0 if on else 0.0,0.32).set_trans(Tween.TRANS_SINE)
		transition.finished.connect(func(): settled.emit())
	else: blend=1.0 if on else 0.0
func update_visuals() -> void:
	if not is_instance_valid(light) or not is_instance_valid(shade): return
	light.light_energy=ON_ENERGY*blend
	shade.material_override.albedo_color=Color("ddd9d3").lerp(Color("ffe8bf"),blend)
	shade.material_override.emission_energy_multiplier=0.22*blend
func _exit_tree() -> void:
	if transition: transition.kill()
