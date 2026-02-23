extends Control
class_name ResultScreen

@onready var icon1: TextureRect = %Icon1
@onready var icon2: TextureRect = %Icon2
@onready var text_label: RichTextLabel = %ResultText
@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue)

func set_result(result: EventResultData) -> void:
	text_label.text = result.text

	var icons := result.icons
	# Anzeige-Logik: max 2, rest ignorieren
	icon1.visible = icons.size() >= 1 and icons[0] != null
	icon1.texture = icons[0] if icons.size() >= 1 else null

	icon2.visible = icons.size() >= 2 and icons[1] != null
	icon2.texture = icons[1] if icons.size() >= 2 else null

func _on_continue() -> void:
	EventManager.event_room_exited.emit()
