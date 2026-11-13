extends RefCounted
const G=preload("res://scripts/garden_rules.gd")
const F=preload("res://scripts/friendship_rules.gd")
const E=preload("res://scripts/neighborhood_events.gd")
const GOALS={"plant":"Plant a free garden seed","garden_water":"Water a growing crop","harvest":"Harvest a ready crop","chat":"Talk with a visitor","request":"Complete a visitor request","friendship":"Share food, a gift, or a quiet moment","special":"Enjoy today's special event"}
const CATALOG={
 "garden.arch":{"name":"Flowering welcome arch","slot":"arch","cost":18,"color":"dca8c1","room":"Garden"},
 "garden.lantern":{"name":"Starlight garden lantern","slot":"lantern","cost":14,"color":"f1d49b","room":"Garden"},
 "garden.planter":{"name":"Lavender planter finish","slot":"planter","cost":12,"color":"b4a0cf","room":"Garden"},
 "garden.bench":{"name":"Rosewood garden bench","slot":"bench","cost":16,"color":"bd9390","room":"Garden"},
 "garden.picnic":{"name":"Strawberry picnic cloth","slot":"picnic","cost":10,"color":"e6a6b9","room":"Garden"},
 "social.frame":{"name":"Friends together frame","slot":"photo","cost":12,"color":"b8ced9","room":"Garden"}}
const CONDITIONS={"first_harvest":"Harvest any garden crop","first_chat":"Choose a friendly conversation reply","first_request":"Complete a visitor request","friend":"Reach 4 friendship XP","close_friend":"10 XP and 7 distinct shared in-game days","garden_event":"Complete Garden Bloom or Moonlit Garden"}
const REWARDS={"first_harvest":"Wind chime","first_chat":"Welcome picture","first_request":"Picnic tea set","friend":"Friendship portrait","close_friend":"Companion figurine","garden_event":"Moonstone keepsake"}
const ACHIEVEMENTS={"first_harvest":"A seed kept its promise","first_chat":"A friendly hello","first_request":"Made with someone in mind","friend":"Someone to call a friend","close_friend":"A home away from home","garden_event":"Under a kinder sky"}
static func defaults() -> Dictionary:
 return {"engaged":false,"plots":[G.plot(),G.plot(),G.plot()],"produce":{"strawberry":0,"carrot":0,"lavender":0},"people":{"mimi":F.defaults(),"noah":F.defaults()},"event":E.defaults(),"achievements":[],"discoveries":[],"harvested":false,"garden_event":false,"daily_goals":[],"recent_goals":[],"last_meal_day":0,"last_recipe":"","bonus_enabled":false}
static func sanitize(raw: Variant,day: int) -> Dictionary:
 var n:=defaults()
 if not raw is Dictionary: return n
 for key in raw:
  if not key in n: n[key]=raw[key]
 for key in ["engaged","harvested","garden_event","bonus_enabled"]:
  if raw.get(key) is bool: n[key]=raw[key]
 n.plots=G.sanitize(raw.get("plots"))
 if raw.get("produce") is Dictionary:
  for id in n.produce:
   if raw.produce.get(id) is int: n.produce[id]=clampi(raw.produce[id],0,9)
 if raw.get("people") is Dictionary:
  for id in n.people:
   n.people[id]=F.sanitize(raw.people.get(id))
   n.people[id].days=n.people[id].days.filter(func(d): return d<=day)
 n.event=E.sanitize(raw.get("event"),day)
 if raw.get("last_meal_day") is int: n.last_meal_day=clampi(raw.last_meal_day,0,day)
 if raw.get("last_recipe") in ["cloud_pancakes","berry_cupcakes","starry_soup"]: n.last_recipe=raw.last_recipe
 for key in ["achievements","discoveries","daily_goals","recent_goals"]:
  if not raw.get(key) is Array: continue
  var allowed: Array=ACHIEVEMENTS.keys() if key=="achievements" else (G.CROPS.keys() if key=="discoveries" else ["meal","water","bed","lamp","curtains","rest","pancakes","cupcakes","soup","good","pairs","evening","explore"]+GOALS.keys())
  n[key]=[]
  for id in raw[key].slice(0,24):
   if id is String and id in allowed and not id in n[key]: n[key].append(id)
 return n
static func achieve(home: Dictionary) -> void:
 var n: Dictionary=home.neighborhood
 var people: Dictionary=n.people
 var conditions:=[n.harvested,people.mimi.met or people.noah.met,people.mimi.requests_done+people.noah.requests_done>0,maxi(people.mimi.xp,people.noah.xp)>=4,people.values().any(func(p): return F.level(p.xp,p.days.size())==3),n.garden_event]
 for i in range(conditions.size()):
  var id: String=ACHIEVEMENTS.keys()[i]
  if conditions[i] and not id in n.achievements:
   n.achievements.append(id)
   home.coins+=2
static func complete_event(home: Dictionary,id: String) -> bool:
 var n: Dictionary=home.neighborhood
 if n.event.id!=id or n.event.done: return false
 n.event.done=true
 home.coins+=E.DEFINITIONS[id].reward
 if id in ["bloom","moon"]: n.garden_event=true
 achieve(home)
 return true
static func observe_meal(home: Dictionary,recipe: String,quality: String,bonus: bool) -> Array:
 var n: Dictionary=home.neighborhood
 n.last_meal_day=home.day;n.last_recipe=recipe
 for id in n.people:
  var p: Dictionary=n.people[id]
  if not p.request.is_empty():
   var wanted: String=F.REQUESTS[p.request].recipe
   if wanted==recipe or (wanted=="good" and quality in ["Good","Perfect"]): p.request_ready=true
 if bonus and home.meal_counts.get(recipe,0)<=2:
  for id in G.CROPS:
   if G.CROPS[id].recipe==recipe and n.produce[id]>0:
    n.produce[id]-=1;home.coins+=2;break
 var matches: Array=[]
 if recipe=="berry_cupcakes" and complete_event(home,"baking"): matches.append("special")
 return matches
static func new_day(home: Dictionary) -> void:
 var n: Dictionary=home.neighborhood
 G.next_day(n.plots,home.day)
 n.event=E.choose(n.event,home.day)
 if not n.engaged: return
 var base: Array=["meal","bed","water","lamp","curtains","rest"]
 var garden: Array=["plant","garden_water"]
 if n.plots.any(func(p): return p.stage==4): garden.append("harvest")
 var social: Array=["chat","friendship","special"]
 # Pending requests remain optional; never force a harvest request with an empty basket.
 if n.people.values().any(func(p): return p.request_ready): social.append("request")
 var chosen: Array=[]
 for pool in [base,garden,social]:
  var choices: Array=pool.filter(func(id): return not id in n.recent_goals)
  if choices.is_empty(): choices=pool
  chosen.append(choices[(home.day+chosen.size())%choices.size()])
 # Full mature gardens can always be harvested and replanted, but a full basket cannot harvest.
 if chosen[1] in ["plant","garden_water"] and n.plots.all(func(p): return p.stage==4):
  chosen[1]="harvest" if n.produce.values().any(func(v): return v<9) else "garden_water"
  # Full baskets can be shared with Noah, or used as optional cooking toppings before replanting.
 n.daily_goals=chosen
 n.recent_goals=chosen.duplicate()
static func action(home: Dictionary,kind: String,info: Dictionary={}) -> Dictionary:
 var n: Dictionary=home.neighborhood
 var out:={"ok":false,"matches":[],"message":"Try a different moment.","reward":false}
 var before: int=home.coins
 match kind:
  "plant","garden_water","harvest":
   var i: int=info.get("plot",-1)
   if not i in [0,1,2]: return out
   var p: Dictionary=n.plots[i]
   if kind=="plant":
    if not G.plant(p,info.get("crop","")): return out
    out.message="A little promise planted. Seeds are always free."
   elif kind=="garden_water":
    if not G.water(p,home.day): out.message="Already watered today, or ready to harvest.";return out
    var noah: Dictionary=n.people.noah
    if noah.request=="noah.help" and not i in noah.request_water:
     noah.request_water.append(i);noah.request_ready=noah.request_water.size()==3
    out.message="A good drink. Cook or rest to see it grow; sleep for harvest."
   else:
    var crop: String=G.harvest(p,n.produce)
    if crop.is_empty(): out.message="Not ready, or your basket is full (9 per crop). Share or cook with produce first.";return out
    n.harvested=true
    if not crop in n.discoveries: n.discoveries.append(crop)
    out.message="Harvested "+G.CROPS[crop].name+" · basket +1"
   n.engaged=true
   out.matches.append(kind)
  "chat","share","moment","accept","decline","claim":
   var id: String=info.get("npc","")
   if not id in n.people: return out
   var p: Dictionary=n.people[id]
   if kind=="chat":
    p.met=true;n.engaged=true
    out.message=F.dialogue(id,p,home.day,home.period,n.last_meal_day==home.day)
    if p.talk_day!=home.day:
     var extra: bool=(id=="mimi" and info.get("choice")=="baking" and n.last_meal_day==home.day) or (id=="noah" and info.get("choice")=="garden" and n.plots.any(func(plot): return plot.stage>0))
     p.xp=mini(12,p.xp+(2 if extra else 1));p.talk_day=home.day;F.shared_day(p,home.day)
    else: out.message+="\nWe've already shared today's friendship chat. Come sit anyway."
    out.matches.append("chat")
   elif kind=="share":
    if n.last_meal_day!=home.day or p.share_day==home.day: out.message="Plate a fresh meal today to share. One friendship bonus per visitor/day.";return out
    p.share_day=home.day;p.xp=mini(12,p.xp+1);F.shared_day(p,home.day)
    out.message="A warm plate, and a warmer welcome. Today’s friendship moment is remembered."
    out.matches.append("friendship")
   elif kind=="moment":
    if home.period<1 or n.event.id!="friendship" or n.event.done: out.message="A friendship afternoon needs a little later light.";return out
    p.xp=mini(12,p.xp+2);F.shared_day(p,home.day)
    complete_event(home,"friendship")
    out.matches=["friendship","special"]
    out.message="An easy silence. A shared laugh. A day worth remembering."
   elif kind=="accept":
    if not p.request.is_empty() or p.claim_day==home.day: out.message="One request per friend per day. Your current promise stays safe.";return out
    p.request=F.available_request(id,p);p.request_ready=false;p.request_water=[]
    out.message="Request accepted. No deadline; your promise survives sleep and Continue."
   elif kind=="decline":
    p.request="";p.request_ready=false;p.request_water=[]
    out.message="Of course. Another time is always fine."
   else:
    if p.request.is_empty() or p.claim_day==home.day: return out
    var req: Dictionary=F.REQUESTS[p.request]
    if not req.produce.is_empty():
     if n.produce[req.produce]<1: out.message="Harvest one "+req.produce+" first.";return out
     n.produce[req.produce]-=1
    elif not p.request_ready: out.message=req.text;return out
    home.coins+=req.reward;p.xp=mini(12,p.xp+3);p.requests_done+=1;p.claim_day=home.day;F.shared_day(p,home.day)
    p.request="";p.request_ready=false;p.request_water=[]
    out.message=F.PEOPLE[id].success+" +3 friendship (up to 12). Shared day remembered."
    out.matches=["request","friendship"]
    if complete_event(home,"surprise"): out.matches.append("special")
  "event":
   var id: String=info.get("id","")
   if id=="moon" and home.period<2: out.message="Return in Evening or Night. The patio bench advances the light.";return out
   if not id in ["bloom","moon","lost"] or not complete_event(home,id): return out
   out.matches=["special"]
   out.message="A little moment worth remembering. Event reward saved."
  _:
   return out
 out.ok=true
 achieve(home)
 out.reward=home.coins>before
 return out
