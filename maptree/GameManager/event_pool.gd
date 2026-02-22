extends Node

# Alle Events (einmalig definieren)
const ALL_EVENTS: Array[EventData] = [
    preload("res://maptree/Event/Events/event_1.tres"),
    preload("res://maptree/Event/Events/event_2.tres"),
    preload("res://maptree/Event/Events/event_3.tres"),
    # ...
    # preload("res://data/Event/Events/event_15.tres"),
]

var _bag: Array[EventData] = []
var rng := RandomNumberGenerator.new()

func reset(s: int = 0) -> void:
    _bag = ALL_EVENTS.duplicate()
    if s != 0:
        rng.seed = s
    else:
        rng.randomize()

func remaining_count() -> int:
    return _bag.size()

func draw_random() -> EventData:
    if _bag.is_empty():
        push_error("EventPool empty!")
        return null
    var i := rng.randi_range(0, _bag.size() - 1)
    var e := _bag[i]
    _bag.remove_at(i)
    return e