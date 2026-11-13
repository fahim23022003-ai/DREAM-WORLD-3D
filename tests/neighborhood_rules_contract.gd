extends SceneTree
const H=preload("res://scripts/home_rules.gd")
const N=preload("res://scripts/neighborhood_rules.gd")
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
 checks+=1
 if ok: print("PASS ",message)
 else: failures+=1;push_error("FAIL "+message)
func do_action(h: RefCounted,kind: String,info: Dictionary={}) -> Dictionary:
 var out: Dictionary=N.action(h.data,kind,info)
 if out.ok:
  for match_id in out.matches: h.event(match_id,"%d:test:%s:%s" % [h.data.day,match_id,info.get("npc",info.get("plot","event"))])
 return out
func _initialize() -> void:
 var h:=H.new()
 check(h.catalog().size()==12 and H.CATALOG.size()==6,"six new purchasable finishes extend stable base catalog")
 check(h.goals()==H.WEEK[0] and h.data.neighborhood.daily_goals.is_empty(),"current existing goals are retained before neighborhood discovery")
 for i in range(3):
  var crop: String=N.G.CROPS.keys()[i]
  check(do_action(h,"plant",{"plot":i,"crop":crop}).ok,"free seed plants distinct "+crop)
  check(not do_action(h,"plant",{"plot":i,"crop":crop}).ok,"occupied spot rejects duplicate seed")
  check(h.data.neighborhood.plots[i].stage==1,"seed is a distinct stable visual stage")
  check(do_action(h,"garden_water",{"plot":i}).ok and h.data.neighborhood.plots[i].stage==2,"watered seed becomes sprout")
  check(not do_action(h,"garden_water",{"plot":i}).ok,"repeated watering cannot grant anything")
 h.advance_time()
 check(h.data.neighborhood.plots.all(func(p): return p.stage==3),"meaningful time event grows visible plants")
 h.sleep_next_day()
 check(h.data.neighborhood.plots.all(func(p): return p.stage==4),"sleep readies watered plants without real-world waiting")
 check(h.goals().size()==3 and "harvest" in h.goals(),"ready crops make a legitimate harvest daily objective")
 for i in range(3):
  check(do_action(h,"harvest",{"plot":i}).ok,"ready crop harvests")
  var coins: int=h.data.coins
  check(not do_action(h,"harvest",{"plot":i}).ok and h.data.coins==coins,"same plot cannot harvest twice")
 check(h.data.neighborhood.produce.values()==[1,1,1] and h.data.neighborhood.discoveries.size()==3,"bounded inventory stores all three discoveries")
 check(do_action(h,"plant",{"plot":0,"crop":"carrot"}).ok,"harvested spot can replant with free seeds")
 h.sleep_next_day();h.sleep_next_day()
 check(h.data.neighborhood.plots[0].stage==1,"unwatered plant waits safely instead of dying")
 for id in ["mimi","noah"]:
  check(N.F.PEOPLE[id].lines.size()>=6,"six unique authored dialogue lines for "+id)
  check(do_action(h,"chat",{"npc":id,"choice":"garden"}).ok,"real conversation discovers "+id)
  var xp: int=h.data.neighborhood.people[id].xp
  for i in range(9): do_action(h,"chat",{"npc":id,"choice":"baking"})
  check(h.data.neighborhood.people[id].xp==xp,"conversation spam cannot farm friendship")
 check(do_action(h,"accept",{"npc":"mimi"}).ok,"Mimi request accepts")
 var pending: String=h.data.neighborhood.people.mimi.request
 var loaded:=H.new(h.data)
 check(loaded.data.neighborhood.people.mimi.request==pending,"accepted request survives reload")
 check(not do_action(h,"claim",{"npc":"mimi"}).ok,"unmade food cannot complete request")
 h.event("meal","fresh-pancakes",{"recipe":"cloud_pancakes","quality":"Cozy"})
 check(h.data.neighborhood.people.mimi.request_ready,"existing free-supply cooking completes visitor condition")
 check(do_action(h,"claim",{"npc":"mimi"}).ok and N.F.level(h.data.neighborhood.people.mimi.xp,h.data.neighborhood.people.mimi.days.size())>=2,"one legitimate request reaches friendship threshold")
 var coins: int=h.data.coins
 check(not do_action(h,"claim",{"npc":"mimi"}).ok and h.data.coins==coins,"request reward cannot duplicate")
 check(not do_action(h,"accept",{"npc":"mimi"}).ok,"one rewarded request per visitor/day")
 check(do_action(h,"accept",{"npc":"noah"}).ok and do_action(h,"claim",{"npc":"noah"}).ok,"harvested carrot fulfills Noah's first request")
 check(h.data.neighborhood.produce.carrot==0,"produce request consumes exactly one item")
 check("friend" in h.data.neighborhood.achievements and "first_request" in h.data.neighborhood.achievements,"friendship and request achievements earn permanent physical keepsake records")
 # Six events are all reachable and do not immediately repeat.
 var seen: Array=[]
 var e:=N.E.defaults()
 for day in range(1,19):
  if day>1: e=N.E.choose(e,day)
  check(not e.id in seen.slice(-3),"event recent-history cooldown at day "+str(day))
  seen.append(e.id)
 check(N.E.DEFINITIONS.keys().all(func(id): return id in seen),"all six event activities enter the schedule")
 for id in ["bloom","moon","lost"]:
  h.data.neighborhood.event={"id":id,"day":h.data.day,"done":false,"history":[id]};h.data.period=3
  check(do_action(h,"event",{"id":id}).ok,"legitimate world event action completes "+id)
  coins=h.data.coins
  check(not do_action(h,"event",{"id":id}).ok and h.data.coins==coins,"event receipt prevents duplicate "+id)
 h.data.neighborhood.event={"id":"friendship","day":h.data.day,"done":false,"history":["friendship"]}
 check(do_action(h,"moment",{"npc":"noah"}).ok,"friendship afternoon uses a real social action")
 h.data.neighborhood.event={"id":"baking","day":h.data.day,"done":false,"history":["baking"]}
 h.event("meal","event-cupcake",{"recipe":"berry_cupcakes","quality":"Good"})
 check(h.data.neighborhood.event.done,"baking event observes actual recipe completion")
 for day in range(7):
  h.sleep_next_day()
  do_action(h,"chat",{"npc":"mimi"})
 check(N.F.level(h.data.neighborhood.people.mimi.xp,h.data.neighborhood.people.mimi.days.size())==3 and h.data.neighborhood.people.mimi.xp<=12,"friendship advances over days and has a firm cap")
 check(N.F.level(12,1)==2 and N.F.level(12,7)==3,"Close Friend needs seven meaningful social days rather than conversation spam")
 var clean:=H.new(h.data)
 check(clean.data==h.data,"garden social and event state round trips safely")
 var n: Dictionary=clean.data.neighborhood
 n.produce.carrot=9;n.plots[0]={"crop":"carrot","stage":4,"water_day":1,"cycle":5}
 check(not do_action(clean,"harvest",{"plot":0}).ok and n.plots[0].stage==4,"full basket leaves ready crop safely in its bed")
 var before: int=n.produce.strawberry
 clean.event("meal","optional-bonus",{"recipe":"berry_cupcakes","quality":"Cozy","garden_bonus":true})
 check(n.produce.strawberry==before-1,"optional cooking consumes produce only when requested")
 var malformed:=N.sanitize({"plots":[{"crop":"bad","stage":999}],"produce":{"carrot":-10},"people":{"mimi":{"xp":9000}},"event":{"id":"bad"}},1)
 check(malformed.plots.size()==3 and malformed.plots[0].stage==0 and malformed.produce.carrot==0 and malformed.people.mimi.xp==12,"malformed neighborhood values are bounded and safe")
 var selection:=H.new();selection.data.neighborhood.engaged=true
 var valid:=true
 var previous: Array=[]
 for day in range(30):
  selection.sleep_next_day()
  var goals: Array=selection.goals()
  valid=valid and goals.size()==3 and goals!=previous and goals.all(func(id): return id in H.goal_definitions())
  previous=goals
 check(valid,"thirty days retain three valid objectives without immediate repeated combinations")
 for request_id in N.F.REQUESTS:
  var sample:=H.new()
  var definition: Dictionary=N.F.REQUESTS[request_id]
  var person: String=definition.npc
  sample.data.neighborhood.people[person].requests_done=(["mimi.pancakes","mimi.cupcakes","mimi.good"] if person=="mimi" else ["noah.carrots","noah.lavender","noah.help"]).find(request_id)
  do_action(sample,"accept",{"npc":person})
  if person=="mimi":
   var recipe: String="cloud_pancakes" if definition.recipe=="good" else definition.recipe
   if definition.recipe=="good":
    sample.event("meal","cozy-first",{"recipe":recipe,"quality":"Cozy"})
    check(not do_action(sample,"claim",{"npc":person}).ok,"Good-quality request rejects a Cozy meal")
   sample.event("meal","valid-result",{"recipe":recipe,"quality":"Good"})
  elif request_id=="noah.help":
   for spot in range(3):
    do_action(sample,"plant",{"plot":spot,"crop":"carrot"});do_action(sample,"garden_water",{"plot":spot})
  else:
   do_action(sample,"plant",{"plot":0,"crop":definition.produce});do_action(sample,"garden_water",{"plot":0});sample.sleep_next_day();do_action(sample,"harvest",{"plot":0})
  check(do_action(sample,"claim",{"npc":person}).ok,"request has a legitimate achievable completion: "+request_id)
 var decline:=H.new();do_action(decline,"accept",{"npc":"mimi"})
 do_action(decline,"decline",{"npc":"mimi"})
 check(decline.data.neighborhood.people.mimi.request.is_empty() and do_action(decline,"accept",{"npc":"mimi"}).ok,"declining a request never makes future content missable")
 print("NEIGHBORHOOD RULES: ",checks-failures,"/",checks)
 quit(0 if failures==0 else 1)
