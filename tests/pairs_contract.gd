extends SceneTree
const R = preload("res://scripts/pairs_rules.gd")
var checks := 0
var failed := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failed += 1
	print("PASS " if value else "FAIL ",message)
func _initialize() -> void:
	var rules = R.new()
	var events: Array = []
	rules.completed.connect(func(result): events.append(result))
	var layouts: Dictionary = {}
	var valid := true
	for round_index in range(10):
		rules.start()
		layouts[str(rules.deck)] = true
		for id in range(6): valid = valid and rules.deck.count(id)==2
	check(valid and layouts.size()>1,"each round shuffles twelve cards into six valid pairs")
	check(rules.select(-1)=="ignored" and rules.select(12)=="ignored","out-of-range choices ignored")
	check(rules.select(0)=="first" and rules.select(0)=="ignored" and rules.moves==0,"same-card click is not a move")
	var other := 1
	while rules.deck[other]==rules.deck[0]: other += 1
	check(rules.select(other)=="mismatch" and rules.moves==1 and rules.locked,"second different card counts one move and locks")
	check(rules.select(11)=="ignored" and rules.moves==1,"rapid extra clicks ignored during resolution")
	rules.settle()
	check(not rules.locked and rules.revealed.is_empty() and rules.pairs==0,"mismatch settles without an award")
	var generation: int = rules.generation
	rules.start()
	check(rules.generation!=generation and rules.moves==0 and not rules.locked,"Restart invalidates prior callbacks and clears locks")
	rules.select(0)
	rules.abort()
	rules.settle()
	check(events.is_empty() and not rules.active and not rules.locked,"abort cancels unfinished round and completion")
	rules.start()
	for id in range(6):
		var indices: Array[int] = []
		for i in range(12):
			if rules.deck[i]==id: indices.append(i)
		rules.select(indices[0])
		rules.select(indices[1])
		check(rules.select(indices[0])=="ignored","matched cards cannot be replayed: "+str(id))
		rules.settle()
	check(rules.finished and events.size()==1 and events[0]=={"puzzle_id":"cozy_pairs","moves":6},"one legitimate completion result contains ID and move count")
	rules.settle()
	rules.select(0)
	check(events.size()==1,"completion cannot emit twice")
	print("PAIRS CONTRACT: ",checks-failed,"/",checks)
	quit(0 if failed==0 else 1)
