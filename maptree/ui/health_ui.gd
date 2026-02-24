class_name HealthUI
extends HBoxContainer

@export var run_status: RunStatus : set = set_run_status

@onready var curr_label: Label = %CurrentHealth
@onready var max_label: Label = %MaxHealth

func _ready() -> void:
	_refresh()

func set_run_status(rs: RunStatus) -> void:
	# ggf. alte Verbindungen lösen
	if run_status != null:
		if run_status.curr_health_changed.is_connected(_on_curr_changed):
			run_status.curr_health_changed.disconnect(_on_curr_changed)
		if run_status.max_health_changed.is_connected(_on_max_changed):
			run_status.max_health_changed.disconnect(_on_max_changed)

	run_status = rs
	if not is_node_ready():
		await ready

	if run_status != null:
		if not run_status.curr_health_changed.is_connected(_on_curr_changed):
			run_status.curr_health_changed.connect(_on_curr_changed)
		if not run_status.max_health_changed.is_connected(_on_max_changed):
			run_status.max_health_changed.connect(_on_max_changed)

	_refresh()

func _on_curr_changed(new_value = null) -> void:
	_refresh()

func _on_max_changed(new_value = null) -> void:
	_refresh()

func _refresh() -> void:
	if run_status == null:
		curr_label.text = ""
		max_label.text = ""
		return
	curr_label.text = str(run_status.curr_health)
	max_label.text = str(run_status.max_health)