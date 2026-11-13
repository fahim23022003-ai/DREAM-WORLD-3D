extends RefCounted
## Authored optional stories. Only settled steps/receipts persist; never animation state.
const F=preload("res://scripts/friendship_rules.gd")
const ARCS={
 "baking":{"name":"Mimi's baking surprise","npc":"mimi","steps":["Pick fresh strawberries after making a plan with Mimi","Plate Berry Cupcakes with your fresh inspiration","Share tea with Mimi to celebrate"],"reward":"Sugarbell cake cloche","color":"e5b2c5"},
 "garden":{"name":"Noah's little garden","npc":"noah","steps":["Plant lavender for Noah's corner","Water that lavender","Harvest your lavender","Invite Noah to help tend another dry crop"],"reward":"Lavender memory corner","color":"b8a5d0"},
 "warming":{"name":"Rosewater housewarming","npc":"both","steps":["Plate a fresh meal for your guests","Share a garden picnic with both friends","Raise a toast at the gathering bell"],"reward":"Together lanterns","color":"e3c99b"}}
const ACTIVITIES={"tea":{"name":"Cozy tea time","hint":"Sit together at the patio table and choose a blend."},"picnic":{"name":"Garden picnic","hint":"Share a little basket on the garden blanket."},"help":{"name":"Garden help","hint":"Tend a dry planted crop together. No extra harvest is created."}}
static func defaults() -> Dictionary:
 return {"engaged":false,"arcs":{"baking":0,"garden":0,"warming":0},"rewards":[],"receipts":[],"bonus_days":{"mimi":0,"noah":0},"activity_days":{},"tea_choice":"berry","picnic_choice":"stories","day_log":[],"earned":0,"last_summary":{},"summary_days":[],"morning_friends":{}}
static func sanitize(raw: Variant) -> Dictionary:
 var out:=defaults()
 if not raw is Dictionary: return out
 for key in raw:
  if not key in out: out[key]=raw[key]
 if raw.get("engaged") is bool: out.engaged=raw.engaged
 if raw.get("arcs") is Dictionary:
  for id in ARCS:
   if raw.arcs.get(id) is int: out.arcs[id]=clampi(raw.arcs[id],0,ARCS[id].steps.size()+1)
 for key in ["rewards","receipts","day_log","summary_days"]:
  if raw.get(key) is Array:
   for value in raw[key].slice(0,128):
    if key=="summary_days":
     if value is int and value>0 and not value in out[key]: out[key].append(value)
    elif value is String and value.length()<100 and (key!="rewards" or value in ARCS) and not value in out[key]: out[key].append(value)
 for key in ["bonus_days","activity_days","morning_friends"]:
  if raw.get(key) is Dictionary:
   for id in raw[key]:
    if id is String and id.length()<32 and raw[key][id] is int: out[key][id]=clampi(raw[key][id],0,1000000)
 if raw.get("earned") is int: out.earned=clampi(raw.earned,0,1000000)
 if raw.get("last_summary") is Dictionary:
  var s: Dictionary=raw.last_summary
  if s.get("day") is int and s.day>0 and s.get("earned") is int and s.get("friends") is Dictionary and s.friends.get("mimi") is int and s.friends.get("noah") is int and s.get("garden") is int and s.get("stories") is Array:
   out.last_summary=s.duplicate(true)
   out.last_summary.day=clampi(s.day,1,1000000);out.last_summary.earned=clampi(s.earned,0,1000000);out.last_summary.garden=clampi(s.garden,0,3)
   out.last_summary.friends={"mimi":clampi(s.friends.mimi,0,12),"noah":clampi(s.friends.noah,0,12)}
   out.last_summary.friendship_gains={"mimi":0,"noah":0}
   if s.get("friendship_gains") is Dictionary:
    for id in ["mimi","noah"]:
     if s.friendship_gains.get(id) is int: out.last_summary.friendship_gains[id]=clampi(s.friendship_gains[id],0,12)
   out.last_summary.moments=[]
   if s.get("moments") is Array:
    for text in s.moments.slice(0,12):
     if text is String and text.length()<100: out.last_summary.moments.append(text)
   out.last_summary.stories=[]
   for id in s.stories.slice(0,3):
    if id in ARCS and not id in out.last_summary.stories: out.last_summary.stories.append(id)
 if raw.get("tea_choice") in ["berry","lavender"]: out.tea_choice=raw.tea_choice
 if raw.get("picnic_choice") in ["stories","clouds"]: out.picnic_choice=raw.picnic_choice
 return out
static func note(home: Dictionary,text: String) -> void:
 if not text in home.life.day_log: home.life.day_log.append(text)
 home.life.day_log=home.life.day_log.slice(-12)
static func begin(home: Dictionary,id: String) -> bool:
 if not id in ARCS or home.life.arcs[id]!=0: return false
 if id=="warming" and (not home.neighborhood.people.mimi.met or not home.neighborhood.people.noah.met or home.life.rewards.is_empty()): return false
 home.neighborhood.engaged=true;home.life.engaged=true;home.life.arcs[id]=1;note(home,"Began "+ARCS[id].name)
 return true
static func observe(home: Dictionary,kind: String,info: Dictionary={}) -> void:
 var l: Dictionary=home.life
 var wanted: Array=[]
 if l.arcs.baking==1 and kind=="harvest" and info.get("crop")=="strawberry": wanted.append("baking")
 if l.arcs.baking==2 and kind=="meal" and info.get("recipe")=="berry_cupcakes": wanted.append("baking")
 if l.arcs.baking==3 and kind=="tea" and info.get("npc")=="mimi": wanted.append("baking")
 if l.arcs.garden==1 and kind=="plant" and info.get("crop")=="lavender": wanted.append("garden")
 if l.arcs.garden==2 and kind=="garden_water" and info.get("crop")=="lavender": wanted.append("garden")
 if l.arcs.garden==3 and kind=="harvest" and info.get("crop")=="lavender": wanted.append("garden")
 if l.arcs.garden==4 and kind=="help" and info.get("npc")=="noah": wanted.append("garden")
 if l.arcs.warming==1 and kind=="meal": wanted.append("warming")
 if l.arcs.warming==2 and kind=="picnic" and info.get("both",false): wanted.append("warming")
 if l.arcs.warming==3 and kind=="toast" and info.get("both",false): wanted.append("warming")
 for id in wanted:
  var token: String=id+":"+str(l.arcs[id])
  if token in l.receipts: continue
  if id=="baking" and l.arcs[id]==1:
   if home.neighborhood.produce.strawberry<1: continue
   home.neighborhood.produce.strawberry-=1
  l.receipts.append(token);l.arcs[id]+=1;note(home,"A chapter of "+ARCS[id].name)
  if l.arcs[id]>ARCS[id].steps.size() and not id in l.rewards:
   l.rewards.append(id);home.coins+=8;note(home,"Memory: "+ARCS[id].reward)
 if kind in ["plant","garden_water","harvest","meal","tea","picnic","help","toast"]: note(home,{"plant":"Planted a little hope","garden_water":"Cared for the garden","harvest":"Brought in a harvest","meal":"Made a warm meal","tea":"Shared tea","picnic":"A garden picnic","help":"Garden help","toast":"A toast to home"}[kind])
static func activity(home: Dictionary,kind: String,npc: String,choice: String,both: bool=false) -> Dictionary:
 if not kind in ACTIVITIES or not npc in home.neighborhood.people: return {"ok":false,"message":"Choose a friend and an activity."}
 var l: Dictionary=home.life
 var key: String=npc+"."+kind
 # Activities remain available, but one friendship benefit/person/day, shared across all three.
 l.engaged=true
 var gain:=0
 var levelups: Array[String]=[]
 for id in (["mimi","noah"] if both else [npc]):
  if l.bonus_days[id]!=home.day:
   var p: Dictionary=home.neighborhood.people[id]
   var before_level: int=F.level(p.xp,p.days.size())
   gain+=mini(12,p.xp+1)-p.xp;p.xp=mini(12,p.xp+1);p.met=true;F.shared_day(p,home.day);l.bonus_days[id]=home.day
   if F.level(p.xp,p.days.size())>before_level: levelups.append(id.capitalize()+" · "+F.title(p.xp,p.days.size()))
 l.activity_days[key]=home.day
 if kind=="tea": l.tea_choice=choice if choice in ["berry","lavender"] else "berry"
 if kind=="picnic": l.picnic_choice=choice if choice in ["stories","clouds"] else "stories"
 observe(home,kind,{"npc":npc,"both":both})
 var result: Dictionary={"ok":true,"gain":gain,"levelups":levelups,"message":("Berry tea and a brave new recipe." if l.tea_choice=="berry" else "Lavender tea, and room for a quieter thought.") if kind=="tea" else ("We traded a funny story for a happy memory." if choice=="stories" else "We found a cloud shaped just like home.") if kind=="picnic" else "A little care, shared. The crop was watered once.","matches":["friendship"]}
 if not levelups.is_empty(): result.message+="\n"+" & ".join(levelups)+"! A keepsake is waiting by the flower fence."
 return result
static func finish_day(home: Dictionary) -> void:
 var l: Dictionary=home.life
 l.last_summary={"day":home.day,"earned":l.earned,"moments":l.day_log.duplicate(),"friends":{},"friendship_gains":{},"garden":home.neighborhood.plots.filter(func(p): return p.stage>0).size(),"stories":l.rewards.duplicate()}
 for id in home.neighborhood.people:
  l.last_summary.friends[id]=home.neighborhood.people[id].xp
  l.last_summary.friendship_gains[id]=home.neighborhood.people[id].xp-l.morning_friends.get(id,home.neighborhood.people[id].xp)
  l.morning_friends[id]=home.neighborhood.people[id].xp
 l.earned=0;l.day_log=[]
