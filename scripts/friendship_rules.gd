extends RefCounted
const PEOPLE={
 "mimi":{"name":"Mimi","preference":"Baking, berry colors and shared little celebrations","lines":["I followed the smell of something lovely. Is your kitchen open?","A cupcake is really just a tiny party with frosting.","Your garden has room for a picnic blanket. Just saying!","I practice my best pancake flip with an empty pan. Much safer.","I brought a story, but forgot the ending. Let's make a happy one.","A good recipe gets even better when someone asks for seconds."],"success":"You made this for me? This is officially my favorite kind of visit!"},
 "noah":{"name":"Noah","preference":"Gardening, lavender and quiet thoughtful moments","lines":["It's peaceful here. May I stay a little while?","The little leaves lean toward the light. I like noticing that.","Carrots are rather brave. All that growing happens out of sight.","Lavender makes a small corner feel like a whole garden.","I don't always know what to say. Sitting together is nice too.","A seed is a very patient sort of promise."],"success":"You remembered. Thank you. It feels good to be understood."}}
const REQUESTS={
 "mimi.pancakes":{"npc":"mimi","name":"A cloud-soft welcome","text":"Plate Cloud Pancakes after accepting, then share them with Mimi.","recipe":"cloud_pancakes","produce":"","reward":6},
 "mimi.cupcakes":{"npc":"mimi","name":"A tiny baking party","text":"Plate Berry Cupcakes after accepting and bring Mimi a fresh batch.","recipe":"berry_cupcakes","produce":"","reward":6},
 "mimi.good":{"npc":"mimi","name":"A recipe worth sharing","text":"Plate any Good or Perfect meal after accepting.","recipe":"good","produce":"","reward":7},
 "noah.carrots":{"npc":"noah","name":"Something grown with care","text":"Harvest a carrot and give Noah one from your basket.","recipe":"","produce":"carrot","reward":6},
 "noah.lavender":{"npc":"noah","name":"A lavender thank-you","text":"Give Noah one harvested lavender sprig.","recipe":"","produce":"lavender","reward":6},
 "noah.help":{"npc":"noah","name":"Three small kindnesses","text":"Water three planting spots after accepting. Replant empty spots with free seeds.","recipe":"","produce":"","reward":7}}
static func defaults() -> Dictionary: return {"xp":0,"talk_day":0,"share_day":0,"claim_day":0,"request":"","request_ready":false,"request_water":[],"requests_done":0,"met":false,"days":[]}
static func sanitize(value: Variant) -> Dictionary:
 var p:=defaults()
 if not value is Dictionary: return p
 for key in ["xp","talk_day","share_day","claim_day","requests_done"]:
  if value.get(key) is int: p[key]=clampi(value[key],0,1000000)
 p.xp=mini(p.xp,12)
 for key in ["met","request_ready"]:
  if value.get(key) is bool: p[key]=value[key]
 if value.get("request","") in REQUESTS: p.request=value.request
 if value.get("request_water") is Array:
  for id in value.request_water:
   if id is int and id in [0,1,2] and not id in p.request_water: p.request_water.append(id)
 if value.get("days") is Array:
  for day in value.days:
   if day is int and day>0 and day<=1000000 and not day in p.days: p.days.append(day)
  p.days=p.days.slice(-64)
 return p
static func level(xp: int,days: int=0) -> int: return 3 if xp>=10 and days>=7 else (2 if xp>=4 else 1)
static func title(xp: int,days: int=0) -> String: return ["Acquaintance","Friend","Close Friend"][level(xp,days)-1]
static func shared_day(p: Dictionary,day: int) -> void:
 if not day in p.days: p.days.append(day)
 p.days=p.days.slice(-64)
static func available_request(id: String,p: Dictionary) -> String:
 return (["mimi.pancakes","mimi.cupcakes","mimi.good"] if id=="mimi" else ["noah.carrots","noah.lavender","noah.help"])[p.requests_done%3]
static func dialogue(id: String,p: Dictionary,day: int,period: int,has_food: bool) -> String:
 var text: String=PEOPLE[id].lines[(day-1+level(p.xp,p.days.size())-1)%6]
 if level(p.xp,p.days.size())==2: text+=("\nMy friend's kitchen! I knew today would be a good day." if id=="mimi" else "\nI feel at home here with you.")
 if level(p.xp,p.days.size())==3: text+=("\nI saved my best story for you. Some things are for close friends." if id=="mimi" else "\nWith you, even the quiet feels like company.")
 if not p.request.is_empty(): text+="\n"+("I think you have just what I asked for." if p.request_ready else "No rush with my request. Tomorrow is fine too.")
 elif has_food: text+="\n"+("Something delicious happened in your kitchen!" if id=="mimi" else "That looks carefully made.")
 elif period>=2: text+="\n"+("The fairy lights make everything a celebration." if id=="mimi" else "Evening suits this garden.")
 return text
