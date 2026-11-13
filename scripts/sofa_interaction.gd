extends Node3D
## Seat pose and a guaranteed clear stand point, independent of sofa rendering.
var seat_offset := Vector3(0,0.24,0.28)
var stand_offset := Vector3(0,0,1.43)
var interaction_id := "sofa"
var prompt := "E   ·   Settle into the sofa"

func _ready() -> void:
	add_to_group("seats")
	add_to_group("interactables")

func interaction_position() -> Vector3:
	return global_position+Vector3(0,1.4,0.75)

func available(player_position: Vector3) -> bool:
	var front := global_position + stand_offset
	return Vector2(player_position.x-front.x,player_position.z-front.z).length() < 1.35

func seat_position() -> Vector3:
	return to_global(seat_offset)

func stand_position() -> Vector3:
	return to_global(stand_offset)
