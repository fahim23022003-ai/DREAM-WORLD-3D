extends "res://tests/phase2b_flow.gd"
func run() -> void:
 output="/tmp/dream-phase2b-review/";root.size=Vector2i(1280,720)
 file=FileAccess.get_file_as_string(BNOTE).strip_edges()
 await load_game();await click("Continue home  →")
 await key(KEY_L,true);await key(KEY_L,false);await click("Invite Noah")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await meet("noah")
 check(nb().data().people.noah.xp==4,"camera review retains genuinely earned friendship")
 await shot("06_noah_garden")
 # Dialogue camera is perpendicular to the player/visitor line, with boundary clearance.
 var d: Vector3=game.player.position-nb().actors.noah.position
 check(absf(cos(game.camera_rig.yaw-atan2(d.x,d.z)))<0.01,"automatic conversation camera separates the two silhouettes")
 print("PHASE 2B CAMERA: ",checks-failures,"/",checks)
 quit(1 if failures else 0)
