class_name Fight
extends Node2D

@export var player: Player

@onready var win_area: Area2D = $Win
@onready var lose_area: Area2D = $Lose



func _ready():
	get_tree().paused = false
	print("started")


func _on_win_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("You won!")
		#EventManager.fight_won.emit()
		EventManager.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)


func _on_lose_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Looser")
		#EventManager.fight_lost.emit()
		EventManager.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)
