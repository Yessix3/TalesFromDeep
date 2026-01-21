class_name RunStatus
extends Resource

signal shells_changed

const STARTING_SHELLS := 0

@export var shells := STARTING_SHELLS: set = set_shells

func set_shells(new_amount: int) -> void:
    shells = new_amount
    shells_changed.emit()