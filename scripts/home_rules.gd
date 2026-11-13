extends RefCounted
## Persistent life-simulation rules. Presentation and filesystem writes live elsewhere.
const RECIPES := {
 "cloud_pancakes":{"name":"Cloud Pancakes","ingredients":"Flour · milk · eggs","prep":"Whisk three fluffy folds","cook":"Flip both sides","prep_action":"Whisk","cook_action":"Flip","beats":2,"prep_inputs":[],"cook_steps":["Flip the first side","Flip the golden second side"]},
 "berry_cupcakes":{"name":"Berry Cupcakes","ingredients":"Berries · flour · butter","prep":"Fold berries into three portions","cook":"Rotate, then lift the baking tray","prep_action":"Fold berries","cook_action":"Turn tray","beats":2,"prep_inputs":["Butter","Flour","Berries"],"cook_steps":["Rotate the baking tray","Lift the baked cupcakes"]},
 "starry_soup":{"name":"Starry Vegetable Soup","ingredients":"Carrot · greens · star pasta","prep":"Dice three handfuls of vegetables","cook":"Stir, season, then finish","prep_action":"Dice","cook_action":"Stir / season","beats":3,"prep_inputs":["Carrot","Greens","Star pasta"],"cook_steps":["Stir the vegetables","Season the broth","Finish the star pasta"]}}
const CATALOG := {
 "bed.strawberry":{"name":"Strawberry quilt","slot":"bedding","cost":12,"color":"e9a1b5","room":"Bedroom"},
 "bed.lavender":{"name":"Lavender quilt","slot":"bedding","cost":16,"color":"b6a0d3","room":"Bedroom"},
 "lamp.moon":{"name":"Moonlight shade","slot":"lamp","cost":14,"color":"b6cced","room":"Bedroom"},
 "kitchen.mint":{"name":"Mint cabinetry","slot":"cabinets","cost":12,"color":"a2c8b7","room":"Kitchen"},
 "kitchen.rosewood":{"name":"Rosewood cabinetry","slot":"cabinets","cost":18,"color":"be8e8c","room":"Kitchen"},
 "ceramics.berry":{"name":"Berry ceramic set","slot":"ceramics","cost":10,"color":"c29ec5","room":"Kitchen"}}
const GOALS := {
 "meal":"Plate any recipe", "pancakes":"Plate Cloud Pancakes", "cupcakes":"Plate Berry Cupcakes", "soup":"Plate Starry Vegetable Soup",
 "good":"Plate a Good or Perfect meal", "water":"Water the living-room plant", "lamp":"Turn on the living-room lamp", "curtains":"Adjust the living-room curtains",
 "pairs":"Finish a Cozy Pairs round", "rest":"Rest on the bedroom bench", "bed":"Make the bed", "evening":"Plate a meal in evening or at night", "explore":"Visit the kitchen fridge"}
const WEEK := [["meal","water","bed"],["pancakes","lamp","rest"],["cupcakes","curtains","good"],["soup","pairs","explore"],["evening","bed","water"],["meal","lamp","rest"],["pancakes","good","pairs"]]
const PERIODS := ["Morning","Afternoon","Evening","Night"]
var data: Dictionary
static func defaults() -> Dictionary:
 return {"day":1,"period":0,"coins":0,"owned":[],"equipped":{"bedding":"starter","lamp":"starter","cabinets":"starter","ceramics":"starter"},"goals_done":[],"set_paid":false,"completed_days":[],"milestones":[],"receipts":[],"cook_serial":0,"meal_counts":{"cloud_pancakes":0,"berry_cupcakes":0,"starry_soup":0},"bed_made":false,"bedside_on":true,"introduced":false}
static func sanitize(value: Variant) -> Dictionary:
 var clean:=defaults()
 if not value is Dictionary: return clean
 # Additive future fields survive round trips; current fields are validated below.
 for key in value:
  if not key in clean: clean[key]=value[key]
 for key in ["day","period","coins","cook_serial"]:
  var v: Variant=value.get(key,clean[key])
  if v is int and v>=0: clean[key]=mini(v,1000000)
 clean.day=maxi(clean.day,1)
 clean.period=clampi(clean.period,0,3)
 for key in ["set_paid","bed_made","bedside_on","introduced"]:
  if value.get(key) is bool: clean[key]=value[key]
 for key in ["owned","goals_done","milestones","receipts","completed_days"]:
  if not value.get(key) is Array: continue
  for id in value[key].slice(0,2048):
   var valid: bool=(id is String and ((key=="owned" and CATALOG.has(id)) or (key=="goals_done" and GOALS.has(id)) or (key=="milestones" and id in ["three_days","seven_days"]) or (key=="receipts" and id.length()<100))) or (key=="completed_days" and id is int and id>0 and id<=clean.day)
   if valid and not id in clean[key]: clean[key].append(id)
 if value.get("equipped") is Dictionary:
  for slot in clean.equipped:
   var id: Variant=value.equipped.get(slot,"starter")
   if id is String and id in clean.owned and CATALOG[id].slot==slot: clean.equipped[slot]=id
 if value.get("meal_counts") is Dictionary:
  for id in RECIPES:
   var n: Variant=value.meal_counts.get(id,0)
   if n is int: clean.meal_counts[id]=clampi(n,0,2)
 return clean
func _init(initial: Dictionary = {}) -> void: data=sanitize(initial)
func goals() -> Array: return WEEK[(int(data.day)-1)%WEEK.size()].duplicate()
func period() -> String: return PERIODS[data.period]
func advance_time() -> void: data.period=mini(data.period+1,3)
func event(kind: String, token: String, info: Dictionary = {}) -> int:
 if kind=="meal" and (not info.get("recipe") in RECIPES or not info.get("quality") in ["Cozy","Good","Perfect"]): return 0
 if token in data.receipts: return 0
 data.receipts.append(token)
 var before: int=data.coins
 var matches: Array=[]
 match kind:
  "meal":
   matches=["meal", {"cloud_pancakes":"pancakes","berry_cupcakes":"cupcakes","starry_soup":"soup"}.get(info.get("recipe"),"")]
   if info.get("quality") in ["Good","Perfect"]: matches.append("good")
   if data.period>=2: matches.append("evening")
   var id: String=info.get("recipe","")
   if id in RECIPES:
    var n: int=data.meal_counts.get(id,0)
    # First two meals per recipe/day earn coins; further practice still has quality feedback.
    if n<2: data.coins+=6 if n==0 else 2
    data.meal_counts[id]=mini(n+1,2)
    data.cook_serial+=1
    data.introduced=true
    advance_time()
  "water": matches=["water"]
  "lamp": matches=["lamp"]
  "curtains": matches=["curtains"]
  "pairs": matches=["pairs"]; advance_time()
  "rest": matches=["rest"]; advance_time()
  "bed": matches=["bed"]; data.bed_made=true
  "explore": matches=["explore"]
 for id in goals():
  if id in matches and not id in data.goals_done:
   data.goals_done.append(id)
   data.coins+=3
 if goals().all(func(id): return id in data.goals_done) and not data.set_paid:
  data.set_paid=true
  data.coins+=6
  if not data.day in data.completed_days: data.completed_days.append(data.day)
  for entry in [[3,"three_days"],[7,"seven_days"]]:
   if data.completed_days.size()>=entry[0] and not entry[1] in data.milestones:
    data.milestones.append(entry[1])
    data.coins+=10 if entry[0]==3 else 20
 return data.coins-before
func sleep_next_day() -> void:
 data.day+=1
 data.period=0
 data.goals_done=[]
 data.set_paid=false
 data.receipts=[]
 data.meal_counts={"cloud_pancakes":0,"berry_cupcakes":0,"starry_soup":0}
 data.bed_made=false
func purchase(id: String) -> bool:
 if not CATALOG.has(id) or id in data.owned or data.coins<CATALOG[id].cost: return false
 data.coins-=CATALOG[id].cost
 data.owned.append(id)
 return true
func equip(id: String) -> bool:
 if not id in data.owned or not CATALOG.has(id): return false
 data.equipped[CATALOG[id].slot]=id
 return true
