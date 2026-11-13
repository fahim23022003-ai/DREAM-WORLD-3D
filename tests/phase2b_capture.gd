extends "res://tests/phase2b_flow.gd"
# A separate fresh fixture keeps the arrival and first-water views readable.
func run() -> void:
 output="/tmp/dream-phase2b-review/";root.size=Vector2i(1280,720)
 file="user://phase2b_capture_"+str(Time.get_unix_time_from_system())+".cfg"
 await load_game();await click("Come on in  →")
 await walk_to(Vector3(3,0,3.6));await walk_to(Vector3(7.2,0,3.6))
 var mimi: Node3D=nb().actors.mimi
 check(mimi.mode!=mimi.Mode.AWAY,"fresh-session visitor arrives through the gate")
 await photo(mimi.position+Vector3(0,0.9,0),mimi.avatar.rotation.y+1.05,0.18,5.2)
 await shot("05_mimi_arrival")
 await walk_to(Vector3(9,0,0.25));await use_garden("garden.plot0");await click("Plant Strawberries")
 await use_garden("garden.plot0");await click("Water crop")
 check(nb().data().plots[0].stage==2,"fresh screenshot follows legitimate seed selection and watering")
 await photo(Vector3(9,0.9,-1.1),-0.85,0.32,5.2);await shot("02_garden_planting")
 print("PHASE 2B CAPTURE: ",checks-failures,"/",checks)
 quit(1 if failures else 0)
