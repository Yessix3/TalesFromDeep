class_name BattleOverPanel
extends Panel

enum Type {WIN, LOSE}

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton



func _ready() -> void:
	continue_button.pressed.connect(func (): EventManager.fight_won.emit(true))
	EventManager.battle_over_screen_requested.connect(show_screen)


func show_screen(text: String, type: Type) -> void:
	label.text = text
	continue_button.visible = type == Type.WIN
	show()
	get_tree().paused = true

