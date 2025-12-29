class_name ShellsUI
extends HBoxContainer

@export var run_status: RunStatus: set = set_run_status

@onready var label: Label = $Label

func _ready() -> void:
	label.text = "0"

func set_run_status(new_value: RunStatus) -> void:
	run_status = new_value

	if not run_status.shells_changed.is_connected(_update_shells):
		run_status.shells_changed.connect(_update_shells)
		_update_shells()

func _update_shells() -> void:
	label.text = str(run_status.shells)