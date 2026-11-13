extends RefCounted
const CROPS={"strawberry":{"name":"Strawberries","color":"d88fa9","recipe":"berry_cupcakes"},"carrot":{"name":"Carrots","color":"dfaa78","recipe":"starry_soup"},"lavender":{"name":"Lavender","color":"af95ce","recipe":"cloud_pancakes"}}
const STAGES=["Empty soil","Seed planted","Sprout","Growing","Ready to harvest"]
static func plot() -> Dictionary: return {"crop":"","stage":0,"water_day":0,"cycle":0}
static func sanitize(raw: Variant) -> Array:
 var plots: Array=[]
 for i in range(3):
  var p:=plot()
  if raw is Array and raw.size()>i and raw[i] is Dictionary:
   var v: Dictionary=raw[i]
   if v.get("cycle") is int: p.cycle=clampi(v.cycle,0,1000000)
   if v.get("crop","") in CROPS:
    p.crop=v.crop
    if v.get("stage") is int: p.stage=clampi(v.stage,1,4)
    for key in ["water_day","cycle"]:
     if v.get(key) is int: p[key]=clampi(v[key],0,1000000)
  plots.append(p)
 return plots
static func plant(p: Dictionary,id: String) -> bool:
 if p.stage!=0 or not id in CROPS: return false
 p.crop=id;p.stage=1;p.water_day=0;p.cycle+=1
 return true
static func water(p: Dictionary,day: int) -> bool:
 if p.stage==0 or p.stage==4 or p.water_day==day: return false
 p.water_day=day
 p.stage=maxi(p.stage,2)
 return true
static func period(plots: Array,day: int) -> void:
 for p in plots:
  if p.stage==2 and p.water_day==day: p.stage=3
static func next_day(plots: Array,day: int) -> void:
 for p in plots:
  if p.stage in [2,3] and p.water_day>0 and p.water_day<day: p.stage=4
static func harvest(p: Dictionary,produce: Dictionary) -> String:
 if p.stage!=4 or not p.crop in CROPS or produce.get(p.crop,0)>=9: return ""
 var id: String=p.crop
 produce[id]=produce.get(id,0)+1
 p.crop="";p.stage=0;p.water_day=0
 return id
