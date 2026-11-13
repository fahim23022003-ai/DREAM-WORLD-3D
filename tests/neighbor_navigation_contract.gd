extends "res://tests/phase_one.gd"
func run() -> void:
 game=load("res://scenes/main.tscn").instantiate();game.save_path="user://npc_nav_"+str(Time.get_unix_time_from_system())+".cfg";root.add_child(game);game.start_game()
 var nb: Node=game.home.neighborhood
 for npc in nb.actors.values(): npc.invite()
 await create_timer(13).timeout
 for id in nb.actors:
  var npc: Node3D=nb.actors[id]
  check(npc.mode in [npc.Mode.WAITING,npc.Mode.WANDERING,npc.Mode.VISITING] and npc.position.distance_to(npc.social)<0.6,"visitor arrives using real collision movement: "+id)
  check(npc.position.x>6.3 and npc.position.x<16.7 and absf(npc.position.z)<4.7,"visitor stays on safe garden navigation points: "+id)
 check(nb.actors.mimi.avatar.scale!=nb.actors.noah.avatar.scale and nb.actors.noah.avatar.skirt.visible==false,"Mimi and Noah have distinct procedural silhouettes")
 var npc: CharacterBody3D=nb.actors.mimi
 npc.talk();var pos: Vector3=npc.position
 await create_timer(0.3).timeout
 check(npc.mode==npc.Mode.TALKING and npc.position==pos,"talking holds a safe social interaction position")
 npc.position=Vector3(10,0,3);npc.mode=npc.Mode.WANDERING;npc.route.assign([Vector3(12,0,3)])
 var wall=load("res://scripts/forms.gd").solid(game,Vector3(11,1,3),Vector3(0.1,2,2))
 await create_timer(1.7).timeout
 check(npc.position.x<10.8,"visitor collision cannot walk through a blocking wall")
 wall.queue_free();await frames(3)
 game.player.position=Vector3(11,0,3);npc.position=Vector3(10,0,3);npc.route.assign([Vector3(12,0,3)])
 await create_timer(1.7).timeout
 check(npc.position.distance_to(game.player.position)>0.5 and npc.position.x<10.6,"visitor pauses before crossing through the player")
 game.player.position=Vector3(0,0,1.8)
 npc.end_talk(true)
 await create_timer(10).timeout
 check(npc.mode==npc.Mode.AWAY and not npc.visible and npc.collision_layer==0,"visitor leaves along gate route and removes invisible collision")
 game.set_active(false)
 game.player.position=npc.start
 npc.invite();await frames(4)
 check(npc.position.distance_to(game.player.position)>0.5,"arrival chooses a clear gate position instead of spawning inside the player")
 check(npc.mode==npc.Mode.ARRIVING and npc.visible and npc.collision_layer==2,"recurring visitor can arrive again naturally")
 game.audio.stop_all()
 print("NEIGHBOR NAVIGATION: ",checks-failures,"/",checks)
 quit(0 if failures==0 else 1)
