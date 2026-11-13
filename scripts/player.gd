extends CharacterBody3D
var camera_rig: Node3D
var enabled := false
var seated := false
var current_seat: Node3D
var nearby_seat: Node3D
var pose_target := Vector3.ZERO
@onready var avatar: Node3D = $Avatar

func _ready() -> void:
	var c := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.26
	capsule.height = 1.85
	c.shape = capsule
	c.position.y = 0.94
	add_child(c)
	floor_snap_length = 0.25

func _physics_process(delta: float) -> void:
	nearby_seat = null
	for seat in get_tree().get_nodes_in_group("seats"):
		if seat.available(global_position): nearby_seat = seat
	if not enabled:
		avatar.animate(delta,0,false,seated)
		return
	if Input.is_action_just_pressed("interact"): interact()
	if seated:
		global_position = global_position.lerp(pose_target,1-exp(-12*delta))
		avatar.rotation.y = lerp_angle(avatar.rotation.y,0,1-exp(-12*delta))
		avatar.animate(delta,0,false,true)
		return
	var axes := Input.get_vector("left","right","forward","back")
	var direction := Vector3(axes.x,0,axes.y).rotated(Vector3.UP,camera_rig.yaw)
	var running := Input.is_action_pressed("run")
	var speed := 4.2 if running else 2.3
	velocity.x = move_toward(velocity.x,direction.x*speed,delta*13)
	velocity.z = move_toward(velocity.z,direction.z*speed,delta*13)
	if not is_on_floor(): velocity.y -= 20*delta
	else: velocity.y = -0.1
	move_and_slide()
	if direction.length()>0.1:
		avatar.rotation.y = lerp_angle(avatar.rotation.y,atan2(direction.x,direction.z),1-exp(-14*delta))
	avatar.animate(delta,Vector2(velocity.x,velocity.z).length(),running,false)

func interact() -> void:
	if seated:
		var visual_start := global_position
		seated = false
		global_position = current_seat.stand_position()
		avatar.position = visual_start-global_position
		create_tween().tween_property(avatar,"position",Vector3.ZERO,0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		velocity = Vector3.ZERO
		current_seat = null
	elif nearby_seat:
		current_seat = nearby_seat
		seated = true
		velocity = Vector3.ZERO
		pose_target = current_seat.seat_position()
