class_name ShopRelicButton
extends Button

signal selected(relic: RelicData)

@export var relic: RelicData : set = set_relic

@onready var icon_rect: TextureRect = %RelictIcon
@onready var cost_label: Label = %RelictCost

func set_relic(r: RelicData) -> void:
	relic = r
	if not is_node_ready():
		await ready
	_refresh()

func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	_refresh()

func _refresh() -> void:
	if relic == null:
		disabled = true
		return
	disabled = false
	icon_rect.texture = relic.icon
	cost_label.text = str(relic.cost_shells) + " Shells"

func _on_pressed() -> void:
	if relic == null:
		return
	selected.emit(relic)
