class_name RunStatus
extends Resource

signal shells_changed
signal relics_changed()

signal curr_health_changed
signal max_health_changed


const STARTING_CURRENT_HEALTH := 10.0
const STARTING_MAX_HEALTH := 10.0

const STARTING_SHELLS := 0

@export var shells := STARTING_SHELLS: set = set_shells

@export var curr_health := STARTING_CURRENT_HEALTH: set = set_curr_health
@export var max_health := STARTING_MAX_HEALTH: set = set_max_health

var relic_counts: Dictionary = {}


func set_shells(new_amount: int) -> void:
    shells = new_amount
    shells_changed.emit()

func add_relic(relic: RelicData, amount: int = 1) -> void:
    if relic == null:
        return
    var key: String = relic.id
    var current: int = relic_counts.get(key, 0)
    relic_counts[key] = current + amount
    relics_changed.emit()

func get_relic_count(relic_id: String) -> int:
    return int(relic_counts.get(relic_id, 0))

func consume_relic(relic_id: String, amount: int = 1) -> bool:
    var current: int = get_relic_count(relic_id)
    if current < amount:
        return false
    relic_counts[relic_id] = current - amount
    if relic_counts[relic_id] <= 0:
        relic_counts.erase(relic_id)
    relics_changed.emit()
    return true

func set_curr_health(new_curr_health: float) -> void:
    curr_health = new_curr_health
    curr_health_changed.emit()

func set_max_health(new_max_health: float) -> void:
    max_health = new_max_health
    max_health_changed.emit()