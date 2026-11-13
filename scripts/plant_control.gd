extends Node3D
signal watered(first: bool)
const F = preload("res://scripts/forms.gd")
var interaction_id := "living_room.houseplant"
var prompt: String:
	get: return "Watering…" if busy else "E   ·   Water plant"
var has_watered := false
var busy := false
var cooldown := 0.0
var elapsed := 0.0
var leaves: Array[MeshInstance3D] = []
var leaf_rotations: Array[Vector3] = []
var effect: Node3D
var drops: Array[MeshInstance3D] = []
func bind(leaf_nodes: Array[MeshInstance3D]) -> void:
	leaves=leaf_nodes
	for leaf in leaves: leaf_rotations.append(leaf.rotation)
	effect=Node3D.new()
	effect.name="ReusableWaterDrops"
	add_child(effect)
	for i in range(9):
		var drop := F.ball(effect,Vector3.ZERO,Vector3(0.04,0.07,0.04),"a2d4e8")
		drop.material_override=drop.material_override.duplicate()
		drop.material_override.emission_enabled=true
		drop.material_override.emission=Color("88b7d0")
		drop.material_override.emission_energy_multiplier=0.25
		drops.append(drop)
	effect.hide()
	add_to_group("interactables")
func available(pos: Vector3) -> bool:
	return Vector2(pos.x-global_position.x,pos.z-global_position.z).length()<1.6
func interaction_position() -> Vector3:
	return global_position+Vector3(0,0.65,0.08)
func water() -> bool:
	if busy or cooldown>0: return false
	busy=true
	elapsed=0
	effect.show()
	update_effect()
	return true
func _process(delta: float) -> void:
	cooldown=maxf(0,cooldown-delta)
	if not busy: return
	elapsed+=delta
	update_effect()
	if elapsed>=1.0:
		busy=false
		cooldown=0.25
		effect.hide()
		for i in range(leaves.size()): leaves[i].rotation=leaf_rotations[i]
		var first := not has_watered
		has_watered=true
		watered.emit(first)
func update_effect() -> void:
	for i in range(drops.size()):
		var t := fmod(elapsed*1.8+i*0.11,1.0)
		drops[i].position=Vector3(cos(i*2.4)*0.16,1.1-t*0.56,0.11+sin(i*2.4)*0.14)
	for i in range(leaves.size()):
		leaves[i].rotation=leaf_rotations[i]+Vector3(0,0,sin(elapsed*TAU*1.8+i*0.6)*sin(minf(elapsed,1)*PI)*0.055)
