extends Control


func _on_button_pressed() -> void:
	EventManager.event_room_exited.emit()
