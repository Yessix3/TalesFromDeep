class_name EventOptionButton
extends Button

@export var button_text: String: set = set_button_text

@onready var custom_text: Label = %OptionText

func set_button_text(new_text: String) -> void:
    button_text = new_text

    if not is_node_ready():
        await ready

    custom_text.text = button_text




func _on_pressed() -> void:
    print("Option" + button_text)
