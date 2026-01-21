extends Control


func _on_button_pressed() -> void:
	EventManager.map_exited.emit()
