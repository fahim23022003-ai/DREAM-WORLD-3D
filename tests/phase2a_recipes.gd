extends "res://tests/phase2a_flow.gd"
func prep_recipe_inputs() -> void:
 for code in [KEY_1,KEY_2,KEY_3]:
  for f in range(180):
   if absf(game.home.meal.cursor()-game.home.meal.target)<0.045: break
   await frames(1)
  await key(code,true);await key(code,false)
func run() -> void:
 output="res://docs/review/phase2a/"
 root.size=Vector2i(1280,720)
 file="user://phase2a_recipes_"+str(Time.get_ticks_usec())+".cfg"
 await load_game()
 await click("Come on in  →")
 await walk_to(Vector3(-3,0,2.8));await walk_to(Vector3(-3,0,6.2))
 for id in ["berry_cupcakes","starry_soup"]:
  await walk_to(Vector3(-3.5,0,7))
  await world_use("kitchen.fridge")
  await click(game.home.RULES.RECIPES[id].name)
  await walk_to(Vector3(-3.55,0,9.25))
  await world_use("kitchen.prep")
  check(game.home.panel.action_button.visible==false,"ingredient-order recipe exposes three accessible ingredient choices")
  await prep_recipe_inputs()
  check(game.home.meal.stage=="prepared","real ingredient order prepares "+id)
  await walk_to(Vector3(-3.55,0,11.75))
  await world_use("kitchen.stove")
  await time_actions(game.home.RULES.RECIPES[id].beats)
  check(game.home.meal.stage=="ready" and game.home.meal.quality() in ["Good","Perfect"],"real timing produces quality cooked "+id)
  await walk_to(Vector3(-3.55,0,9.25))
  await world_use("kitchen.prep")
  check(game.home.meal.stage=="done","plating commits recipe result "+id)
  await click("Enjoy my meal")
  await photo(Vector3(-5,1.35,9.25),1.0,0.38,2.5)
  await shot("14_berry_cupcakes" if id=="berry_cupcakes" else "15_starry_soup")
 check(game.home.rules.data.coins==15,"two distinct genuine recipe completions earn bounded rewards")
 # Late-day objective remains achievable after reaching night.
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
 await click("Save & main menu")
 print("PHASE 2A RECIPES: ",checks-failures,"/",checks)
 if failures: quit(1);return
 await click("Quit")
