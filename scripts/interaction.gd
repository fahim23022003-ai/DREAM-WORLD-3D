extends RefCounted
## One shared decision for prompt and activation: range, camera-facing and clear sight line.
static func resolve(player: CharacterBody3D, camera_rig: Node3D) -> Node3D:
	var chosen: Node3D = null
	var score := INF
	var forward := Vector3.FORWARD.rotated(Vector3.UP,camera_rig.yaw)
	for target in player.get_tree().get_nodes_in_group("interactables"):
		if not target.available(player.global_position): continue
		var point: Vector3 = target.interaction_position()
		var delta := point-player.global_position
		var flat := Vector3(delta.x,0,delta.z)
		if flat.length()>0.15 and flat.normalized().dot(forward)<0.2: continue
		var query := PhysicsRayQueryParameters3D.create(player.global_position+Vector3(0,1.4,0),point,1,[player.get_rid()])
		if not player.get_world_3d().direct_space_state.intersect_ray(query).is_empty(): continue
		if flat.length_squared()<score:
			score = flat.length_squared()
			chosen = target
	return chosen
