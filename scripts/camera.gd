extends Node3D
var target: CharacterBody3D
var yaw := 0.24
var pitch := 0.25
var distance := 5.6
var sensitivity := 0.0024
var enabled := false
var focus_offset := Vector3.ZERO
var arm: SpringArm3D
var camera: Camera3D

func _ready() -> void:
	arm = SpringArm3D.new()
	arm.spring_length = distance
	arm.margin = 0.18
	var shape := SphereShape3D.new()
	shape.radius = 0.18
	arm.shape = shape
	add_child(arm)
	camera = Camera3D.new()
	camera.fov = 56
	camera.near = 0.07
	arm.add_child(camera)
	camera.current = true

func _unhandled_input(event: InputEvent) -> void:
	if not enabled: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x*sensitivity
		pitch = clampf(pitch+event.relative.y*sensitivity,-0.12,0.82)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: distance = maxf(2,distance-0.4)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: distance = minf(6.8,distance+0.4)

func _process(delta: float) -> void:
	if not target: return
	global_position = global_position.lerp(target.global_position+focus_offset+Vector3(0,1.25,0),1-exp(-10*delta))
	rotation = Vector3(-pitch,yaw,0)
	var small_room: bool=target.position.z>5 and target.position.x<6 and focus_offset.length()<0.2
	arm.spring_length = lerpf(arm.spring_length,distance,1-exp(-12*delta))
	if enabled:
		camera.fov=lerpf(camera.fov,64.0 if small_room and arm.get_hit_length()<2.8 else 56.0,1-exp(-5*delta))
	var head: Vector3=target.global_position+Vector3(0,1.55,0)
	if is_instance_valid(target.avatar): target.avatar.visible=camera.global_position.distance_to(head)>1.05

	for actor in get_tree().get_nodes_in_group("camera_characters"):
		if is_instance_valid(actor.avatar): actor.avatar.visible=camera.global_position.distance_to(actor.global_position+Vector3(0,1.55,0))>1.35
