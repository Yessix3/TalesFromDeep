class_name Fight
extends Node2D

@export var player: Player

@onready var win_area: Area2D = $Win
@onready var lose_area: Area2D = $Loose

enum BattleOverType { WIN, LOSE }


func _ready():
	win_area.body_entered.connect(_on_win_area_entered)
	lose_area.body_entered.connect(_on_lose_area_entered)



func _on_win_area_entered(body):
	if body.is_in_group("player"):
		EventManager.fight_won.emit(true)
		EventManager.battle_over_screen_requested.emit("Victorious!", BattleOverType.WIN)


func _on_lose_area_entered(body):
	if body.is_in_group("player"):
		EventManager.fight_won.emit(false)
		EventManager.battle_over_screen_requested.emit("Game Over!", BattleOverType.LOSE)
