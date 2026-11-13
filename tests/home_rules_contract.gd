extends SceneTree
const H=preload("res://scripts/home_rules.gd")
const C=preload("res://scripts/cooking_rules.gd")
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
 checks+=1
 if ok: print("PASS ",message)
 else: failures+=1; push_error("FAIL "+message)
func _initialize() -> void:
 var h:=H.new()
 check(h.data.day==1 and h.data.coins==0 and h.goals()==["meal","water","bed"],"fresh day has achievable introductory goals")
 check(H.GOALS.size()>=10 and H.CATALOG.size()==6 and H.RECIPES.size()==3,"actual content has thirteen goals, six finishes and three recipes")
 for id in H.RECIPES:
  for outcome in ["Perfect","Good","Cozy"]:
   var c:=C.new()
   check(c.begin(id,"meal-token"),"recipe begins: "+id)
   while c.stage!="ready":
    c.phase=c.target+({"Perfect":0.0,"Good":0.16,"Cozy":0.27}[outcome])
    var choices: Array=H.RECIPES[id].prep_inputs
    c.hit(choices[c.hits] if c.stage=="ingredients" and not choices.is_empty() else "")
   check(c.quality()==outcome and c.errors.size()==3+H.RECIPES[id].beats,"input determines "+outcome+" for "+id)
 check(h.event("meal","invalid",{"recipe":"invented","quality":"Perfect"})==0 and h.data.coins==0,"invalid recipe cannot complete an economic objective")
 var n:=h.event("meal","1:meal:0",{"recipe":"cloud_pancakes","quality":"Good"})
 check(n==9 and h.data.period==1,"meal earns six plus real goal and advances morning")
 check(h.event("meal","1:meal:0",{"recipe":"cloud_pancakes","quality":"Good"})==0 and h.data.coins==9,"duplicate result cannot pay twice")
 h.event("water","1:water")
 h.event("bed","1:bed")
 check(h.data.coins==21 and h.data.set_paid and h.data.completed_days==[1],"three real goals pay once plus daily set")
 var old: int=h.data.coins
 h.event("bed","new-bed-token")
 check(h.data.coins==old,"new repeated action token cannot farm an already paid goal")
 check(not h.purchase("invalid") and not h.equip("bed.lavender"),"unknown purchase and unowned equipment rejected")
 check(h.purchase("bed.strawberry") and h.data.coins==9 and h.equip("bed.strawberry"),"purchase deducts cost and owns equipable finish")
 check(not h.purchase("bed.strawberry") and h.data.coins==9,"owned finish never costs twice")
 check(not h.purchase("kitchen.rosewood") and h.data.coins==9,"unaffordable purchase leaves balance intact")
 h.event("meal","1:meal:1",{"recipe":"cloud_pancakes","quality":"Cozy"})
 old=h.data.coins
 h.event("meal","1:meal:2",{"recipe":"cloud_pancakes","quality":"Perfect"})
 check(h.data.coins==old,"third same-recipe meal earns no farmable coins")
 var owned: Array=h.data.owned.duplicate()
 h.sleep_next_day()
 check(h.data.day==2 and h.data.period==0 and h.data.goals_done.is_empty() and not h.data.set_paid and h.data.owned==owned,"sleep refreshes daily fields and keeps purchased ownership")
 # Complete real event combinations across seven in-game days.
 var week:=H.new()
 for day in range(1,9):
  for id in week.goals():
   var info: Dictionary={}
   var kind: String=id
   if id in ["meal","pancakes","cupcakes","soup","good","evening"]:
    kind="meal"
    info={"recipe":{"cupcakes":"berry_cupcakes","soup":"starry_soup"}.get(id,"cloud_pancakes"),"quality":"Good"}
    if id=="evening": week.data.period=2
   week.event(kind,"%d:%s" % [day,id],info)
  check(week.data.set_paid and day in week.data.completed_days,"day %d completes through matching actual event types" % day)
  if day==3: check(week.data.milestones==["three_days"],"third completed day grants one permanent keepsake")
  if day==7: check(week.data.milestones==["three_days","seven_days"],"seventh completed day grants commemorative frame")
  if day<8: week.sleep_next_day()
 check(week.data.day==8 and week.goals()==H.WEEK[0],"day eight continues goals and recipes")
 var late:=H.new()
 late.data.day=5
 late.data.period=3
 late.event("meal","night-meal",{"recipe":"starry_soup","quality":"Cozy"})
 check("evening" in late.data.goals_done,"after-sunset goal remains possible at night")
 week.data["future_life_field"]={"retained":42}
 var restored:=H.new(week.data)
 check(restored.data==week.data,"all rule state survives sanitized reload")
 var bad:=H.sanitize({"day":-9,"coins":"rich","owned":["invalid","bed.strawberry"],"equipped":{"lamp":"bed.strawberry"},"goals_done":[3],"period":99})
 check(bad.day==1 and bad.coins==0 and bad.equipped.lamp=="starter" and bad.period==3,"malformed progression and cross-slot equipment default safely")
 print("HOME RULES: ",checks-failures,"/",checks)
 quit(0 if failures==0 else 1)
