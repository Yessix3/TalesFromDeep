class_name Health
extends Node


signal max_health_changed(diff: int)
signal health_changed(diff: int)
signal health_empty

@export var immortal: bool = false
@export var max_health: int = 1: set = set_max_health, get = get_max_health
@onready var health: int = max_health 



func set_max_health(value:int):
	pass

func get_max_health() -> int:
	return max_health
