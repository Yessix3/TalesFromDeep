extends Button
class_name PractiseMenuButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://maptree/mapTree/main_menu.tscn")
