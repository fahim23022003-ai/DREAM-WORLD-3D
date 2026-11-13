extends SceneTree
var game: Node3D
func _initialize() -> void: call_deferred("run")
func run() -> void:
 root.size=Vector2i(1280,720)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 game=load("res://scenes/main.tscn").instantiate();game.save_path="user://benchmark_only.cfg";root.add_child(game);game.start_game()
 var results: Array=[]
 var shots:=OS.get_environment("DREAM_REVIEW")
 var views: Array=[["01_living_room",Vector3(0,1.1,0),0.22,0.22,6.8],["02_kitchen",Vector3(-3,1.15,9.4),1.05,0.3,6.4],["03_bedroom",Vector3(3,1,10),3.65,0.3,6.4],["04_garden",Vector3(11.8,1,-0.6),0.0,0.38,7.0]]
 for view in views:
  game.camera_rig.focus_offset=view[1]-game.player.position-Vector3(0,1.25,0);game.camera_rig.yaw=view[2];game.camera_rig.pitch=view[3];game.camera_rig.distance=view[4]
  for i in range(40): await process_frame
  await RenderingServer.frame_post_draw
  if not shots.is_empty(): root.get_texture().get_image().save_png(shots+"/"+view[0]+"_"+OS.get_environment("DREAM_VERSION")+".png")
  var samples: Array=[]
  for i in range(120):
   var began:=Time.get_ticks_usec();await process_frame;samples.append((Time.get_ticks_usec()-began)/1000.0)
  samples.sort()
  results.append({"view":view[0],"median_ms":samples[60],"p95_ms":samples[114],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)})
 print("BENCHMARK ",JSON.stringify(results));quit()
