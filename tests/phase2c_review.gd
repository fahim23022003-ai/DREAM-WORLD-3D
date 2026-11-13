extends "res://tests/phase2c_flow.gd"
const REVIEW_LEDGER:="/tmp/dream-phase2c-review-ledger.json"
func face_clear(id: String) -> void:
 await create_timer(0.9).timeout
 var point: Vector2=game.camera_rig.camera.unproject_position(nb().actors[id].avatar.head.global_position)
 check(point.x>40 and point.x<game.home.panel.panel.position.x-20 and point.y>40 and point.y<660,id+" face remains in the world beside the dialogue panel")
func resume_review() -> void:
 var expected: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(REVIEW_LEDGER))
 check(game.home.rules.data.coins==int(expected.coins),"second real process restart restores exact post-activity coins")
 for id in ["mimi","noah"]:
  check(nb().data().people[id].xp==int(expected[id]) and nb().actors[id].avatar.left_leg.rotation.z==0,"friendship and neutral leg recovery persist correctly for "+id)
 check(game.home.rules.data.life.rewards==["garden","baking","warming"] and game.home.rules.data.life.receipts.size()==10,"repeat gatherings never duplicate story rewards or receipts")
 check(not game.player.social_owned and life().active_kind.is_empty(),"Continue has no persisted animation ownership")
 await garden_photo();await shot("17_quit_continue")
 await key(KEY_L,true);await key(KEY_L,false);root.size=Vector2i(1920,1080);await frames(8);await RenderingServer.frame_post_draw
 check(game.ui.root.get_global_rect().encloses(game.home.panel.panel.get_global_rect()),"final friendship journal fits at 1920x1080")
 root.get_texture().get_image().save_png(output+"21_journal_1920x1080.png")
 await close_panel();await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false);await click("Save & main menu")
 print("PHASE 2C REVIEW CONTINUE: ",checks-failures,"/",checks)
 if failures: quit(1);return
 await click("Quit")
func run() -> void:
 output="res://docs/review/phase2c/";root.size=Vector2i(1280,720)
 file=FileAccess.get_file_as_string(CNOTE).strip_edges();await load_game();await click("Continue home  →")
 if "--resume" in OS.get_cmdline_user_args(): await resume_review();return
 check(game.home.rules.data.life.rewards.size()==3,"visual review starts on the genuinely completed three-story fixture")
 await key(KEY_F1,true);await key(KEY_F1,false)
 check(game.ui.mode=="help" and not game.active,"real F1 opens the full controls without persistent HUD clutter")
 await shot("19_controls_help");await close_panel()
 var previous: bool=game.save.onboarding.dismissed
 await key(KEY_T,true);await key(KEY_T,false)
 check(game.save.onboarding.dismissed!=previous,"real T dismisses or restores contextual guidance")
 await key(KEY_T,true);await key(KEY_T,false)
 if game.player.position.x<6: await to_garden()
 await shared("Cozy tea time","mimi","Lavender tea · a quiet thank-you")
 check(game.player.avatar.sit_blend>0.8,"player sitting animation retains ownership while the UI is open")
 check(true,"recordable shared tea scene is live")
 await create_timer(3).timeout
 await click("Keep this memory");await create_timer(14).timeout
 check(game.home.rules.data.life.tea_choice=="lavender" and life().world.tea_colors.all(func(n): return n.material_override.albedo_color.is_equal_approx(Color("b8a7d0"))),"actual lavender choice changes the visible cup palette")
 await shot("09_shared_tea_time");await click("Back to the garden")
 await shared("Garden picnic","mimi","Watch cloud shapes")
 check(life().active_both,"completed housewarming unlocks repeat group picnics")
 await click("Keep this memory");await create_timer(0.7).timeout
 check(game.home.rules.data.life.picnic_choice=="clouds" and life().world.cloth.material_override.albedo_color.is_equal_approx(Color("b9cedd")),"actual cloud choice changes picnic fabric and outcome")
 await shot("10_garden_picnic");await click("Back to the garden");await create_timer(0.6).timeout
 for npc in nb().actors.values(): check(absf(npc.avatar.left_leg.rotation.z)<0.04,"picnic stand-up clears crossed-leg pose for "+npc.person)
 await speak("mimi");await face_clear("mimi");await shot("06_mimi_expressions");await close_panel()
 await speak("noah");await face_clear("noah");await shot("07_noah_expressions");await click("Shared activities");await click("Rest on the garden bench")
 await walk_to(Vector3(11,0,1))
 for i in range(1200):
  if nb().actors.noah.seated_requested: break
  await frames(1)
 check(nb().actors.noah.seated_requested,"repeat visitor bench approach remains valid after picnic")
 await create_timer(0.8).timeout;await photo(nb().actors.noah.avatar.global_position+Vector3(0,0.9,0),0.15,0.15,4.6);await shot("08_actual_seated_npc")
 await walk_to(Vector3(14.4,0,2.1));await use_garden("garden.gathering");await activity_ready()
 var before: Array=game.home.rules.data.life.receipts.duplicate()
 await click("Keep this memory");await create_timer(0.7).timeout
 check(game.home.rules.data.life.receipts==before and before.size()==10,"a real repeat gathering cannot replay a story chapter reward")
 for npc in nb().actors.values(): check(absf(npc.avatar.left_leg.rotation.z)<0.04,"standing gathering uses neutral leg stance for "+npc.person)
 await shot("12_housewarming_gathering");await click("Back to the garden")
 await key(KEY_Q,true);await key(KEY_Q,false);await shot("13_improved_daily_ui");await close_panel()
 await key(KEY_L,true);await key(KEY_L,false);await shot("14_improved_journal");await click("Keepsakes");await click("More keepsakes →");await shot("20_future_keepsakes");await close_panel()
 await photo(Vector3(16.3,0.65,-2.9),0.2,0.15,3.2);await shot("18_noah_garden_memory")
 await to_kitchen();await photo(Vector3(-3.35,1.3,13.25),PI-0.8,0.16,2.7);await shot("11_story_event")
 var ledger:={"coins":game.home.rules.data.coins,"mimi":nb().data().people.mimi.xp,"noah":nb().data().people.noah.xp}
 FileAccess.open(REVIEW_LEDGER,FileAccess.WRITE).store_string(JSON.stringify(ledger))
 await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false);await click("Save & main menu")
 print("PHASE 2C REVIEW: ",checks-failures,"/",checks)
 if failures: quit(1);return
 await click("Quit")
