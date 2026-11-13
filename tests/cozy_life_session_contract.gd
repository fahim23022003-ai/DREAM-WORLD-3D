extends "res://tests/phase_one.gd"
const S=preload("res://scripts/save_data.gd")
const H=preload("res://scripts/home_rules.gd")
const L=preload("res://scripts/cozy_story_rules.gd")
func inside(text: String) -> void:
 await frames(4)
 check(game.ui.root.get_global_rect().encloses(game.home.panel.panel.get_global_rect()),text)
func run() -> void:
 for version in [1,2,3,4,5]:
  var path: String="user://life_legacy_%d_%d.cfg" % [version,Time.get_ticks_usec()]
  var cfg:=ConfigFile.new();cfg.set_value("meta","schema_version",version)
  var old:=H.defaults();old.erase("life");old.coins=48;old.neighborhood.produce.carrot=2;old.neighborhood.people.noah.xp=5;old.neighborhood.people.noah.days=[1,2];old.day=2;old.goals_done=["meal"];old.receipts=["old-paid-receipt"]
  cfg.set_value("home","life",old);cfg.set_value("future","untouched",42);cfg.save(path)
  var bytes:=FileAccess.get_file_as_bytes(path)
  var save:=S.new();save.path=path;save.load_local()
  check(save.home.coins==48 and save.home.neighborhood.produce.carrot==2 and save.home.neighborhood.people.noah.days==[1,2],"schema %d preserves currency, garden and shared days" % version)
  check(FileAccess.get_file_as_bytes(path+".v%d.bak" % version)==bytes,"schema %d keeps its exact backup" % version)
  check(save.home.goals_done==["meal"] and save.home.receipts==["old-paid-receipt"] and save.home.life.rewards.is_empty(),"schema %d preserves old receipts with safe story defaults" % version)
  check(save.write_local(Vector3(10,0,2))==OK,"schema %d migrates atomically to schema 6" % version)
  var read:=ConfigFile.new();read.load(path);check(read.get_value("future","untouched")==42 and read.get_value("meta","schema_version")==6,"schema %d retains unknown configuration" % version)
 game=load("res://scenes/main.tscn").instantiate();game.save_path="user://life_session_"+str(Time.get_ticks_usec())+".cfg";root.add_child(game);game.start_game()
 var home: Node=game.home;var nb: Node=home.neighborhood;var life: Node=nb.life
 check(home.commit(func(): L.begin(home.rules.data,"baking")),"story begins through existing atomic commit")
 home.rules.data.neighborhood.plots[0]={"crop":"strawberry","stage":4,"water_day":1,"cycle":1}
 var before: Dictionary=home.rules.data.duplicate(true)
 DirAccess.make_dir_absolute(game.save_path+".tmp")
 var fail: Dictionary=nb.transact("harvest",{"plot":0})
 check(not fail.ok and home.rules.data==before,"failed harvest rolls back story ingredient, crop, inventory and coins together")
 DirAccess.remove_absolute(game.save_path+".tmp")
 var good: Dictionary=nb.transact("harvest",{"plot":0})
 check(good.ok and home.rules.data.life.arcs.baking==2 and nb.data().produce.strawberry==0,"retry reserves one strawberry and advances the chapter once")
 var paid: int=home.rules.data.coins
 check(not nb.transact("harvest",{"plot":0}).ok and home.rules.data.coins==paid,"harvest/story retry cannot duplicate a reward")
 var save:=S.new();save.path=game.save_path;save.load_local()
 check(save.home.life.arcs.baking==2 and save.home.life.receipts==["baking:1"],"story chapter and receipt survive a real filesystem round trip")
 home.commit(func(): home.rules.event("meal","fixture-cupcakes",{"recipe":"berry_cupcakes","quality":"Good"}))
 check(home.rules.data.life.arcs.baking==3,"a plated cupcake fixture prepares the final story chapter")
 # Activity transaction fixture, independent of genuine rendered acceptance.
 home.open_shell("Activity fixture");life.active_kind="tea";life.active_npc="mimi";life.phase="seated"
 var previous: Dictionary=home.rules.data.duplicate(true)
 DirAccess.make_dir_absolute(game.save_path+".tmp");life.finish_activity()
 check(home.rules.data==previous and life.phase=="seated","failed shared-activity write retains a retryable pose with no friendship loss")
 DirAccess.remove_absolute(game.save_path+".tmp");life.finish_activity()
 check(life.phase=="complete" and nb.data().people.mimi.xp==1,"shared-activity retry awards the bounded friendship benefit once")
 check(home.rules.data.life.rewards==["baking"] and home.rules.data.coins==previous.coins+10,"retry saves the final story reward and first-chat keepsake exactly once")
 life.finish_activity();check(nb.data().people.mimi.xp==1,"completed activity cannot be claimed again")
 home.close();check(life.active_kind.is_empty(),"closing recovers the activity controller safely")
 for npc in nb.actors.values(): npc.invite()
 await create_timer(14).timeout
 for npc in nb.actors.values():
  check(life.try_relax(npc),npc.person+" reserves a distinct bench place")
 for i in range(1500):
  if nb.actors.values().all(func(npc): return npc.seated_requested): break
  await frames(1)
 await create_timer(0.8).timeout
 for npc in nb.actors.values():
  check(npc.seated_requested and npc.mode==npc.Mode.VISITING,npc.person+" walks to the bench before actually sitting")
  await frames(15)
  check((npc.position+npc.avatar.position).distance_to(npc.seat_point)<0.08,npc.person+" seated hips match the assigned physical bench location")
 var query:=PhysicsRayQueryParameters3D.create(Vector3(14.25,1,-2.9),Vector3(14.25,1,-3.35),3,[game.player.get_rid()])
 check(game.player.get_world_3d().direct_space_state.intersect_ray(query).is_empty(),"seated collision follows the bench occupant and leaves the garden walkway clear")
 check(nb.actors.mimi.seat_point.distance_to(nb.actors.noah.seat_point)>1.2,"two seated visitors never share a bench slot")
 nb.actors.mimi.talk();await create_timer(0.75).timeout
 check(not nb.actors.mimi.seated_requested and nb.actors.mimi.avatar.position.length()<0.01,"interrupted seated visitor stands and recovers before conversation")
 check(not life.reservations.has("bench.mimi"),"standing releases the seat reservation")
 nb.actors.noah.end_talk(true);await create_timer(0.8).timeout
 check(not nb.actors.noah.seated_requested and nb.actors.noah.avatar.position.length()<0.01,"departure finishes the standing transition without retaining a seated offset")
 game.player.position=Vector3(9.4,0,3);nb.actors.mimi.position=Vector3(10,0,3);nb.actors.mimi.mode=nb.actors.mimi.Mode.WANDERING;nb.actors.mimi.route.assign([Vector3(12,0,3)])
 await create_timer(0.6).timeout
 check(nb.actors.mimi.position.x>10.3,"visitor can walk away from a nearby player instead of deadlocking the corridor")
 game.player.position=Vector3(11.1,0,3);await create_timer(0.5).timeout
 check(nb.actors.mimi.position.x<10.65 and nb.actors.mimi.position.distance_to(game.player.position)>0.5,"visitor still yields before moving toward the player")
 game.player.position=Vector3(0,0,1.8)
 for size in [Vector2i(1280,720),Vector2i(1920,1080)]:
  root.size=size
  for section in ["friends","keepsakes","discoveries"]:
   nb.journal(section);await inside(section+" journal page fits "+str(size))
  nb.journal("keepsakes",1);await inside("future keepsakes page fits "+str(size))
  var scroll: ScrollContainer=home.panel.panel.find_children("*","ScrollContainer",true,false)[0]
  check(scroll.vertical_scroll_mode==ScrollContainer.SCROLL_MODE_DISABLED and scroll.scroll_vertical==0,"journal headings cannot be sliced by scrolling at "+str(size))
  for arc in L.ARCS:
   life.open_stories("",arc);await inside("complete story chapter card fits "+str(size)+" "+arc)
  life.open_activities("mimi");await inside("shared activities picker fits "+str(size))
  home.rules.data.life.last_summary={"day":1,"earned":20,"moments":["A warm meal","A little care","A shared story"],"friends":{"mimi":4,"noah":4},"garden":3,"stories":["baking"]}
  life.summary();await inside("end of day summary fits "+str(size))
 home.close()
 game.player.position=Vector3(10,0,2.2);nb.actors.mimi.position=Vector3(10.8,0,2.2);nb.actors.mimi.mode=nb.actors.mimi.Mode.WAITING
 var settled: Dictionary=home.rules.data.duplicate(true)
 life.begin_activity("tea","mimi");await frames(15)
 check(game.player.social_owned and nb.actors.mimi.activity_owned,"shared approach owns both animation controllers")
 home.close();await frames(30)
 check(not game.player.social_owned and not nb.actors.mimi.activity_owned and life.active_kind.is_empty(),"Esc-equivalent close interrupts approach and restores both controls")
 check(home.rules.data==settled,"interrupted approach cannot change friendship, story, inventory or currency")
 home.rules.data.life.arcs.warming=3
 for npc in nb.actors.values(): npc.mode=npc.Mode.AWAY
 life.begin_activity("gathering","mimi")
 check(life.active_kind.is_empty() and game.active,"ringing an unattended gathering bell safely waits in the playable world")
 check(nb.actors.values().all(func(npc): return npc.mode==npc.Mode.ARRIVING),"the bell invites both absent guests through actual arrival states")
 var count: int=preload("res://scripts/forms.gd").materials.size()
 for i in range(30): life.refresh();nb.world.apply(nb.data(),home.rules.data)
 check(preload("res://scripts/forms.gd").materials.size()==count,"settled story and garden refreshes do not allocate new materials")
 check(game.audio.players.has("sit") and game.audio.players.has("day_end") and game.audio.players.has("story"),"new local audio is loaded through existing settings-aware players")
 home.close();game.audio.stop_all()
 print("COZY LIFE SESSION: ",checks-failures,"/",checks);quit(1 if failures else 0)
