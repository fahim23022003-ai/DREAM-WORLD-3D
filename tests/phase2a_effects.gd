extends "res://tests/phase2a_flow.gd"
func run() -> void:
 output="res://docs/review/phase2a/"
 root.size=Vector2i(1280,720)
 file="user://phase2a_effects_"+str(Time.get_ticks_usec())+".cfg"
 await load_game()
 await click("Come on in  →")
 await walk_to(Vector3(-3,0,2.8));await walk_to(Vector3(-3,0,6.2));await walk_to(Vector3(-3.5,0,7))
 await world_use("kitchen.fridge")
 await click("Cloud Pancakes")
 await walk_to(Vector3(-3.55,0,9.25))
 await world_use("kitchen.prep")
 await time_actions(3)
 await walk_to(Vector3(-3.55,0,11.75))
 await world_use("kitchen.stove")
 await create_timer(0.5).timeout
 check(game.home.rooms.steam.visible and game.home.rooms.steam.get_children().all(func(puff): return puff.scale.length()<0.3 and puff.material_override.albedo_color.a<0.5),"steam stays small translucent and contained at the actual stove")
 await shot("05_cooking_active")
 await time_actions(2)
 await walk_to(Vector3(-3.55,0,9.25))
 await world_use("kitchen.prep")
 check(game.home.meal.stage=="done","actual effects review finishes and plates the recipe")
 await shot("06_finished_food")
 await click("Enjoy my meal")
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await click("Save & main menu")
 print("PHASE 2A EFFECTS: ",checks-failures,"/",checks)
 if failures: quit(1);return
 await click("Quit")
