extends Node3D
## Seat pose and a guaranteed clear stand point, independent of sofa rendering.
var seat_offset := Vector3(0,0.24,0.28)
var stand_offset := Vector3(0,0,1.43)

func _ready() -> void:
	add_to_group("seats")

func available(player_position: Vector3) -> bool:
	var front := global_position + stand_offset
	return Vector2(player_position.x-front.x,player_position.z-front.z).length() < 1.35

func seat_position() -> Vector3:
	return to_global(seat_offset)

func stand_position() -> Vector3:
	return to_global(stand_offset)
