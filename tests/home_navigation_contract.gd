extends "res://tests/phase_one.gd"
func ray(a: Vector3,b: Vector3) -> Dictionary:
 return game.player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(a,b,1,[game.player.get_rid()]))
func run() -> void:
 game=load("res://scenes/main.tscn").instantiate()
 game.save_path="user://nav_"+str(Time.get_ticks_usec())+".cfg"
 root.add_child(game)
 game.start_game()
 await frames(6)
 for x in [-3.0,3.0]:
  check(ray(Vector3(x,1,4),Vector3(x,1,6)).is_empty(),"doorway at x=%s is genuinely open" % x)
  check(not ray(Vector3(x,0.2,9),Vector3(x,-1,9)).is_empty(),"new room has continuous solid floor")
 check(not ray(Vector3(0,1,4),Vector3(0,1,6)).is_empty(),"doorway divider remains solid")
 check(not ray(Vector3(-3,1,10),Vector3(3,1,10)).is_empty(),"rooms have a solid dividing wall")
 check(not ray(Vector3(-3,0.6,9.25),Vector3(-5.7,0.6,9.25)).is_empty(),"kitchen counter has physical collision")
 check(not ray(Vector3(1.5,0.4,11),Vector3(4,0.4,11)).is_empty(),"bed frame blocks walking through furniture")
 check(not ray(Vector3(-3,1.2,13),Vector3(-3,1.2,15)).is_empty(),"outer room wall stays solid")
 for entry in [[Vector3(-3.5,0,7),"kitchen.fridge"],[Vector3(-3.55,0,9.25),"kitchen.prep"],[Vector3(-3.55,0,11.75),"kitchen.stove"],[Vector3(3.8,0,8.25),"bedroom.make"],[Vector3(1.5,0,10.65),"bedroom.bed"],[Vector3(1.13,0,11.15),"bedroom.lamp"],[Vector3(1.3,0,8.8),"bedroom.rest"]]:
  game.player.position=entry[0]
  game.player.velocity=Vector3.ZERO
  var target: Node3D=game.home.rooms.stations[entry[1]]
  var d: Vector3=target.global_position-game.player.position
  game.camera_rig.yaw=atan2(-d.x,-d.z)
  await frames(6)
  check(game.interaction_target==target,"reachable shared resolver target "+entry[1])
 # On a real physics camera update, the spring arm must pull in before the dividing wall.
 game.player.position=Vector3(-1,0,6.5)
 game.camera_rig.focus_offset=Vector3.ZERO
 game.camera_rig.yaw=PI/2
 game.camera_rig.pitch=0.2
 game.camera_rig.distance=5.6
 await create_timer(0.5).timeout
 check(game.camera_rig.arm.get_hit_length()<2 and game.camera_rig.camera.global_position.x<0,"camera spring arm retracts before the central wall")
 game.home.rules.data.period=3
 game.home.refresh()
 await create_timer(2.5).timeout
 check(game.home.rooms.env.ambient_light_energy<0.4 and game.room.curtain_control.day_factor<0.5 and game.home.rooms.kitchen_light.light_energy>0.4,"night transitions change ambient window fill and indoor balance")
 game.audio.stop_all()
 print("HOME NAVIGATION: ",checks-failures,"/",checks)
 quit(0 if failures==0 else 1)
