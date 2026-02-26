extends Node

# Alle Events (einmalig definieren)
const ALL_EVENTS: Array[EventData] = [
	preload("res://maptree/Event/Events/event_1.tres"), #ja 
	preload("res://maptree/Event/Events/event_2.tres"), # ja 
	preload("res://maptree/Event/Events/event_3.tres"), #ja 
	preload("res://maptree/Event/Events/event_4.tres"), #ja
	#preload("res://maptree/Event/Events/event_5.tres"),
	#preload("res://maptree/Event/Events/event_6.tres"),
	#preload("res://maptree/Event/Events/event_7.tres"),
	#preload("res://maptree/Event/Events/event_8.tres"),
	preload("res://maptree/Event/Events/event_9.tres"), #ja
	preload("res://maptree/Event/Events/event_11.tres"), #ja
]

var _bag: Array[EventData] = []
var rng := RandomNumberGenerator.new()

func reset(s: int = 0) -> void:
	_refill_bag()
	if s != 0:
		rng.seed = s
	else:
		rng.randomize()

func remaining_count() -> int:
	return _bag.size()

func draw_random() -> EventData:
	if _bag.is_empty():
		_refill_bag()
	var i := rng.randi_range(0, _bag.size() - 1)
	var e := _bag[i]
	_bag.remove_at(i)
	return e

func _refill_bag() -> void:
	_bag = ALL_EVENTS.duplicate()
	_bag.shuffle()

func export_state() -> Array[String]:
	var paths: Array[String] = []
	for e in _bag:
		if e != null and e.resource_path != "":
			paths.append(e.resource_path)
	return paths

func import_state(paths: Array[String]) -> void:
	_bag.clear()

	var by_path: Dictionary = {}
	for e in ALL_EVENTS:
		if e != null and e.resource_path != "":
			by_path[e.resource_path] = e

	for p in paths:
		if by_path.has(p):
			_bag.append(by_path[p])
		else:
			push_warning("[EventPool] Unknown event path in save: %s" % p)
