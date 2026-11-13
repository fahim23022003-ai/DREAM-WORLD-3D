extends "res://tests/phase_one.gd"
func bounds(message: String) -> void:
 await frames(4)
 var rect: Rect2=game.home.panel.panel.get_global_rect()
 var visible: Rect2=game.ui.root.get_global_rect()
 check(visible.encloses(rect) and rect.position.x>=0 and rect.position.y>=0,message)
func run() -> void:
 game=load("res://scenes/main.tscn").instantiate()
 game.save_path="user://home_layout_"+str(Time.get_ticks_usec())+".cfg"
 root.add_child(game)
 game.start_game()
 for size in [Vector2i(1280,720),Vector2i(1920,1080)]:
  root.size=size
  await frames(5)
  game.save.appearance.display_name="MMMMMMMMMMMMMMMMMMMMMMMM"
  game.resume_game()
  await frames(4)
  check(game.ui.home_label.get_parent().get_global_rect().end.x<game.home.strip.get_parent().get_global_rect().position.x,"long name cannot overlap day and coin badge at "+str(size))
  game.save.appearance.display_name="Dreamer"
  game.resume_game()
  game.open_style(game.State.DECOR)
  await frames(4)
  check(game.ui.root.get_global_rect().encloses(game.feature.panel.get_global_rect()),"existing Decor plus catalog entry fits at "+str(size))
  game.cancel_feature()
  game.home.open_goals()
  await bounds("daily goals readable in logical viewport at "+str(size))
  game.home.close()
  game.home.open_catalog()
  await bounds("six-row catalog readable at "+str(size))
  game.home.preview_finish("bed.lavender")
  await bounds("free locked 3D preview readable at "+str(size))
  game.home.close()
  game.home.open_sleep()
  await bounds("sleep confirmation readable at "+str(size))
  game.home.close()
  for id in game.home.RULES.RECIPES:
   game.home.meal.begin(id,"layout-fixture")
   game.home.open_recipes()
   await bounds("in-progress recipe pantry fits at "+str(size)+" "+id)
   game.home.close()
   game.home.open_timing(false)
   await bounds("prep input instructions and choices fit at "+str(size)+" "+id)
   game.home.close()
 game.audio.stop_all()
 print("HOME LAYOUT: ",checks-failures,"/",checks)
 quit(0 if failures==0 else 1)
