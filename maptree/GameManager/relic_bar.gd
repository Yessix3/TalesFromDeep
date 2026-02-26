class_name RelicBarUI
extends Control

signal relic_ui_requested(relic: RelicData)

@export var run_status: RunStatus : set = set_run_status

@onready var bar: Container = %RelicBar

const RELIC_UI_SCENE: PackedScene = preload("res://maptree/ui/relic_ui.tscn")


var _widgets: Dictionary = {}

func set_run_status(rs: RunStatus) -> void:
	run_status = rs
	if not is_node_ready():
		await ready

	# neu verbinden
	_disconnect()
	_connect()
	_rebuild_from_status()

func _ready() -> void:
	_connect()
	_rebuild_from_status()

func _connect() -> void:
	if run_status == null:
		return
	if not run_status.relics_changed.is_connected(_on_relics_changed):
		run_status.relics_changed.connect(_on_relics_changed)

func _disconnect() -> void:
	if run_status == null:
		return
	if run_status.relics_changed.is_connected(_on_relics_changed):
		run_status.relics_changed.disconnect(_on_relics_changed)

func _on_relics_changed() -> void:
	_rebuild_from_status()

func _rebuild_from_status() -> void:
	if run_status == null:
		return

	var existing_ids := _widgets.keys()
	for id in existing_ids:
		var count := run_status.get_relic_count(id)
		if count <= 0:
			var w: RelicUI = _widgets[id]
			if is_instance_valid(w):
				w.queue_free()
			_widgets.erase(id)

	for id in run_status.relic_counts.keys():
		var count: int = run_status.get_relic_count(id)
		if count <= 0:
			continue

		if not _widgets.has(id):
			var relic: RelicData = RelicDatabase.get_relic(id)
			if relic == null:
				continue

			var node: Node = RELIC_UI_SCENE.instantiate()
			var w := node as RelicUI
			if w == null:
				push_error("relic_ui.tscn root is not RelicUI.")
				return

			w.relic = relic
			w.relic_clicked.connect(_on_relic_clicked)
			bar.add_child(w)
			_widgets[id] = w

		_widgets[id].set_amount(count)

func _on_relic_clicked(relic: RelicData) -> void:
	relic_ui_requested.emit(relic)
