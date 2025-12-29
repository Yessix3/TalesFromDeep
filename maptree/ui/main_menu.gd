extends Control

const MANAGE_SCENE := preload("res://maptree/GameManager/game_manager.tscn")
@onready var continue_button: Button = %Continue

func _ready() -> void:
	get_tree().paused = false

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_new_run_pressed() -> void:
	get_tree().change_scene_to_packed(MANAGE_SCENE)

func _on_continue_pressed() -> void:
	print("continue run")
