extends Control


func _on_button_pressed() -> void:
	EventManager.battle_reward_exited.emit()
