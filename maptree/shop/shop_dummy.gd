extends Control



func _on_button_pressed() -> void:
	EventManager.shop_exited.emit()

