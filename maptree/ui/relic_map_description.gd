extends ColorRect
class_name RelicMapDescription

signal use_requested(relic: RelicData)
var is_in_battle: bool = false

@onready var icon: TextureRect = %Icon
@onready var amount_label: Label = %Amount
@onready var desc: RichTextLabel = %Description
@onready var use_button: Button = %UseButton
@onready var exit_button: Button = %ExitButton

var run_status: RunStatus
var relic: RelicData

func _ready() -> void:
	visible = false
	use_button.pressed.connect(_on_use_pressed)
	exit_button.pressed.connect(hide_modal)

	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	%UseButton.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	%ExitButton.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

func show_modal(rs: RunStatus, r: RelicData) -> void:
	run_status = rs
	relic = r

	visible = true
	get_tree().paused = true
	_refresh()

func hide_modal() -> void:
	get_tree().paused = false
	visible = false

func _refresh() -> void:
	if relic == null or run_status == null:
		use_button.disabled = true
		return

	icon.texture = relic.icon
	var count := run_status.get_relic_count(relic.id)
	amount_label.text = str(count)
	desc.text = relic.description

	var is_potion := relic.type == RelicData.Type.POTION
	var is_health := is_potion and relic.subtype == RelicData.Subtype.HEALTH
	var is_poison := RelicData.Type.POISON
	var is_battle_only_potion := (is_potion and not is_health) or is_poison

	var can_use := false

	if count <= 0:
		can_use = false
	elif relic.type == RelicData.Type.WEAPON:
		can_use = false
	elif is_health:
		# Health überall, aber nur wenn nicht full
		can_use = run_status.curr_health < run_status.max_health
	elif is_battle_only_potion:
		# Protection/Strength nur im Battle
		can_use = is_in_battle

	use_button.disabled = not can_use

	print("[RelicDesc] refresh relic=", relic.id,
		" count=", count,
		" is_in_battle=", is_in_battle,
		" use_disabled=", use_button.disabled)

func refresh() -> void:
	_refresh()

func _on_use_pressed() -> void:
	if relic == null or run_status == null:
		return

	print("[RelicDesc] use pressed relic=", relic.id, " is_in_battle=", is_in_battle)

	# Immer an GameManager melden
	use_requested.emit(relic)

	# Nur Health-Potions hier lokal sofort verarbeiten, damit UI direkt updated
	if relic.type == RelicData.Type.POTION and relic.subtype == RelicData.Subtype.HEALTH:
		if run_status.try_use_relic(relic):
			_refresh()
	hide_modal()


func _on_exit_button_pressed() -> void:
	hide_modal()

func set_is_in_battle(v: bool) -> void:
	is_in_battle = v
	print("[RelicDesc] set_is_in_battle =", is_in_battle)
	_refresh()


