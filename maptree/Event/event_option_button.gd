class_name EventOptionButton
extends Button

signal option_chosen(option: OptionButtonData)

@export var option: OptionButtonData : set = set_option

@onready var custom_text: Label = %OptionText

func set_option(new_option: OptionButtonData) -> void:
    option = new_option
    if not is_node_ready():
        await ready
    custom_text.text = option.text if option else ""

func _ready() -> void:
    if not pressed.is_connected(_on_pressed):
        pressed.connect(_on_pressed)


func _on_pressed() -> void:
    if option == null:
        push_warning("Button pressed without option assigned.")
        return
    option_chosen.emit(option)
    