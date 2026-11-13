extends RefCounted
signal completed(result: Dictionary)
var deck: Array[int] = []
var matched: Array[bool] = []
var revealed: Array[int] = []
var moves := 0
var pairs := 0
var locked := false
var finished := false
var active := false
var generation := 0

func start() -> void:
	generation += 1
	deck.assign([0,0,1,1,2,2,3,3,4,4,5,5])
	deck.shuffle()
	matched.assign([false,false,false,false,false,false,false,false,false,false,false,false])
	revealed.clear()
	moves = 0
	pairs = 0
	locked = false
	finished = false
	active = true

func select(index: int) -> String:
	if not active or locked or finished or index<0 or index>=12 or matched[index] or index in revealed: return "ignored"
	revealed.append(index)
	if revealed.size()==1: return "first"
	moves += 1
	locked = true
	if deck[revealed[0]]==deck[revealed[1]]:
		for card in revealed: matched[card] = true
		pairs += 1
		return "match"
	return "mismatch"

func settle() -> void:
	if not active or not locked: return
	revealed.clear()
	locked = false
	if pairs==6 and not finished:
		finished = true
		active = false
		completed.emit({"puzzle_id":"cozy_pairs","moves":moves})

func abort() -> void:
	generation += 1
	active = false
	locked = false
	revealed.clear()
