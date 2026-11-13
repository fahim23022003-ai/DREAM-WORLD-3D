extends RefCounted
const DEFINITIONS={
 "surprise":{"name":"A knock of kindness","hint":"Mimi has arrived with a request. Complete any visitor request.","reward":4},
 "bloom":{"name":"Garden bloom","hint":"The pink flower patch by the fence has bloomed. E to gather its gift.","reward":4},
 "baking":{"name":"Cozy baking day","hint":"Plate Berry Cupcakes today for a little extra celebration.","reward":4},
 "lost":{"name":"A little lost ribbon","hint":"Mimi left a ribbon on the living-room console. Find it with E; she'll get it safely.","reward":4},
 "friendship":{"name":"Friendship afternoon","hint":"After morning, share a quiet garden moment with either visitor.","reward":4},
 "moon":{"name":"Moonlit garden","hint":"In Evening or Night, enjoy the lantern by the patio. Rest on the garden bench to advance time.","reward":5}}
static func defaults() -> Dictionary: return {"id":"surprise","day":1,"done":false,"history":["surprise"]}
static func sanitize(value: Variant,day: int) -> Dictionary:
 var e:=defaults();e.day=day
 if not value is Dictionary: return e
 if value.get("id","") in DEFINITIONS: e.id=value.id
 if value.get("day") is int: e.day=maxi(1,value.day)
 if value.get("done") is bool: e.done=value.done
 if value.get("history") is Array:
  e.history=[]
  for id in value.history.slice(-3):
   if id in DEFINITIONS: e.history.append(id)
 return e
static func choose(previous: Dictionary,day: int) -> Dictionary:
 var ids: Array=DEFINITIONS.keys()
 var available: Array=ids.filter(func(id): return not id in previous.history)
 var wanted: String=ids[(day-1)%ids.size()]
 if not wanted in available: wanted=available[(day-1)%available.size()]
 var history: Array=previous.history.duplicate()
 history.append(wanted)
 return {"id":wanted,"day":day,"done":false,"history":history.slice(-3)}
