extends "res://tests/phase2b_flow.gd"
func scroll_keepsakes() -> void:
 var scroll: ScrollContainer
 for node in game.home.panel.panel.find_children("*","ScrollContainer",true,false): scroll=node;break
 var point: Vector2=scroll.get_global_rect().get_center()
 var motion:=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true)
 for i in range(14):
  for down in [true,false]:
   var wheel:=InputEventMouseButton.new();wheel.position=point;wheel.global_position=point;wheel.button_index=MOUSE_BUTTON_WHEEL_DOWN;wheel.pressed=down;root.push_input(wheel,true)
  await frames(1)
 await RenderingServer.frame_post_draw
func run() -> void:
 output="/tmp/dream-phase2b-review/";root.size=Vector2i(1280,720)
 file=FileAccess.get_file_as_string(BNOTE).strip_edges()
 await load_game();await click("Continue home  →")
 if "--resume" in OS.get_cmdline_user_args():
  var data: Dictionary=nb().data()
  check(game.home.rules.data.coins==35 and data.produce.carrot==0,"second process retains the exact carrot-request reward and consumed produce")
  check(data.people.noah.requests_done==1 and data.people.noah.xp==4 and data.people.noah.days==[2],"Noah's actual request friendship and shared day survive Quit")
  check(data.people.mimi.days==[1] and data.people.mimi.xp==4,"Mimi's independent friendship remains intact")
  check(data.achievements.size()==5 and not "close_friend" in data.achievements,"earned keepsakes persist while long-term Close Friend remains honestly locked")
  await key(KEY_Q,true);await key(KEY_Q,false);await shot("11_new_daily_goals");await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
  await key(KEY_L,true);await key(KEY_L,false);await shot("12_progress_journal")
  root.size=Vector2i(1920,1080);await frames(8);await RenderingServer.frame_post_draw
  check(game.ui.root.get_global_rect().encloses(game.home.panel.panel.get_global_rect()),"friendship collection cards fit at 1920x1080")
  root.get_texture().get_image().save_png(output+"17_journal_1920x1080.png")
  root.size=Vector2i(1280,720);await frames(6)
  await scroll_keepsakes();await shot("19_earned_and_future_keepsakes")
  await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
  print("PHASE 2B SOCIAL CONTINUE: ",checks-failures,"/",checks)
 else:
  check(game.home.rules.data.coins==26 and nb().data().produce.carrot==1,"Noah journey starts with genuinely harvested produce and unchanged saved coins")
  await key(KEY_L,true);await key(KEY_L,false)
  await click("Today's moment · Garden bloom ✓")
  check(nb().data().event.done,"event card presents a genuinely completed garden bloom")
  await shot("10_dynamic_event");await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
  await meet("noah");await click("Garden stories")
  check(nb().data().people.noah.met and nb().data().people.noah.xp==1,"Noah's own authored conversation earns independent friendship")
  await click("Visitor request");await click("Accept request")
  check(nb().data().people.noah.request=="noah.carrots","Noah requests real harvested carrots")
  await shot("08_visitor_request")
  await click("Share & claim reward")
  check(nb().data().produce.carrot==0 and nb().data().people.noah.requests_done==1,"real request claim consumes exactly one carrot")
  check(nb().data().people.noah.xp==4 and game.home.rules.data.coins==35,"Noah becomes Friend and the correct daily objective reward joins the request coins")
  await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
  await photo(nb().actors.noah.position+Vector3(0,1.0,0),nb().actors.noah.avatar.rotation.y+1.05,0.15,5.0);await shot("06_noah_garden")
  print("PHASE 2B SOCIAL: ",checks-failures,"/",checks)
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false);await click("Save & main menu")
 if failures: quit(1);return
 await click("Quit")
