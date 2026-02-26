extends Control

const MANAGE_SCENE := preload("res://maptree/GameManager/game_manager.tscn")
const PRACTICE_SCENE := preload("res://levels/Easy1.tscn")

@onready var continue_button: Button = %Continue

@export var run_startup: GameManagerStartUp

func _ready() -> void:
	get_tree().paused = false
	continue_button.disabled = SaveGame.load_data() == null

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_new_run_pressed() -> void:
	run_startup.type = GameManagerStartUp.Type.NEW_RUN
	get_tree().change_scene_to_packed(MANAGE_SCENE)

func _on_continue_pressed() -> void:
	run_startup.type = GameManagerStartUp.Type.CONTINUED_RUN
	get_tree().change_scene_to_packed(MANAGE_SCENE)


func _on_practise_pressed() -> void:
	get_tree().change_scene_to_packed(PRACTICE_SCENE)
