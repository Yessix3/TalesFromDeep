class_name BattleOverPanel
extends Panel

signal closed(type: int)

enum Type {WIN, LOSE}

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton

var _type: Type = Type.LOSE



func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	continue_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	if not continue_button.pressed.is_connected(_on_continue):
		continue_button.pressed.connect(_on_continue)

	hide()


func show_screen(text: String, type: Type) -> void:
	print("BattleOverPanel show_screen called, type=", type)
	_type = type
	label.text = text
	show()
	get_tree().paused = true

func _on_continue() -> void:
	print("continue pressed")
	hide()
	get_tree().paused = false
	closed.emit(_type)
