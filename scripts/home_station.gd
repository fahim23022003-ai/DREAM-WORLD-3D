extends Node3D
var interaction_id := ""
var prompt := ""
var radius := 1.55
func _ready() -> void: add_to_group("interactables")
func available(pos: Vector3) -> bool: return Vector2(pos.x-global_position.x,pos.z-global_position.z).length()<radius
func interaction_position() -> Vector3: return global_position+Vector3(0,1.35,0)
