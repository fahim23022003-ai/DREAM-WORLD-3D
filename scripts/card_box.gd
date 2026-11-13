extends Node3D
const F = preload("res://scripts/forms.gd")
var interaction_id := "cozy_pairs_box"
var prompt := "E   ·   Play Cozy Pairs"
func _ready() -> void:
	add_to_group("interactables")
	F.finish(F.box(self,Vector3.ZERO,Vector3(0.51,0.15,0.34),"c5b0d9",0.045),"fabric")
	F.box(self,Vector3(0,0.077,0),Vector3(0.52,0.025,0.35),"efe3ef",0.012)
	var art := F.picture(self,Vector3(0,0.093,0),Vector2(0.21,0.21),"res://assets/pairs/flower.svg")
	art.rotation.x = -PI/2
	art.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	art.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	F.box(self,Vector3(0,-0.005,0.175),Vector3(0.1,0.035,0.012),"d7bf90",0.005)
func available(pos: Vector3) -> bool:
	return Vector2(pos.x-global_position.x,pos.z-global_position.z).length()<1.75
func interaction_position() -> Vector3:
	return global_position+Vector3(0,0.12,0)
