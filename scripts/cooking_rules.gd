extends RefCounted
const HOME=preload("res://scripts/home_rules.gd")
var recipe := ""
var stage := "idle"
var errors: Array[float]=[]
var hits := 0
var target := 0.5
var phase := 0.0
var serial := ""
var rng:=RandomNumberGenerator.new()
func begin(id: String, token: String) -> bool:
 if not HOME.RECIPES.has(id): return false
 rng.randomize()
 recipe=id
 serial=token
 stage="ingredients"
 errors.clear()
 hits=0
 next_target()
 return true
func next_target() -> void:
 target=rng.randf_range(0.28,0.72)
 phase=rng.randf_range(0,0.15)
func tick(delta: float) -> void: phase=fmod(phase+delta*0.43,2.0)
func cursor() -> float: return phase if phase<=1 else 2-phase
func hit(action: String="") -> bool:
 if not stage in ["ingredients","prepared"]: return false
 var penalty:=0.0
 var choices: Array=HOME.RECIPES[recipe].prep_inputs
 if stage=="ingredients" and not choices.is_empty() and action!=choices[hits]: penalty=0.28
 errors.append(minf(absf(cursor()-target)+penalty,1.0))
 hits+=1
 var needed: int=3 if stage=="ingredients" else HOME.RECIPES[recipe].beats
 if hits>=needed:
  stage="prepared" if stage=="ingredients" else "ready"
  hits=0
  return true
 next_target()
 return false
func quality() -> String:
 if errors.is_empty(): return "Cozy"
 var average:=0.0
 for e in errors: average+=e
 average/=errors.size()
 return "Perfect" if average<=0.085 else ("Good" if average<=0.22 else "Cozy")
func abort() -> void:
 stage="idle"
 recipe=""
 errors.clear()
