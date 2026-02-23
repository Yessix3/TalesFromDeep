class_name RunStatus
extends Resource

signal shells_changed
signal curr_health_changed
signal max_health_changed


const STARTING_CURRENT_HEALTH := 10.0
const STARTING_MAX_HEALTH := 10.0

const STARTING_SHELLS := 0

@export var shells := STARTING_SHELLS: set = set_shells

@export var curr_health := STARTING_CURRENT_HEALTH: set = set_curr_health
@export var max_health := STARTING_MAX_HEALTH: set = set_max_health


func set_shells(new_amount: int) -> void:
    shells = new_amount
    shells_changed.emit()

func set_curr_health(new_curr_health: float) -> void:
    curr_health = new_curr_health
    curr_health_changed.emit()

func set_max_health(new_max_health: float) -> void:
    max_health = new_max_health
    max_health_changed.emit()