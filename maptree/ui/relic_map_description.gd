extends ColorRect
class_name RelicMapDescription

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

func show_modal(rs: RunStatus, r: RelicData) -> void:
	run_status = rs
	relic = r

	visible = true
	_refresh()

func hide_modal() -> void:
	visible = false

func _refresh() -> void:
	if relic == null or run_status == null:
		return

	icon.texture = relic.icon
	amount_label.text = str(run_status.get_relic_count(relic.id))
	desc.text = relic.description

	# Use nur für Heiltrank aktivieren (Beispiel)
	var can_use := relic.type == RelicData.Type.POTION and relic.subtype == RelicData.Subtype.HEALTH
	use_button.disabled = not can_use or run_status.get_relic_count(relic.id) <= 0

func _on_use_pressed() -> void:
	if relic == null or run_status == null:
		return

	# Verbrauch 1
	if not run_status.consume_relic(relic.id, 1):
		_refresh()
		return

	# Effekt anwenden (Beispiel: Heal)
	if relic.subtype == RelicData.Subtype.HEALTH:
		# hier musst du an dein HP-System andocken:
		# run_status.player_health = clamp(run_status.player_health + relic.power, 0, run_status.player_health_max)
		pass

	_refresh()
